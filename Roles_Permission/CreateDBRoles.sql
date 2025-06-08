-- ================================================
-- Script: CreateDBRoles
-- Mô tả: Tạo các Database Role để phân quyền cho Customer, Employee và Admin
-- Quan hệ:
--   • Các Role này sẽ được gán EXECUTE trên từng nhóm Stored Procedure tương ứng
--   • Sau khi tạo role, chúng ta sẽ gán User (từ Login) vào role phù hợp
-- ================================================

-- 1. Tạo role cho Khách hàng
IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'db_Customer' 
      AND type = N'R'  -- Role
)
BEGIN
    CREATE ROLE db_Customer;
    PRINT 'Created role: db_Customer';
END
ELSE
    PRINT 'Role db_Customer already exists.';

-- 2. Tạo role cho Nhân viên bán vé
IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'db_Employee' 
      AND type = N'R'
)
BEGIN
    CREATE ROLE db_Employee;
    PRINT 'Created role: db_Employee';
END
ELSE
    PRINT 'Role db_Employee already exists.';

-- 3. Tạo role cho Quản trị viên
IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'db_Admin' 
      AND type = N'R'
)
BEGIN
    CREATE ROLE db_Admin;
    PRINT 'Created role: db_Admin';
END
ELSE
    PRINT 'Role db_Admin already exists.';

GO