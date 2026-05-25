const http = require("http");
const fs = require("fs/promises");
const path = require("path");
const { URL } = require("url");

const { poolPromise, sql } = require("./db");

const port = Number(process.env.PORT || 3000);

const databaseName =
  process.env.SQL_DATABASE || "Fellow4UDB";

const swaggerJsonPath =
  path.join(__dirname, "swagger.json");

// ─────────────────────────────────────────────

function setCorsHeaders(res) {

  res.setHeader(
    "Access-Control-Allow-Origin",
    "*"
  );

  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, PATCH, DELETE, OPTIONS"
  );

  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization"
  );

}

function sendJson(
  res,
  statusCode,
  payload
) {

  setCorsHeaders(res);

  res.writeHead(statusCode, {
    "Content-Type": "application/json"
  });

  res.end(
    JSON.stringify(payload)
  );

}

function sendHtml(
  res,
  statusCode,
  content
) {

  setCorsHeaders(res);

  res.writeHead(statusCode, {
    "Content-Type":
      "text/html; charset=utf-8"
  });

  res.end(content);

}

// ─────────────────────────────────────────────

function buildSwaggerUiHtml(baseUrl) {

  return `
<!DOCTYPE html>
<html lang="vi">

<head>

  <meta charset="UTF-8" />

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  />

  <title>Fellow4U API Docs</title>

  <link
    rel="stylesheet"
    href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css"
  />

  <style>

    body {
      margin: 0;
      background: #fafafa;
    }

    .topbar {
      display: none !important;
    }

  </style>

</head>

<body>

  <div id="swagger-ui"></div>

  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>

  <script>

    window.onload = () => {

      SwaggerUIBundle({

        url:
          "${baseUrl}/api/docs/swagger.json",

        dom_id: "#swagger-ui",

        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIBundle.SwaggerUIStandalonePreset
        ],

        layout: "BaseLayout",

        deepLinking: true,

        tryItOutEnabled: true

      });

    };

  </script>

</body>
</html>
`;

}

// ─────────────────────────────────────────────

async function readJsonBody(req) {

  const chunks = [];

  for await (const chunk of req) {
    chunks.push(chunk);
  }

  const raw = Buffer
    .concat(chunks)
    .toString("utf-8")
    .trim();

  if (!raw) {
    return {};
  }

  try {

    return JSON.parse(raw);

  } catch {

    const err = new Error(
      "Invalid JSON body"
    );

    err.statusCode = 400;

    throw err;

  }

}

function createToken(username) {

  return Buffer.from(
    `${username}-${Date.now()}`
  ).toString("base64url");

}

// ─────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────

async function handleLogin(req, res) {

  const body =
    await readJsonBody(req);

  const identity =
    body.username ||
    body.email;

  const password =
    body.password;

  if (!identity || !password) {

    return sendJson(res, 400, {
      message:
        "username/email and password are required"
    });

  }

  const pool =
    await poolPromise;

  const result =
    await pool.request()

      .input(
        "identity",
        sql.NVarChar(255),
        identity
      )

      .input(
        "password",
        sql.NVarChar(255),
        password
      )

      .query(`
        SELECT TOP (1)
          Id,
          Username,
          Email,
          FirstName,
          LastName
        FROM dbo.Users
        WHERE
          (
            Username = @identity
            OR Email = @identity
          )
          AND Password = @password
      `);

  const user =
    result.recordset[0];

  if (!user) {

    return sendJson(res, 401, {
      message: "Invalid credentials"
    });

  }

  return sendJson(res, 200, {

    message:
      "Login successful.",

    accessToken:
      createToken(user.Username),

    refreshToken:
      createToken(
        `${user.Username}-refresh`
      ),

    user: {

      id:
        user.Id,

      username:
        user.Username,

      email:
        user.Email,

      firstName:
        user.FirstName,

      lastName:
        user.LastName,

      fullName:
        `${user.FirstName} ${user.LastName}`.trim()

    }

  });

}

// ─────────────────────────────────────────────
// REGISTER
// ─────────────────────────────────────────────

