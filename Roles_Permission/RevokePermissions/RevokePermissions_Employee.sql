-- ================================================
-- File: 04_Roles_Permissions/03_RevokePermissions/Employee/RevokePermissions_Employee.sql
-- Description:
--   Thu hồi mọi quyền EXECUTE và SELECT đã cấp cho role db_Employee
-- ================================================

USE MovieTheaterManagement;
GO

-- 1. Revoke EXECUTE các Stored Procedures nghiệp vụ khách hàng
REVOKE EXECUTE ON dbo.sp_Login             FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_GetMovieSchedule  FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_GetAvailableSeats FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_CreateOrder       FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_PayOrder          FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_CancelOrder       FROM db_Employee;

-- 2. Revoke EXECUTE CRUD phim/suất chiếu
REVOKE EXECUTE ON dbo.sp_AddMovie       FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_UpdateMovie    FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_DeleteMovie    FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_AddShowtime    FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_UpdateShowtime FROM db_Employee;
REVOKE EXECUTE ON dbo.sp_DeleteShowtime FROM db_Employee;

-- 3. Revoke EXECUTE báo cáo doanh thu ngày
REVOKE EXECUTE ON dbo.sp_GetRevenueByDate FROM db_Employee;
GO

-- 4. Revoke SELECT trên Views hỗ trợ
REVOKE SELECT ON dbo.vw_AvailableShowtimes FROM db_Employee;
REVOKE SELECT ON dbo.vw_CinemaSeatStatus   FROM db_Employee;
GO

-- 5. Revoke SELECT bổ sung trên bảng Movie và Showtime
REVOKE SELECT ON dbo.Movie    FROM db_Employee;
REVOKE SELECT ON dbo.Showtime FROM db_Employee;
GO
