-- ================================================
-- View: vw_AvailableShowtimes
-- Mô tả: Hiển thị danh sách tất cả các suất chiếu có ghế trống
-- Quan hệ:
--   • Showtime.movie_id  → Movie.movie_id
--   • Showtime.cinema_id → Cinema.cinema_id
-- Các cột trả về:
--   • showtime_id     – Khóa chính của suất chiếu
--   • movie_id        – Khóa ngoại liên kết đến phim
--   • movie_title     – Tiêu đề phim (Movie.title)
--   • cinema_id       – Khóa ngoại liên kết đến rạp
--   • cinema_name     – Tên rạp (Cinema.name)
--   • start_time      – Thời gian bắt đầu chiếu
--   • price           – Giá vé
--   • available_seats – Số ghế trống hiện tại
-- Điều kiện lọc:
--   • Chỉ bao gồm các bản ghi có available_seats > 0
-- ================================================
CREATE VIEW dbo.vw_AvailableShowtimes
AS
SELECT
    st.showtime_id,
    st.movie_id,
    m.title           AS movie_title,
    st.cinema_id,
    c.name            AS cinema_name,
    st.start_time,
    st.price,
    st.available_seats
FROM dbo.Showtime AS st
    INNER JOIN dbo.Movie  AS m
        ON st.movie_id  = m.movie_id     -- FK: Showtime → Movie
    INNER JOIN dbo.Cinema AS c
        ON st.cinema_id = c.cinema_id    -- FK: Showtime → Cinema
WHERE st.available_seats > 0;            -- Lọc suất chiếu còn ghế trống
GO

select * from dbo.vw_AvailableShowtimes