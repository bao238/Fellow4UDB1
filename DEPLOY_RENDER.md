# Deploy Fellow4U lên Render

Hướng dẫn deploy toàn bộ hệ thống Fellow4U lên Render (cloud), bao gồm backend API và Flutter Web.

---

## 1. Kiến trúc deploy

```
Internet
   ↓
Render Static Site (Flutter Web)
   ↓  (HTTPS API calls)
Render Web Service (Node.js API)
   ↓  (TCP/SQL)
GearHost SQL Server (den1.mssql8.gear.host)
```

| Thành phần | Nền tảng | URL mẫu |
|---|---|---|
| Backend API | Render Web Service | `https://fellow4u-api.onrender.com` |
| Frontend Web | Render Static Site | `https://fellow4u-web.onrender.com` |
| Database | GearHost SQL Server | `den1.mssql8.gear.host` |

---

## 2. Điều kiện bắt buộc

- Code đã được đẩy lên GitHub
- Database GearHost đang hoạt động và cho phép kết nối từ internet (đã có sẵn)
- Tài khoản Render (free tier đủ dùng)

---

## 3. Deploy backend API

### Cách 1 — Dùng `render.yaml` (khuyến nghị)

File `render.yaml` đã có sẵn ở thư mục gốc. Render tự đọc và tạo service.

1. Vào [render.com](https://render.com) → **New** → **Blueprint**
2. Kết nối repo GitHub
3. Render tự detect `render.yaml` và tạo 2 service

Sau đó thêm biến môi trường cho service `fellow4u-api`:

| Key | Value |
|---|---|
| `NODE_ENV` | `production` |
| `SQL_CONNECTION_STRING` | `Server=den1.mssql8.gear.host;Database=fellow4udb1;User Id=fellow4udb1;Password=Om63C~-d8TyA;Encrypt=true;TrustServerCertificate=true` |
| `SQL_ENCRYPT` | `true` |
| `SQL_TRUST_SERVER_CERTIFICATE` | `true` |

### Cách 2 — Tạo thủ công

1. Vào Render → **New Web Service**
2. Kết nối repo GitHub
3. Cấu hình:
   - **Root Directory:** `api`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** Node
4. Thêm biến môi trường như bảng trên

---

## 4. Deploy Flutter Web

### Build local trước khi deploy

```powershell
flutter pub get
flutter build web --release `
  --dart-define=API_BASE_URL=https://fellow4u-api.onrender.com `
  --dart-define=AUTH_BASE_URL=https://fellow4u-api.onrender.com
```

Output: `build/web/`

### Deploy lên Render Static Site

1. Vào Render → **New Static Site**
2. Kết nối repo GitHub
3. Cấu hình:
   - **Root Directory:** `.` (thư mục gốc)
   - **Build Command:**
     ```
     flutter pub get && flutter build web --release --dart-define=API_BASE_URL=https://fellow4u-api.onrender.com --dart-define=AUTH_BASE_URL=https://fellow4u-api.onrender.com
     ```
   - **Publish Directory:** `build/web`

> **Lưu ý:** Render cần cài Flutter. Nếu không tự detect, thêm build image hoặc dùng GitHub Actions để build trước rồi deploy artifact.

---

## 5. Kiểm tra sau deploy

```
GET https://fellow4u-api.onrender.com/api/meta/health
GET https://fellow4u-api.onrender.com/api/meta/routes
GET https://fellow4u-api.onrender.com/api/TopJourneys
POST https://fellow4u-api.onrender.com/api/auth/login
```

Mở Flutter Web public và thử đăng nhập với tài khoản demo.

---

## 6. Biến môi trường đầy đủ

### Backend (`fellow4u-api`)

| Key | Giá trị | Bắt buộc |
|---|---|---|
| `NODE_ENV` | `production` | ✅ |
| `PORT` | `3000` | ✅ |
| `SQL_CONNECTION_STRING` | connection string GearHost | ✅ |
| `SQL_ENCRYPT` | `true` | ✅ |
| `SQL_TRUST_SERVER_CERTIFICATE` | `true` | ✅ |

### Frontend (`fellow4u-web`) — dart-define khi build

| Key | Giá trị |
|---|---|
| `API_BASE_URL` | `https://fellow4u-api.onrender.com` |
| `AUTH_BASE_URL` | `https://fellow4u-api.onrender.com` |
| `API_TIMEOUT_MS` | `20000` (tùy chọn, tăng timeout cho Render free tier) |

---

## 7. Lưu ý quan trọng

**Render free tier cold start:** Service miễn phí sẽ sleep sau 15 phút không có request. Request đầu tiên sau khi sleep có thể mất 30–60 giây. Nâng lên paid tier để tránh.

**CORS:** API đã bật `Access-Control-Allow-Origin: *` nên Flutter Web public có thể gọi được.

**HTTPS:** Render tự cấp SSL. Đảm bảo `API_BASE_URL` dùng `https://`, không phải `http://`.

**Database:** GearHost SQL Server cho phép kết nối từ internet. Không cần whitelist IP Render.

---

## 8. Checklist deploy

- [ ] Code đã push lên GitHub
- [ ] `render.yaml` đã có trong repo
- [ ] Render service `fellow4u-api` đã tạo và chạy
- [ ] Biến môi trường `SQL_CONNECTION_STRING` đã set
- [ ] `GET /api/meta/health` trả `status: ok`
- [ ] Flutter Web build thành công với `API_BASE_URL` đúng
- [ ] Render Static Site đã deploy
- [ ] Đăng nhập thành công trên web public

---

## 9. Troubleshooting

| Vấn đề | Nguyên nhân | Giải pháp |
|---|---|---|
| API trả 500 khi start | Sai connection string | Kiểm tra biến `SQL_CONNECTION_STRING` |
| Flutter Web gọi `localhost:3000` | Quên `--dart-define` khi build | Rebuild với `API_BASE_URL` đúng |
| CORS error trên browser | API không trả header CORS | Kiểm tra `setCorsHeaders` trong `server.js` |
| Render cold start timeout | Free tier sleep | Tăng `API_TIMEOUT_MS` lên 30000 |
| Login 404 | `API_BASE_URL` sai | Kiểm tra URL API trên Render |
