-- ================================================
-- Proc: sp_GetTopMovies
-- Mô tả: Lấy top N phim bán chạy nhất theo doanh thu trong khoảng thời gian cho trước
--
-- Đầu vào:
--   @start_date DATETIME  – Ngày/giờ bắt đầu (inclusive)
--   @end_date   DATETIME  – Ngày/giờ kết thúc (inclusive)
--   @top_n      INT       – Số lượng phim hàng đầu cần lấy (mặc định 10)
--
-- Kết quả trả về (Result set), thứ tự giảm dần theo TotalRevenue:
--   • movie_id      – Mã phim (Movie.movie_id)
--   • movie_title   – Tiêu đề phim (Movie.title)
--   • TicketsSold   – Tổng số vé đã bán (đếm OrderDetail)
--   • TotalRevenue  – Tổng doanh thu (tổng price từ OrderDetail)
--
-- Logic:
--   1. Chỉ xét các Order đã thanh toán (Order.status = 'ĐãThanhToán')
--   2. Kết nối Order → OrderDetail → Showtime → Movie
--   3. Lọc theo khoảng thời gian o.order_date BETWEEN @start_date AND @end_date
--   4. Nhóm theo Movie.movie_id, Movie.title
--   5. Lấy TOP N theo TotalRevenue
--
-- Quan hệ:
--   • Order.order_id       → OrderDetail.order_id
--   • OrderDetail.showtime_id → Showtime.showtime_id
--   • Showtime.movie_id    → Movie.movie_id
-- ================================================
CREATE PROCEDURE dbo.sp_GetTopMovies
    @start_date DATETIME,
    @end_date   DATETIME,
    @top_n      INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- 1. Validate tham số
    ------------------------------------------------------------
    IF @start_date IS NULL OR @end_date IS NULL
    BEGIN
        RAISERROR(N'Bạn phải cung cấp cả @start_date và @end_date.', 16, 1);
        RETURN;
    END
    IF @start_date > @end_date
    BEGIN
        RAISERROR(N'@start_date không được lớn hơn @end_date.', 16, 1);
        RETURN;
    END
    IF @top_n IS NULL OR @top_n <= 0
    BEGIN
        RAISERROR(N'@top_n phải là số nguyên dương.', 16, 1);
        RETURN;
    END

    ------------------------------------------------------------
    -- 2. Truy vấn top N phim theo doanh thu
    ------------------------------------------------------------
    SELECT TOP (@top_n)
        m.movie_id,
        m.title           AS movie_title,
        COUNT(od.order_detail_id) AS TicketsSold,
        SUM(od.price)     AS TotalRevenue
    FROM dbo.[Order] AS o
    INNER JOIN dbo.OrderDetail AS od
        ON o.order_id = od.order_id
    INNER JOIN dbo.Showtime AS st
        ON od.showtime_id = st.showtime_id
    INNER JOIN dbo.Movie AS m
        ON st.movie_id = m.movie_id
    WHERE
        o.status = N'ĐãThanhToán'
        AND o.order_date BETWEEN @start_date AND @end_date
    GROUP BY
        m.movie_id,
        m.title
    ORDER BY
        TotalRevenue DESC;  -- Sắp xếp giảm dần theo doanh thu
END
GO
