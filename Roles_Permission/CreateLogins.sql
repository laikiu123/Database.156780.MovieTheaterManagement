-- ================================================
-- File: 04_Roles_Permissions/00_CreateLogins/CreateLogins.sql
-- Description:
--   Tạo các SQL Server Login ở cấp instance (server-level principals)
--   để sau này map sang Database User trong database ứng dụng.
--   Các login này tương ứng với các vai trò:
--     • Customer → testcust_login
--     • Employee → testemp_login
--     • Admin    → testadmin_login
--
-- Lưu ý:
--   – Phải chạy trong ngữ cảnh database master.
--   – Mật khẩu chỉ mang tính minh họa; khi triển khai production, 
--     cần tuân thủ chính sách mật khẩu của tổ chức.
-- ================================================
USE master;
GO

---------------------------------------------------------------
-- 1. Login cho Customer
---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 
    FROM sys.server_principals 
    WHERE name = N'testcust_login' 
      AND type_desc = N'SQL_LOGIN'
)
BEGIN
    CREATE LOGIN testcust_login
        WITH PASSWORD = N'CustPass123';  -- Thay bằng mật khẩu an toàn hơn
    PRINT 'Created server-level login: testcust_login';
END
ELSE
    PRINT 'Login testcust_login already exists.';
GO

---------------------------------------------------------------
-- 2. Login cho Employee
---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 
    FROM sys.server_principals 
    WHERE name = N'testemp_login' 
      AND type_desc = N'SQL_LOGIN'
)
BEGIN
    CREATE LOGIN testemp_login
        WITH PASSWORD = N'EmpPass123';  -- Thay bằng mật khẩu an toàn hơn
    PRINT 'Created server-level login: testemp_login';
END
ELSE
    PRINT 'Login testemp_login already exists.';
GO

---------------------------------------------------------------
-- 3. Login cho Admin
---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 
    FROM sys.server_principals 
    WHERE name = N'testadmin_login' 
      AND type_desc = N'SQL_LOGIN'
)
BEGIN
    CREATE LOGIN testadmin_login
        WITH PASSWORD = N'AdminPass123';  -- Thay bằng mật khẩu an toàn hơn
    PRINT 'Created server-level login: testadmin_login';
END
ELSE
    PRINT 'Login testadmin_login already exists.';
GO
