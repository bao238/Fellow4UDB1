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

  CREATE UNIQUE INDEX UX_Users_Username ON dbo.Users (Username);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Users_Email' AND object_id = OBJECT_ID(N'dbo.Users'))
BEGIN
  CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users (Email);
END
GO

IF OBJECT_ID(N'dbo.BestGuides', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.BestGuides (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    City NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(50) NOT NULL
  );
END
GO

IF OBJECT_ID(N'dbo.TopJourneys', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.TopJourneys (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL
  );
END
GO

IF OBJECT_ID(N'dbo.TopExperiences', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.TopExperiences (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId INT NOT NULL,
    Title NVARCHAR(255) NOT NULL
  );
END
GO

IF OBJECT_ID(N'dbo.Notifications', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Notifications (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ActorName NVARCHAR(150) NOT NULL,
    ActorAvatar NVARCHAR(255) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    EventDate NVARCHAR(40) NOT NULL,
    AccentColor NVARCHAR(20) NOT NULL,
    BadgeIcon NVARCHAR(50) NOT NULL,
    ShowReviewButton BIT NOT NULL CONSTRAINT DF_Notifications_ShowReviewButton DEFAULT (0),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT (SYSUTCDATETIME())
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = 1)
BEGIN
  SET IDENTITY_INSERT dbo.Users ON;
  INSERT INTO dbo.Users (
    Id,
    FirstName,
    LastName,
    Email,
    Username,
    Password,
    Country,
    Role
  )
  VALUES
    (1, N'Emily', N'Johnson', N'emily.johnson@example.com', N'emilys', N'emilyspass', N'United States', N'Traveler');
  SET IDENTITY_INSERT dbo.Users OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = 2)
BEGIN
  SET IDENTITY_INSERT dbo.Users ON;
  INSERT INTO dbo.Users (
    Id,
    FirstName,
    LastName,
    Email,
    Username,
    Password,
    Country,
    Role
  )
  VALUES
    (2, N'Bao', N'Dinh', N'bao@example.com', N'bao12345', N'bao123456', N'Vietnam', N'Traveler');
  SET IDENTITY_INSERT dbo.Users OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin')
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
  VALUES
    (N'Admin', N'Fellow4U', N'admin@fellow4u.com', N'admin', N'admin123', N'Vietnam', N'Admin');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TopJourneys WHERE Id = 1)
BEGIN
  SET IDENTITY_INSERT dbo.TopJourneys ON;
  INSERT INTO dbo.TopJourneys (Id, UserId, Title, Body)
  VALUES
    (1, 1, N'Da Nang - Ba Na - Hoi An', N'Classic 3-day journey.');
  SET IDENTITY_INSERT dbo.TopJourneys OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TopJourneys WHERE Id = 2)
BEGIN
  SET IDENTITY_INSERT dbo.TopJourneys ON;
  INSERT INTO dbo.TopJourneys (Id, UserId, Title, Body)
  VALUES
    (2, 2, N'Thailand Highlights', N'Culture and street food route.');
  SET IDENTITY_INSERT dbo.TopJourneys OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.BestGuides WHERE Id = 1)
BEGIN
  SET IDENTITY_INSERT dbo.BestGuides ON;
  INSERT INTO dbo.BestGuides (Id, Name, Email, City, Phone)
  VALUES
    (1, N'Tuan Tran', N'tuan@example.com', N'Da Nang', N'0900000001');
  SET IDENTITY_INSERT dbo.BestGuides OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.BestGuides WHERE Id = 2)
BEGIN
  SET IDENTITY_INSERT dbo.BestGuides ON;
  INSERT INTO dbo.BestGuides (Id, Name, Email, City, Phone)
  VALUES
    (2, N'Linh Hana', N'linh@example.com', N'Ha Noi', N'0900000002');
  SET IDENTITY_INSERT dbo.BestGuides OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TopExperiences WHERE Id = 1)
BEGIN
  SET IDENTITY_INSERT dbo.TopExperiences ON;
  INSERT INTO dbo.TopExperiences (Id, UserId, Title)
  VALUES
    (1, 1, N'2 Hour Bicycle Tour in Hoi An');
  SET IDENTITY_INSERT dbo.TopExperiences OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TopExperiences WHERE Id = 2)
BEGIN
  SET IDENTITY_INSERT dbo.TopExperiences ON;
  INSERT INTO dbo.TopExperiences (Id, UserId, Title)
  VALUES
    (2, 2, N'Ba Na Hill 1 Day Plan');
  SET IDENTITY_INSERT dbo.TopExperiences OFF;
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM dbo.Notifications
  WHERE Message = N'Tuan Tran accepted your request for the trip in Danang, Vietnam on Jan 20, 2020'
)
BEGIN
  INSERT INTO dbo.Notifications (
    ActorName,
    ActorAvatar,
    Message,
    EventDate,
    AccentColor,
    BadgeIcon,
    ShowReviewButton
  )
  VALUES (
    N'Tuan Tran',
    N'assets/images/guide_tuan_tran.png',
    N'Tuan Tran accepted your request for the trip in Danang, Vietnam on Jan 20, 2020',
    N'Jan 16',
    N'#8BC34A',
    N'check',
    0
  );
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM dbo.Notifications
  WHERE Message = N'Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020'
)
BEGIN
  INSERT INTO dbo.Notifications (
    ActorName,
    ActorAvatar,
    Message,
    EventDate,
    AccentColor,
    BadgeIcon,
    ShowReviewButton
  )
  VALUES (
    N'Emmy',
    N'assets/images/guide_emmy.png',
    N'Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020',
    N'Jan 16',
    N'#FFC107',
    N'attach_money',
    0
  );
END
GO

IF NOT EXISTS (
  SELECT 1
  FROM dbo.Notifications
  WHERE Message = N'Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.'
)
BEGIN
  INSERT INTO dbo.Notifications (
    ActorName,
    ActorAvatar,
    Message,
    EventDate,
    AccentColor,
    BadgeIcon,
    ShowReviewButton
  )
  VALUES (
    N'Fellow4U',
    N'assets/images/app_icon.png',
    N'Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.',
    N'Jan 24',
    N'#3F8CFF',
    N'rate_review',
    1
  );
END
GO
