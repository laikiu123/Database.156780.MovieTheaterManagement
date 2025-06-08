-- ================================================
-- Test Script Part 4: Demo nghiệp vụ "Admin"
-- Mô tả: Workflow Quản trị viên – quản lý nhân viên và báo cáo nâng cao
-- Chạy trong database ứng dụng (ví dụ: CinemaDB)
-- ================================================
USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Thêm nhân viên mới (sp_AddEmployee)
---------------------------------------------------------------
DECLARE 
    @newEmpId     INT,
    @newEmpPwd    VARBINARY(64) = HASHBYTES('SHA2_256', N'AdminDemo!1');

PRINT '--- 1. sp_AddEmployee ---';
EXEC dbo.sp_AddEmployee
    @username        = N'admindemo',
    @password_hash   = @newEmpPwd,
    @full_name       = N'Admin Demo',
    @email           = N'admindemo@example.com',
    @phone           = N'0912345678',
    @role            = N'Employee',   -- có thể thử Employee hoặc Admin
    @cinema_id       = 2,            -- gán rạp 2
    @employee_id_out = @newEmpId OUTPUT;

SELECT @newEmpId AS CreatedEmployeeId;
GO

---------------------------------------------------------------
-- 2. Cập nhật nhân viên (sp_UpdateEmployee)
---------------------------------------------------------------
PRINT '--- 2. sp_UpdateEmployee ---';
EXEC dbo.sp_UpdateEmployee
    @employee_id = @newEmpId,
    @role        = N'Admin';         -- thăng chức lên Admin

-- Xác nhận
SELECT employee_id, username, role 
FROM dbo.Employee 
WHERE employee_id = @newEmpId;
GO

---------------------------------------------------------------
-- 3. Xóa nhân viên (sp_DeleteEmployee)
--    (Chỉ xóa nếu không có đơn nào gán employee_id)
---------------------------------------------------------------
PRINT '--- 3. sp_DeleteEmployee ---';
EXEC dbo.sp_DeleteEmployee
    @employee_id = @newEmpId;

-- Kiểm tra
SELECT 
    CASE WHEN EXISTS(
        SELECT 1 FROM dbo.Employee WHERE employee_id = @newEmpId
    ) THEN 'Still Exists' ELSE 'Deleted' END AS DeleteStatus;
GO

---------------------------------------------------------------
-- 4. Báo cáo doanh thu theo tháng (sp_GetRevenueByMonth)
---------------------------------------------------------------
DECLARE
    @admStartMonth DATETIME = DATEADD(MONTH, -3, GETDATE()),
    @admEndMonth   DATETIME = GETDATE();

PRINT '--- 4. sp_GetRevenueByMonth ---';
EXEC dbo.sp_GetRevenueByMonth
    @start_date = @admStartMonth,
    @end_date   = @admEndMonth;
GO

---------------------------------------------------------------
-- 5. Top phim bán chạy (sp_GetTopMovies)
---------------------------------------------------------------
PRINT '--- 5. sp_GetTopMovies ---';
EXEC dbo.sp_GetTopMovies
    @start_date = @admStartMonth,
    @end_date   = @admEndMonth,
    @top_n      = 3;
GO

---------------------------------------------------------------
-- 6. Top rạp có doanh thu cao nhất (sp_GetTopCinemas)
---------------------------------------------------------------
PRINT '--- 6. sp_GetTopCinemas ---';
EXEC dbo.sp_GetTopCinemas
    @start_date = @admStartMonth,
    @end_date   = @admEndMonth,
    @top_n      = 3;
GO

---------------------------------------------------------------
-- 7. Xem View báo cáo tháng (vw_MonthlyRevenue)
---------------------------------------------------------------
PRINT '--- 7. vw_MonthlyRevenue ---';
SELECT *
FROM dbo.vw_MonthlyRevenue
WHERE ([Year] = YEAR(GETDATE()) OR [Year] = YEAR(DATEADD(MONTH, -1, GETDATE())))
  AND ([Month] BETWEEN MONTH(DATEADD(MONTH, -1, GETDATE())) AND MONTH(GETDATE()));
GO

PRINT '=== Kết thúc Demo nghiệp vụ Admin ===';
