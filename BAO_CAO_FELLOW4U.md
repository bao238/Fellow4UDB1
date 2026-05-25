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

Dự án đã được deploy thành công lên cloud (Render) và kết nối với SQL Server thực tế (GearHost), có thể truy cập công khai qua internet.

**URL production:**
- Flutter Web: https://fellow4udb1.onrender.com
- API Backend: https://fellow4udb.onrender.com
- Swagger UI: https://fellow4udb.onrender.com/api/docs

---

## 2. Mục tiêu dự án

- Phát triển giao diện người dùng bằng Flutter theo hướng hiện đại, dễ sử dụng.
- Xây dựng backend API Node.js thuần (không framework) để cung cấp dữ liệu cho ứng dụng.
- Thiết kế cơ sở dữ liệu SQL Server phục vụ lưu trữ người dùng và nội dung du lịch.
- Tổ chức các API theo nhóm chức năng rõ ràng với CORS đầy đủ.
- Tích hợp Swagger UI để kiểm thử API trực tiếp trên trình duyệt.
- Deploy lên Render (cloud) với SQL Server GearHost, chạy được cả localhost lẫn production.

---

## 3. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Frontend | Flutter 3.x, Dart 3.x |
| HTTP Client | Dio 5.x |
| Backend | Node.js (HTTP server thuần, không Express) |
| Database driver | mssql 12.x (tedious) |
| Cơ sở dữ liệu | Microsoft SQL Server (GearHost cloud) |
| API Documentation | Swagger UI (OpenAPI 3.0.3) |
| Deploy | Render (Web Service + Static Site) |
| Kiểm thử API | Postman collection + Swagger UI |
| Source control | GitHub |


---

## 4. Kiến trúc hệ thống

### 4.1 Sơ đồ kiến trúc tổng quát

```
┌─────────────────────────────────────────────────────────┐
│                   NGƯỜI DÙNG                            │
└─────────────────────┬───────────────────────────────────┘
                      │ tương tác
┌─────────────────────▼───────────────────────────────────┐
│         FLUTTER APP (Web / Mobile)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │→ │  Controllers │→ │  Repositories│  │
│  │  (UI Layer)  │  │(Presentation)│  │  (Data Layer)│  │
│  └──────────────┘  └──────────────┘  └──────┬───────┘  │
│                                             │           │
│  ┌──────────────────────────────────────────▼────────┐  │
│  │         Dio HTTP Client + ApiConfig               │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │ HTTPS/JSON
┌─────────────────────▼───────────────────────────────────┐
│      NODE.JS API SERVER (Render Web Service)            │
│  URL: https://fellow4udb.onrender.com                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  server.js — HTTP routing + 22 API endpoints     │   │
│  │  db.js     — SQL Server connection pool (mssql)  │   │
│  │  swagger.json — OpenAPI 3.0 spec                 │   │
│  └──────────────────────────┬───────────────────────┘   │
└─────────────────────────────┼───────────────────────────┘
                              │ TCP/SQL
┌─────────────────────────────▼───────────────────────────┐
│      SQL SERVER DATABASE (GearHost cloud)               │
│  Server: den1.mssql8.gear.host                          │
│  Database: fellow4udb1                                  │
│  ┌──────────┐ ┌─────────────┐ ┌────────────────────┐   │
│  │  Users   │ │ TopJourneys │ │    BestGuides       │   │
│  └──────────┘ └─────────────┘ └────────────────────┘   │
│  ┌──────────────────┐  ┌──────────────────────────┐     │
│  │  TopExperiences  │  │      Notifications        │     │
│  └──────────────────┘  └──────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Luồng dữ liệu khi đăng nhập

```
[Người dùng nhấn Sign In]
        ↓
[SignInScreen → AuthController.login()]
        ↓
[AuthRepositoryImpl → AuthApiService → Dio.post("/api/auth/login")]
        ↓
[Node.js handleLogin() → SQL: SELECT FROM dbo.Users WHERE Username=? AND Password=?]
        ↓
[SQL Server GearHost trả kết quả]
        ↓
[Node.js trả JSON 200: { id, username, email, accessToken, ... }]
        ↓
