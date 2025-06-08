-- ================================================
-- File: 04_Roles_Permissions/03_RevokePermissions/Customer/RevokePermissions_Customer.sql
-- Description:
--   Thu hồi mọi quyền EXECUTE và SELECT đã cấp cho role db_Customer
-- ================================================

USE MovieTheaterManagement;
GO

-- 1. Revoke EXECUTE trên Stored Procedures
REVOKE EXECUTE ON dbo.sp_Login             FROM db_Customer;
REVOKE EXECUTE ON dbo.sp_GetMovieSchedule  FROM db_Customer;
REVOKE EXECUTE ON dbo.sp_GetAvailableSeats FROM db_Customer;
REVOKE EXECUTE ON dbo.sp_CreateOrder       FROM db_Customer;
REVOKE EXECUTE ON dbo.sp_PayOrder          FROM db_Customer;
REVOKE EXECUTE ON dbo.sp_CancelOrder       FROM db_Customer;
GO

-- 2. Revoke SELECT trên Views
REVOKE SELECT ON dbo.vw_AvailableShowtimes FROM db_Customer;
REVOKE SELECT ON dbo.vw_CinemaSeatStatus   FROM db_Customer;
GO

-- 3. Revoke SELECT trên bảng để xem lịch sử và chi tiết đơn hàng
REVOKE SELECT ON dbo.[Order]     FROM db_Customer;
REVOKE SELECT ON dbo.OrderDetail FROM db_Customer;
GO

-- 4. Revoke SELECT bổ sung trên dữ liệu phim và suất chiếu
REVOKE SELECT ON dbo.Movie    FROM db_Customer;
REVOKE SELECT ON dbo.Showtime FROM db_Customer;
GO
