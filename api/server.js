const http = require("http");
const fs = require("fs/promises");
const path = require("path");
const { URL } = require("url");

const { poolPromise, sql } = require("./db");

const port = Number(process.env.PORT || 3000);
const databaseName = process.env.SQL_DATABASE || "Fellow4UDB";
const sqlSetupPath = path.join(__dirname, "sql", "fellow4udb_setup.sql");
const authSqlSetupPath = path.join(__dirname, "sql", "fellow4udb_auth_login.sql");
const notificationsSqlSetupPath = path.join(__dirname, "sql", "fellow4udb_notifications_api.sql");
const swaggerJsonPath = path.join(__dirname, "swagger.json");

const apiRoutes = [
  { method: "GET",    path: "/api/docs",                    description: "Swagger UI — interactive API documentation." },
  { method: "GET",    path: "/api/docs/swagger.json",       description: "OpenAPI 3.0 spec (JSON)." },
  { method: "GET",    path: "/api/meta/routes",             description: "List supported API routes." },
  { method: "GET",    path: "/api/meta/health",             description: "Check API and SQL Server readiness." },
  { method: "GET",    path: "/api/setup/sql",               description: "Read the SQL setup script for Fellow4UDB." },
  { method: "GET",    path: "/api/setup/sql/auth",          description: "Read the SQL auth/login setup script." },
  { method: "GET",    path: "/api/setup/sql/notifications", description: "Read the SQL notifications API setup script." },
  { method: "GET",    path: "/api/TopJourneys",             description: "List top journeys from SQL Server." },
  { method: "GET",    path: "/api/TopJourneys/{id}",        description: "Get a journey by id." },
  { method: "POST",   path: "/api/TopJourneys",             description: "Create a new journey." },
  { method: "PUT",    path: "/api/TopJourneys/{id}",        description: "Replace a journey." },
  { method: "PATCH",  path: "/api/TopJourneys/{id}",        description: "Partially update a journey." },
  { method: "DELETE", path: "/api/TopJourneys/{id}",        description: "Delete a journey." },
  { method: "GET",    path: "/api/BestGuides",              description: "List best guides from SQL Server." },
  { method: "GET",    path: "/api/BestGuides/{id}",         description: "Get a guide by id." },
  { method: "GET",    path: "/api/TopExperiences",          description: "List top experiences from SQL Server." },
  { method: "GET",    path: "/api/TopExperiences/{id}",     description: "Get an experience by id." },
  { method: "GET",    path: "/api/notifications",           description: "List notifications from SQL Server." },
  { method: "GET",    path: "/api/notifications/{id}",      description: "Get a notification by id from SQL Server." },
  { method: "POST",   path: "/api/auth/login",              description: "Authenticate a user from dbo.Users." },
  { method: "POST",   path: "/api/auth/register",           description: "Create a user in dbo.Users." },
  { method: "GET",    path: "/api/users",                   description: "List users from dbo.Users." },
  { method: "GET",    path: "/api/users/{id}",              description: "Get a user by id." },
  { method: "POST",   path: "/api/users/add",               description: "Add a user to dbo.Users." },
];

// ─── helpers ────────────────────────────────────────────────────────────────

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
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Fellow4U API Docs</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  <style>
    body { margin: 0; }
    .topbar { display: none !important; }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script>
    SwaggerUIBundle({
      url: "${baseUrl}/api/docs/swagger.json",
      dom_id: "#swagger-ui",
      presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
      layout: "BaseLayout",
      deepLinking: true,
      tryItOutEnabled: true,
    });
  </script>
