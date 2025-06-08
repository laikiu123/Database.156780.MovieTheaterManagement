-- ================================================
-- File: 04_Roles_Permissions/03_RevokePermissions/Admin/RevokePermissions_Admin.sql
-- Description:
--   Thu hồi mọi quyền EXECUTE và SELECT đã cấp cho role db_Admin
-- ================================================

USE MovieTheaterManagement;
GO

-- 1. Revoke EXECUTE trên tất cả Stored Procedures của Customer & Employee
REVOKE EXECUTE ON dbo.sp_Login             FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_GetMovieSchedule  FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_GetAvailableSeats FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_CreateOrder       FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_PayOrder          FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_CancelOrder       FROM db_Admin;

REVOKE EXECUTE ON dbo.sp_AddMovie       FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_UpdateMovie    FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_DeleteMovie    FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_AddShowtime    FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_UpdateShowtime FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_DeleteShowtime FROM db_Admin;

REVOKE EXECUTE ON dbo.sp_GetRevenueByDate  FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_GetRevenueByMonth FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_GetTopMovies      FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_GetTopCinemas     FROM db_Admin;

REVOKE EXECUTE ON dbo.sp_AddEmployee    FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_UpdateEmployee FROM db_Admin;
REVOKE EXECUTE ON dbo.sp_DeleteEmployee FROM db_Admin;
GO

-- 2. Revoke SELECT trên Views báo cáo và hỗ trợ
REVOKE SELECT ON dbo.vw_AvailableShowtimes FROM db_Admin;
REVOKE SELECT ON dbo.vw_CinemaSeatStatus   FROM db_Admin;
REVOKE SELECT ON dbo.vw_DailyRevenue      FROM db_Admin;
REVOKE SELECT ON dbo.vw_MonthlyRevenue    FROM db_Admin;
GO

-- 3. Revoke SELECT trên tất cả bảng dữ liệu
REVOKE SELECT ON dbo.Customer    FROM db_Admin;
REVOKE SELECT ON dbo.Employee    FROM db_Admin;
REVOKE SELECT ON dbo.Movie       FROM db_Admin;
REVOKE SELECT ON dbo.Cinema      FROM db_Admin;
REVOKE SELECT ON dbo.Seat        FROM db_Admin;
REVOKE SELECT ON dbo.Showtime    FROM db_Admin;
REVOKE SELECT ON dbo.[Order]     FROM db_Admin;
REVOKE SELECT ON dbo.OrderDetail FROM db_Admin;
GO