[Flutter: LoginResponseModel.fromJson() → AuthSession.save() → navigate /explore]
```

### 4.3 Cấu trúc thư mục

```
flutter_application_1/
├── lib/
│   ├── core/
│   │   ├── auth/auth_session.dart      # Lưu token phiên đăng nhập
│   │   ├── config/api_config.dart      # URL switching (local/production)
│   │   └── network/                   # Dio client, endpoints, exceptions
│   ├── features/
│   │   ├── auth/                      # Đăng nhập / Đăng ký
│   │   ├── accounts/                  # Quản lý tài khoản
│   │   ├── explore/                   # Journeys, Guides, Experiences
│   │   └── notifications/             # Thông báo
│   └── screens/                       # 20 màn hình UI
├── api/
│   ├── server.js                      # HTTP server + 22 API endpoints
│   ├── db.js                          # SQL Server connection pool
│   ├── swagger.json                   # OpenAPI 3.0.3 spec
│   └── sql/                           # Scripts tạo DB và seed data
├── render.yaml                        # Cấu hình deploy Render
└── assets/images/                     # Hình ảnh ứng dụng
```

### 4.4 Tổng số API

Hệ thống có **22 API endpoint** chia thành 7 nhóm:

| Nhóm | Số endpoint |
|---|---|
| Auth (đăng nhập, đăng ký) | 2 |
| TopJourneys (CRUD đầy đủ) | 6 |
| BestGuides | 2 |
| TopExperiences | 2 |
| Notifications | 2 |
| Users / Accounts | 3 |
| Metadata & Swagger & SQL Setup | 5 |
| **Tổng** | **22** |


---

## 5. Thiết kế cơ sở dữ liệu

**Database:** `fellow4udb1` — GearHost SQL Server (`den1.mssql8.gear.host`)

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

### 5.2 Tài khoản demo

| Username | Password | Role |
|---|---|---|
| `emilys` | `emilyspass` | Traveler |
| `bao12345` | `bao123456` | Traveler |
| `admin` | `admin123` | Admin |


---

## 6. Danh sách 10 API tiêu biểu

> **Server local:** `http://localhost:3000`
> **Server production:** `https://fellow4udb.onrender.com`
> Tất cả response đều là JSON. CORS bật cho mọi origin (`*`).

### 6.1 Bảng tổng hợp API theo nhóm

**Bảng 3.1 — API Auth**

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | /api/auth/login | Đăng nhập, trả về access token |
| POST | /api/auth/register | Đăng ký tài khoản mới |

**Bảng 3.2 — API TopJourneys**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/TopJourneys | Lấy danh sách hành trình |
| GET | /api/TopJourneys/{id} | Lấy chi tiết hành trình |
| POST | /api/TopJourneys | Tạo hành trình mới |
| PUT | /api/TopJourneys/{id} | Cập nhật toàn bộ hành trình |
| PATCH | /api/TopJourneys/{id} | Cập nhật một phần hành trình |
| DELETE | /api/TopJourneys/{id} | Xóa hành trình |

**Bảng 3.3 — API BestGuides**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/BestGuides | Lấy danh sách hướng dẫn viên |
| GET | /api/BestGuides/{id} | Lấy chi tiết hướng dẫn viên |

**Bảng 3.4 — API TopExperiences**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/TopExperiences | Lấy danh sách trải nghiệm nổi bật |
| GET | /api/TopExperiences/{id} | Lấy chi tiết trải nghiệm |

**Bảng 3.5 — API Notifications**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/notifications | Lấy danh sách thông báo |
| GET | /api/notifications/{id} | Lấy chi tiết thông báo |

**Bảng 3.6 — API Users**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/users | Lấy danh sách người dùng |
| GET | /api/users/{id} | Lấy chi tiết người dùng |
| POST | /api/users/add | Thêm người dùng mới |

**Bảng 3.7 — API Metadata & Swagger**

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/docs | Swagger UI — kiểm thử API trực tiếp |
| GET | /api/meta/health | Kiểm tra trạng thái server và DB |
| GET | /api/meta/routes | Danh sách tất cả route |
| GET | /api/setup/sql | Xem SQL setup script |
| GET | /api/setup/sql/auth | Xem SQL auth script |


### 6.2 Mô tả chi tiết 10 API tiêu biểu

---

### API 1 — Kiểm tra trạng thái hệ thống

| | |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/meta/health` |
| **Chức năng** | Kiểm tra API server đang chạy và kết nối SQL Server thành công |

**Response (200 OK):**
```json
{
  "status": "ok",
  "database": "fellow4udb1",
  "time": "2026-05-25T08:00:00.000Z"
}
```

---

### API 2 — Đăng nhập

| | |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/api/auth/login` |
| **Chức năng** | Xác thực tài khoản bằng username hoặc email và mật khẩu, trả về access token |

**Request body:**
```json
{ "username": "emilys", "password": "emilyspass" }
```

