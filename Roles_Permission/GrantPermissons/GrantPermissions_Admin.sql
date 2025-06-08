-- ================================================
-- File: 04_Roles_Permissions/02_GrantPermissions/Admin/GrantPermissions_Admin.sql
-- Description:
--   Cấp quyền đầy đủ cho Role db_Admin (Quản trị viên)
--   – Kế thừa tất cả quyền của Customer và Employee
--   – Thêm quyền quản lý nhân viên
--   – Thêm quyền xem báo cáo doanh thu nâng cao
--   – Cho phép đọc toàn bộ dữ liệu để phục vụ chức năng quản trị
-- ================================================

USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Grant EXECUTE cho tất cả Stored Procedures của Customer
--    và Employee (đặt vé, quản lý phim, suất, báo cáo ngày)
---------------------------------------------------------------
GRANT EXECUTE ON dbo.sp_Login             TO db_Admin; -- Đăng nhập
GRANT EXECUTE ON dbo.sp_GetMovieSchedule  TO db_Admin; -- Xem lịch chiếu
GRANT EXECUTE ON dbo.sp_GetAvailableSeats TO db_Admin; -- Xem ghế trống
GRANT EXECUTE ON dbo.sp_CreateOrder       TO db_Admin; -- Tạo đơn đặt vé
GRANT EXECUTE ON dbo.sp_PayOrder          TO db_Admin; -- Thanh toán đơn
GRANT EXECUTE ON dbo.sp_CancelOrder       TO db_Admin; -- Hủy đơn

GRANT EXECUTE ON dbo.sp_AddMovie          TO db_Admin; -- Thêm phim
GRANT EXECUTE ON dbo.sp_UpdateMovie       TO db_Admin; -- Cập nhật phim
GRANT EXECUTE ON dbo.sp_DeleteMovie       TO db_Admin; -- Ngừng chiếu phim

GRANT EXECUTE ON dbo.sp_AddShowtime       TO db_Admin; -- Thêm suất chiếu
GRANT EXECUTE ON dbo.sp_UpdateShowtime    TO db_Admin; -- Cập nhật suất chiếu
GRANT EXECUTE ON dbo.sp_DeleteShowtime    TO db_Admin; -- Xóa suất chiếu

GRANT EXECUTE ON dbo.sp_GetRevenueByDate  TO db_Admin; -- Báo cáo doanh thu theo ngày
GO

---------------------------------------------------------------
-- 2. Grant EXECUTE cho Stored Procedures báo cáo nâng cao
---------------------------------------------------------------
GRANT EXECUTE ON dbo.sp_GetRevenueByMonth TO db_Admin; -- Báo cáo doanh thu theo tháng
GRANT EXECUTE ON dbo.sp_GetTopMovies      TO db_Admin; -- Top phim bán chạy
GRANT EXECUTE ON dbo.sp_GetTopCinemas     TO db_Admin; -- Top rạp có doanh thu cao nhất
GO

---------------------------------------------------------------
-- 3. Grant EXECUTE cho Stored Procedures quản lý nhân viên
---------------------------------------------------------------
GRANT EXECUTE ON dbo.sp_AddEmployee       TO db_Admin; -- Thêm nhân viên
GRANT EXECUTE ON dbo.sp_UpdateEmployee    TO db_Admin; -- Cập nhật thông tin nhân viên
GRANT EXECUTE ON dbo.sp_DeleteEmployee    TO db_Admin; -- Xóa nhân viên
GO

---------------------------------------------------------------
-- 4. Grant SELECT trên tất cả Views
---------------------------------------------------------------
GRANT SELECT ON dbo.vw_AvailableShowtimes TO db_Admin; -- Xem suất còn ghế
GRANT SELECT ON dbo.vw_CinemaSeatStatus   TO db_Admin; -- Xem trạng thái ghế
GRANT SELECT ON dbo.vw_DailyRevenue      TO db_Admin; -- Xem doanh thu ngày
GRANT SELECT ON dbo.vw_MonthlyRevenue    TO db_Admin; -- Xem doanh thu tháng
GO

---------------------------------------------------------------
-- 5. Grant SELECT trên tất cả bảng để admin có thể đọc dữ liệu
---------------------------------------------------------------
GRANT SELECT ON dbo.Customer             TO db_Admin; -- Xem thông tin khách hàng
GRANT SELECT ON dbo.Employee             TO db_Admin; -- Xem thông tin nhân viên
GRANT SELECT ON dbo.Movie                TO db_Admin; -- Xem danh sách phim
GRANT SELECT ON dbo.Cinema               TO db_Admin; -- Xem danh sách rạp
GRANT SELECT ON dbo.Seat                 TO db_Admin; -- Xem danh sách ghế
GRANT SELECT ON dbo.Showtime             TO db_Admin; -- Xem chi tiết suất chiếu
GRANT SELECT ON dbo.[Order]              TO db_Admin; -- Xem đơn hàng
GRANT SELECT ON dbo.OrderDetail          TO db_Admin; -- Xem chi tiết đơn hàng
GO

-- Lưu ý:
--  • db_Admin có toàn quyền thực hiện nghiệp vụ đặt vé, quản lý phim/suất,
--    quản lý nhân viên và xem tất cả báo cáo.
--  • Khi cần mở rộng hoặc thu hẹp phạm vi, chỉ cần thêm/revoke ở đây.
-- ================================================
