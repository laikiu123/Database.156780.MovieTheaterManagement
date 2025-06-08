-- ================================================
-- Proc: sp_UpdateShowtime
-- Mô tả: Cập nhật thông tin một suất chiếu trong bảng Showtime
--
-- Đầu vào:
--   @showtime_id  INT               – Mã suất chiếu cần cập nhật
--   @start_time   DATETIME     = NULL – Thời gian chiếu mới (NULL nếu không đổi)
--   @price        DECIMAL(10,2)= NULL – Giá vé mới (NULL nếu không đổi)
--
-- Logic:
--   1. Kiểm tra existence của showtime_id
--   2. Validate tham số nếu được cung cấp (@start_time không NULL, @price >= 0)
--      – @start_time phải lớn hơn hoặc bằng thời điểm hiện tại
--   3. Cập nhật các trường chỉ khi tham số khác NULL, giữ nguyên giá trị cũ nếu NULL
--   4. Không cho phép đổi movie_id hoặc cinema_id sau khi khởi tạo để tránh bất đồng bộ ghế
--
-- Quan hệ:
--   • Showtime.movie_id  → Movie.movie_id
--   • Showtime.cinema_id → Cinema.cinema_id
--   • Các cập nhật start_time/price không ảnh hưởng đến FK
-- ================================================
CREATE PROCEDURE dbo.sp_UpdateShowtime
    @showtime_id INT,
    @start_time  DATETIME       = NULL,
    @price       DECIMAL(10,2)  = NULL
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
        -- 2. Validate tham số nếu có giá trị truyền vào
        ------------------------------------------------------------
        IF @start_time IS NOT NULL
        BEGIN
            -- Không cho phép đặt thời gian chiếu về quá khứ
            IF @start_time < GETDATE()
            BEGIN
                RAISERROR(
                    N'Thời gian mới (@start_time) phải lớn hơn hoặc bằng thời gian hiện tại.',
                    16, 1
                );
                RETURN;
            END
        END

        IF @price IS NOT NULL
           AND @price < 0
        BEGIN
            RAISERROR(
                N'Giá vé (@price) phải lớn hơn hoặc bằng 0 nếu được cung cấp.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Cập nhật các trường cần thay đổi
        ------------------------------------------------------------
        UPDATE dbo.Showtime
        SET
            start_time = COALESCE(@start_time, start_time),
            price      = COALESCE(@price, price)
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
