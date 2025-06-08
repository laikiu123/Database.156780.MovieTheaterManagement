-- ================================================
-- Test Script Part 5: Demo phân quyền
-- Mô tả: Chứng minh Role-Based Security qua việc thực thi các lệnh 
--       dưới ngữ cảnh của Customer, Employee và Admin
-- Chạy trong database ứng dụng (ví dụ: CinemaDB)
-- ================================================
USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Demo với Customer User
---------------------------------------------------------------
PRINT '--- Impersonate as Customer: testcust_user ---';
EXECUTE AS USER = 'testcust_user';
-- Xác nhận user
SELECT SYSTEM_USER AS LoginName, USER_NAME() AS DbUser;

-- 1.a. Được phép: xem lịch chiếu
PRINT '-> Khách hàng gọi sp_GetMovieSchedule (được phép)';
EXEC dbo.sp_GetMovieSchedule
    @movie_id  = NULL,
    @cinema_id = NULL,
    @date_from = GETDATE(),
    @date_to   = DATEADD(DAY,7,GETDATE());
GO

-- 1.b. Bị từ chối: thêm phim mới
PRINT '-> Khách hàng gọi sp_AddMovie (bị deny)';
BEGIN TRY
    EXEC dbo.sp_AddMovie
        @title            = N'Phim Test',
        @genre            = N'Drama',
        @duration_minutes = 100,
        @language         = N'English',
        @status           = N'ĐangChiếu',
        @movie_id_out     = @dummy OUTPUT;
END TRY
BEGIN CATCH
    SELECT 
        ERROR_MESSAGE() AS ExpectedError;
END CATCH;
GO

REVERT;
GO

---------------------------------------------------------------
-- 2. Demo với Employee User
---------------------------------------------------------------
PRINT '--- Impersonate as Employee: testemp_user ---';
EXECUTE AS USER = 'testemp_user';
SELECT SYSTEM_USER AS LoginName, USER_NAME() AS DbUser;

-- 2.a. Được phép: thêm phim mới
PRINT '-> Nhân viên gọi sp_AddMovie (được phép)';
DECLARE @empMovieTestId INT;
EXEC dbo.sp_AddMovie
    @title            = N'NV Test Movie',
    @genre            = N'Action',
    @duration_minutes = 90,
    @language         = N'English',
    @status           = N'ĐangChiếu',
    @movie_id_out     = @empMovieTestId OUTPUT;
SELECT @empMovieTestId AS CreatedByEmployee;
GO

-- 2.b. Bị từ chối: xem báo cáo top phim
PRINT '-> Nhân viên gọi sp_GetTopMovies (bị deny)';
BEGIN TRY
    EXEC dbo.sp_GetTopMovies
        @start_date = DATEADD(MONTH,-1,GETDATE()),
        @end_date   = GETDATE(),
        @top_n      = 3;
END TRY
BEGIN CATCH
    SELECT 
        ERROR_MESSAGE() AS ExpectedError;
END CATCH;
GO

REVERT;
GO

---------------------------------------------------------------
-- 3. Demo với Admin User
---------------------------------------------------------------
PRINT '--- Impersonate as Admin: testadmin_user ---';
EXECUTE AS USER = 'testadmin_user';
SELECT SYSTEM_USER AS LoginName, USER_NAME() AS DbUser;

-- 3.a. Được phép: xem top phim
PRINT '-> Admin gọi sp_GetTopMovies (được phép)';
EXEC dbo.sp_GetTopMovies
    @start_date = DATEADD(MONTH,-1,GETDATE()),
    @end_date   = GETDATE(),
    @top_n      = 5;
GO

-- 3.b. Được phép: thêm nhân viên mới
PRINT '-> Admin gọi sp_AddEmployee (được phép)';
DECLARE @adminNewEmpId INT;
EXEC dbo.sp_AddEmployee
    @username        = N'adminTest',
    @password_hash   = HASHBYTES('SHA2_256', N'Admin#123'),
    @full_name       = N'Admin Test',
    @email           = N'admin.test@example.com',
    @phone           = N'0901111222',
    @role            = N'Employee',
    @cinema_id       = 1,
    @employee_id_out = @adminNewEmpId OUTPUT;
SELECT @adminNewEmpId AS CreatedByAdmin;
GO

REVERT;
GO

PRINT '=== Kết thúc Demo phân quyền ===';
