-- ================================================
-- Test Script Part 2: Demo nghiệp vụ "Khách hàng"
-- Mô tả: Chạy tuần tự workflow của khách hàng từ đăng ký → đăng nhập → xem lịch chiếu 
--       → xem ghế trống → đặt vé → thanh toán → hủy vé
-- Chạy trong database ứng dụng (ví dụ: CinemaDB)
-- ================================================
USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Đăng ký khách hàng mới
---------------------------------------------------------------
DECLARE 
    @newCustId   INT,
    @newPwdHash  VARBINARY(64) = HASHBYTES('SHA2_256', N'Demo@123');

PRINT '--- 1. sp_AddCustomer ---';
EXEC dbo.sp_AddCustomer
    @username        = N'demoCust',
    @password_hash   = @newPwdHash,
    @full_name       = N'Khách Demo',
    @email           = N'demo.cust@example.com',
    @phone           = N'0900000000',
    @dob             = '1990-01-01',
    @customer_id_out = @newCustId OUTPUT;

SELECT @newCustId AS CreatedCustomerId;
GO

---------------------------------------------------------------
-- 2. Đăng nhập với tài khoản vừa tạo
---------------------------------------------------------------
DECLARE
    @loginCustId   INT,
    @loginCustRole NVARCHAR(20);

PRINT '--- 2. sp_Login (Customer) ---';
EXEC dbo.sp_Login
    @username      = N'demoCust',
    @password_hash = @newPwdHash,
    @user_id_out   = @loginCustId OUTPUT,
    @role_out      = @loginCustRole OUTPUT;

SELECT 
    @loginCustId   AS LoginCustomerId,
    @loginCustRole AS LoginRole;
GO

---------------------------------------------------------------
-- 3. Xem lịch chiếu (7 ngày tới)
---------------------------------------------------------------
DECLARE 
    @dateFrom DATETIME = GETDATE(),
    @dateTo   DATETIME = DATEADD(DAY, 7, @dateFrom);

PRINT '--- 3. sp_GetMovieSchedule ---';
EXEC dbo.sp_GetMovieSchedule
    @movie_id  = NULL,     -- NULL = tất cả phim
    @cinema_id = NULL,     -- NULL = tất cả rạp
    @date_from = @dateFrom,
    @date_to   = @dateTo;
GO

---------------------------------------------------------------
-- 4. Xem ghế trống cho suất đầu tiên
---------------------------------------------------------------
DECLARE
    @showtimeId    INT  = (SELECT TOP 1 showtime_id 
                           FROM dbo.Showtime 
                           WHERE available_seats > 0
                           ORDER BY start_time),
    @availSeatsTbl TABLE (seat_id INT, row_number NVARCHAR(5), col_number INT, seat_type NVARCHAR(50));

PRINT '--- 4. sp_GetAvailableSeats ---';
INSERT INTO @availSeatsTbl
EXEC dbo.sp_GetAvailableSeats 
    @showtime_id = @showtimeId;

SELECT * FROM @availSeatsTbl;
GO

---------------------------------------------------------------
-- 5. Đặt vé: chọn 2 ghế đầu
---------------------------------------------------------------
DECLARE
    @seatIds NVARCHAR(MAX) = (
        SELECT STRING_AGG(CAST(seat_id AS NVARCHAR(10)), ',')
        FROM (
            SELECT TOP 2 seat_id 
            FROM @availSeatsTbl 
            ORDER BY seat_id
        ) AS t
    ),
    @orderId  INT;

PRINT '--- 5. sp_CreateOrder ---';
PRINT 'Đặt các ghế: ' + @seatIds;
EXEC dbo.sp_CreateOrder
    @customer_id  = @newCustId,
    @showtime_id  = @showtimeId,
    @seat_ids     = @seatIds,
    @employee_id  = NULL,
    @order_id_out = @orderId OUTPUT;

SELECT @orderId AS CreatedOrderId;
GO

---------------------------------------------------------------
-- 6. Thanh toán đơn đặt vé
---------------------------------------------------------------
PRINT '--- 6. sp_PayOrder ---';
EXEC dbo.sp_PayOrder
    @order_id         = @orderId,
    @payment_method   = N'Ví',
    @transaction_code = N'TXNDemo123';

-- Xem lại trạng thái đơn
SELECT order_id, status, payment_method, payment_date
FROM dbo.[Order]
WHERE order_id = @orderId;
GO

---------------------------------------------------------------
-- 7. Hủy vé (ví dụ sau khi thanh toán thử)
---------------------------------------------------------------
PRINT '--- 7. sp_CancelOrder ---';
EXEC dbo.sp_CancelOrder
    @order_id = @orderId;

-- Xem lại trạng thái đơn và available_seats sau hủy
SELECT order_id, status
FROM dbo.[Order]
WHERE order_id = @orderId;

SELECT available_seats
FROM dbo.Showtime
WHERE showtime_id = @showtimeId;
GO

PRINT '=== Kết thúc Demo nghiệp vụ Khách hàng ===';
