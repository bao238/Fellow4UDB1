IF DB_ID(N'Fellow4UDB') IS NULL
BEGIN
  CREATE DATABASE [Fellow4UDB];
END
GO

USE [Fellow4UDB];
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Users (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Username NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Country NVARCHAR(100) NOT NULL CONSTRAINT DF_Users_Country DEFAULT (N''),
    Role NVARCHAR(50) NOT NULL CONSTRAINT DF_Users_Role DEFAULT (N'Traveler'),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME())
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Users_Username' AND object_id = OBJECT_ID(N'dbo.Users'))
BEGIN
  CREATE UNIQUE INDEX UX_Users_Username ON dbo.Users (Username);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Users_Email' AND object_id = OBJECT_ID(N'dbo.Users'))
BEGIN
  CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users (Email);
END
GO

IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'emilys')
BEGIN
  UPDATE dbo.Users
  SET
    FirstName = N'Emily',
    LastName = N'Johnson',
    Email = N'emily.johnson@example.com',
    Password = N'emilyspass',
    Country = N'United States',
    Role = N'Traveler'
  WHERE Username = N'emilys';
END
ELSE
BEGIN
  INSERT INTO dbo.Users (
    FirstName,
    LastName,
    Email,
    Username,
    Password,
    Country,
    Role
  )
  VALUES (
    N'Emily',
    N'Johnson',
    N'emily.johnson@example.com',
    N'emilys',
    N'emilyspass',
    N'United States',
    N'Traveler'
  );
END
GO

IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'bao12345')
BEGIN
  UPDATE dbo.Users
  SET
    FirstName = N'Bao',
    LastName = N'Dinh',
    Email = N'bao@example.com',
    Password = N'bao123456',
    Country = N'Vietnam',
    Role = N'Traveler'
  WHERE Username = N'bao12345';
END
ELSE
BEGIN
  INSERT INTO dbo.Users (
    FirstName,
    LastName,
    Email,
    Username,
    Password,
    Country,
    Role
  )
  VALUES (
    N'Bao',
    N'Dinh',
    N'bao@example.com',
    N'bao12345',
    N'bao123456',
    N'Vietnam',
    N'Traveler'
  );
END
GO

IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin')
BEGIN
  UPDATE dbo.Users
  SET
    FirstName = N'Fellow',
    LastName = N'Admin',
    Email = N'admin@fellow4u.local',
    Password = N'admin123',
    Country = N'Vietnam',
    Role = N'Admin'
  WHERE Username = N'admin';
END
ELSE
BEGIN
  INSERT INTO dbo.Users (
    FirstName,
    LastName,
    Email,
    Username,
    Password,
    Country,
    Role
  )
  VALUES (
    N'Fellow',
    N'Admin',
    N'admin@fellow4u.local',
    N'admin',
    N'admin123',
    N'Vietnam',
    N'Admin'
  );
END
GO

SELECT
  Id,
  Username,
  Email,
  Role
FROM dbo.Users
WHERE Username IN (N'emilys', N'bao12345', N'admin')
ORDER BY Id;
GO
