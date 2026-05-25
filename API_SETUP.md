# API Setup — Fellow4U

Hướng dẫn cài đặt và cấu hình API cho dự án Fellow4U.

---

## 1. Yêu cầu

- Node.js 18+
- npm
- Kết nối internet (để truy cập SQL Server GearHost)

---

## 2. Cài đặt và chạy API

```bash
cd api
npm install
npm start
```

Server chạy tại: `http://localhost:3000`

Kiểm tra ngay:
```
GET http://localhost:3000/api/meta/health
```

Response thành công:
```json
{
  "status": "ok",
  "database": "Fellow4UDB",
  "time": "2026-05-25T08:00:00.000Z"
}
```

---

## 3. Cấu hình kết nối SQL Server

File: `api/db.js`

### Mặc định (GearHost cloud)

```
Server:   den1.mssql8.gear.host
Database: fellow4udb1
User:     fellow4udb1
Password: Om63C~-d8TyA
```

### Override bằng biến môi trường

```bash
# Windows CMD
set SQL_SERVER=den1.mssql8.gear.host
set SQL_DATABASE=fellow4udb1
set SQL_USER=fellow4udb1
set SQL_PASSWORD=Om63C~-d8TyA
set SQL_ENCRYPT=true
set SQL_TRUST_SERVER_CERTIFICATE=true
```

```bash
# Hoặc dùng connection string đầy đủ
set SQL_CONNECTION_STRING=Server=den1.mssql8.gear.host;Database=fellow4udb1;User Id=fellow4udb1;Password=Om63C~-d8TyA;Encrypt=true;TrustServerCertificate=true
```

---

## 4. Tạo và seed database

Chạy các script SQL theo thứ tự trong SQL Server Management Studio (SSMS) hoặc Azure Data Studio:

### Bước 1 — Setup cơ bản
```
api/sql/fellow4udb_setup.sql
```
Tạo các bảng: `Users`, `TopJourneys`, `BestGuides`, `TopExperiences`, `Notifications`
Seed dữ liệu mẫu cơ bản.

### Bước 2 — Seed demo accounts
```
api/sql/fellow4udb_auth_login.sql
```
Tạo hoặc cập nhật 3 tài khoản demo:

| Username | Password | Role |
|---|---|---|
| `emilys` | `emilyspass` | Traveler |
| `bao12345` | `bao123456` | Traveler |
| `admin` | `admin123` | Admin |

### Bước 3 — Seed notifications
```
api/sql/fellow4udb_notifications_api.sql
```
Tạo dữ liệu mẫu cho bảng `Notifications`.

---

## 5. Cấu hình Flutter

File: `lib/core/config/api_config.dart`

### Mặc định (dev local)

- `baseUrl` = `http://localhost:3000`
- `authBaseUrl` = `http://localhost:3000`
- `timeoutMs` = `15000`

Khi chạy Flutter Web trên `localhost`, app tự động dùng `http://localhost:3000` (không bị nhầm sang port Flutter).

### Override bằng `--dart-define`

```bash
flutter run --dart-define=API_BASE_URL=https://fellow4u-api.onrender.com \
            --dart-define=AUTH_BASE_URL=https://fellow4u-api.onrender.com
```

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://fellow4u-api.onrender.com \
  --dart-define=AUTH_BASE_URL=https://fellow4u-api.onrender.com \
  --dart-define=API_TIMEOUT_MS=20000
