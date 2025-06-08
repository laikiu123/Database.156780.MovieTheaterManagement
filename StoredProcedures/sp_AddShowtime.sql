-- ================================================
-- Proc: sp_AddShowtime
-- Mô tả: Thêm mới một suất chiếu vào bảng Showtime
--
-- Đầu vào:
--   @movie_id           INT            – Mã phim (FK → Movie.movie_id)
--   @cinema_id          INT            – Mã rạp (FK → Cinema.cinema_id)
--   @start_time         DATETIME       – Thời gian bắt đầu chiếu
--   @price              DECIMAL(10,2)  – Giá vé (>= 0)
--   @showtime_id_out    INT OUTPUT     – OUTPUT: showtime_id sinh ra
--
-- Logic:
--   1. Validate existence của Movie và Cinema
--   2. Validate start_time và price
--   3. Tính total_seats từ số ghế trong Cinema (COUNT(*) FROM Seat)
--   4. Thiết lập available_seats = total_seats
--   5. INSERT vào Showtime
--   6. Trả về showtime_id mới qua OUTPUT
--
-- Quan hệ:
--   • Showtime.movie_id  → Movie.movie_id
--   • Showtime.cinema_id → Cinema.cinema_id
-- ================================================
CREATE PROCEDURE dbo.sp_AddShowtime
    @movie_id        INT,
    @cinema_id       INT,
    @start_time      DATETIME,
    @price           DECIMAL(10,2),
    @showtime_id_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra existence của Movie
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Movie
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
        -- 2. Kiểm tra existence của Cinema
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Cinema
            WHERE cinema_id = @cinema_id
        )
        BEGIN
            RAISERROR(
                N'Cinema với cinema_id = %d không tồn tại.',
                16, 1, @cinema_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Validate start_time và price
        ------------------------------------------------------------
        IF @start_time IS NULL
        BEGIN
            RAISERROR(N'Bạn phải cung cấp @start_time.', 16, 1);
            RETURN;
        END

        IF @price IS NULL OR @price < 0
        BEGIN
            RAISERROR(N'@price phải >= 0.', 16, 1);
            RETURN;
        END

        ------------------------------------------------------------
        -- 4. Tính tổng số ghế của phòng chiếu (total_seats)
        ------------------------------------------------------------
        DECLARE @total_seats INT;
        SELECT @total_seats = COUNT(*)
        FROM dbo.Seat
        WHERE cinema_id = @cinema_id;

        ------------------------------------------------------------
        -- 5. Thực hiện INSERT vào bảng Showtime
        ------------------------------------------------------------
        INSERT INTO dbo.Showtime (
            movie_id,
            cinema_id,
            start_time,
            price,
            total_seats,
            available_seats
        )
        VALUES (
            @movie_id,
            @cinema_id,
            @start_time,
            @price,
            @total_seats,
            @total_seats        -- lúc khởi tạo, ghế trống = tổng số ghế
        );

        -- Lấy showtime_id mới sinh
        SET @showtime_id_out = SCOPE_IDENTITY();
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