**Response (200 OK):**
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

**Response lỗi (401):** `{ "message": "Invalid credentials" }`

---

### API 3 — Đăng ký tài khoản

| | |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/api/auth/register` |
| **Chức năng** | Tạo tài khoản mới trong `dbo.Users`, kiểm tra trùng username/email |

**Request body:**
```json
{
  "firstName": "Nguyen", "lastName": "Van A",
  "email": "vana@example.com", "username": "vana2026",
  "password": "vana123456", "country": "Vietnam", "role": "Traveler"
}
```

**Response (201 Created):**
```json
{
  "id": 4, "firstName": "Nguyen", "lastName": "Van A",
  "email": "vana@example.com", "username": "vana2026",
  "country": "Vietnam", "role": "Traveler"
}
```

**Response lỗi (422):** `{ "message": "Username already exists" }`

---

### API 4 — Lấy danh sách hành trình

| | |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/TopJourneys` |
| **Query** | `?_limit=N` (tùy chọn) |
| **Chức năng** | Trả về danh sách hành trình từ `dbo.TopJourneys` |

**Response (200 OK):**
```json
[
  { "id": 1, "userId": 1, "title": "Da Nang - Ba Na - Hoi An", "body": "Classic 3-day journey." },
  { "id": 2, "userId": 2, "title": "Thailand Highlights", "body": "Culture and street food route." }
]
```

---

### API 5 — Tạo hành trình mới

| | |
|---|---|
| **Method** | `POST` |
| **Endpoint** | `/api/TopJourneys` |
| **Chức năng** | Thêm hành trình mới vào `dbo.TopJourneys` |

**Request body:**
```json
{ "userId": 1, "title": "Hue Ancient Journey", "body": "A 2-day historical trip in Hue." }
```

**Response (201 Created):**
```json
{ "id": 3, "userId": 1, "title": "Hue Ancient Journey", "body": "A 2-day historical trip in Hue." }
```

---

### API 6 — Cập nhật một phần hành trình

| | |
|---|---|
| **Method** | `PATCH` |
| **Endpoint** | `/api/TopJourneys/{id}` |
| **Chức năng** | Cập nhật một hoặc nhiều trường, trường không gửi giữ nguyên |

**Request body:**
```json
{ "title": "Da Nang - Ba Na - Hoi An (Updated)" }
```

**Response (200 OK):**
```json
{ "id": 1, "userId": 1, "title": "Da Nang - Ba Na - Hoi An (Updated)", "body": "Classic 3-day journey." }
```

---

### API 7 — Xóa hành trình

| | |
|---|---|
| **Method** | `DELETE` |
| **Endpoint** | `/api/TopJourneys/{id}` |
| **Chức năng** | Xóa hành trình khỏi database theo ID |

**Response (200 OK):** `{ "message": "Deleted post successfully." }`

**Response lỗi (404):** `{ "message": "Journey not found" }`

---

### API 8 — Lấy danh sách hướng dẫn viên

| | |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/BestGuides` |
| **Query** | `?_limit=N` (tùy chọn) |
| **Chức năng** | Trả về danh sách hướng dẫn viên từ `dbo.BestGuides` |

**Response (200 OK):**
```json
[
  { "id": 1, "name": "Tuan Tran", "email": "tuan@example.com", "city": "Da Nang", "phone": "0900000001", "address": { "city": "Da Nang" } },
  { "id": 2, "name": "Linh Hana", "email": "linh@example.com", "city": "Ha Noi", "phone": "0900000002", "address": { "city": "Ha Noi" } }
]
```

---

### API 9 — Lấy danh sách thông báo

| | |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/notifications` |
| **Query** | `?_limit=N` (tùy chọn) |
| **Chức năng** | Trả về thông báo từ `dbo.Notifications`, sắp xếp mới nhất trước |

**Response (200 OK):**
```json
[
  {
    "id": 3, "actorName": "Fellow4U", "actorAvatar": "assets/images/app_icon.png",
    "message": "Your trip in Danang has been finished. Please leave a review.",
    "date": "Jan 24", "accentColor": "#3F8CFF", "badgeIcon": "rate_review", "showReviewButton": true
  }
]
```

---

### API 10 — Lấy danh sách người dùng

| | |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `/api/users` |
| **Query** | `?_limit=N` (tùy chọn) |
| **Chức năng** | Trả về danh sách tài khoản từ `dbo.Users` (không bao gồm password) |

