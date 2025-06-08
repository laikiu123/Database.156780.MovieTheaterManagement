-- ================================================
-- Proc: sp_CancelOrder
-- Mô tả: Hủy một Order và hoàn trả ghế cho suất chiếu tương ứng
--
-- Đầu vào:
--   @order_id   INT  – Mã đơn hàng cần hủy
--
-- Logic:
--   1. Kiểm tra existence của Order
--   2. Đọc trạng thái hiện tại
--      • Nếu đã huỷ sẵn thì raise error
--      • Nếu trạng thái không phải 'ChưaThanhToán' hoặc 'ĐãThanhToán' thì raise error
--   3. Tính số ghế cần trả lại: đếm nhóm theo showtime_id trong OrderDetail
--      – Quan hệ: OrderDetail.order_id → Order.order_id
--      – Quan hệ: OrderDetail.showtime_id → Showtime.showtime_id
--   4. Cập nhật lại available_seats trong bảng Showtime
--   5. Cập nhật Order.status = 'ĐãHuỷ'
--   6. (Không xóa OrderDetail để giữ lịch sử; OrderDetail với Order.status != 'ĐãThanhToán' sẽ không chặn ghế)
--   7. Toàn bộ trong 1 transaction để đảm bảo atomicity
-- ================================================
CREATE PROCEDURE sp_CancelOrder
    @order_id INT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra existence của Order
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM [Order]
            WHERE order_id = @order_id
        )
        BEGIN
            RAISERROR(
                N'Order với order_id = %d không tồn tại.',
                16, 1, @order_id
            );
            ROLLBACK;
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Đọc trạng thái hiện tại của Order
        ------------------------------------------------------------
        DECLARE @curr_status NVARCHAR(20);
        SELECT @curr_status = status
        FROM [Order]
        WHERE order_id = @order_id;

        IF @curr_status = N'ĐãHuỷ'
        BEGIN
            RAISERROR(
                N'Order %d đã ở trạng thái "ĐãHuỷ".',
                16, 1, @order_id
            );
            ROLLBACK;
            RETURN;
        END

        IF @curr_status NOT IN (N'ChưaThanhToán', N'ĐãThanhToán')
        BEGIN
            RAISERROR(
                N'Không thể hủy Order %d khi trạng thái hiện tại: %s.',
                16, 1, @order_id, @curr_status
            );
            ROLLBACK;
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Tính số ghế cần hoàn trả, nhóm theo showtime_id
        ------------------------------------------------------------
        -- Sử dụng CTE để lấy số lượng ghế của từng suất chiếu
        ;WITH SeatCounts AS (
            SELECT 
                od.showtime_id,
                COUNT(*) AS cnt
            FROM OrderDetail AS od
            WHERE od.order_id = @order_id
            GROUP BY od.showtime_id
        )
        ------------------------------------------------------------
        -- 4. Cập nhật lại available_seats trong bảng Showtime
        ------------------------------------------------------------
        UPDATE st
        SET st.available_seats = st.available_seats + sc.cnt
        FROM Showtime AS st
        JOIN SeatCounts AS sc
          ON st.showtime_id = sc.showtime_id;
        -- Quan hệ: Showtime.showtime_id ← OrderDetail.showtime_id

        ------------------------------------------------------------
        -- 5. Cập nhật trạng thái Order thành 'ĐãHuỷ'
        ------------------------------------------------------------
        UPDATE [Order]
        SET status = N'ĐãHuỷ'
        WHERE order_id = @order_id;

        ------------------------------------------------------------
        -- 6. Commit transaction
        ------------------------------------------------------------
        COMMIT;
    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- 7. Xử lý lỗi: rollback và re-raise lỗi
        ------------------------------------------------------------
        IF XACT_STATE() <> 0
            ROLLBACK;

        DECLARE
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();

        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH
END
GO
