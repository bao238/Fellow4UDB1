# BÁO CÁO DỰ ÁN FELLOW4U

**Đề tài:** Xây dựng ứng dụng du lịch Fellow4U bằng Flutter kết hợp Node.js và SQL Server

**Sinh viên thực hiện:** ........................................

**Lớp:** ........................................

**Giảng viên hướng dẫn:** ........................................

**Thời gian:** 2026

---

## Mục lục
1. Giới thiệu đề tài
2. Mục tiêu dự án
3. Công nghệ sử dụng
4. Kiến trúc hệ thống
5. Thiết kế cơ sở dữ liệu
6. Danh sách 10 API tiêu biểu
7. Kiểm thử API
8. Các lỗi đã phát hiện và sửa
9. Nhận xét về dự án
10. Hướng phát triển
11. Kết luận

---

## 1. Giới thiệu đề tài

Fellow4U là ứng dụng du lịch xây dựng bằng Flutter ở phía giao diện và Node.js kết hợp SQL Server ở phía backend. Ứng dụng hỗ trợ người dùng khám phá hành trình, hướng dẫn viên, trải nghiệm nổi bật, thông báo hệ thống và chức năng xác thực tài khoản.

Dự án hướng tới mục tiêu xây dựng một hệ thống mẫu có kiến trúc rõ ràng, dễ mở rộng, dễ kiểm thử và phù hợp cho việc minh họa quy trình phát triển ứng dụng di động kết nối API thực tế với SQL Server cloud.

---

## 2. Mục tiêu dự án

- Phát triển giao diện người dùng bằng Flutter theo hướng hiện đại, dễ sử dụng.
- Xây dựng backend API Node.js thuần (không framework) để cung cấp dữ liệu cho ứng dụng.
- Thiết kế cơ sở dữ liệu SQL Server phục vụ lưu trữ người dùng và nội dung du lịch.
- Tổ chức các API theo nhóm chức năng rõ ràng với CORS đầy đủ.
- Hỗ trợ kiểm thử bằng Postman collection và endpoint metadata.
- Hỗ trợ deploy lên Render (cloud) với SQL Server GearHost.

---

## 3. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Frontend | Flutter 3.x, Dart 3.x |
| HTTP Client | Dio 5.x |
| Backend | Node.js (HTTP server thuần, không Express) |
| Database driver | mssql 12.x (tedious) |
| Cơ sở dữ liệu | Microsoft SQL Server (GearHost cloud) |
| Deploy | Render (Web Service + Static Site) |
| Kiểm thử API | Postman collection |


---

## 4. Kiến trúc hệ thống

### 4.1 Sơ đồ kiến trúc tổng quát

```
┌─────────────────────────────────────────────────────────┐
│                   NGƯỜI DÙNG                            │
└─────────────────────┬───────────────────────────────────┘
                      │ tương tác
┌─────────────────────▼───────────────────────────────────┐
│              FLUTTER APP (Frontend)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │  Controllers │  │  Repositories│  │
│  │  (UI Layer)  │→ │ (Presentation│→ │  (Data Layer)│  │
│  └──────────────┘  └──────────────┘  └──────┬───────┘  │
│                                             │           │
│  ┌──────────────────────────────────────────▼────────┐  │
│  │         Dio HTTP Client + ApiConfig               │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │ HTTP/JSON (port 3000)
┌─────────────────────▼───────────────────────────────────┐
│           NODE.JS API SERVER (Backend)                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │  server.js — HTTP routing + request handlers     │   │
│  │  db.js     — SQL Server connection pool (mssql)  │   │
│  └──────────────────────────┬───────────────────────┘   │
└─────────────────────────────┼───────────────────────────┘
                              │ TCP/SQL
┌─────────────────────────────▼───────────────────────────┐
│         SQL SERVER DATABASE (GearHost cloud)            │
│  den1.mssql8.gear.host  /  Database: fellow4udb1        │
│  ┌──────────┐ ┌─────────────┐ ┌────────────────────┐   │
│  │  Users   │ │ TopJourneys │ │    BestGuides       │   │
│  └──────────┘ └─────────────┘ └────────────────────┘   │
│  ┌──────────────────┐  ┌──────────────────────────┐     │
│  │  TopExperiences  │  │      Notifications        │     │
│  └──────────────────┘  └──────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Sơ đồ luồng dữ liệu (Data Flow)

```
[Người dùng nhấn Sign In]
        ↓
[SignInScreen._onSignIn()]
        ↓