**Response (200 OK):**
```json
{
  "users": [
    { "id": 1, "firstName": "Emily", "lastName": "Johnson", "email": "emily.johnson@example.com", "username": "emilys" },
    { "id": 2, "firstName": "Bao", "lastName": "Dinh", "email": "bao@example.com", "username": "bao12345" }
  ]
}
```


---

## 7. Kiểm thử API

### 7.1 Swagger UI

Dự án tích hợp **Swagger UI** (OpenAPI 3.0.3) trực tiếp vào API server:

- **Local:** `http://localhost:3000/api/docs`
- **Production:** `https://fellow4udb.onrender.com/api/docs`

Swagger UI cho phép xem mô tả, schema và **thực thi API trực tiếp** trên trình duyệt mà không cần Postman.

### 7.2 Postman Collection

File: `api/postman/Fellow4U_Local_API.postman_collection.json`

### 7.3 Kết quả kiểm thử API (Postman + Swagger)

| # | Method | Endpoint | Kết quả | Status |
|---|---|---|---|---|
| 1 | GET | `/api/meta/health` | ✅ Kết nối SQL Server thành công | 200 |
| 2 | GET | `/api/meta/routes` | ✅ Trả về 22 endpoint | 200 |
| 3 | POST | `/api/auth/login` | ✅ Đăng nhập thành công, trả token | 200 |
| 4 | POST | `/api/auth/login` | ✅ Sai mật khẩu trả lỗi đúng | 401 |
| 5 | POST | `/api/auth/register` | ✅ Tạo tài khoản mới trong SQL | 201 |
| 6 | POST | `/api/auth/register` | ✅ Username trùng trả lỗi đúng | 422 |
| 7 | GET | `/api/TopJourneys` | ✅ Trả dữ liệu từ SQL Server | 200 |
| 8 | POST | `/api/TopJourneys` | ✅ Tạo hành trình mới trong SQL | 201 |
| 9 | PATCH | `/api/TopJourneys/1` | ✅ Cập nhật một phần thành công | 200 |
| 10 | DELETE | `/api/TopJourneys/3` | ✅ Xóa thành công | 200 |
| 11 | GET | `/api/BestGuides` | ✅ Trả dữ liệu từ SQL Server | 200 |
| 12 | GET | `/api/TopExperiences` | ✅ Trả dữ liệu từ SQL Server | 200 |
| 13 | GET | `/api/notifications` | ✅ Trả dữ liệu từ SQL Server | 200 |
| 14 | GET | `/api/users` | ✅ Trả danh sách người dùng | 200 |

### 7.4 Kiểm thử trên Flutter Web (production)

URL: `https://fellow4udb1.onrender.com`

| Chức năng | Kết quả |
|---|---|
| Đăng nhập `emilys / emilyspass` | ✅ Thành công, dữ liệu từ SQL Server |
| Đăng nhập `bao12345 / bao123456` | ✅ Thành công |
| Đăng nhập `admin / admin123` | ✅ Thành công |
| Sai mật khẩu | ✅ Hiển thị lỗi "Invalid credentials" |
| Đăng ký tài khoản mới | ✅ Tạo bản ghi trong `dbo.Users` |
| Màn hình Explore | ✅ Journeys, Guides, Experiences từ SQL |
| Màn hình Notifications | ✅ Dữ liệu từ `dbo.Notifications` |


---

## 8. Các lỗi đã phát hiện và sửa

### Lỗi 1 — Flutter Web gọi sai URL API (nghiêm trọng)

**Nguyên nhân:** `api_config.dart` dùng `Uri.base.origin` khi `kIsWeb = true`. Khi chạy Flutter Web dev trên `localhost:54963`, `Uri.base.origin` trả về `http://localhost:54963` thay vì `http://localhost:3000`. Trên Render, Flutter Web (`fellow4udb1.onrender.com`) gọi chính nó thay vì API (`fellow4udb.onrender.com`).

**File:** `lib/core/config/api_config.dart`

**Trước:**
```dart
if (kIsWeb) return Uri.base.origin; // ← sai: trả về URL của Flutter Web
```

**Sau:**
```dart
static const String _productionApiUrl = 'https://fellow4udb.onrender.com';

static String get baseUrl {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  if (_isLocalOrigin) return _defaultLocalApiUrl; // localhost:3000
  return _productionApiUrl;                        // production cố định
}
```

---

### Lỗi 2 — `LoginResponseModel` đọc sai cấu trúc JSON

**Nguyên nhân:** Model mong đợi `json['user']['id']` nhưng server trả về flat: `json['id']`.

**File:** `lib/features/auth/data/models/login_response_model.dart`

