-- ================================================
-- Test Script Part 3: Demo nghiệp vụ "Nhân viên"
-- Mô tả: Workflow nhân viên bán vé – quản lý phim, suất chiếu và báo cáo ngày
-- Chạy trong database ứng dụng (ví dụ: CinemaDB)
-- ================================================
USE MovieTheaterManagement;
GO

---------------------------------------------------------------
-- 1. Thêm phim mới (sp_AddMovie)
---------------------------------------------------------------
DECLARE @empMovieId INT;
EXEC dbo.sp_AddMovie
    @title            = N'NV Demo Movie',
    @genre            = N'Drama',
    @duration_minutes = 95,
    @language         = N'Vietnamese',
    @description      = N'Phim demo do nhân viên thêm',
    @status           = N'ĐangChiếu',
    @poster_url       = NULL,
    @movie_id_out     = @empMovieId OUTPUT;
SELECT @empMovieId AS EmpCreatedMovieId;
GO

---------------------------------------------------------------
-- 2. Cập nhật phim (sp_UpdateMovie)
---------------------------------------------------------------
EXEC dbo.sp_UpdateMovie
    @movie_id         = @empMovieId,
    @title            = N'NV Demo Movie (Updated)',
    @genre            = N'Comedy',
    @duration_minutes = 100;
-- Kiểm tra cập nhật
SELECT movie_id, title, genre, duration_minutes, status
FROM dbo.Movie
WHERE movie_id = @empMovieId;
GO

---------------------------------------------------------------
-- 3. Soft-delete phim (sp_DeleteMovie)
---------------------------------------------------------------
EXEC dbo.sp_DeleteMovie
    @movie_id = @empMovieId;
-- Kiểm tra trạng thái
SELECT movie_id, status
FROM dbo.Movie
WHERE movie_id = @empMovieId;
GO

---------------------------------------------------------------
-- 4. Thêm suất chiếu (sp_AddShowtime)
---------------------------------------------------------------
DECLARE 
    @empShowtimeId INT,
    @empStart      DATETIME = DATEADD(DAY, 1, GETDATE());
EXEC dbo.sp_AddShowtime
    @movie_id        = @empMovieId,
    @cinema_id       = 1,             -- Giả sử Cinema 1 tồn tại
    @start_time      = @empStart,
    @price           = 150000,
    @showtime_id_out = @empShowtimeId OUTPUT;
SELECT @empShowtimeId AS EmpCreatedShowtimeId;
GO

---------------------------------------------------------------
-- 5. Cập nhật suất chiếu (sp_UpdateShowtime)
---------------------------------------------------------------
DECLARE @empNewStart DATETIME = DATEADD(DAY, 2, GETDATE());
EXEC dbo.sp_UpdateShowtime
    @showtime_id = @empShowtimeId,
    @start_time  = @empNewStart,
    @price       = 140000;
-- Kiểm tra cập nhật
SELECT showtime_id, start_time, price
FROM dbo.Showtime
WHERE showtime_id = @empShowtimeId;
GO

---------------------------------------------------------------
-- 6. Xóa suất chiếu (sp_DeleteShowtime)
---------------------------------------------------------------
EXEC dbo.sp_DeleteShowtime
    @showtime_id = @empShowtimeId;
-- Xác nhận đã xóa
SELECT COUNT(*) AS EmpShowtimeExists
FROM dbo.Showtime
WHERE showtime_id = @empShowtimeId;
GO

---------------------------------------------------------------
-- 7. Báo cáo doanh thu theo ngày (sp_GetRevenueByDate)
---------------------------------------------------------------
DECLARE
    @repStart DATETIME = DATEADD(DAY, -7, GETDATE()),
    @repEnd   DATETIME = GETDATE();
EXEC dbo.sp_GetRevenueByDate
    @start_date = @repStart,
    @end_date   = @repEnd;
GO

---------------------------------------------------------------
-- 8. Xem View báo cáo ngày (vw_DailyRevenue)
---------------------------------------------------------------
SELECT *
FROM dbo.vw_DailyRevenue
WHERE [Date] BETWEEN @repStart AND @repEnd;
GO

PRINT '=== Kết thúc Demo nghiệp vụ Nhân viên ===';
