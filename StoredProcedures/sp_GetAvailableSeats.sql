-- ================================================
-- Proc: sp_GetAvailableSeats
-- Mô tả: Lấy danh sách các ghế còn trống cho một suất chiếu
--
-- Đầu vào:
--   @showtime_id INT  – mã suất chiếu cần kiểm tra
--
-- Kết quả trả về:
--   seat_id      – Khóa chính của bảng Seat
--   row_number   – Hàng của ghế
--   col_number   – Cột của ghế
--   seat_type    – Loại ghế (Thường/VIP/NgườiKhuyếtTật)
--
-- Logic:
--   1. Kiểm tra xem showtime_id có tồn tại trong bảng Showtime không
--   2. Lấy tất cả hàng–cột ghế (Seat) thuộc cùng Cinema với suất chiếu
--      – Quan hệ: Seat.cinema_id → Cinema.cinema_id
--      – Quan hệ: Showtime.cinema_id → Cinema.cinema_id
--   3. Chỉ chọn những ghế đang ở trạng thái 'Available'
--      – Thuộc tính: Seat.status
--   4. Loại bỏ những ghế đã được đặt thành công:
--      – Quan hệ: OrderDetail.seat_id → Seat.seat_id
--      – Quan hệ: OrderDetail.showtime_id → Showtime.showtime_id
--      – Quan hệ: OrderDetail.order_id → Order.order_id
--      – Chỉ loại ghế thuộc các Order có status = 'ĐãThanhToán'
-- ================================================
CREATE PROCEDURE sp_GetAvailableSeats
    @showtime_id INT
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- 1. Validate: kiểm tra existence của showtime_id
    ------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1
        FROM Showtime
        WHERE showtime_id = @showtime_id
    )
    BEGIN
        RAISERROR(
            N'Mã suất chiếu %d không tồn tại.', 
            16, 1, 
            @showtime_id
        );
        RETURN;
    END

    ------------------------------------------------------------
    -- 2. Truy vấn ghế trống
    ------------------------------------------------------------
    SELECT
        s.seat_id,
        s.row_number,
        s.col_number,
        s.seat_type
    FROM Seat AS s
    INNER JOIN Showtime AS st
        ON s.cinema_id = st.cinema_id
        -- Quan hệ: Seat.cinema_id → Showtime.cinema_id
        AND st.showtime_id = @showtime_id
    WHERE
        s.status = N'Available'  -- chỉ chọn ghế chưa được đánh dấu hỏng/không sử dụng
        AND NOT EXISTS (
            -- Loại ghế đã được đặt thành công (order.status = 'ĐãThanhToán')
            SELECT 1
            FROM OrderDetail AS od
            INNER JOIN [Order] AS o
                ON od.order_id = o.order_id
                AND o.status = N'ĐãThanhToán'
            WHERE
                od.showtime_id = @showtime_id
                AND od.seat_id     = s.seat_id
        )
    ORDER BY
        s.row_number,   -- ưu tiên theo thứ tự hàng
        s.col_number;   -- sau đó theo thứ tự cột
END
GO