**Trước:**
```dart
final rawUser = json['user']; // ← không tồn tại → id=0, username=''
```

**Sau:**
```dart
id: (json['id'] as num? ?? 0).toInt(),
username: (json['username'] ?? '').toString(),
```

---

### Lỗi 3 — Cast `response.data as Map` crash khi nhận String

**Nguyên nhân:** Khi server trả HTML (trang lỗi Render) hoặc String, Dio không parse thành Map → crash.

**Files:** `auth_repository_impl.dart`, `accounts_repository_impl.dart`

**Fix:** Thêm helper `_toMap()` xử lý an toàn:
```dart
static Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is String) {
    try { return jsonDecode(raw) as Map<String, dynamic>; } catch (_) {}
  }
  return {};
}
```

---

### Lỗi 4 — Cast `data as List` crash trong explore/notifications

**Files:** `explore_api_controller.dart`, `notifications_api_controller.dart`

**Trước:** `(data as List<dynamic>)` → crash nếu API trả lỗi

**Sau:** `(data is List ? data : <dynamic>[])` → an toàn

---

### Lỗi 5 — `dart:io` import không hoạt động trên Flutter Web

**Nguyên nhân:** `api_exception.dart` import `dart:io` và dùng `SocketException` — không tồn tại trên web platform.

**Fix:** Bỏ `import 'dart:io'`, dùng `kIsWeb` để phân biệt platform.

---

### Lỗi 6 — Swagger UI dùng `https://` khi chạy local

**Nguyên nhân:** `buildSwaggerUiHtml` fallback về `"https"` khi không có `x-forwarded-proto` header → Swagger fetch `https://localhost:3000` nhưng server chạy `http://`.

**Fix:** Fallback về `"http"` khi không có header:
```js
const protocol = forwardedProto ? forwardedProto.split(",")[0].trim() : "http";
```

---

### Lỗi 7 — UptimeRobot báo 404 (HEAD /)

**Nguyên nhân:** Server chỉ xử lý `GET /`, không xử lý `HEAD /` mà UptimeRobot dùng để monitor.

**Fix:** Thêm handler `HEAD /` trả 200.

---

## 9. Nhận xét về dự án

### Ưu điểm

- Kiến trúc phân lớp rõ ràng: Presentation → Domain → Data → Network
- Backend Node.js thuần, không phụ thuộc framework, dễ đọc và kiểm soát
- CORS đầy đủ, hỗ trợ preflight OPTIONS
- Xử lý lỗi tốt ở cả API (HTTP status codes chuẩn) và Flutter (ApiException)
- Tích hợp Swagger UI — kiểm thử API trực tiếp trên trình duyệt
- Deploy thành công lên Render cloud, kết nối SQL Server GearHost thực tế
- Flutter Web và Mobile chạy được với cùng codebase
- Hỗ trợ cả môi trường localhost và production tự động

### Hạn chế

- Password lưu dạng plain text (chưa hash bcrypt)
- Token xác thực là base64 đơn giản, chưa phải JWT thực sự
- Backend chưa tách lớp controller/service/repository
- Chưa có pagination chuẩn (chỉ có `_limit`)
- Chưa có rate limiting

---

## 10. Hướng phát triển

- **Bảo mật:** Hash password bằng bcrypt, dùng JWT với refresh token rotation
- **Backend:** Tách theo mô hình Express + controller/service/repository
- **State management:** Dùng Riverpod hoặc BLoC
- **Pagination:** Thêm cursor-based pagination
- **Tìm kiếm:** Thêm endpoint search cho journeys, guides
- **Upload ảnh:** Tích hợp cloud storage

---

## 11. Kết luận

Dự án Fellow4U đã xây dựng thành công ứng dụng du lịch hoàn chỉnh, bao gồm:

- Giao diện Flutter đẹp, responsive, chạy được trên Web và Mobile
- Backend API Node.js với **22 endpoint** kết nối SQL Server GearHost thực tế
- CRUD hoàn chỉnh cho TopJourneys (GET, POST, PUT, PATCH, DELETE)
- Xác thực người dùng với dữ liệu SQL thực tế
- Swagger UI tích hợp để kiểm thử API trực tiếp
- Deploy thành công lên Render: https://fellow4udb1.onrender.com
- Đã phát hiện và sửa **7 lỗi thực tế** trong quá trình phát triển và kiểm thử

Hệ thống đáp ứng đầy đủ yêu cầu D1: mô tả 10 API (endpoint, method, request/response mẫu) và sơ đồ kiến trúc ứng dụng.