[AuthController.login()]
        ↓
[AuthRepositoryImpl.login()]
        ↓
[AuthApiService → Dio.post("/api/auth/login")]
        ↓
[Node.js: handleLogin() → SQL query dbo.Users]
        ↓
[SQL Server trả kết quả]
        ↓
[Node.js trả JSON 200 + accessToken]
        ↓
[Flutter parse LoginResponseModel]
        ↓
[AuthSession.save() → navigate /explore]
```

### 4.3 Cấu trúc thư mục dự án

```
flutter_application_1/
├── lib/
│   ├── core/
│   │   ├── auth/           # AuthSession (lưu token phiên)
│   │   ├── config/         # ApiConfig (base URL, timeout)
│   │   └── network/        # ApiClient (Dio), endpoints, exceptions
│   ├── features/
│   │   ├── auth/           # Đăng nhập / Đăng ký
│   │   ├── accounts/       # Quản lý tài khoản
│   │   ├── explore/        # Journeys, Guides, Experiences
│   │   └── notifications/  # Thông báo
│   └── screens/            # Các màn hình UI
├── api/
│   ├── server.js           # HTTP server + 22 API endpoints
│   ├── db.js               # SQL Server connection pool
│   └── sql/                # Scripts tạo DB và seed data
└── assets/images/          # Hình ảnh ứng dụng
```

### 4.4 Tổng số API hiện có

Hệ thống có **22 API endpoint** chia thành 6 nhóm:

| Nhóm | Số endpoint |
|---|---|
| Auth (đăng nhập, đăng ký) | 2 |
| TopJourneys (CRUD đầy đủ) | 6 |
| BestGuides | 2 |
| TopExperiences | 2 |
| Notifications | 2 |
| Users / Accounts | 3 |
| Metadata & SQL Setup | 5 |
| **Tổng** | **22** |


---

## 5. Thiết kế cơ sở dữ liệu

Database: `fellow4udb1` — GearHost SQL Server cloud (`den1.mssql8.gear.host`)

### 5.1 Sơ đồ các bảng

```
dbo.Users
 ├── Id          INT IDENTITY(1,1)  PK
 ├── FirstName   NVARCHAR(100)      NOT NULL
 ├── LastName    NVARCHAR(100)      NOT NULL
 ├── Email       NVARCHAR(255)      NOT NULL  UNIQUE
 ├── Username    NVARCHAR(100)      NOT NULL  UNIQUE
 ├── Password    NVARCHAR(255)      NOT NULL
 ├── Country     NVARCHAR(100)      DEFAULT ''
 ├── Role        NVARCHAR(50)       DEFAULT 'Traveler'
 └── CreatedAt   DATETIME2          DEFAULT SYSUTCDATETIME()

dbo.TopJourneys
 ├── Id      INT IDENTITY(1,1)  PK
 ├── UserId  INT                NOT NULL
 ├── Title   NVARCHAR(255)      NOT NULL
 └── Body    NVARCHAR(MAX)      NOT NULL

dbo.BestGuides
 ├── Id     INT IDENTITY(1,1)  PK
 ├── Name   NVARCHAR(150)      NOT NULL
 ├── Email  NVARCHAR(255)      NOT NULL
 ├── City   NVARCHAR(150)      NOT NULL
 └── Phone  NVARCHAR(50)       NOT NULL

dbo.TopExperiences
 ├── Id      INT IDENTITY(1,1)  PK
 ├── UserId  INT                NOT NULL
 └── Title   NVARCHAR(255)      NOT NULL

dbo.Notifications
 ├── Id                INT IDENTITY(1,1)  PK
 ├── ActorName         NVARCHAR(150)      NOT NULL
 ├── ActorAvatar       NVARCHAR(255)      NOT NULL
 ├── Message           NVARCHAR(MAX)      NOT NULL
 ├── EventDate         NVARCHAR(40)       NOT NULL
 ├── AccentColor       NVARCHAR(20)       NOT NULL
 ├── BadgeIcon         NVARCHAR(50)       NOT NULL
 ├── ShowReviewButton  BIT                DEFAULT 0
 └── CreatedAt         DATETIME2          DEFAULT SYSUTCDATETIME()
```

### 5.2 Tài khoản demo mặc định

| Username | Password | Role |
|---|---|---|
| `emilys` | `emilyspass` | Traveler |
| `bao12345` | `bao123456` | Traveler |
| `admin` | `admin123` | Admin |


---

## 6. Danh sách 10 API tiêu biểu

> Server chạy tại: `http://localhost:3000`
> Tất cả response đều là JSON. CORS bật cho mọi origin (`*`).

