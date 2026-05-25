# Fellow4U

Ứng dụng du lịch Flutter kết nối Node.js API và SQL Server cloud.

- **Frontend:** Flutter Web + Mobile
- **Backend:** Node.js API server (port 3000)
- **Database:** SQL Server — `fellow4udb1` trên GearHost (`den1.mssql8.gear.host`)

---

## Chạy nhanh (Windows)

```bat
run_web.bat
```

Script này sẽ tự động:
1. Kiểm tra API + SQL tại `http://localhost:3000/api/meta/health`
2. Khởi động lại API server (`api/server.js`) ở background
3. Chạy Flutter Web (`flutter run -d chrome`)

---

## Chạy thủ công

### 1. Chạy API server

```bash
cd api
npm install
npm start
```

Server chạy tại: `http://localhost:3000`

Kiểm tra kết nối:
```
GET http://localhost:3000/api/meta/health
GET http://localhost:3000/api/meta/routes
```

**Swagger UI (tài liệu API tương tác):**
```
GET http://localhost:3000/api/docs
```

### 2. Chạy Flutter app

```bash
flutter pub get
flutter run
```

Chạy trên web:
```bash
flutter run -d chrome
```

---

## Tài khoản demo

| Username | Password | Role |
|---|---|---|
| `emilys` | `emilyspass` | Traveler |
| `bao12345` | `bao123456` | Traveler |
| `admin` | `admin123` | Admin |

---

## Cấu hình database

Kết nối mặc định trong `api/db.js`:

```
Server:   den1.mssql8.gear.host
Database: fellow4udb1
User:     fellow4udb1
```

Override bằng biến môi trường:
```bash
set SQL_SERVER=den1.mssql8.gear.host
set SQL_DATABASE=fellow4udb1
set SQL_USER=fellow4udb1
set SQL_PASSWORD=your_password
```

Hoặc dùng connection string:
```bash
set SQL_CONNECTION_STRING=Server=...;Database=...;User Id=...;Password=...
```

---

## Tạo và seed database

Chạy các script SQL theo thứ tự:

```
api/sql/fellow4udb_setup.sql              ← Tạo bảng + seed data cơ bản
api/sql/fellow4udb_auth_login.sql         ← Seed demo accounts (emilys, bao12345, admin)
api/sql/fellow4udb_notifications_api.sql  ← Seed notifications
```

---

## Danh sách API

| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/meta/health` | Kiểm tra trạng thái server + DB |
| GET | `/api/meta/routes` | Danh sách tất cả route |
| POST | `/api/auth/login` | Đăng nhập |
| POST | `/api/auth/register` | Đăng ký |
| GET | `/api/TopJourneys` | Danh sách hành trình |
| GET | `/api/TopJourneys/{id}` | Chi tiết hành trình |
| POST | `/api/TopJourneys` | Tạo hành trình |
| PUT | `/api/TopJourneys/{id}` | Cập nhật toàn bộ hành trình |
| PATCH | `/api/TopJourneys/{id}` | Cập nhật một phần hành trình |
| DELETE | `/api/TopJourneys/{id}` | Xóa hành trình |
| GET | `/api/BestGuides` | Danh sách hướng dẫn viên |
| GET | `/api/BestGuides/{id}` | Chi tiết hướng dẫn viên |
| GET | `/api/TopExperiences` | Danh sách trải nghiệm |
| GET | `/api/TopExperiences/{id}` | Chi tiết trải nghiệm |
| GET | `/api/notifications` | Danh sách thông báo |
| GET | `/api/notifications/{id}` | Chi tiết thông báo |
| GET | `/api/users` | Danh sách người dùng |
| GET | `/api/users/{id}` | Chi tiết người dùng |
| POST | `/api/users/add` | Thêm người dùng |
| GET | `/api/setup/sql` | Xem SQL setup script |
| GET | `/api/setup/sql/auth` | Xem SQL auth script |
| GET | `/api/setup/sql/notifications` | Xem SQL notifications script |

Thêm `?_limit=N` vào các GET list để giới hạn số bản ghi.

---

## Postman

Import file:
```
api/postman/Fellow4U_Local_API.postman_collection.json
```

---

## Deploy lên Render

Xem hướng dẫn chi tiết: [DEPLOY_RENDER.md](DEPLOY_RENDER.md)

Tóm tắt:
- Backend: Render Web Service, root dir `api`, start `npm start`
- Frontend: Render Static Site, build `flutter build web --release --dart-define=API_BASE_URL=https://fellow4u-api.onrender.com`
- Database: GearHost SQL Server (đã có sẵn, truy cập được từ internet)
