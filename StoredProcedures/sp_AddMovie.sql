-- ================================================
-- Proc: sp_AddMovie
-- Mô tả: Thêm mới một phim vào bảng Movie
--
-- Đầu vào:
--   @title             NVARCHAR(200)    – Tiêu đề phim (bắt buộc, không trùng rỗng)
--   @genre             NVARCHAR(100)    – Thể loại phim (có thể NULL)
--   @duration_minutes  INT              – Thời lượng phim (phút, bắt buộc > 0)
--   @language          NVARCHAR(50)     – Ngôn ngữ chính (có thể NULL)
--   @description       NVARCHAR(MAX)    – Mô tả chi tiết (có thể NULL)
--   @status            NVARCHAR(20)     – Trạng thái phim: 'ĐangChiếu' hoặc 'NgừngChiếu' (mặc định 'ĐangChiếu')
--   @poster_url        NVARCHAR(500)    – URL hình poster (có thể NULL)
--   @movie_id_out      INT OUTPUT       – OUTPUT: movie_id sinh ra
--
-- Logic:
--   1. Validate: title không rỗng, duration_minutes > 0.
--   2. (Tuỳ chọn) Có thể kiểm tra duplicate dựa trên title nếu muốn.
--   3. Thực hiện INSERT.
--   4. Trả về movie_id mới qua OUTPUT.
--
-- Quan hệ:
--   • Movie table chỉ lưu thông tin phim độc lập, chưa liên kết FK ở đây.
-- ================================================
CREATE PROCEDURE dbo.sp_AddMovie
    @title            NVARCHAR(200),
    @genre            NVARCHAR(100)    = NULL,
    @duration_minutes INT,
    @language         NVARCHAR(50)     = NULL,
    @description      NVARCHAR(MAX)    = NULL,
    @status           NVARCHAR(20)     = N'ĐangChiếu',
    @poster_url       NVARCHAR(500)    = NULL,
    @movie_id_out     INT              OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Validate các tham số đầu vào
        ------------------------------------------------------------
        IF @title IS NULL OR LTRIM(RTRIM(@title)) = N''
        BEGIN
            RAISERROR(N'Tiêu đề phim (@title) không được để trống.', 16, 1);
            RETURN;
        END

        IF @duration_minutes IS NULL OR @duration_minutes <= 0
        BEGIN
            RAISERROR(N'Thời lượng phim (@duration_minutes) phải lớn hơn 0.', 16, 1);
            RETURN;
        END

        IF @status NOT IN (N'ĐangChiếu', N'NgừngChiếu')
        BEGIN
            RAISERROR(
                N'Trạng thái phim (@status) phải là ''ĐangChiếu'' hoặc ''NgừngChiếu''.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. (Tuỳ chọn) Kiểm tra duplicate title
        --    Nếu muốn ngăn trùng tiêu đề: bỏ comment khối dưới
        ------------------------------------------------------------
        /*
        IF EXISTS (
            SELECT 1
            FROM dbo.Movie
            WHERE title = @title
        )
        BEGIN
            RAISERROR(
                N'Phim với tiêu đề "%s" đã tồn tại.', 
                16, 1, @title
            );
            RETURN;
        END
        */

        ------------------------------------------------------------
        -- 3. Thực hiện INSERT vào bảng Movie
        ------------------------------------------------------------
        INSERT INTO dbo.Movie (
            title,
            genre,
            duration_minutes,
            language,
            description,
            status,
            poster_url
        )
        VALUES (
            @title,
            @genre,
            @duration_minutes,
            @language,
            @description,
            @status,
            @poster_url
        );

        -- Lấy movie_id mới sinh
        SET @movie_id_out = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Bắt lỗi và re-raise ra ngoài caller
        ------------------------------------------------------------
        DECLARE 
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();
        RAISERROR(@err_msg, @err_sev, @err_state);
        RETURN;
    END CATCH;
END
GO
