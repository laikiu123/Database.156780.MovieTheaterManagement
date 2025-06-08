-- ================================================
-- Proc: sp_CreateOrder
-- Mô tả: Tạo mới một đơn đặt vé (Order + OrderDetail) cho một suất chiếu
--
-- Đầu vào:
--   @customer_id    INT            – Mã khách hàng (FK → Customer.customer_id)
--   @showtime_id    INT            – Mã suất chiếu (FK → Showtime.showtime_id)
--   @seat_ids       NVARCHAR(MAX)  – Danh sách seat_id tách bởi dấu phẩy (ví dụ: '1,2,3')
--   @employee_id    INT    = NULL  – Mã nhân viên xử lý (nếu đặt offline; NULL nếu online)
--
-- Đầu ra:
--   @order_id_out   INT OUTPUT     – Mã đơn hàng vừa sinh (Order.order_id)
--
-- Logic:
--   1. Validate existence của Customer, Showtime
--   2. Parse @seat_ids thành table variable @SeatList
--   3. Validate mỗi seat_id:
--       • Thuộc cùng cinema với Showtime
--       • Có status = 'Available'
--       • Chưa được đặt (OrderDetail + Order.status = 'ĐãThanhToán')
--   4. Tính:
--       • @unit_price    = Showtime.price
--       • @seat_count    = COUNT(@SeatList)
--       • @total_amount  = @unit_price * @seat_count
--       • Đảm bảo @seat_count <= Showtime.available_seats
--   5. Trong TRANSACTION:
--       a) INSERT Order với status = 'ChưaThanhToán', tổng tiền = @total_amount
--       b) OUTPUT SCOPE_IDENTITY() → @order_id_out
--       c) INSERT OrderDetail cho mỗi seat trong @SeatList
--       d) UPDATE Showtime.available_seats -= @seat_count
--   6. Commit/rollback
--
-- Quan hệ:
--   • Order.customer_id    → Customer.customer_id
--   • Order.employee_id    → Employee.employee_id (có thể NULL)
--   • OrderDetail.order_id → Order.order_id
--   • OrderDetail.showtime_id → Showtime.showtime_id
--   • OrderDetail.seat_id  → Seat.seat_id
--   • Showtime.cinema_id   → Seat.cinema_id
-- ================================================
CREATE PROCEDURE dbo.sp_CreateOrder
    @customer_id    INT,
    @showtime_id    INT,
    @seat_ids       NVARCHAR(MAX),
    @employee_id    INT            = NULL,
    @order_id_out   INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Validate existence của Customer
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Customer WHERE customer_id = @customer_id
        )
        BEGIN
            RAISERROR(N'Customer_id = %d không tồn tại.', 16, 1, @customer_id);
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Validate existence của Showtime và lấy thông tin cần thiết
        ------------------------------------------------------------
        DECLARE @cinema_id      INT,
                @unit_price     DECIMAL(10,2),
                @avail_seats    INT;
        SELECT
            @cinema_id   = cinema_id,
            @unit_price  = price,
            @avail_seats = available_seats
        FROM dbo.Showtime
        WHERE showtime_id = @showtime_id;

        IF @cinema_id IS NULL
        BEGIN
            RAISERROR(N'Showtime_id = %d không tồn tại.', 16, 1, @showtime_id);
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Parse danh sách seat_ids vào table variable
        ------------------------------------------------------------
        DECLARE @SeatList TABLE (seat_id INT PRIMARY KEY);
        INSERT INTO @SeatList(seat_id)
        SELECT
            TRY_CAST(LTRIM(RTRIM(value)) AS INT)
        FROM STRING_SPLIT(@seat_ids, ',')
        WHERE TRY_CAST(LTRIM(RTRIM(value)) AS INT) IS NOT NULL;

        -- Đếm số seat hợp lệ
        DECLARE @seat_count INT = (SELECT COUNT(*) FROM @SeatList);
        IF @seat_count = 0
        BEGIN
            RAISERROR(N'Phải cung cấp ít nhất một seat_id hợp lệ.', 16, 1);
            RETURN;
        END

        ------------------------------------------------------------
        -- 4. Validate seat_ids thuộc cùng cinema và có status = 'Available'
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM @SeatList sl
            LEFT JOIN dbo.Seat s
              ON sl.seat_id = s.seat_id
             AND s.cinema_id = @cinema_id
             AND s.status = N'Available'
            WHERE s.seat_id IS NULL
        )
        BEGIN
            RAISERROR(
                N'Một hoặc nhiều seat_id không hợp lệ hoặc không còn trống cho showtime này.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 5. Check ghế chưa được đặt thành công (OrderDetail + Order.status)
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM @SeatList sl
            JOIN dbo.OrderDetail od
              ON sl.seat_id = od.seat_id
             AND od.showtime_id = @showtime_id
            JOIN dbo.[Order] o
              ON od.order_id = o.order_id
             AND o.status = N'ĐãThanhToán'
        )
        BEGIN
            RAISERROR(
                N'Một hoặc nhiều ghế đã được đặt trước đó cho suất chiếu này.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 6. Đảm bảo đủ ghế trống trong Showtime
        ------------------------------------------------------------
        IF @seat_count > @avail_seats
        BEGIN
            RAISERROR(
                N'Số ghế yêu cầu (%d) vượt quá số ghế trống hiện có (%d).',
                16, 1, @seat_count, @avail_seats
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 7. Tính tổng tiền và tạo Order trong TRANSACTION
        ------------------------------------------------------------
        DECLARE @total_amount DECIMAL(12,2) = @unit_price * @seat_count;

        BEGIN TRANSACTION;
            -- a) Insert Order với trạng thái 'ChưaThanhToán'
            INSERT INTO dbo.[Order] (
                customer_id,
                employee_id,
                total_amount,
                status
            )
            VALUES (
                @customer_id,
                @employee_id,
                @total_amount,
                N'ChưaThanhToán'
            );
            SET @order_id_out = SCOPE_IDENTITY();

            -- b) Insert OrderDetail cho mỗi seat
            INSERT INTO dbo.OrderDetail (
                order_id,
                showtime_id,
                seat_id,
                price
            )
            SELECT
                @order_id_out,
                @showtime_id,
                seat_id,
                @unit_price
            FROM @SeatList;

            -- c) Cập nhật lại available_seats
            UPDATE dbo.Showtime
            SET available_seats = available_seats - @seat_count
            WHERE showtime_id = @showtime_id;

        COMMIT;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK;

        DECLARE
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();
        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH;
END
GO