### 6.1 Bảng tổng hợp toàn bộ API theo nhóm

**Bảng 3.1 — API Auth (Xác thực)**

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | /api/auth/login | Đăng nhập, trả về access token |
| POST | /api/auth/register | Đăng ký tài khoản mới |

**Bảng 3.2 — API TopJourneys (Hành trình)**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/TopJourneys | Lấy danh sách hành trình |
| GET | /api/TopJourneys/{id} | Lấy chi tiết hành trình |
| POST | /api/TopJourneys | Tạo hành trình mới |
| PUT | /api/TopJourneys/{id} | Cập nhật toàn bộ hành trình |
| PATCH | /api/TopJourneys/{id} | Cập nhật một phần hành trình |
| DELETE | /api/TopJourneys/{id} | Xóa hành trình |

**Bảng 3.3 — API BestGuides (Hướng dẫn viên)**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/BestGuides | Lấy danh sách hướng dẫn viên |
| GET | /api/BestGuides/{id} | Lấy chi tiết hướng dẫn viên |

**Bảng 3.4 — API TopExperiences (Trải nghiệm)**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/TopExperiences | Lấy danh sách trải nghiệm nổi bật |
| GET | /api/TopExperiences/{id} | Lấy chi tiết trải nghiệm |

**Bảng 3.5 — API Notifications (Thông báo)**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/notifications | Lấy danh sách thông báo |
| GET | /api/notifications/{id} | Lấy chi tiết thông báo |

**Bảng 3.6 — API Users / Accounts (Người dùng)**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/users | Lấy danh sách người dùng |
| GET | /api/users/{id} | Lấy chi tiết người dùng |
| POST | /api/users/add | Thêm người dùng mới |

**Bảng 3.7 — API Metadata & SQL Setup**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/meta/health | Kiểm tra trạng thái server và DB |
| GET | /api/meta/routes | Lấy danh sách tất cả route |
| GET | /api/setup/sql | Xem SQL setup script |
| GET | /api/setup/sql/auth | Xem SQL auth script |
| GET | /api/setup/sql/notifications | Xem SQL notifications script |

---

### 6.2 Mô tả chi tiết 10 API tiêu biểu

---

### API 1 — Kiểm tra trạng thái hệ thống

| Trường | Giá trị |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/meta/health` |
| **Chức năng** | Kiểm tra API server đang chạy và kết nối SQL Server thành công |
| **Auth** | Không yêu cầu |

**Response mẫu (200 OK):**
```json
{
  "status": "ok",
  "database": "Fellow4UDB",
  "time": "2026-05-25T08:00:00.000Z"
}
```

---

### API 2 — Đăng nhập người dùng

| Trường | Giá trị |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/api/auth/login` |
| **Chức năng** | Xác thực tài khoản bằng username (hoặc email) và mật khẩu, trả về access token |
| **Auth** | Không yêu cầu |

**Request body:**
```json
{
  "username": "emilys",
  "password": "emilyspass"
}
```

**Response mẫu (200 OK):**
```json
{
  "message": "Login successful.",
  "accessToken": "ZW1pbHlzLTE3NDgyMDAwMDA=",
  "refreshToken": "ZW1pbHlzLXJlZnJlc2gtMTc0ODIwMDAwMA==",
  "id": 1,
  "username": "emilys",
  "email": "emily.johnson@example.com",
  "firstName": "Emily",
  "lastName": "Johnson",
  "fullName": "Emily Johnson"
}
```

**Response lỗi (401 Unauthorized):**
```json
{ "message": "Invalid credentials" }
```

---

### API 3 — Đăng ký tài khoản mới

| Trường | Giá trị |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/api/auth/register` |
| **Chức năng** | Tạo tài khoản mới trong bảng `dbo.Users`, kiểm tra trùng username/email |
| **Auth** | Không yêu cầu |

**Request body:**
```json
{
  "firstName": "Nguyen",
  "lastName": "Van A",
  "email": "vana@example.com",
  "username": "vana2026",
  "password": "vana123456",
  "country": "Vietnam",
  "role": "Traveler"
}
```

**Response mẫu (201 Created):**
```json
{
  "id": 4,
  "firstName": "Nguyen",
  "lastName": "Van A",
  "email": "vana@example.com",
  "username": "vana2026",
  "country": "Vietnam",
  "role": "Traveler"
}
```

**Response lỗi (422 Unprocessable Entity):**
```json
{ "message": "Username already exists" }
```


---

### API 4 — Lấy danh sách hành trình nổi bật

| Trường | Giá trị |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/TopJourneys` |
| **Query params** | `?_limit=N` — giới hạn số bản ghi trả về (tùy chọn) |
| **Chức năng** | Trả về danh sách hành trình du lịch từ bảng `dbo.TopJourneys` |
| **Auth** | Không yêu cầu |

