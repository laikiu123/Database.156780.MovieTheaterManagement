----------------------------------------------------------------
-- 1. Test sp_AddCustomer
----------------------------------------------------------------
DECLARE 
    @custId   INT,
    @custPwd  VARBINARY(64) = HASHBYTES('SHA2_256', N'CustPass123');

EXEC dbo.sp_AddCustomer
    @username        = N'testcust',
    @password_hash   = @custPwd,
    @full_name       = N'Test Customer',
    @email           = N'testcust@example.com',
    @phone           = N'0123456789',
    @dob             = '1990-01-01',
    @customer_id_out = @custId OUTPUT;

SELECT @custId AS CreatedCustomerId;
GO

----------------------------------------------------------------
-- 2. Test sp_AddEmployee
----------------------------------------------------------------
DECLARE
    @empId   INT,
    @empPwd  VARBINARY(64) = HASHBYTES('SHA2_256', N'EmpPass123');

EXEC dbo.sp_AddEmployee
    @username        = N'testemp',
    @password_hash   = @empPwd,
    @full_name       = N'Test Employee',
    @email           = N'testemp@example.com',
    @phone           = N'0987654321',
    @role            = N'Employee',
    @cinema_id       = 1,            -- Giả sử Cinema 1 tồn tại
    @employee_id_out = @empId OUTPUT;

SELECT @empId AS CreatedEmployeeId;
GO

----------------------------------------------------------------
-- 3. Test sp_Login (Customer)
----------------------------------------------------------------
DECLARE
    @loginCustId   INT,
    @loginCustRole NVARCHAR(20),
    @custPwd2      VARBINARY(64) = HASHBYTES('SHA2_256', N'CustPass123');

EXEC dbo.sp_Login
    @username      = N'testcust',
    @password_hash = @custPwd2,
    @user_id_out   = @loginCustId OUTPUT,
    @role_out      = @loginCustRole OUTPUT;

SELECT 
    @loginCustId   AS LoginCustomerId,
    @loginCustRole AS LoginRole;
GO

----------------------------------------------------------------
-- 4. Test sp_Login (Employee)
----------------------------------------------------------------
DECLARE
    @loginEmpId   INT,
    @loginEmpRole NVARCHAR(20),
    @empPwd2      VARBINARY(64) = HASHBYTES('SHA2_256', N'EmpPass123');

EXEC dbo.sp_Login
    @username      = N'testemp',
    @password_hash = @empPwd2,
    @user_id_out   = @loginEmpId OUTPUT,
    @role_out      = @loginEmpRole OUTPUT;

SELECT 
    @loginEmpId   AS LoginEmployeeId,
    @loginEmpRole AS LoginRole;
GO

----------------------------------------------------------------
-- 5. Test sp_AddMovie
----------------------------------------------------------------
DECLARE @movieId INT;

EXEC dbo.sp_AddMovie
    @title            = N'Test Movie',
    @genre            = N'Action',
    @duration_minutes = 120,
    @language         = N'English',
    @description      = N'Demo movie for testing.',
    @status           = N'ĐangChiếu',
    @poster_url       = N'http://example.com/poster.jpg',
    @movie_id_out     = @movieId OUTPUT;

SELECT @movieId AS CreatedMovieId;
GO

----------------------------------------------------------------
-- 6. Test sp_UpdateMovie
----------------------------------------------------------------
DECLARE @movieId2 INT = (SELECT TOP 1 movie_id FROM dbo.Movie ORDER BY movie_id DESC);

EXEC dbo.sp_UpdateMovie
    @movie_id         = @movieId2,
    @title            = N'Test Movie Updated',
    @genre            = N'Adventure',
    @duration_minutes = 130,
    @status           = N'ĐangChiếu';

SELECT @movieId2 AS UpdatedMovieId;
GO

----------------------------------------------------------------
-- 7. Test sp_DeleteMovie (soft-delete)
----------------------------------------------------------------
DECLARE @movieId3 INT = (SELECT TOP 1 movie_id FROM dbo.Movie ORDER BY movie_id DESC);

EXEC dbo.sp_DeleteMovie
    @movie_id = @movieId3;

SELECT @movieId3 AS SoftDeletedMovieId;
GO

----------------------------------------------------------------
-- 8. Test sp_AddShowtime
----------------------------------------------------------------
DECLARE 
    @showtimeId INT,
    @movieId4   INT       = (SELECT TOP 1 movie_id FROM dbo.Movie ORDER BY movie_id DESC),
    @nextTime   DATETIME  = DATEADD(DAY, 1, GETDATE());  
    -- Tính trước DATEADD, gán vào biến để dùng khi EXEC

EXEC dbo.sp_AddShowtime
    @movie_id        = @movieId4,
    @cinema_id       = 1,             -- Giả sử Cinema 1 tồn tại
    @start_time      = @nextTime,     -- Sử dụng biến đã tính
    @price           = 100000,
    @showtime_id_out = @showtimeId OUTPUT;

SELECT @showtimeId AS CreatedShowtimeId;
GO

