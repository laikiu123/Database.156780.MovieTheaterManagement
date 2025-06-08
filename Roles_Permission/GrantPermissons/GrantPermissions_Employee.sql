-- ================================================
-- File: 04_Roles_Permissions/02_GrantPermissions/Employee/GrantPermissions_Employee.sql
-- Description:
--   Cấp quyền cho Role db_Employee (Nhân viên bán vé)
--   – Kế thừa quyền của Customer để đặt vé online/offline
--   – Thêm quyền CRUD phim/suất chiếu
--   – Thêm quyền xem báo cáo doanh thu ngắn hạn
-- ================================================

USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Grant EXECUTE các Stored Procedures Customer cần có
---------------------------------------------------------------
-- Cho phép đăng nhập
GRANT EXECUTE ON dbo.sp_Login             TO db_Employee;
-- Cho phép xem lịch chiếu
GRANT EXECUTE ON dbo.sp_GetMovieSchedule  TO db_Employee;
-- Cho phép xem ghế trống
GRANT EXECUTE ON dbo.sp_GetAvailableSeats TO db_Employee;
-- Cho phép tạo đơn (offline hoặc hỗ trợ khách đặt)
GRANT EXECUTE ON dbo.sp_CreateOrder       TO db_Employee;
-- Cho phép ghi nhận thanh toán (offline)
GRANT EXECUTE ON dbo.sp_PayOrder          TO db_Employee;
-- Cho phép hủy đơn (theo chính sách quầy)
GRANT EXECUTE ON dbo.sp_CancelOrder       TO db_Employee;
GO

---------------------------------------------------------------
-- 2. Grant EXECUTE các Stored Procedures quản lý phim/suất chiếu
---------------------------------------------------------------
-- Thêm phim mới
GRANT EXECUTE ON dbo.sp_AddMovie          TO db_Employee;
-- Cập nhật thông tin phim
GRANT EXECUTE ON dbo.sp_UpdateMovie       TO db_Employee;
-- Soft-delete phim (ngừng chiếu)
GRANT EXECUTE ON dbo.sp_DeleteMovie       TO db_Employee;

-- Thêm suất chiếu mới
GRANT EXECUTE ON dbo.sp_AddShowtime       TO db_Employee;
-- Cập nhật suất chiếu
GRANT EXECUTE ON dbo.sp_UpdateShowtime    TO db_Employee;
-- Xóa suất chiếu (nếu không có đơn liên quan)
GRANT EXECUTE ON dbo.sp_DeleteShowtime    TO db_Employee;
GO

---------------------------------------------------------------
-- 3. Grant EXECUTE các Stored Procedures báo cáo doanh thu
---------------------------------------------------------------
-- Cho phép xem doanh thu theo ngày (ngắn hạn)
GRANT EXECUTE ON dbo.sp_GetRevenueByDate  TO db_Employee;
GO

---------------------------------------------------------------
-- 4. Grant SELECT các View hỗ trợ giao diện nhân viên
---------------------------------------------------------------
-- Cho phép xem tổng quan suất chiếu còn ghế trống
GRANT SELECT ON dbo.vw_AvailableShowtimes TO db_Employee;
-- Cho phép xem chi tiết trạng thái ghế cho từng suất
GRANT SELECT ON dbo.vw_CinemaSeatStatus   TO db_Employee;
GO

---------------------------------------------------------------
-- 5. Grant SELECT bổ sung nếu cần (tuỳ front-end)
---------------------------------------------------------------
-- Cho phép đọc Movie và Showtime để hiển thị danh sách phim và lịch chiếu
GRANT SELECT ON dbo.Movie         TO db_Employee;
GRANT SELECT ON dbo.Showtime      TO db_Employee;
GO

-- Lưu ý:
-- • Nhân viên có thể thực hiện tất cả nghiệp vụ đặt vé tương tự Customer,
--   đồng thời quản lý phim và suất chiếu.
-- • Nhân viên chỉ được xem báo cáo doanh thu theo ngày; báo cáo nâng cao
--   (tháng, top) được dành cho Admin.
-- ================================================