**Ví dụ request:** `GET /api/TopJourneys?_limit=5`

**Response mẫu (200 OK):**
```json
[
  {
    "id": 1,
    "userId": 1,
    "title": "Da Nang - Ba Na - Hoi An",
    "body": "Classic 3-day journey."
  },
  {
    "id": 2,
    "userId": 2,
    "title": "Thailand Highlights",
    "body": "Culture and street food route."
  }
]
```

---

### API 5 — Lấy chi tiết một hành trình

| Trường | Giá trị |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/TopJourneys/{id}` |
| **Chức năng** | Lấy thông tin chi tiết của một hành trình theo ID |
| **Auth** | Không yêu cầu |

**Ví dụ request:** `GET /api/TopJourneys/1`

**Response mẫu (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "title": "Da Nang - Ba Na - Hoi An",
  "body": "Classic 3-day journey."
}
```

**Response lỗi (404 Not Found):**
```json
{ "message": "Journey not found" }
```

---

### API 6 — Tạo mới hành trình

| Trường | Giá trị |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/api/TopJourneys` |
| **Chức năng** | Thêm một hành trình mới vào bảng `dbo.TopJourneys` |
| **Auth** | Không yêu cầu |

**Request body:**
```json
{
  "userId": 1,
  "title": "Hue Ancient Journey",
  "body": "A 2-day historical trip in Hue."
}
```

**Response mẫu (201 Created):**
```json
{
  "id": 3,
  "userId": 1,
  "title": "Hue Ancient Journey",
  "body": "A 2-day historical trip in Hue."
}
```

**Response lỗi (400 Bad Request):**
```json
{ "message": "userId, title, body are required" }
```

---

### API 7 — Cập nhật một phần hành trình

| Trường | Giá trị |
|---|---|
| **Method** | `PATCH` |
| **Endpoint** | `/api/TopJourneys/{id}` |
| **Chức năng** | Cập nhật một hoặc nhiều trường của hành trình; trường không gửi sẽ giữ nguyên giá trị cũ |
| **Auth** | Không yêu cầu |

**Ví dụ request:** `PATCH /api/TopJourneys/1`

**Request body (chỉ cần gửi trường muốn thay đổi):**
```json
{
  "title": "Da Nang - Ba Na - Hoi An (Updated)"
}
```

**Response mẫu (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "title": "Da Nang - Ba Na - Hoi An (Updated)",
  "body": "Classic 3-day journey."
}
```

---

### API 8 — Xóa hành trình

| Trường | Giá trị |
|---|---|
| **Method** | `DELETE` |
| **Endpoint** | `/api/TopJourneys/{id}` |
| **Chức năng** | Xóa một hành trình khỏi database theo ID |
| **Auth** | Không yêu cầu |

**Ví dụ request:** `DELETE /api/TopJourneys/3`

**Response mẫu (200 OK):**
```json
{ "message": "Deleted post successfully." }
```

**Response lỗi (404 Not Found):**
```json
{ "message": "Journey not found" }
```


---

### API 9 — Lấy danh sách hướng dẫn viên

| Trường | Giá trị |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/BestGuides` |
| **Query params** | `?_limit=N` (tùy chọn) |
| **Chức năng** | Trả về danh sách hướng dẫn viên nổi bật từ bảng `dbo.BestGuides` |
| **Auth** | Không yêu cầu |

**Response mẫu (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Tuan Tran",
    "email": "tuan@example.com",
    "city": "Da Nang",
    "phone": "0900000001",
    "address": { "city": "Da Nang" }
  },
  {
    "id": 2,
    "name": "Linh Hana",
    "email": "linh@example.com",
    "city": "Ha Noi",
    "phone": "0900000002",
    "address": { "city": "Ha Noi" }
  }
]
```

---

### API 10 — Lấy danh sách thông báo

