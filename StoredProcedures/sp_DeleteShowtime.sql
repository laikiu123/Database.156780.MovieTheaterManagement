-- ================================================
-- Proc: sp_DeleteShowtime
-- Mô tả: Xóa một suất chiếu khỏi bảng Showtime (physical delete)
--
-- Đầu vào:
--   @showtime_id   INT  – Mã suất chiếu cần xóa
--
-- Logic:
--   1. Kiểm tra existence của showtime_id trong bảng Showtime
--   2. Kiểm tra ràng buộc FK với OrderDetail:
--        • Nếu đã có bản ghi OrderDetail liên quan (dù đơn đã hủy hay chưa),
--          không cho phép xóa để bảo toàn lịch sử giao dịch
--   3. Thực hiện DELETE trên bảng Showtime
--
-- Quan hệ/FK:
--   • OrderDetail.showtime_id → Showtime.showtime_id
--   • Showtime.movie_id        → Movie.movie_id
--   • Showtime.cinema_id       → Cinema.cinema_id
-- ================================================
CREATE PROCEDURE dbo.sp_DeleteShowtime
    @showtime_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra existence của Showtime
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Showtime
            WHERE showtime_id = @showtime_id
        )
        BEGIN
            RAISERROR(
                N'Showtime với showtime_id = %d không tồn tại.',
                16, 1, @showtime_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Kiểm tra ràng buộc với OrderDetail
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM dbo.OrderDetail
            WHERE showtime_id = @showtime_id
        )
        BEGIN
            RAISERROR(
                N'Không thể xóa Showtime %d vì đã có đơn hàng liên quan.',
                16, 1, @showtime_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Thực hiện DELETE
        ------------------------------------------------------------
        DELETE FROM dbo.Showtime
        WHERE showtime_id = @showtime_id;
    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Bắt và re-raise lỗi
        ------------------------------------------------------------
        DECLARE
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();
        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH;
END
GO
