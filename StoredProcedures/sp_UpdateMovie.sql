-- ================================================
-- Proc: sp_UpdateMovie
-- Mô tả: Cập nhật thông tin một phim trong bảng Movie
--
-- Đầu vào:
--   @movie_id          INT               – Mã phim cần cập nhật
--   @title             NVARCHAR(200) = NULL – Tiêu đề mới (NULL nếu không đổi)
--   @genre             NVARCHAR(100) = NULL – Thể loại mới (NULL nếu không đổi)
--   @duration_minutes  INT           = NULL – Thời lượng mới (phút, >0 nếu không NULL)
--   @language          NVARCHAR(50)  = NULL – Ngôn ngữ mới (NULL nếu không đổi)
--   @description       NVARCHAR(MAX) = NULL – Mô tả mới (NULL nếu không đổi)
--   @status            NVARCHAR(20)  = NULL – Trạng thái mới: 'ĐangChiếu' hoặc 'NgừngChiếu' (NULL nếu không đổi)
--   @poster_url        NVARCHAR(500) = NULL – URL poster mới (NULL nếu không đổi)
--
-- Logic:
--   1. Kiểm tra existence của movie_id
--   2. Validate tham số (duration >0, status hợp lệ) nếu có giá trị truyền vào
--   3. Cập nhật các trường chỉ khi tham số khác NULL (giữ nguyên giá trị cũ nếu NULL)
--   4. Cập nhật updated_at = GETDATE()
--
-- Quan hệ:
--   • Bảng Showtime có FK st.movie_id → Movie.movie_id; cập nhật title/status tại đây không thay đổi FK.
-- ================================================
CREATE PROCEDURE dbo.sp_UpdateMovie
    @movie_id          INT,
    @title             NVARCHAR(200)    = NULL,
    @genre             NVARCHAR(100)    = NULL,
    @duration_minutes  INT              = NULL,
    @language          NVARCHAR(50)     = NULL,
    @description       NVARCHAR(MAX)    = NULL,
    @status            NVARCHAR(20)     = NULL,
    @poster_url        NVARCHAR(500)    = NULL
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
        -- 2. Validate tham số nếu có giá trị truyền vào
        ------------------------------------------------------------
        IF @duration_minutes IS NOT NULL
           AND @duration_minutes <= 0
        BEGIN
            RAISERROR(
                N'Duration_minutes phải lớn hơn 0 nếu được cung cấp.',
                16, 1
            );
            RETURN;
        END

        IF @status IS NOT NULL
           AND @status NOT IN (N'ĐangChiếu', N'NgừngChiếu')
        BEGIN
            RAISERROR(
                N'Status phải là ''ĐangChiếu'' hoặc ''NgừngChiếu'' nếu được cung cấp.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Thực hiện cập nhật
        ------------------------------------------------------------
        UPDATE dbo.Movie
        SET
            title            = COALESCE(@title, title),
            genre            = COALESCE(@genre, genre),
            duration_minutes = COALESCE(@duration_minutes, duration_minutes),
            language         = COALESCE(@language, language),
            description      = COALESCE(@description, description),
            status           = COALESCE(@status, status),
            poster_url       = COALESCE(@poster_url, poster_url),
            updated_at       = GETDATE()
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