| Trường | Giá trị |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/notifications` |
| **Query params** | `?_limit=N` (tùy chọn) |
| **Chức năng** | Trả về danh sách thông báo từ bảng `dbo.Notifications`, sắp xếp mới nhất trước (ORDER BY Id DESC) |
| **Auth** | Không yêu cầu |

**Response mẫu (200 OK):**
```json
[
  {
    "id": 3,
    "actorName": "Fellow4U",
    "actorAvatar": "assets/images/app_icon.png",
    "message": "Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.",
    "date": "Jan 24",
    "accentColor": "#3F8CFF",
    "badgeIcon": "rate_review",
    "showReviewButton": true
  },
  {
    "id": 2,
    "actorName": "Emmy",
    "actorAvatar": "assets/images/guide_emmy.png",
    "message": "Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020",
    "date": "Jan 16",
    "accentColor": "#FFC107",
    "badgeIcon": "attach_money",
    "showReviewButton": false
  }
]
```


---

## 7. Kiểm thử API

### 7.1 Swagger UI — Tài liệu API tương tác

Dự án tích hợp **Swagger UI** (OpenAPI 3.0) trực tiếp vào API server. Sau khi chạy `npm start`, truy cập:

```
http://localhost:3000/api/docs
```

Swagger UI cho phép:
- Xem toàn bộ 22 endpoint được nhóm theo chức năng
- Đọc mô tả, request body schema, response schema của từng API
- **Thực thi API trực tiếp** trên trình duyệt (Try it out) mà không cần Postman
- Xem OpenAPI spec dạng JSON tại `http://localhost:3000/api/docs/swagger.json`

File spec: `api/swagger.json` (OpenAPI 3.0.3)

### 7.2 Postman Collection

File: `api/postman/Fellow4U_Local_API.postman_collection.json`

Import vào Postman và chạy trực tiếp với server đang chạy tại `http://localhost:3000`.

### 7.3 Bảng kết quả kiểm thử API

| # | Method | Endpoint | Kết quả | HTTP Status |
|---|---|---|---|---|
| 1 | GET | `/api/meta/health` | ✅ Kết nối SQL Server thành công | 200 |
| 2 | GET | `/api/meta/routes` | ✅ Trả về 22 endpoint | 200 |
| 3 | POST | `/api/auth/login` | ✅ Đăng nhập thành công, trả token | 200 |
| 4 | POST | `/api/auth/login` | ✅ Sai mật khẩu trả lỗi đúng | 401 |
| 5 | POST | `/api/auth/register` | ✅ Tạo tài khoản mới thành công | 201 |
| 6 | POST | `/api/auth/register` | ✅ Username trùng trả lỗi đúng | 422 |
| 7 | GET | `/api/TopJourneys` | ✅ Trả danh sách hành trình | 200 |
| 8 | GET | `/api/TopJourneys/1` | ✅ Trả chi tiết hành trình | 200 |
| 9 | POST | `/api/TopJourneys` | ✅ Tạo hành trình mới | 201 |
| 10 | PATCH | `/api/TopJourneys/1` | ✅ Cập nhật một phần thành công | 200 |
| 11 | PUT | `/api/TopJourneys/1` | ✅ Cập nhật toàn bộ thành công | 200 |
| 12 | DELETE | `/api/TopJourneys/3` | ✅ Xóa thành công | 200 |
| 13 | GET | `/api/BestGuides` | ✅ Trả danh sách hướng dẫn viên | 200 |
| 14 | GET | `/api/TopExperiences` | ✅ Trả danh sách trải nghiệm | 200 |
| 15 | GET | `/api/notifications` | ✅ Trả danh sách thông báo | 200 |
| 16 | GET | `/api/users` | ✅ Trả danh sách người dùng | 200 |

### 7.3 Kiểm thử trên Flutter Web

Ứng dụng chạy tại `http://localhost:64487`, API tại `http://localhost:3000`.

| Chức năng | Kết quả |
|---|---|
| Đăng nhập `emilys / emilyspass` | ✅ Thành công, chuyển sang màn hình Explore |
| Đăng nhập `bao12345 / bao123456` | ✅ Thành công |
| Đăng nhập `admin / admin123` | ✅ Thành công |
| Nhập sai mật khẩu | ✅ Hiển thị lỗi "Invalid credentials" |
| Màn hình Explore tải dữ liệu | ✅ Journeys, Guides, Experiences từ API |
| Màn hình Notifications | ✅ Tải thông báo từ API |
| Màn hình Profile / Accounts | ✅ Tải danh sách users từ API |
| Đăng ký tài khoản mới | ✅ Tạo thành công, chuyển về Sign In |

---

