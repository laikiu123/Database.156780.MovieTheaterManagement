/*
-- Tạo các INDEX tối ưu cho các bảng chính
-- Giúp tăng tốc độ truy vấn, đặc biệt với các cột thường dùng trong WHERE, JOIN hoặc ORDER BY
*/

-- 1. INDEX cho bảng Movie: lọc phim theo trạng thái
CREATE INDEX idx_movie_status
    ON Movie(status);
GO

-- 2. INDEX cho bảng Showtime:
--    • Tìm lịch chiếu của một phim theo ngày nhanh hơn
--    • Tìm suất chiếu tại một rạp theo ngày nhanh hơn
CREATE INDEX idx_showtime_movie_start
    ON Showtime(movie_id, start_time);
GO
CREATE INDEX idx_showtime_cinema_start
    ON Showtime(cinema_id, start_time);
GO

-- 3. INDEX cho bảng Seat: liệt kê ghế theo rạp
CREATE INDEX idx_seat_cinema
    ON Seat(cinema_id);
GO

-- 4. INDEX cho bảng [Order]:
--    • Truy vấn đơn hàng của khách
--    • Lọc và thống kê theo trạng thái, thời gian
CREATE INDEX idx_order_customer_date
    ON [Order](customer_id, order_date);
GO
CREATE INDEX idx_order_status_date
    ON [Order](status, order_date);
GO

-- 5. INDEX cho bảng OrderDetail:
--    • Join nhanh với Order
--    • (showtime_id, seat_id) đã có UNIQUE INDEX từ constraint uq_od_showtime_seat
--    • Bổ sung INDEX cho order_id để join vào Order
CREATE INDEX idx_od_order
    ON OrderDetail(order_id);
GO
