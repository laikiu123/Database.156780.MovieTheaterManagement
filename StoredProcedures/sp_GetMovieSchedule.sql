-- ================================================
-- Proc: sp_GetMovieSchedule
-- Mô tả: Lấy danh sách các suất chiếu của phim theo điều kiện lọc
-- Đầu vào:
--   @movie_id   INT           = NULL   -- Lọc theo mã phim (NULL là lấy tất cả phim)
--   @cinema_id  INT           = NULL   -- Lọc theo mã rạp (NULL là lấy tất cả rạp)
--   @date_from  DATETIME                  -- Ngày/giờ bắt đầu khoảng lấy lịch
--   @date_to    DATETIME                  -- Ngày/giờ kết thúc khoảng lấy lịch
-- Đầu ra:
--   Bảng tạm gồm các cột:
--     • showtime_id     – khóa chính của bảng Showtime
--     • movie_id        – khóa ngoại liên kết với Movie(movie_id)
--     • movie_title     – tiêu đề phim (từ Movie.title)
--     • cinema_id       – khóa ngoại liên kết với Cinema(cinema_id)
--     • cinema_name     – tên rạp (từ Cinema.name)
--     • start_time      – thời gian bắt đầu suất chiếu
--     • price           – giá vé
--     • total_seats     – tổng số ghế của suất chiếu (lấy từ trường total_seats)
--     • available_seats – số ghế trống hiện tại (lấy từ trường available_seats)
-- 
-- Quan hệ:
--   • Showtime.movie_id  → Movie.movie_id
--   • Showtime.cinema_id → Cinema.cinema_id
-- ================================================
CREATE PROCEDURE sp_GetMovieSchedule
    @movie_id   INT         = NULL,
    @cinema_id  INT         = NULL,
    @date_from  DATETIME,
    @date_to    DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    ------------------------------------------------------------
    -- 1. Kiểm tra tham số ngày
    ------------------------------------------------------------
    IF @date_from IS NULL OR @date_to IS NULL
    BEGIN
        RAISERROR(N'Bạn phải cung cấp @date_from và @date_to.', 16, 1);
        RETURN;
    END
    IF @date_from > @date_to
    BEGIN
        RAISERROR(N'@date_from không được lớn hơn @date_to.', 16, 1);
        RETURN;
    END

    ------------------------------------------------------------
    -- 2. Truy vấn suất chiếu
    ------------------------------------------------------------
    SELECT
        st.showtime_id,
        st.movie_id,
        m.title          AS movie_title,
        st.cinema_id,
        c.name           AS cinema_name,
        st.start_time,
        st.price,
        st.total_seats,
        st.available_seats
    FROM Showtime AS st
    INNER JOIN Movie AS m
        ON st.movie_id = m.movie_id       -- Quan hệ FK: Showtime → Movie
    INNER JOIN Cinema AS c
        ON st.cinema_id = c.cinema_id     -- Quan hệ FK: Showtime → Cinema
    WHERE
        (@movie_id  IS NULL OR st.movie_id  = @movie_id)
        AND (@cinema_id IS NULL OR st.cinema_id = @cinema_id)
        AND st.start_time BETWEEN @date_from AND @date_to
    ORDER BY st.start_time;
END
GO