</body>
</html>`;
}

async function readJsonBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString("utf-8").trim();
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch (_) {
    const error = new Error("Invalid JSON body.");
    error.statusCode = 400;
    throw error;
  }
}

function createToken(username) {
  const raw = `${username}-${Date.now()}`;
  return Buffer.from(raw).toString("base64url");
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
  const value = Number(raw);
  if (!Number.isInteger(value) || value <= 0) return null;
  return value;
}

// ─── normalizers ────────────────────────────────────────────────────────────

function normalizeJourney(r) {
  return { id: r.Id, userId: r.UserId, title: r.Title, body: r.Body };
}

function normalizeGuide(r) {
  return { id: r.Id, name: r.Name, email: r.Email, city: r.City, phone: r.Phone, address: { city: r.City } };
}

function normalizeExperience(r) {
  return { id: r.Id, userId: r.UserId, title: r.Title };
}

function normalizeUser(r) {
  return { id: r.Id, firstName: r.FirstName, lastName: r.LastName, email: r.Email, username: r.Username, country: r.Country, role: r.Role };
}

function normalizeNotification(r) {
  return { id: r.Id, actorName: r.ActorName, actorAvatar: r.ActorAvatar, message: r.Message, date: r.EventDate, accentColor: r.AccentColor, badgeIcon: r.BadgeIcon, showReviewButton: Boolean(r.ShowReviewButton) };
}

// ─── validators ─────────────────────────────────────────────────────────────

function asRequiredText(value) {
  if (typeof value !== "string") return null;
  const t = value.trim();
  return t || null;
}

function asOptionalText(value) {
  if (typeof value !== "string") return null;
  const t = value.trim();
  return t || null;
}

function asRequiredInt(value) {
  const parsed = Number(value);
  return Number.isInteger(parsed) ? parsed : null;
}

// ─── handlers ───────────────────────────────────────────────────────────────

async function handleLogin(req, res) {
  const body = await readJsonBody(req);
  const username = asRequiredText(body.username);
  const email = asRequiredText(body.email);
  const password = asRequiredText(body.password);
  const identity = username || email;

  if (!identity || !password) {
    return sendJson(res, 400, { message: "username/email and password are required" });
  }

  const pool = await poolPromise;
  const result = await pool.request()
    .input("identity", sql.NVarChar(255), identity)
    .input("password", sql.NVarChar(255), password)
    .query(`
      SELECT TOP (1) Id, Username, Email, FirstName, LastName
      FROM dbo.Users
      WHERE (Username = @identity OR Email = @identity) AND Password = @password
    `);

  const user = result.recordset[0];
  if (!user) return sendJson(res, 401, { message: "Invalid credentials" });

  return sendJson(res, 200, {
    message: "Login successful.",
    accessToken: createToken(user.Username),
    refreshToken: createToken(`${user.Username}-refresh`),
    id: user.Id,
    username: user.Username,
    email: user.Email,
    firstName: user.FirstName,
    lastName: user.LastName,
    fullName: `${user.FirstName} ${user.LastName}`.trim(),
  });
}

async function handleGetUsers(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const request = pool.request();
  const query = limit
    ? `SELECT TOP (@limit) Id,FirstName,LastName,Email,Username,Country,Role FROM dbo.Users ORDER BY Id`
    : `SELECT Id,FirstName,LastName,Email,Username,Country,Role FROM dbo.Users ORDER BY Id`;
  if (limit) request.input("limit", sql.Int, limit);
  const result = await request.query(query);
  return sendJson(res, 200, {
    users: result.recordset.map(normalizeUser).map((u) => ({
      id: u.id, firstName: u.firstName, lastName: u.lastName, email: u.email, username: u.username,
    })),
  });
}

async function handleGetUserDetail(res, id) {
  const pool = await poolPromise;
  const result = await pool.request()
    .input("id", sql.Int, id)
    .query(`SELECT TOP (1) Id,FirstName,LastName,Email,Username,Country,Role FROM dbo.Users WHERE Id = @id`);
  const record = result.recordset[0];
  if (!record) return sendJson(res, 404, { message: "User not found" });
  return sendJson(res, 200, normalizeUser(record));
}

function handleGetApiRoutes(res) {
  return sendJson(res, 200, {
    name: "Fellow4U Local API",
    database: databaseName,
    swaggerUi: "/api/docs",
    sqlSetupPath: "/api/setup/sql",
    endpoints: apiRoutes,
  });
}

async function handleHealthCheck(res) {
  const pool = await poolPromise;
  await pool.request().query("SELECT 1 AS Ok");
  return sendJson(res, 200, { status: "ok", database: databaseName, time: new Date().toISOString() });
}

async function handleGetSetupSql(res, urlObj) {
  const content = await fs.readFile(sqlSetupPath, "utf-8");
  const dl = urlObj.searchParams.get("download") === "1" || urlObj.searchParams.get("download") === "true";
  return sendText(res, 200, content, dl ? { "Content-Disposition": 'attachment; filename="fellow4udb_setup.sql"' } : {});
}

async function handleGetAuthSetupSql(res, urlObj) {
  const content = await fs.readFile(authSqlSetupPath, "utf-8");
  const dl = urlObj.searchParams.get("download") === "1" || urlObj.searchParams.get("download") === "true";
  return sendText(res, 200, content, dl ? { "Content-Disposition": 'attachment; filename="fellow4udb_auth_login.sql"' } : {});
}

async function handleGetNotificationsSetupSql(res, urlObj) {
  const content = await fs.readFile(notificationsSqlSetupPath, "utf-8");
  const dl = urlObj.searchParams.get("download") === "1" || urlObj.searchParams.get("download") === "true";
  return sendText(res, 200, content, dl ? { "Content-Disposition": 'attachment; filename="fellow4udb_notifications_api.sql"' } : {});
}

async function handleAddUser(req, res) {
  const body = await readJsonBody(req);
  const firstName = asRequiredText(body.firstName);
  const lastName  = asRequiredText(body.lastName);
  const email     = asRequiredText(body.email);
  const username  = asRequiredText(body.username);
  const password  = asRequiredText(body.password);
  const country   = asOptionalText(body.country) || "";
  const role      = asOptionalText(body.role) || "Traveler";

  if (!firstName || !lastName || !email || !username || !password) {
    return sendJson(res, 400, { message: "firstName, lastName, email, username, password are required" });
  }

  const pool = await poolPromise;
  const existing = await pool.request()
    .input("username", sql.NVarChar(100), username)
    .input("email", sql.NVarChar(255), email)
    .query(`SELECT TOP (1) Id, Username, Email FROM dbo.Users WHERE Username = @username OR Email = @email`);

  if (existing.recordset.length > 0) {
    const dup = existing.recordset[0];
    if ((dup.Username || "").toLowerCase() === username.toLowerCase()) {
      return sendJson(res, 422, { message: "Username already exists" });
    }
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
      .query(`
        INSERT INTO dbo.Users (FirstName,LastName,Email,Username,Password,Country,Role)
        OUTPUT INSERTED.Id,INSERTED.FirstName,INSERTED.LastName,INSERTED.Email,INSERTED.Username,INSERTED.Country,INSERTED.Role
        VALUES (@firstName,@lastName,@email,@username,@password,@country,@role)
      `);
  } catch (error) {
    const msg = (error.message || "").toLowerCase();
    if (error.number === 2601 || error.number === 2627 || msg.includes("duplicate key")) {
      if (msg.includes("ux_users_email") || msg.includes("(email")) return sendJson(res, 422, { message: "Email already exists" });
      if (msg.includes("ux_users_username") || msg.includes("(username")) return sendJson(res, 422, { message: "Username already exists" });
      return sendJson(res, 422, { message: "Username or email already exists" });
    }
    throw error;
  }

  return sendJson(res, 201, normalizeUser(result.recordset[0]));
}

async function handleListJourneys(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const request = pool.request();
  const query = limit
    ? `SELECT TOP (@limit) Id,UserId,Title,Body FROM dbo.TopJourneys ORDER BY Id`
    : `SELECT Id,UserId,Title,Body FROM dbo.TopJourneys ORDER BY Id`;
  if (limit) request.input("limit", sql.Int, limit);
  const result = await request.query(query);
  return sendJson(res, 200, result.recordset.map(normalizeJourney));
}

async function handleJourneyDetail(res, id) {
  const pool = await poolPromise;
  const result = await pool.request()
    .input("id", sql.Int, id)
    .query(`SELECT TOP (1) Id,UserId,Title,Body FROM dbo.TopJourneys WHERE Id = @id`);
  const record = result.recordset[0];
  if (!record) return sendJson(res, 404, { message: "Journey not found" });
  return sendJson(res, 200, normalizeJourney(record));
}

async function handleCreateJourney(req, res) {
  const body = await readJsonBody(req);
  const userId = asRequiredInt(body.userId);
  const title  = asRequiredText(body.title);
  const desc   = asRequiredText(body.body);
  if (userId === null || !title || !desc) {
    return sendJson(res, 400, { message: "userId, title, body are required" });
  }
  const pool = await poolPromise;
  const result = await pool.request()
    .input("userId", sql.Int, userId)
    .input("title",  sql.NVarChar(255), title)
    .input("body",   sql.NVarChar(sql.MAX), desc)
    .query(`INSERT INTO dbo.TopJourneys (UserId,Title,Body) OUTPUT INSERTED.Id,INSERTED.UserId,INSERTED.Title,INSERTED.Body VALUES (@userId,@title,@body)`);
  return sendJson(res, 201, normalizeJourney(result.recordset[0]));
}

async function handleUpdateJourney(req, res, id, partial) {
  const body = await readJsonBody(req);
  if (!partial) {
    const userId = asRequiredInt(body.userId);
    const title  = asRequiredText(body.title);
    const desc   = asRequiredText(body.body);
    if (userId === null || !title || !desc) return sendJson(res, 400, { message: "userId, title, body are required" });
    const pool = await poolPromise;
    const result = await pool.request()
      .input("id", sql.Int, id).input("userId", sql.Int, userId)
      .input("title", sql.NVarChar(255), title).input("body", sql.NVarChar(sql.MAX), desc)
      .query(`UPDATE dbo.TopJourneys SET UserId=@userId,Title=@title,Body=@body OUTPUT INSERTED.Id,INSERTED.UserId,INSERTED.Title,INSERTED.Body WHERE Id=@id`);
    const record = result.recordset[0];
    if (!record) return sendJson(res, 404, { message: "Journey not found" });
    return sendJson(res, 200, normalizeJourney(record));
  }

  const hasUserId = Object.prototype.hasOwnProperty.call(body, "userId");
  const hasTitle  = Object.prototype.hasOwnProperty.call(body, "title");
  const hasBody   = Object.prototype.hasOwnProperty.call(body, "body");
  if (!hasUserId && !hasTitle && !hasBody) return sendJson(res, 400, { message: "At least one of userId, title, body is required" });

  const userId = hasUserId ? asRequiredInt(body.userId) : null;
  const title  = hasTitle  ? asRequiredText(body.title) : null;
  const desc   = hasBody   ? asRequiredText(body.body)  : null;
  if ((hasUserId && userId === null) || (hasTitle && !title) || (hasBody && !desc)) {
    return sendJson(res, 400, { message: "Invalid update payload" });
  }

  const pool = await poolPromise;
  const result = await pool.request()
    .input("id", sql.Int, id).input("userId", sql.Int, userId)
    .input("title", sql.NVarChar(255), title).input("body", sql.NVarChar(sql.MAX), desc)
    .query(`UPDATE dbo.TopJourneys SET UserId=COALESCE(@userId,UserId),Title=COALESCE(@title,Title),Body=COALESCE(@body,Body) OUTPUT INSERTED.Id,INSERTED.UserId,INSERTED.Title,INSERTED.Body WHERE Id=@id`);
  const record = result.recordset[0];
  if (!record) return sendJson(res, 404, { message: "Journey not found" });
  return sendJson(res, 200, normalizeJourney(record));
}

async function handleDeleteJourney(res, id) {
  const pool = await poolPromise;
  const result = await pool.request()
    .input("id", sql.Int, id)
    .query(`DELETE FROM dbo.TopJourneys OUTPUT DELETED.Id WHERE Id=@id`);
  if (result.recordset.length === 0) return sendJson(res, 404, { message: "Journey not found" });
  return sendJson(res, 200, { message: "Deleted post successfully." });
}

async function handleListGuides(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const request = pool.request();
  const query = limit
    ? `SELECT TOP (@limit) Id,Name,Email,City,Phone FROM dbo.BestGuides ORDER BY Id`
    : `SELECT Id,Name,Email,City,Phone FROM dbo.BestGuides ORDER BY Id`;
  if (limit) request.input("limit", sql.Int, limit);
  const result = await request.query(query);
  return sendJson(res, 200, result.recordset.map(normalizeGuide));
}

async function handleGuideDetail(res, id) {
  const pool = await poolPromise;
  const result = await pool.request()
    .input("id", sql.Int, id)
    .query(`SELECT TOP (1) Id,Name,Email,City,Phone FROM dbo.BestGuides WHERE Id=@id`);
  const record = result.recordset[0];
  if (!record) return sendJson(res, 404, { message: "Guide not found" });
  return sendJson(res, 200, normalizeGuide(record));
}

async function handleListExperiences(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const request = pool.request();
  const query = limit
    ? `SELECT TOP (@limit) Id,UserId,Title FROM dbo.TopExperiences ORDER BY Id`
    : `SELECT Id,UserId,Title FROM dbo.TopExperiences ORDER BY Id`;
  if (limit) request.input("limit", sql.Int, limit);
  const result = await request.query(query);
  return sendJson(res, 200, result.recordset.map(normalizeExperience));
}

async function handleExperienceDetail(res, id) {
  const pool = await poolPromise;
  const result = await pool.request()
    .input("id", sql.Int, id)
    .query(`SELECT TOP (1) Id,UserId,Title FROM dbo.TopExperiences WHERE Id=@id`);
  const record = result.recordset[0];
  if (!record) return sendJson(res, 404, { message: "Experience not found" });
  return sendJson(res, 200, normalizeExperience(record));
}

async function handleListNotifications(res, urlObj) {
  const limit = parseLimit(urlObj);
  const pool = await poolPromise;
  const request = pool.request();
  const query = limit
    ? `SELECT TOP (@limit) Id,ActorName,ActorAvatar,Message,EventDate,AccentColor,BadgeIcon,ShowReviewButton FROM dbo.Notifications ORDER BY Id DESC`
    : `SELECT Id,ActorName,ActorAvatar,Message,EventDate,AccentColor,BadgeIcon,ShowReviewButton FROM dbo.Notifications ORDER BY Id DESC`;
  if (limit) request.input("limit", sql.Int, limit);
  try {
    const result = await request.query(query);
    return sendJson(res, 200, result.recordset.map(normalizeNotification));
  } catch (error) {
    if (error.number === 208) return sendJson(res, 200, []);
    throw error;
  }
}

async function handleNotificationDetail(res, id) {
  const pool = await poolPromise;
  let result;
  try {
    result = await pool.request()
      .input("id", sql.Int, id)
      .query(`SELECT TOP (1) Id,ActorName,ActorAvatar,Message,EventDate,AccentColor,BadgeIcon,ShowReviewButton FROM dbo.Notifications WHERE Id=@id`);
  } catch (error) {
    if (error.number === 208) return sendJson(res, 404, { message: "Notifications table not initialized" });
    throw error;
  }
  const record = result.recordset[0];
  if (!record) return sendJson(res, 404, { message: "Notification not found" });
  return sendJson(res, 200, normalizeNotification(record));
}

// ─── main router ────────────────────────────────────────────────────────────

async function handleRequest(req, res) {
  setCorsHeaders(res);

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  const urlObj = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = urlObj.pathname.length > 1
    ? urlObj.pathname.replace(/\/+$/, "")
    : urlObj.pathname;

  // ── Swagger UI ──────────────────────────────────────────────────────────
  if (req.method === "GET" && pathname === "/api/docs") {
    const baseUrl = `http://${req.headers.host || `localhost:${port}`}`;
    sendHtml(res, 200, buildSwaggerUiHtml(baseUrl));
    return;
  }

  if (req.method === "GET" && pathname === "/api/docs/swagger.json") {
    try {
      const content = await fs.readFile(swaggerJsonPath, "utf-8");
      setCorsHeaders(res);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(content);
    } catch (_) {
      sendJson(res, 404, { message: "swagger.json not found" });
    }
    return;
  }

  // ── Meta ────────────────────────────────────────────────────────────────
  if (req.method === "GET" && pathname === "/api/meta/routes") { handleGetApiRoutes(res); return; }
  if (req.method === "GET" && pathname === "/api/meta/health") { await handleHealthCheck(res); return; }

  // ── SQL Setup ───────────────────────────────────────────────────────────
  if (req.method === "GET" && pathname === "/api/setup/sql/auth")          { await handleGetAuthSetupSql(res, urlObj); return; }
  if (req.method === "GET" && pathname === "/api/setup/sql/notifications")  { await handleGetNotificationsSetupSql(res, urlObj); return; }
  if (req.method === "GET" && pathname === "/api/setup/sql")                { await handleGetSetupSql(res, urlObj); return; }

  // ── Auth ────────────────────────────────────────────────────────────────
  if (req.method === "POST" && (pathname === "/api/auth/login" || pathname === "/auth/login")) {
    await handleLogin(req, res); return;
  }
  if (req.method === "POST" && (pathname === "/api/auth/register" || pathname === "/auth/register")) {
    await handleAddUser(req, res); return;
  }

  // ── Users ───────────────────────────────────────────────────────────────
  if (req.method === "GET"  && (pathname === "/api/users" || pathname === "/users")) { await handleGetUsers(res, urlObj); return; }
  if (req.method === "POST" && (pathname === "/api/users/add" || pathname === "/users/add")) { await handleAddUser(req, res); return; }

  const userRoute = parseEntityPath(pathname, "/api/users");
  if (req.method === "GET" && userRoute.matches && userRoute.id !== null) {
    if (Number.isNaN(userRoute.id)) { sendJson(res, 400, { message: "Invalid user id" }); return; }
    await handleGetUserDetail(res, userRoute.id); return;
  }

  // ── TopJourneys ─────────────────────────────────────────────────────────
  const journeyRoute = parseEntityPath(pathname, "/api/TopJourneys");
  if (journeyRoute.matches) {
    if (journeyRoute.id !== null && Number.isNaN(journeyRoute.id)) { sendJson(res, 400, { message: "Invalid journey id" }); return; }
    if (req.method === "GET"    && journeyRoute.id === null)  { await handleListJourneys(res, urlObj); return; }
    if (req.method === "GET"    && journeyRoute.id !== null)  { await handleJourneyDetail(res, journeyRoute.id); return; }
    if (req.method === "POST"   && journeyRoute.id === null)  { await handleCreateJourney(req, res); return; }
    if (req.method === "PUT"    && journeyRoute.id !== null)  { await handleUpdateJourney(req, res, journeyRoute.id, false); return; }
    if (req.method === "PATCH"  && journeyRoute.id !== null)  { await handleUpdateJourney(req, res, journeyRoute.id, true); return; }
    if (req.method === "DELETE" && journeyRoute.id !== null)  { await handleDeleteJourney(res, journeyRoute.id); return; }
  }

  // ── BestGuides ──────────────────────────────────────────────────────────
  const guideRoute = parseEntityPath(pathname, "/api/BestGuides");
  if (guideRoute.matches) {
    if (guideRoute.id !== null && Number.isNaN(guideRoute.id)) { sendJson(res, 400, { message: "Invalid guide id" }); return; }
    if (req.method === "GET" && guideRoute.id === null)  { await handleListGuides(res, urlObj); return; }
    if (req.method === "GET" && guideRoute.id !== null)  { await handleGuideDetail(res, guideRoute.id); return; }
  }

  // ── TopExperiences ──────────────────────────────────────────────────────
  const expRoute = parseEntityPath(pathname, "/api/TopExperiences");
  if (expRoute.matches) {
    if (expRoute.id !== null && Number.isNaN(expRoute.id)) { sendJson(res, 400, { message: "Invalid experience id" }); return; }
    if (req.method === "GET" && expRoute.id === null)  { await handleListExperiences(res, urlObj); return; }
    if (req.method === "GET" && expRoute.id !== null)  { await handleExperienceDetail(res, expRoute.id); return; }
  }

  // ── Notifications ───────────────────────────────────────────────────────
  const notifRoute = parseEntityPath(pathname, "/api/notifications");
  if (notifRoute.matches) {
    if (notifRoute.id !== null && Number.isNaN(notifRoute.id)) { sendJson(res, 400, { message: "Invalid notification id" }); return; }
    if (req.method === "GET" && notifRoute.id === null)  { await handleListNotifications(res, urlObj); return; }
    if (req.method === "GET" && notifRoute.id !== null)  { await handleNotificationDetail(res, notifRoute.id); return; }
  }

  sendJson(res, 404, { message: "Route not found", path: pathname });
}

// ─── server ──────────────────────────────────────────────────────────────────

const server = http.createServer(async (req, res) => {
  try {
    await handleRequest(req, res);
  } catch (error) {
    console.error("API error:", error);
    sendJson(res, error.statusCode || 500, { message: error.message || "Internal server error" });
  }
});

server.listen(port, () => {
  console.log(`Local API running at http://localhost:${port}`);
  console.log(`Swagger UI:         http://localhost:${port}/api/docs`);
});
