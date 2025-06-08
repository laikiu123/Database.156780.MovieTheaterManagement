-- ================================================
-- File: 04_Roles_Permissions/02_GrantPermissions/Customer/GrantPermissions_Customer.sql
-- Description:
--   Cấp quyền SELECT và EXECUTE cho Role db_Customer (Customer)
--   – Thực thi các Stored Procedures và đọc dữ liệu từ các View để phục vụ nghiệp vụ đặt vé
-- ================================================

USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Grant EXECUTE trên các Stored Procedures cho Customer
---------------------------------------------------------------
-- Cho phép khách hàng gọi procedure để đăng nhập
GRANT EXECUTE ON dbo.sp_Login TO db_Customer;

-- Cho phép xem lịch chiếu của phim (truy vấn Showtimes theo phim, rạp, ngày)
GRANT EXECUTE ON dbo.sp_GetMovieSchedule TO db_Customer;

-- Cho phép xem danh sách ghế trống cho một suất chiếu
GRANT EXECUTE ON dbo.sp_GetAvailableSeats TO db_Customer;

-- Cho phép tạo mới đơn hàng đặt vé (Order + OrderDetail)
GRANT EXECUTE ON dbo.sp_CreateOrder TO db_Customer;

-- Cho phép thanh toán đơn hàng đã tạo
GRANT EXECUTE ON dbo.sp_PayOrder TO db_Customer;

-- Cho phép hủy đơn hàng (nếu chính sách cho phép khách hủy)
GRANT EXECUTE ON dbo.sp_CancelOrder TO db_Customer;
GO

---------------------------------------------------------------
-- 2. Grant SELECT trên các Views cho Customer
---------------------------------------------------------------
-- Cho phép xem tổng quan các suất chiếu còn ghế trống
GRANT SELECT ON dbo.vw_AvailableShowtimes TO db_Customer;

-- Cho phép xem chi tiết trạng thái (Booked/Available) của từng ghế cho mỗi suất chiếu
GRANT SELECT ON dbo.vw_CinemaSeatStatus TO db_Customer;
GO

---------------------------------------------------------------
-- 3. Grant SELECT để xem lịch sử đặt vé và chi tiết đơn hàng
---------------------------------------------------------------
-- Cho phép xem thông tin đơn hàng (Order) của chính mình
GRANT SELECT ON dbo.[Order] TO db_Customer;

-- Cho phép xem chi tiết từng ghế đã đặt trong đơn hàng (OrderDetail)
GRANT SELECT ON dbo.OrderDetail TO db_Customer;
GO

---------------------------------------------------------------
-- 4. Grant SELECT bổ sung để hiển thị thông tin liên quan
---------------------------------------------------------------
-- Cho phép xem thông tin phim (Movie) để hiện tiêu đề, thể loại, mô tả
GRANT SELECT ON dbo.Movie TO db_Customer;

-- Cho phép xem thông tin suất chiếu (Showtime) để hiện giá, thời gian
GRANT SELECT ON dbo.Showtime TO db_Customer;
GO

-- Lưu ý:
-- • Các quyền trên chỉ cho phép khách hàng đọc và tương tác với dữ liệu của riêng họ (Order/OrderDetail).
-- • Khách hàng không được phép chỉnh sửa dữ liệu phim, suất chiếu hay truy cập báo cáo doanh thu.
-- ================================================
