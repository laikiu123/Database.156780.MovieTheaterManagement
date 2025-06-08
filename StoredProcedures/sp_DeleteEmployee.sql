-- ================================================
-- Proc: sp_DeleteEmployee
-- Mô tả: Xóa một nhân viên khỏi bảng Employee (physical delete)
--
-- Đầu vào:
--   @employee_id   INT  – Mã nhân viên cần xóa
--
-- Logic:
--   1. Kiểm tra existence của Employee
--   2. Kiểm tra ràng buộc FK: không cho xóa nếu nhân viên đã xử lý đơn hàng
--   3. Nếu an toàn, thực hiện DELETE
--
-- Quan hệ/FK:
--   • [Order].employee_id → Employee.employee_id
--     – Nếu một Order đã gán employee_id thì không xóa được để tránh phá rối lịch sử
-- ================================================
CREATE PROCEDURE dbo.sp_DeleteEmployee
    @employee_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra existence của Employee
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Employee
            WHERE employee_id = @employee_id
        )
        BEGIN
            RAISERROR(
                N'Employee với employee_id = %d không tồn tại.',
                16, 1, @employee_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Kiểm tra ràng buộc FK với Order
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM dbo.[Order]
            WHERE employee_id = @employee_id
        )
        BEGIN
            RAISERROR(
                N'Không thể xóa nhân viên %d vì đã có đơn hàng được xử lý bởi họ.',
                16, 1, @employee_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Thực hiện DELETE
        ------------------------------------------------------------
        DELETE FROM dbo.Employee
        WHERE employee_id = @employee_id;

    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Bắt lỗi và re-raise
        ------------------------------------------------------------
        DECLARE
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();
        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH;
END
GO
