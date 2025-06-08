-- ================================================
-- View: vw_CinemaSeatStatus
-- Mô tả: Hiển thị trạng thái (Booked/Available) của từng ghế cho mỗi suất chiếu
--
-- Quan hệ:
--   • Showtime.cinema_id     → Cinema.cinema_id
--   • Cinema.cinema_id       → Seat.cinema_id
--   • OrderDetail.showtime_id→ Showtime.showtime_id
--   • OrderDetail.seat_id    → Seat.seat_id
--   • Order.order_id         → OrderDetail.order_id
--
-- Cột trả về:
--   • showtime_id     – Mã suất chiếu
--   • cinema_name     – Tên rạp (Cinema.name)
--   • seat_id         – Mã ghế (Seat.seat_id)
--   • row_number      – Hàng ghế
--   • col_number      – Cột ghế
--   • seat_status     – 'Booked' nếu ghế đã được đặt (Order.status = 'ĐãThanhToán'), ngược lại 'Available'
--
-- Điều kiện:
--   • Tạo bản ghi cho mỗi kết hợp (showtime, seat) trong cùng một rạp
--   • Xác định trạng thái ghế dựa trên OrderDetail và Order
-- ================================================
CREATE VIEW dbo.vw_CinemaSeatStatus
AS
SELECT
    st.showtime_id,
    c.name        AS cinema_name,
    s.seat_id,
    s.row_number,
    s.col_number,
    CASE
        WHEN o.status = N'ĐãThanhToán' THEN N'Booked'
        ELSE N'Available'
    END AS seat_status
FROM dbo.Showtime AS st
    INNER JOIN dbo.Cinema AS c
        ON st.cinema_id = c.cinema_id    -- FK: Showtime → Cinema
    INNER JOIN dbo.Seat AS s
        ON s.cinema_id = c.cinema_id     -- FK: Seat → Cinema
    LEFT JOIN dbo.OrderDetail AS od
        ON od.showtime_id = st.showtime_id
       AND od.seat_id     = s.seat_id
    LEFT JOIN dbo.[Order] AS o
        ON od.order_id = o.order_id
        AND o.status   = N'ĐãThanhToán'  -- Chỉ coi ghế đã thanh toán (Booked)
GO

select * from dbo.vw_CinemaSeatStatus