## 8. Các lỗi đã phát hiện và sửa

### Lỗi 1 — 404 khi đăng nhập trên Flutter Web (nghiêm trọng)

**Nguyên nhân:** `api_config.dart` dùng `Uri.base.origin` khi `kIsWeb = true`. Khi chạy Flutter Web dev server trên `localhost:64487`, `Uri.base.origin` trả về `http://localhost:64487` thay vì `http://localhost:3000`. Mọi request đều gửi sai port → 404.

**File:** `lib/core/config/api_config.dart`

**Trước khi sửa:**
```dart
static String get baseUrl {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  if (kIsWeb) return Uri.base.origin;  // ← lỗi: trả về port Flutter
  return _defaultLocalApiUrl;
}
```

**Sau khi sửa:**
```dart
static String get baseUrl {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  if (kIsWeb && !_isLocalOrigin) return Uri.base.origin; // chỉ dùng khi production
  return _defaultLocalApiUrl;
}

static bool get _isLocalOrigin {
  if (!kIsWeb) return false;
  final host = Uri.base.host;
  return host == 'localhost' || host == '127.0.0.1';
}
```

---

### Lỗi 2 — Crash tiềm ẩn khi cast null trong auth repository

**File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Trước:** `final data = response.data as Map<String, dynamic>;`

**Sau:** `final data = (response.data as Map<String, dynamic>?) ?? {};`

---

### Lỗi 3 — Crash tiềm ẩn khi cast null trong accounts repository

**File:** `lib/features/accounts/data/repositories/accounts_repository_impl.dart`

Cùng pattern với lỗi 2, đã fix tương tự.

---

### Lỗi 4 — Thiếu user `admin` trong database

**Nguyên nhân:** Demo account "Admin: admin" hiển thị trong UI nhưng không có bản ghi trong DB.

**File:** `api/sql/fellow4udb_setup.sql` — Đã thêm INSERT cho user `admin / admin123 / Admin`.

---

## 9. Nhận xét về dự án

### Ưu điểm

- Kiến trúc phân lớp rõ ràng: Presentation → Domain → Data → Network
- Backend Node.js thuần, không phụ thuộc framework, dễ đọc và kiểm soát
- CORS đầy đủ, hỗ trợ cả preflight OPTIONS
- Xử lý lỗi tốt ở cả API (HTTP status codes chuẩn) và Flutter (ApiException)
- Có sẵn dữ liệu mẫu, Postman collection và endpoint metadata
- Hỗ trợ deploy cloud (Render + GearHost SQL Server)
- Flutter Web và Mobile đều chạy được với cùng codebase

### Hạn chế

- Password lưu dạng plain text (chưa hash bcrypt)
- Token xác thực là base64 đơn giản, chưa phải JWT thực sự
- Backend chưa tách lớp controller/service/repository
- Chưa có Swagger/OpenAPI UI
- Chưa có pagination chuẩn (chỉ có `_limit`)
- Chưa có rate limiting và input sanitization đầy đủ

---

## 10. Hướng phát triển

- **Bảo mật:** Hash password bằng bcrypt, dùng JWT thực sự với refresh token rotation
- **Backend:** Tách theo mô hình Express + controller/service/repository
- **API docs:** Tích hợp Swagger/OpenAPI
- **State management:** Dùng Riverpod hoặc BLoC thay vì StatefulWidget thuần
- **Pagination:** Thêm cursor-based pagination cho các list API
- **Tìm kiếm:** Thêm endpoint search cho journeys, guides
- **Upload ảnh:** Tích hợp cloud storage cho avatar và ảnh hành trình

---

## 11. Kết luận

Dự án Fellow4U đã xây dựng thành công một ứng dụng du lịch hoàn chỉnh ở mức demo, bao gồm:

- Giao diện Flutter đẹp, responsive, chạy được trên Web và Mobile
- Backend API Node.js kết nối SQL Server cloud (GearHost) với **22 endpoint** đầy đủ
- CRUD hoàn chỉnh cho TopJourneys (GET, POST, PUT, PATCH, DELETE)
- Xác thực người dùng (đăng nhập / đăng ký) với kiểm tra trùng username/email
- Đã phát hiện và sửa 4 lỗi thực tế trong quá trình kiểm thử

Hệ thống đáp ứng đầy đủ yêu cầu mô tả 10 API tiêu biểu (endpoint, method, request/response mẫu) và sơ đồ kiến trúc ứng dụng theo tiêu chí D1 của báo cáo đồ án.
