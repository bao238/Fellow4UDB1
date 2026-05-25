IF DB_ID(N'Fellow4UDB') IS NULL
BEGIN
  CREATE DATABASE [Fellow4UDB];
END
GO

USE [Fellow4UDB];
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

IF EXISTS (
  SELECT 1
  FROM dbo.Notifications
  WHERE Message = N'Tuan Tran accepted your request for the trip in Danang, Vietnam on Jan 20, 2020'
)
BEGIN
  UPDATE dbo.Notifications
  SET
    ActorName = N'Tuan Tran',
    ActorAvatar = N'assets/images/guide_tuan_tran.png',
    EventDate = N'Jan 16',
    AccentColor = N'#8BC34A',
    BadgeIcon = N'check',
    ShowReviewButton = 0
  WHERE Message = N'Tuan Tran accepted your request for the trip in Danang, Vietnam on Jan 20, 2020';
END
ELSE
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

IF EXISTS (
  SELECT 1
  FROM dbo.Notifications
  WHERE Message = N'Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020'
)
BEGIN
  UPDATE dbo.Notifications
  SET
    ActorName = N'Emmy',
    ActorAvatar = N'assets/images/guide_emmy.png',
    EventDate = N'Jan 16',
    AccentColor = N'#FFC107',
    BadgeIcon = N'attach_money',
    ShowReviewButton = 0
  WHERE Message = N'Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020';
END
ELSE
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

IF EXISTS (
  SELECT 1
  FROM dbo.Notifications
  WHERE Message = N'Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.'
)
BEGIN
  UPDATE dbo.Notifications
  SET
    ActorName = N'Fellow4U',
    ActorAvatar = N'assets/images/app_icon.png',
    EventDate = N'Jan 24',
    AccentColor = N'#3F8CFF',
    BadgeIcon = N'rate_review',
    ShowReviewButton = 1
  WHERE Message = N'Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.';
END
ELSE
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

SELECT
  Id,
  ActorName,
  EventDate,
  BadgeIcon,
  ShowReviewButton
FROM dbo.Notifications
ORDER BY Id DESC;
GO
