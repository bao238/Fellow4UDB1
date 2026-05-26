const http = require("http");
const fs = require("fs/promises");
const path = require("path");
const { URL } = require("url");
const crypto = require("crypto");

const { poolPromise, sql } = require("./db");

const port = Number(process.env.PORT || 3000);
const databaseName = process.env.SQL_DATABASE || "Fellow4UDB";
const sqlSetupPath = path.join(__dirname, "sql", "fellow4udb_setup.sql");
const authSqlSetupPath = path.join(__dirname, "sql", "fellow4udb_auth_login.sql");
const notificationsSqlSetupPath = path.join(__dirname, "sql", "fellow4udb_notifications_api.sql");
const swaggerJsonPath = path.join(__dirname, "swagger.json");

// JWT secret — dùng env var khi production
const JWT_SECRET = process.env.JWT_SECRET || "fellow4u_secret_key_2026";
const JWT_EXPIRES_IN = 60 * 60 * 24; // 24 giờ (giây)

// ── JWT helpers (không cần package) ──────────────────────────────────────────

function base64urlEncode(str) {
  return Buffer.from(str).toString("base64url");
}

function base64urlDecode(str) {
  return Buffer.from(str, "base64url").toString("utf-8");
}

function signJwt(payload) {
  const header = base64urlEncode(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const body   = base64urlEncode(JSON.stringify({ ...payload, exp: Math.floor(Date.now() / 1000) + JWT_EXPIRES_IN }));
  const sig    = crypto.createHmac("sha256", JWT_SECRET).update(`${header}.${body}`).digest("base64url");
  return `${header}.${body}.${sig}`;
}

function verifyJwt(token) {
  try {
    const parts = token.split(".");
    if (parts.length !== 3) return null;
    const [header, body, sig] = parts;
    const expected = crypto.createHmac("sha256", JWT_SECRET).update(`${header}.${body}`).digest("base64url");
    if (sig !== expected) return null;
    const payload = JSON.parse(base64urlDecode(body));
    if (payload.exp && Math.floor(Date.now() / 1000) > payload.exp) return null; // hết hạn
    return payload;
  } catch (_) {
    return null;
  }
}

function extractBearerToken(req) {
  const auth = req.headers["authorization"] || "";
  if (!auth.startsWith("Bearer ")) return null;
  return auth.slice(7).trim();
}

// Middleware kiểm tra JWT — trả 401 nếu không hợp lệ
function requireAuth(req, res) {
  const token = extractBearerToken(req);
  if (!token) {
    sendJson(res, 401, { message: "Authorization token required" });
    return null;
  }
  const payload = verifyJwt(token);
  if (!payload) {
    sendJson(res, 401, { message: "Invalid or expired token" });
    return null;
  }
  return payload; // trả payload nếu hợp lệ
}

// ── helpers ──────────────────────────────────────────────────────────────────

function setCorsHeaders(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

function sendJson(res, statusCode, payload) {
  setCorsHeaders(res);
  res.writeHead(statusCode, { "Content-Type": "application/json" });
  res.end(JSON.stringify(payload));
}

function sendText(res, statusCode, content, headers = {}) {
  setCorsHeaders(res);
  res.writeHead(statusCode, { "Content-Type": "text/plain; charset=utf-8", ...headers });
  res.end(content);
}

function sendHtml(res, statusCode, content) {
  setCorsHeaders(res);
  res.writeHead(statusCode, { "Content-Type": "text/html; charset=utf-8" });
  res.end(content);
}

function buildSwaggerUiHtml(baseUrl) {
  return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Fellow4U API Docs</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  <style>body{margin:0;background:#fafafa;}.topbar{display:none!important;}</style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script>
    window.onload = () => {
      SwaggerUIBundle({
        url: "${baseUrl}/api/docs/swagger.json",
        dom_id: "#swagger-ui",
        presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
        layout: "BaseLayout",
        deepLinking: true,
        tryItOutEnabled: true,
      });
    };
  </script>
</body>
</html>`;
}

async function readJsonBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString("utf-8").trim();
  if (!raw) return {};
  try { return JSON.parse(raw); }
  catch (_) { const e = new Error("Invalid JSON body"); e.statusCode = 400; throw e; }
}

function createToken(username) {
  return Buffer.from(`${username}-${Date.now()}`).toString("base64url");
}

function parseEntityPath(pathname, prefix) {
  if (pathname === prefix) return { matches: true, id: null };
  if (!pathname.startsWith(`${prefix}/`)) return { matches: false, id: null };
  const rawId = pathname.slice(prefix.length + 1);
  if (!/^\d+$/.test(rawId)) return { matches: true, id: Number.NaN };
  return { matches: true, id: Number(rawId) };
}

function parseLimit(urlObj) {
  const raw = urlObj.searchParams.get("_limit") || urlObj.searchParams.get("limit");
  if (!raw) return null;
  const v = Number(raw);
  return Number.isInteger(v) && v > 0 ? v : null;
}

function asText(v) { if (typeof v !== "string") return null; const t = v.trim(); return t || null; }
function asInt(v) { const n = Number(v); return Number.isInteger(n) ? n : null; }

// ── normalizers ───────────────────────────────────────────────────────────────

const norm = {
  journey: (r) => ({ id: r.Id, userId: r.UserId, title: r.Title, body: r.Body }),
  guide:   (r) => ({ id: r.Id, name: r.Name, email: r.Email, city: r.City, phone: r.Phone, address: { city: r.City } }),
  exp:     (r) => ({ id: r.Id, userId: r.UserId, title: r.Title }),
  user:    (r) => ({ id: r.Id, firstName: r.FirstName, lastName: r.LastName, email: r.Email, username: r.Username, country: r.Country, role: r.Role }),
  notif:   (r) => ({ id: r.Id, actorName: r.ActorName, actorAvatar: r.ActorAvatar, message: r.Message, date: r.EventDate, accentColor: r.AccentColor, badgeIcon: r.BadgeIcon, showReviewButton: Boolean(r.ShowReviewButton) }),
};

// ── auth handlers ─────────────────────────────────────────────────────────────

async function handleLogin(req, res) {
  const body = await readJsonBody(req);
  const identity = asText(body.username) || asText(body.email);
  const password = asText(body.password);
  if (!identity || !password) return sendJson(res, 400, { message: "username/email and password are required" });

  const pool = await poolPromise;
  const result = await pool.request()
    .input("identity", sql.NVarChar(255), identity)
    .input("password", sql.NVarChar(255), password)
    .query("SELECT TOP(1) Id,Username,Email,FirstName,LastName FROM dbo.Users WHERE (Username=@identity OR Email=@identity) AND Password=@password");

  const user = result.recordset[0];
  if (!user) return sendJson(res, 401, { message: "Invalid credentials" });

  const accessToken  = signJwt({ id: user.Id, username: user.Username, role: user.Role || "Traveler" });
  const refreshToken = signJwt({ id: user.Id, username: user.Username, type: "refresh" });

  return sendJson(res, 200, {
    message: "Login successful.",
    accessToken,
    refreshToken,
    id: user.Id,
    username: user.Username,
    email: user.Email,
    firstName: user.FirstName,
    lastName: user.LastName,
    fullName: `${user.FirstName} ${user.LastName}`.trim(),
  });
}

async function handleRegister(req, res) {
  const body = await readJsonBody(req);
  const firstName = asText(body.firstName);
  const lastName  = asText(body.lastName);
  const email     = asText(body.email);
  const username  = asText(body.username);
  const password  = asText(body.password);
  const country   = asText(body.country) || "";
  const role      = asText(body.role) || "Traveler";

  if (!firstName || !lastName || !email || !username || !password)
    return sendJson(res, 400, { message: "firstName, lastName, email, username, password are required" });

  const pool = await poolPromise;
  const existing = await pool.request()
    .input("username", sql.NVarChar(100), username)
    .input("email", sql.NVarChar(255), email)
    .query("SELECT TOP(1) Id,Username,Email FROM dbo.Users WHERE Username=@username OR Email=@email");

  if (existing.recordset.length > 0) {
    const dup = existing.recordset[0];
    if ((dup.Username || "").toLowerCase() === username.toLowerCase())
      return sendJson(res, 422, { message: "Username already exists" });
    return sendJson(res, 422, { message: "Email already exists" });
  }

  let result;
  try {
    result = await pool.request()
      .input("firstName", sql.NVarChar(100), firstName)
      .input("lastName",  sql.NVarChar(100), lastName)
      .input("email",     sql.NVarChar(255), email)
      .input("username",  sql.NVarChar(100), username)
      .input("password",  sql.NVarChar(255), password)
      .input("country",   sql.NVarChar(100), country)
      .input("role",      sql.NVarChar(50),  role)
      .query("INSERT INTO dbo.Users(FirstName,LastName,Email,Username,Password,Country,Role) OUTPUT INSERTED.Id,INSERTED.FirstName,INSERTED.LastName,INSERTED.Email,INSERTED.Username,INSERTED.Country,INSERTED.Role VALUES(@firstName,@lastName,@email,@username,@password,@country,@role)");
  } catch (err) {
    const msg = (err.message || "").toLowerCase();
    if (err.number === 2601 || err.number === 2627 || msg.includes("duplicate key")) {
      if (msg.includes("email")) return sendJson(res, 422, { message: "Email already exists" });
      return sendJson(res, 422, { message: "Username already exists" });
    }
    throw err;
  }
  return sendJson(res, 201, norm.user(result.recordset[0]));
}

// ── meta handlers ─────────────────────────────────────────────────────────────

async function handleHealthCheck(res) {
  const pool = await poolPromise;
  await pool.request().query("SELECT 1 AS Ok");
  return sendJson(res, 200, { status: "ok", database: databaseName, time: new Date().toISOString() });
}

function handleGetApiRoutes(res) {
  return sendJson(res, 200, {
    name: "Fellow4U API",
    database: databaseName,
    swaggerUi: "/api/docs",
    endpoints: [
      { method: "GET",    path: "/api/docs" },
      { method: "GET",    path: "/api/meta/health" },
      { method: "GET",    path: "/api/meta/routes" },
      { method: "POST",   path: "/api/auth/login" },
      { method: "POST",   path: "/api/auth/register" },
      { method: "GET",    path: "/api/TopJourneys" },
      { method: "GET",    path: "/api/TopJourneys/{id}" },
      { method: "POST",   path: "/api/TopJourneys" },
      { method: "PUT",    path: "/api/TopJourneys/{id}" },
      { method: "PATCH",  path: "/api/TopJourneys/{id}" },
      { method: "DELETE", path: "/api/TopJourneys/{id}" },
      { method: "GET",    path: "/api/BestGuides" },
      { method: "GET",    path: "/api/BestGuides/{id}" },
      { method: "GET",    path: "/api/TopExperiences" },
      { method: "GET",    path: "/api/TopExperiences/{id}" },
      { method: "GET",    path: "/api/notifications" },
      { method: "GET",    path: "/api/notifications/{id}" },
      { method: "GET",    path: "/api/users" },
      { method: "GET",    path: "/api/users/{id}" },
      { method: "POST",   path: "/api/users/add" },
    ],
  });
}

// ── journey handlers ──────────────────────────────────────────────────────────

async function handleListJourneys(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const req2 = pool.request();
  const q = limit ? "SELECT TOP(@limit) Id,UserId,Title,Body FROM dbo.TopJourneys ORDER BY Id"
                  : "SELECT Id,UserId,Title,Body FROM dbo.TopJourneys ORDER BY Id";
  if (limit) req2.input("limit", sql.Int, limit);
  const r = await req2.query(q);
  return sendJson(res, 200, r.recordset.map(norm.journey));
}

async function handleJourneyDetail(res, id) {
  const pool = await poolPromise;
  const r = await pool.request().input("id", sql.Int, id)
    .query("SELECT TOP(1) Id,UserId,Title,Body FROM dbo.TopJourneys WHERE Id=@id");
  const rec = r.recordset[0];
  if (!rec) return sendJson(res, 404, { message: "Journey not found" });
  return sendJson(res, 200, norm.journey(rec));
}

async function handleCreateJourney(req, res) {
  const body = await readJsonBody(req);
  const userId = asInt(body.userId), title = asText(body.title), desc = asText(body.body);
  if (userId === null || !title || !desc) return sendJson(res, 400, { message: "userId, title, body are required" });
  const pool = await poolPromise;
  const r = await pool.request()
    .input("userId", sql.Int, userId).input("title", sql.NVarChar(255), title).input("body", sql.NVarChar(sql.MAX), desc)
    .query("INSERT INTO dbo.TopJourneys(UserId,Title,Body) OUTPUT INSERTED.Id,INSERTED.UserId,INSERTED.Title,INSERTED.Body VALUES(@userId,@title,@body)");
  return sendJson(res, 201, norm.journey(r.recordset[0]));
}

async function handleUpdateJourney(req, res, id, partial) {
  const body = await readJsonBody(req);
  if (!partial) {
    const userId = asInt(body.userId), title = asText(body.title), desc = asText(body.body);
    if (userId === null || !title || !desc) return sendJson(res, 400, { message: "userId, title, body are required" });
    const pool = await poolPromise;
    const r = await pool.request()
      .input("id", sql.Int, id).input("userId", sql.Int, userId).input("title", sql.NVarChar(255), title).input("body", sql.NVarChar(sql.MAX), desc)
      .query("UPDATE dbo.TopJourneys SET UserId=@userId,Title=@title,Body=@body OUTPUT INSERTED.Id,INSERTED.UserId,INSERTED.Title,INSERTED.Body WHERE Id=@id");
    const rec = r.recordset[0];
    if (!rec) return sendJson(res, 404, { message: "Journey not found" });
    return sendJson(res, 200, norm.journey(rec));
  }
  const hasU = Object.prototype.hasOwnProperty.call(body, "userId");
  const hasT = Object.prototype.hasOwnProperty.call(body, "title");
  const hasB = Object.prototype.hasOwnProperty.call(body, "body");
  if (!hasU && !hasT && !hasB) return sendJson(res, 400, { message: "At least one of userId, title, body is required" });
  const userId = hasU ? asInt(body.userId) : null;
  const title  = hasT ? asText(body.title) : null;
  const desc   = hasB ? asText(body.body)  : null;
  const pool = await poolPromise;
  const r = await pool.request()
    .input("id", sql.Int, id).input("userId", sql.Int, userId).input("title", sql.NVarChar(255), title).input("body", sql.NVarChar(sql.MAX), desc)
    .query("UPDATE dbo.TopJourneys SET UserId=COALESCE(@userId,UserId),Title=COALESCE(@title,Title),Body=COALESCE(@body,Body) OUTPUT INSERTED.Id,INSERTED.UserId,INSERTED.Title,INSERTED.Body WHERE Id=@id");
  const rec = r.recordset[0];
  if (!rec) return sendJson(res, 404, { message: "Journey not found" });
  return sendJson(res, 200, norm.journey(rec));
}

async function handleDeleteJourney(res, id) {
  const pool = await poolPromise;
  const r = await pool.request().input("id", sql.Int, id)
    .query("DELETE FROM dbo.TopJourneys OUTPUT DELETED.Id WHERE Id=@id");
  if (r.recordset.length === 0) return sendJson(res, 404, { message: "Journey not found" });
  return sendJson(res, 200, { message: "Deleted post successfully." });
}

// ── guide handlers ────────────────────────────────────────────────────────────

async function handleListGuides(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const req2 = pool.request();
  const q = limit ? "SELECT TOP(@limit) Id,Name,Email,City,Phone FROM dbo.BestGuides ORDER BY Id"
                  : "SELECT Id,Name,Email,City,Phone FROM dbo.BestGuides ORDER BY Id";
  if (limit) req2.input("limit", sql.Int, limit);
  const r = await req2.query(q);
  return sendJson(res, 200, r.recordset.map(norm.guide));
}

async function handleGuideDetail(res, id) {
  const pool = await poolPromise;
  const r = await pool.request().input("id", sql.Int, id)
    .query("SELECT TOP(1) Id,Name,Email,City,Phone FROM dbo.BestGuides WHERE Id=@id");
  const rec = r.recordset[0];
  if (!rec) return sendJson(res, 404, { message: "Guide not found" });
  return sendJson(res, 200, norm.guide(rec));
}

// ── experience handlers ───────────────────────────────────────────────────────

async function handleListExperiences(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const req2 = pool.request();
  const q = limit ? "SELECT TOP(@limit) Id,UserId,Title FROM dbo.TopExperiences ORDER BY Id"
                  : "SELECT Id,UserId,Title FROM dbo.TopExperiences ORDER BY Id";
  if (limit) req2.input("limit", sql.Int, limit);
  const r = await req2.query(q);
  return sendJson(res, 200, r.recordset.map(norm.exp));
}

async function handleExperienceDetail(res, id) {
  const pool = await poolPromise;
  const r = await pool.request().input("id", sql.Int, id)
    .query("SELECT TOP(1) Id,UserId,Title FROM dbo.TopExperiences WHERE Id=@id");
  const rec = r.recordset[0];
  if (!rec) return sendJson(res, 404, { message: "Experience not found" });
  return sendJson(res, 200, norm.exp(rec));
}

// ── notification handlers ─────────────────────────────────────────────────────

async function handleListNotifications(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const req2 = pool.request();
  const q = limit
    ? "SELECT TOP(@limit) Id,ActorName,ActorAvatar,Message,EventDate,AccentColor,BadgeIcon,ShowReviewButton FROM dbo.Notifications ORDER BY Id DESC"
    : "SELECT Id,ActorName,ActorAvatar,Message,EventDate,AccentColor,BadgeIcon,ShowReviewButton FROM dbo.Notifications ORDER BY Id DESC";
  if (limit) req2.input("limit", sql.Int, limit);
  try {
    const r = await req2.query(q);
    return sendJson(res, 200, r.recordset.map(norm.notif));
  } catch (err) {
    if (err.number === 208) return sendJson(res, 200, []);
    throw err;
  }
}

async function handleNotificationDetail(res, id) {
  const pool = await poolPromise;
  let r;
  try {
    r = await pool.request().input("id", sql.Int, id)
      .query("SELECT TOP(1) Id,ActorName,ActorAvatar,Message,EventDate,AccentColor,BadgeIcon,ShowReviewButton FROM dbo.Notifications WHERE Id=@id");
  } catch (err) {
    if (err.number === 208) return sendJson(res, 404, { message: "Notifications table not initialized" });
    throw err;
  }
  const rec = r.recordset[0];
  if (!rec) return sendJson(res, 404, { message: "Notification not found" });
  return sendJson(res, 200, norm.notif(rec));
}

// ── user handlers ─────────────────────────────────────────────────────────────

async function handleListUsers(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const req2 = pool.request();
  const q = limit ? "SELECT TOP(@limit) Id,FirstName,LastName,Email,Username,Country,Role FROM dbo.Users ORDER BY Id"
                  : "SELECT Id,FirstName,LastName,Email,Username,Country,Role FROM dbo.Users ORDER BY Id";
  if (limit) req2.input("limit", sql.Int, limit);
  const r = await req2.query(q);
  return sendJson(res, 200, {
    users: r.recordset.map(norm.user).map((u) => ({ id: u.id, firstName: u.firstName, lastName: u.lastName, email: u.email, username: u.username })),
  });
}

async function handleUserDetail(res, id) {
  const pool = await poolPromise;
  const r = await pool.request().input("id", sql.Int, id)
    .query("SELECT TOP(1) Id,FirstName,LastName,Email,Username,Country,Role FROM dbo.Users WHERE Id=@id");
  const rec = r.recordset[0];
  if (!rec) return sendJson(res, 404, { message: "User not found" });
  return sendJson(res, 200, norm.user(rec));
}

async function handleAddUser(req, res) {
  const body = await readJsonBody(req);
  const firstName = asText(body.firstName), lastName = asText(body.lastName);
  const email = asText(body.email), username = asText(body.username), password = asText(body.password);
  const country = asText(body.country) || "", role = asText(body.role) || "Traveler";
  if (!firstName || !lastName || !email || !username || !password)
    return sendJson(res, 400, { message: "firstName, lastName, email, username, password are required" });
  const pool = await poolPromise;
  const existing = await pool.request()
    .input("username", sql.NVarChar(100), username).input("email", sql.NVarChar(255), email)
    .query("SELECT TOP(1) Id,Username,Email FROM dbo.Users WHERE Username=@username OR Email=@email");
  if (existing.recordset.length > 0) {
    const dup = existing.recordset[0];
    if ((dup.Username || "").toLowerCase() === username.toLowerCase()) return sendJson(res, 422, { message: "Username already exists" });
    return sendJson(res, 422, { message: "Email already exists" });
  }
  let result;
  try {
    result = await pool.request()
      .input("firstName", sql.NVarChar(100), firstName).input("lastName", sql.NVarChar(100), lastName)
      .input("email", sql.NVarChar(255), email).input("username", sql.NVarChar(100), username)
      .input("password", sql.NVarChar(255), password).input("country", sql.NVarChar(100), country).input("role", sql.NVarChar(50), role)
      .query("INSERT INTO dbo.Users(FirstName,LastName,Email,Username,Password,Country,Role) OUTPUT INSERTED.Id,INSERTED.FirstName,INSERTED.LastName,INSERTED.Email,INSERTED.Username,INSERTED.Country,INSERTED.Role VALUES(@firstName,@lastName,@email,@username,@password,@country,@role)");
  } catch (err) {
    const msg = (err.message || "").toLowerCase();
    if (err.number === 2601 || err.number === 2627 || msg.includes("duplicate key")) {
      if (msg.includes("email")) return sendJson(res, 422, { message: "Email already exists" });
      return sendJson(res, 422, { message: "Username already exists" });
    }
    throw err;
  }
  return sendJson(res, 201, norm.user(result.recordset[0]));
}

// ── sql setup handlers ────────────────────────────────────────────────────────

async function handleSetupSql(res, urlObj, filePath, filename) {
  const content = await fs.readFile(filePath, "utf-8");
  const dl = urlObj.searchParams.get("download") === "1" || urlObj.searchParams.get("download") === "true";
  return sendText(res, 200, content, dl ? { "Content-Disposition": `attachment; filename="${filename}"` } : {});
}

// ── main router ───────────────────────────────────────────────────────────────

async function handleRequest(req, res) {
  setCorsHeaders(res);
  if (req.method === "OPTIONS") { res.writeHead(204); res.end(); return; }

  const urlObj = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = urlObj.pathname.length > 1 ? urlObj.pathname.replace(/\/+$/, "") : urlObj.pathname;

  // Swagger
  if (req.method === "GET" && pathname === "/api/docs") {
    const forwardedProto = req.headers["x-forwarded-proto"];
    const host = req.headers.host || `localhost:${port}`;
    // Khi chạy local không có x-forwarded-proto → dùng http
    // Khi deploy Render có x-forwarded-proto: https → dùng https
    const protocol = forwardedProto ? forwardedProto.split(",")[0].trim() : "http";
    sendHtml(res, 200, buildSwaggerUiHtml(`${protocol}://${host}`));
    return;
  }
  if (req.method === "GET" && pathname === "/api/docs/swagger.json") {
    try {
      const content = await fs.readFile(swaggerJsonPath, "utf-8");
      setCorsHeaders(res); res.writeHead(200, { "Content-Type": "application/json" }); res.end(content);
    } catch (_) { sendJson(res, 404, { message: "swagger.json not found" }); }
    return;
  }

  // Meta
  if (req.method === "GET" && pathname === "/api/meta/health") { await handleHealthCheck(res); return; }
  if (req.method === "GET" && pathname === "/api/meta/routes") { handleGetApiRoutes(res); return; }

  // SQL Setup
  if (req.method === "GET" && pathname === "/api/setup/sql/auth")         { await handleSetupSql(res, urlObj, authSqlSetupPath, "fellow4udb_auth_login.sql"); return; }
  if (req.method === "GET" && pathname === "/api/setup/sql/notifications") { await handleSetupSql(res, urlObj, notificationsSqlSetupPath, "fellow4udb_notifications_api.sql"); return; }
  if (req.method === "GET" && pathname === "/api/setup/sql")               { await handleSetupSql(res, urlObj, sqlSetupPath, "fellow4udb_setup.sql"); return; }

  // Auth
  if (req.method === "POST" && (pathname === "/api/auth/login"    || pathname === "/auth/login"))    { await handleLogin(req, res); return; }
  if (req.method === "POST" && (pathname === "/api/auth/register" || pathname === "/auth/register")) { await handleRegister(req, res); return; }

  // Users — GET list và add cần auth
  if (req.method === "GET"  && (pathname === "/api/users" || pathname === "/users")) {
    if (!requireAuth(req, res)) return;
    await handleListUsers(res, urlObj); return;
  }
  if (req.method === "POST" && (pathname === "/api/users/add" || pathname === "/users/add")) {
    if (!requireAuth(req, res)) return;
    await handleAddUser(req, res); return;
  }
  const userRoute = parseEntityPath(pathname, "/api/users");
  if (req.method === "GET" && userRoute.matches && userRoute.id !== null) {
    if (!requireAuth(req, res)) return;
    if (Number.isNaN(userRoute.id)) { sendJson(res, 400, { message: "Invalid user id" }); return; }
    await handleUserDetail(res, userRoute.id); return;
  }

  // TopJourneys — GET public, write cần auth
  const jRoute = parseEntityPath(pathname, "/api/TopJourneys");
  if (jRoute.matches) {
    if (jRoute.id !== null && Number.isNaN(jRoute.id)) { sendJson(res, 400, { message: "Invalid journey id" }); return; }
    if (req.method === "GET"    && jRoute.id === null)  { await handleListJourneys(res, urlObj); return; }
    if (req.method === "GET"    && jRoute.id !== null)  { await handleJourneyDetail(res, jRoute.id); return; }
    if (req.method === "POST"   && jRoute.id === null)  { if (!requireAuth(req, res)) return; await handleCreateJourney(req, res); return; }
    if (req.method === "PUT"    && jRoute.id !== null)  { if (!requireAuth(req, res)) return; await handleUpdateJourney(req, res, jRoute.id, false); return; }
    if (req.method === "PATCH"  && jRoute.id !== null)  { if (!requireAuth(req, res)) return; await handleUpdateJourney(req, res, jRoute.id, true); return; }
    if (req.method === "DELETE" && jRoute.id !== null)  { if (!requireAuth(req, res)) return; await handleDeleteJourney(res, jRoute.id); return; }
  }

  // BestGuides
  const gRoute = parseEntityPath(pathname, "/api/BestGuides");
  if (gRoute.matches) {
    if (gRoute.id !== null && Number.isNaN(gRoute.id)) { sendJson(res, 400, { message: "Invalid guide id" }); return; }
    if (req.method === "GET" && gRoute.id === null) { await handleListGuides(res, urlObj); return; }
    if (req.method === "GET" && gRoute.id !== null) { await handleGuideDetail(res, gRoute.id); return; }
  }

  // TopExperiences
  const eRoute = parseEntityPath(pathname, "/api/TopExperiences");
  if (eRoute.matches) {
    if (eRoute.id !== null && Number.isNaN(eRoute.id)) { sendJson(res, 400, { message: "Invalid experience id" }); return; }
    if (req.method === "GET" && eRoute.id === null) { await handleListExperiences(res, urlObj); return; }
    if (req.method === "GET" && eRoute.id !== null) { await handleExperienceDetail(res, eRoute.id); return; }
  }

  // Notifications
  const nRoute = parseEntityPath(pathname, "/api/notifications");
  if (nRoute.matches) {
    if (nRoute.id !== null && Number.isNaN(nRoute.id)) { sendJson(res, 400, { message: "Invalid notification id" }); return; }
    if (req.method === "GET" && nRoute.id === null) { await handleListNotifications(res, urlObj); return; }
    if (req.method === "GET" && nRoute.id !== null) { await handleNotificationDetail(res, nRoute.id); return; }
  }

  // Root + HEAD (UptimeRobot health check)
  if (pathname === "/") {
    if (req.method === "HEAD") {
      res.writeHead(200);
      res.end();
      return;
    }
    if (req.method === "GET") {
      return sendJson(res, 200, { message: "Fellow4U API running", swagger: "/api/docs", health: "/api/meta/health" });
    }
  }

  sendJson(res, 404, { message: "Route not found", path: pathname });
}

// ── server ────────────────────────────────────────────────────────────────────

const server = http.createServer(async (req, res) => {
  try { await handleRequest(req, res); }
  catch (error) {
    console.error("API error:", error);
    sendJson(res, error.statusCode || 500, { message: error.message || "Internal server error" });
  }
});

server.listen(port, () => {
  console.log(`Fellow4U API running at http://localhost:${port}`);
  console.log(`Swagger UI:  http://localhost:${port}/api/docs`);
  console.log(`Health:      http://localhost:${port}/api/meta/health`);
  console.log(`Routes:      http://localhost:${port}/api/meta/routes`);
});
