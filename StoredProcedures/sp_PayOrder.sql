-- ================================================
-- Proc: sp_PayOrder
-- Mô tả: Thanh toán cho một Order chưa được thanh toán
--
-- Đầu vào:
--   @order_id         INT                – Mã đơn cần thanh toán
--   @payment_method   NVARCHAR(20)       – Phương thức thanh toán: 'TiềnMặt', 'Thẻ', 'Ví'
--   @transaction_code NVARCHAR(100) = NULL – Mã giao dịch (nếu có, ví dụ mã VNPAY, MoMo)
--
-- Logic:
--   1. Kiểm tra existence của order_id trong bảng [Order]
--   2. Đảm bảo order đang ở trạng thái 'ChưaThanhToán'
--   3. Cập nhật:
--        • status        = 'ĐãThanhToán'
--        • payment_method = @payment_method
--        • payment_date   = GETDATE()
--        • (có thể lưu @transaction_code nếu thêm cột transaction_code)
--   4. Đảm bảo atomic: dùng transaction
--   5. Khi thành công trả về thông báo, khi lỗi rollback và raise error
--
-- Quan hệ:
--   • [Order].order_id     → làm việc với bảng Order
--   • [Order].status       → liên kết với business flow của Order
--   • [Order].payment_method / payment_date
-- ================================================
CREATE PROCEDURE sp_PayOrder
    @order_id         INT,
    @payment_method   NVARCHAR(20),
    @transaction_code NVARCHAR(100) = NULL
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
            RAISERROR(N'Order với order_id = %d không tồn tại.', 16, 1, @order_id);
            ROLLBACK;
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Kiểm tra trạng thái hiện tại của Order
        ------------------------------------------------------------
        DECLARE @curr_status NVARCHAR(20);
        SELECT @curr_status = status
        FROM [Order]
        WHERE order_id = @order_id;

        IF @curr_status <> N'ChưaThanhToán'
        BEGIN
            RAISERROR(
                N'Order %d không ở trạng thái "ChưaThanhToán" (hiện tại: %s).', 
                16, 1, @order_id, @curr_status
            );
            ROLLBACK;
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Thực hiện cập nhật thanh toán
        ------------------------------------------------------------
        UPDATE [Order]
        SET
            status         = N'ĐãThanhToán',
            payment_method = @payment_method,
            payment_date   = GETDATE()
            -- Nếu có cột transaction_code, thêm: , transaction_code = @transaction_code
        WHERE order_id = @order_id;

        ------------------------------------------------------------
        -- 4. Commit transaction
        ------------------------------------------------------------
        COMMIT;
    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Xử lý lỗi: rollback và raise lỗi
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
