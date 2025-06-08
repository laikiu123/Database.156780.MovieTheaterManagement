-- ================================================
-- File: 04_Roles_Permissions/01_CreateUsers/CreateUsers.sql
-- Mô tả: Tạo Database User trong database ứng dụng, 
--       ánh xạ với các Login server-level đã tạo trước đó
--
-- Lưu ý:
--   • Chạy trong ngữ cảnh database ứng dụng (USE CinemaDB)
--   • Phải có các Login: testcust_login, testemp_login, testadmin_login
-- ================================================
USE MovieTheaterManagement;  
GO

---------------------------------------------------------------
-- 1. Database User cho Customer
---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'testcust_user' 
      AND type = N'U'  -- User
)
BEGIN
    CREATE USER testcust_user
        FOR LOGIN testcust_login;
    PRINT 'Created database user: testcust_user';
END
ELSE
    PRINT 'Database user testcust_user already exists.';

---------------------------------------------------------------
-- 2. Database User cho Employee
---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'testemp_user' 
      AND type = N'U'
)
BEGIN
    CREATE USER testemp_user
        FOR LOGIN testemp_login;
    PRINT 'Created database user: testemp_user';
END
ELSE
    PRINT 'Database user testemp_user already exists.';

---------------------------------------------------------------
-- 3. Database User cho Admin
---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'testadmin_user' 
      AND type = N'U'
)
BEGIN
    CREATE USER testadmin_user
        FOR LOGIN testadmin_login;
    PRINT 'Created database user: testadmin_user';
END
ELSE
    PRINT 'Database user testadmin_user already exists.';
GO