----------------------------------------------------------------
-- 9. Test sp_UpdateShowtime (đã sửa để khai báo trước @nextTime2)
----------------------------------------------------------------
DECLARE 
    @showtimeId2 INT       = (SELECT TOP 1 showtime_id FROM dbo.Showtime ORDER BY showtime_id DESC),
    @nextTime2    DATETIME  = DATEADD(DAY, 2, GETDATE());  -- Tính trước DATEADD

EXEC dbo.sp_UpdateShowtime
    @showtime_id = @showtimeId2,
    @start_time  = @nextTime2,     -- Dùng biến đã khai báo
    @price       = 110000;

SELECT @showtimeId2 AS UpdatedShowtimeId;
GO

----------------------------------------------------------------
-- 10. Test sp_DeleteShowtime
----------------------------------------------------------------
DECLARE @showtimeId3 INT = (SELECT TOP 1 showtime_id FROM dbo.Showtime ORDER BY showtime_id DESC);

EXEC dbo.sp_DeleteShowtime
    @showtime_id = @showtimeId3;

SELECT @showtimeId3 AS DeletedShowtimeId;
GO

----------------------------------------------------------------
-- 11. Test sp_GetMovieSchedule
----------------------------------------------------------------
DECLARE @movieId5 INT = (SELECT TOP 1 movie_id FROM dbo.Movie ORDER BY movie_id DESC);

EXEC dbo.sp_GetMovieSchedule
    @movie_id  = @movieId5,
    @cinema_id = 1,
    @date_from = GETDATE(),
    @date_to   = DATEADD(DAY,7,GETDATE());
GO

----------------------------------------------------------------
-- 12. Test sp_GetAvailableSeats
----------------------------------------------------------------
DECLARE @showtimeId4 INT = (SELECT TOP 1 showtime_id FROM dbo.Showtime ORDER BY showtime_id DESC);

EXEC dbo.sp_GetAvailableSeats
    @showtime_id = @showtimeId4;
GO

----------------------------------------------------------------
-- 13. Test sp_CreateOrder
----------------------------------------------------------------
DECLARE
    @orderId1     INT,
    @custId2      INT = (SELECT TOP 1 customer_id FROM dbo.Customer ORDER BY customer_id DESC),
    @showtimeId5  INT = (SELECT TOP 1 showtime_id FROM dbo.Showtime ORDER BY showtime_id DESC);

EXEC dbo.sp_CreateOrder
    @customer_id    = @custId2,
    @showtime_id    = @showtimeId5,
    @seat_ids       = N'1,2',
    @employee_id    = NULL,
    @order_id_out   = @orderId1 OUTPUT;

SELECT @orderId1 AS CreatedOrderId;
GO

----------------------------------------------------------------
-- 14. Test sp_PayOrder
----------------------------------------------------------------
DECLARE @orderId2 INT = (SELECT TOP 1 order_id FROM dbo.[Order] ORDER BY order_id DESC);

EXEC dbo.sp_PayOrder
    @order_id         = @orderId2,
    @payment_method   = N'Ví',
    @transaction_code = N'TESTPAY123';

SELECT @orderId2 AS PaidOrderId;
GO

----------------------------------------------------------------
-- 15. Test sp_CancelOrder
----------------------------------------------------------------
DECLARE @orderId3 INT = (SELECT TOP 1 order_id FROM dbo.[Order] WHERE status = N'ĐãThanhToán' ORDER BY order_id DESC);

EXEC dbo.sp_CancelOrder
    @order_id = @orderId3;

SELECT @orderId3 AS CanceledOrderId;
GO

----------------------------------------------------------------
-- 16. Test sp_GetRevenueByDate
----------------------------------------------------------------
EXEC dbo.sp_GetRevenueByDate
    @start_date = DATEADD(DAY,-1,GETDATE()),
    @end_date   = DATEADD(DAY, 1,GETDATE());
GO

----------------------------------------------------------------
-- 17. Test sp_GetRevenueByMonth
----------------------------------------------------------------
EXEC dbo.sp_GetRevenueByMonth
    @start_date = DATEADD(MONTH,-1,GETDATE()),
    @end_date   = DATEADD(MONTH, 1,GETDATE());
GO

----------------------------------------------------------------
-- 18. Test sp_GetTopMovies
----------------------------------------------------------------
EXEC dbo.sp_GetTopMovies
    @start_date = DATEADD(MONTH,-1,GETDATE()),
    @end_date   = DATEADD(MONTH, 1,GETDATE()),
    @top_n      = 5;
GO

----------------------------------------------------------------
-- 19. Test sp_GetTopCinemas
----------------------------------------------------------------
EXEC dbo.sp_GetTopCinemas
    @start_date = DATEADD(MONTH,-1,GETDATE()),
    @end_date   = DATEADD(MONTH, 1,GETDATE()),
    @top_n      = 5;
GO

----------------------------------------------------------------
-- 20. Test Views
----------------------------------------------------------------
SELECT * FROM dbo.vw_AvailableShowtimes;
GO

SELECT * 
FROM dbo.vw_CinemaSeatStatus
WHERE showtime_id = (SELECT TOP 1 showtime_id FROM dbo.Showtime ORDER BY showtime_id DESC);
GO

SELECT * FROM dbo.vw_DailyRevenue;
GO

SELECT * FROM dbo.vw_MonthlyRevenue;
GO
