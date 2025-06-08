-- ================================================
-- Proc: sp_DeleteMovie
-- Mô tả: “Xoá” một phim bằng cách chuyển trạng thái sang 'NgừngChiếu'
--        (Soft delete). Không xóa vật lý để giữ lịch sử và tránh lỗi FK.
--
-- Đầu vào:
--   @movie_id   INT  – Mã phim cần xóa (đánh dấu ngừng chiếu)
--
-- Logic:
--   1. Kiểm tra movie_id có tồn tại không
--   2. Đọc trạng thái hiện tại:
--        • Nếu đã là 'NgừngChiếu' thì báo lỗi (đã xóa trước đó)
--   3. Cập nhật Movie.status = 'NgừngChiếu' và updated_at = GETDATE()
--
-- Quan hệ/FK:
--   • Bảng Showtime có FK st.movie_id → Movie.movie_id
--     – Khi soft-delete phim, tất cả showtime liên quan vẫn giữ nguyên
--       (nếu cần, frontend/backend sẽ không hiển thị các showtime này vì phim đã ngừng chiếu)
-- ================================================
CREATE PROCEDURE dbo.sp_DeleteMovie
    @movie_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra existence của Movie
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Movie
            WHERE movie_id = @movie_id
        )
        BEGIN
            RAISERROR(
                N'Movie với movie_id = %d không tồn tại.', 
                16, 1, @movie_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Kiểm tra trạng thái hiện tại
        ------------------------------------------------------------
        DECLARE @curr_status NVARCHAR(20);
        SELECT @curr_status = status
        FROM dbo.Movie
        WHERE movie_id = @movie_id;

        IF @curr_status = N'NgừngChiếu'
        BEGIN
            RAISERROR(
                N'Movie %d đã ở trạng thái "NgừngChiếu".', 
                16, 1, @movie_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Cập nhật soft-delete: chuyển status và cập nhật thời gian
        ------------------------------------------------------------
        UPDATE dbo.Movie
        SET 
            status     = N'NgừngChiếu',
            updated_at = GETDATE()
        WHERE movie_id = @movie_id;

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