```

---

## 6. Danh sách đầy đủ các API

### Auth
```
POST /api/auth/login
POST /api/auth/register
```

**Login body:**
```json
{
  "username": "emilys",
  "password": "emilyspass"
}
```
Cũng chấp nhận `email` thay cho `username`:
```json
{
  "email": "emily.johnson@example.com",
  "password": "emilyspass"
}
```

**Register body:**
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

Lỗi register có thể trả về:
- `422 Username already exists`
- `422 Email already exists`
- `422 Username or email already exists`

---

### Journeys (CRUD đầy đủ)
```
GET    /api/TopJourneys           ← ?_limit=N
GET    /api/TopJourneys/{id}
POST   /api/TopJourneys
PUT    /api/TopJourneys/{id}      ← cập nhật toàn bộ
PATCH  /api/TopJourneys/{id}      ← cập nhật một phần
DELETE /api/TopJourneys/{id}
```

**POST / PUT body:**
```json
{
  "userId": 1,
  "title": "Hue Ancient Journey",
  "body": "A 2-day historical trip in Hue."
}
```

**PATCH body (chỉ cần gửi trường muốn thay đổi):**
```json
{
  "title": "New Title"
}
```

---

### Guides
```
GET /api/BestGuides         ← ?_limit=N
GET /api/BestGuides/{id}
```

---

### Experiences
```
GET /api/TopExperiences         ← ?_limit=N
GET /api/TopExperiences/{id}
```

---

### Notifications
```
GET /api/notifications          ← ?_limit=N
GET /api/notifications/{id}
```

---

### Users / Accounts
```
GET  /api/users             ← ?_limit=N
GET  /api/users/{id}
POST /api/users/add
```

**POST /api/users/add body:**
```json
{
  "firstName": "Nguyen",
  "lastName": "Van A",
  "email": "vana@example.com",
  "username": "vana2026",
  "password": "vana123456"
}
```

---

### Metadata & SQL Setup
```
GET /api/meta/routes
GET /api/meta/health
GET /api/setup/sql
GET /api/setup/sql?download=1
GET /api/setup/sql/auth
GET /api/setup/sql/auth?download=1
GET /api/setup/sql/notifications
GET /api/setup/sql/notifications?download=1
```

---

## 7. Postman

Import file:
```
api/postman/Fellow4U_Local_API.postman_collection.json
```

Quick test URLs:
```
GET  http://localhost:3000/api/meta/health
GET  http://localhost:3000/api/meta/routes
POST http://localhost:3000/api/auth/login
POST http://localhost:3000/api/auth/register
GET  http://localhost:3000/api/TopJourneys
POST http://localhost:3000/api/TopJourneys
PATCH http://localhost:3000/api/TopJourneys/1
DELETE http://localhost:3000/api/TopJourneys/1
GET  http://localhost:3000/api/BestGuides
GET  http://localhost:3000/api/TopExperiences
GET  http://localhost:3000/api/notifications
GET  http://localhost:3000/api/users
POST http://localhost:3000/api/users/add
```

---

## 8. Xử lý lỗi

### Phía API (Node.js)

| HTTP Status | Ý nghĩa |
|---|---|
| 200 | Thành công |
| 201 | Tạo mới thành công |
| 204 | Preflight OPTIONS (CORS) |
| 400 | Request body thiếu hoặc sai định dạng |
| 401 | Sai username/password |
| 404 | Không tìm thấy resource |
| 422 | Dữ liệu vi phạm ràng buộc (username/email trùng) |
| 500 | Lỗi server |

### Phía Flutter (Dio + ApiException)

| ApiErrorType | Nguyên nhân |
|---|---|
| `network` | Không kết nối được API server |
| `timeout` | Request quá thời gian chờ |
| `unauthorized` | HTTP 401 |
| `notFound` | HTTP 404 |
| `validation` | HTTP 422 |
| `server` | HTTP 5xx |

---

## 9. Lưu ý quan trọng

- Khi chạy Flutter Web dev (`flutter run -d chrome`), app chạy ở port khác (ví dụ `64487`) so với API (`3000`). `ApiConfig` đã xử lý đúng trường hợp này — luôn dùng `localhost:3000` khi dev local.
- Khi build production web, phải truyền `--dart-define=API_BASE_URL=...` để trỏ đúng URL API public.
- CORS đã được bật cho mọi origin (`*`) ở API server.
