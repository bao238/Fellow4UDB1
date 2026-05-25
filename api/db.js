const sql = require("mssql");

function parseBool(value, defaultValue = false) {
  if (value == null || value === "") {
    return defaultValue;
  }

  return ["1", "true", "yes", "on"].includes(String(value).toLowerCase());
}

function buildConfig() {
  const connectionString = process.env.SQL_CONNECTION_STRING;
  const isProduction = process.env.NODE_ENV === "production";

  if (connectionString) {
    return {
      connectionString,
      options: {
        encrypt: parseBool(process.env.SQL_ENCRYPT, isProduction),
        trustServerCertificate: parseBool(
          process.env.SQL_TRUST_SERVER_CERTIFICATE,
          !isProduction,
        ),
        enableArithAbort: true,
      },
    };
  }

  return {
    server: process.env.SQL_SERVER || "den1.mssql8.gear.host",
    database: process.env.SQL_DATABASE || "fellow4udb1",
    options: {
      encrypt: parseBool(process.env.SQL_ENCRYPT, true),
      trustServerCertificate: parseBool(
        process.env.SQL_TRUST_SERVER_CERTIFICATE,
        true,
      ),
      enableArithAbort: true,
    },
    authentication: {
      type: "default",
      options: {
        userName: process.env.SQL_USER || "fellow4udb1",
        password: process.env.SQL_PASSWORD || "Om63C~-d8TyA",
      },
    },
  };
}

const poolPromise = new sql.ConnectionPool(buildConfig())
  .connect()
  .then((pool) => {
    console.log("Connected to SQL Server");
    return pool;
  })
  .catch((err) => {
    console.error("Database Connection Failed:", err);
    process.exit(1);
  });

module.exports = {
  sql,
  poolPromise,
};