async function handleRegister(req, res) {

  const body =
    await readJsonBody(req);

  const firstName =
    body.firstName;

  const lastName =
    body.lastName;

  const email =
    body.email;

  const username =
    body.username;

  const password =
    body.password;

  const country =
    body.country;

  const role =
    body.role || "Traveler";

  if (
    !firstName ||
    !lastName ||
    !email ||
    !username ||
    !password
  ) {

    return sendJson(res, 400, {
      message:
        "Missing required fields"
    });

  }

  const pool =
    await poolPromise;

  const existingUser =
    await pool.request()

      .input(
        "email",
        sql.NVarChar(255),
        email
      )

      .input(
        "username",
        sql.NVarChar(255),
        username
      )

      .query(`
        SELECT TOP (1) *
        FROM dbo.Users
        WHERE
          Email = @email
          OR Username = @username
      `);

  if (
    existingUser.recordset.length > 0
  ) {

    return sendJson(res, 409, {
      message:
        "Email or username already exists"
    });

  }

  await pool.request()

    .input(
      "firstName",
      sql.NVarChar(255),
      firstName
    )

    .input(
      "lastName",
      sql.NVarChar(255),
      lastName
    )

    .input(
      "email",
      sql.NVarChar(255),
      email
    )

    .input(
      "username",
      sql.NVarChar(255),
      username
    )

    .input(
      "password",
      sql.NVarChar(255),
      password
    )

    .input(
      "country",
      sql.NVarChar(255),
      country
    )

    .input(
      "role",
      sql.NVarChar(100),
      role
    )

    .query(`
      INSERT INTO dbo.Users
      (
        FirstName,
        LastName,
        Email,
        Username,
        Password,
        Country,
        Role
      )
      VALUES
      (
        @firstName,
        @lastName,
        @email,
        @username,
        @password,
        @country,
        @role
      )
    `);

  return sendJson(res, 201, {

    message:
      "Register successful"

  });

}

// ─────────────────────────────────────────────

async function handleHealthCheck(res) {

  const pool =
    await poolPromise;

  await pool.request()
    .query("SELECT 1 AS Ok");

  return sendJson(res, 200, {

    status: "ok",

    database:
      databaseName,

    time:
      new Date().toISOString()

  });

}

// ─────────────────────────────────────────────

async function handleRequest(req, res) {

  setCorsHeaders(res);

  if (req.method === "OPTIONS") {

    res.writeHead(204);

    res.end();

    return;

  }

  const urlObj = new URL(
    req.url,
    `http://${req.headers.host || "localhost"}`
  );

  const pathname =
    urlObj.pathname.length > 1
      ? urlObj.pathname.replace(/\/+$/, "")
      : urlObj.pathname;

  // SWAGGER UI

  if (
    req.method === "GET" &&
    pathname === "/api/docs"
  ) {

    const protocol =
      req.headers["x-forwarded-proto"]
      || "https";

    const baseUrl =
      `${protocol}://${req.headers.host}`;

    sendHtml(
      res,
      200,
      buildSwaggerUiHtml(baseUrl)
    );

    return;

  }

  // SWAGGER JSON

  if (
    req.method === "GET" &&
    pathname === "/api/docs/swagger.json"
  ) {

    try {

      const content =
        await fs.readFile(
          swaggerJsonPath,
          "utf-8"
        );

      setCorsHeaders(res);

      res.writeHead(200, {
        "Content-Type":
          "application/json"
      });

      res.end(content);

    } catch {

      sendJson(res, 404, {
        message:
          "swagger.json not found"
      });

    }

    return;

  }

  // HEALTH

  if (
    pathname === "/api/meta/health"
  ) {

    if (req.method === "HEAD") {

      res.writeHead(200);

      res.end();

      return;

    }

    if (req.method === "GET") {

      await handleHealthCheck(res);

      return;

    }

  }

  // REGISTER

  if (
    req.method === "POST" &&
    (
      pathname === "/api/auth/register"
      ||
      pathname === "/auth/register"
    )
  ) {

    await handleRegister(req, res);

    return;

  }

  // LOGIN

  if (
    req.method === "POST" &&
    (
      pathname === "/api/auth/login"
      ||
      pathname === "/auth/login"
    )
  ) {

    await handleLogin(req, res);

    return;

  }

  // ROOT

  if (
    req.method === "GET" &&
    pathname === "/"
  ) {

    return sendJson(res, 200, {

      message:
        "Fellow4U API running",

      swagger:
        "/api/docs",

      health:
        "/api/meta/health"

    });

  }

  // 404

  sendJson(res, 404, {

    message:
      "Route not found",

    path:
      pathname

  });

}

// ─────────────────────────────────────────────

const server =
  http.createServer(
    async (req, res) => {

      try {

        await handleRequest(
          req,
          res
        );

      } catch (error) {

        console.error(error);

        sendJson(
          res,
          error.statusCode || 500,
          {
            message:
              error.message
              || "Internal server error"
          }
        );

      }

    }
  );

// ─────────────────────────────────────────────

server.listen(port, () => {

  console.log(
    `Server running on port ${port}`
  );

  console.log(
    `Swagger: http://localhost:${port}/api/docs`
  );

});
