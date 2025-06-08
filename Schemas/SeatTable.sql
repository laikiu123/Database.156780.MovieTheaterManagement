-- ================================================
-- 3. TẠO BẢNG Seat
-- Lưu thông tin về từng ghế trong mỗi rạp
-- ================================================
CREATE TABLE Seat (
    seat_id     INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    cinema_id   INT              NOT NULL
        CONSTRAINT fk_seat_cinema 
        REFERENCES Cinema(cinema_id),
        -- Khóa ngoại liên kết với Cinema
    row_number  NVARCHAR(5)      NOT NULL,
        -- Mã hàng (ví dụ: 'A', 'B', 'C'…)
    col_number  INT              NOT NULL 
        CHECK (col_number > 0),
        -- Số cột (1, 2, 3…), bắt buộc >0
    seat_type   NVARCHAR(50)     NOT NULL 
        CONSTRAINT chk_seat_type 
        CHECK (seat_type IN (N'Thường', N'VIP', N'NgườiKhuyếtTật')),
        -- Loại ghế: Thường, VIP, hoặc dành cho khách khuyết tật
    status      NVARCHAR(20)     NOT NULL 
        CONSTRAINT chk_seat_status 
        CHECK (status IN (N'Available', N'Unavailable'))
        -- Trạng thái ghế: còn/không còn sử dụng
);
GO

-- ================================================
-- CHÈN DỮ LIỆU CHO BẢNG Seat CHO 4 RẠP
-- Rạp gồm:
--   1: Rạp 1  (12 hàng × 16 cột)
--   2: Rạp 2  (10 hàng × 14 cột)
--   3: Rạp 3  (15 hàng × 20 cột)
--   4: Rạp 4  ( 8 hàng × 12 cột)
-- Quy ước seat_type:
--   + Hàng 1–2 (A, B)       → 'VIP'
--   + Hàng cuối cùng       → 'NgườiKhuyếtTật'
--   + Các hàng còn lại     → 'Thường'
-- Tất cả ghế mới có status = 'Available'
-- ================================================
DECLARE 
    @cinema_id      INT,
    @total_rows     INT,
    @total_columns  INT;

DECLARE cinema_cursor CURSOR FOR
    SELECT cinema_id, total_rows, total_columns
      FROM Cinema
     WHERE cinema_id BETWEEN 1 AND 4;  -- Chỉ 4 rạp

OPEN cinema_cursor;
FETCH NEXT FROM cinema_cursor INTO @cinema_id, @total_rows, @total_columns;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @r INT = 1;
    WHILE @r <= @total_rows
    BEGIN
        DECLARE @row_label NVARCHAR(5) = CHAR(64 + @r);  -- 1->A, 2->B, …

        DECLARE @c INT = 1;
        WHILE @c <= @total_columns
        BEGIN
            DECLARE @seat_type NVARCHAR(50) = N'Thường';

            IF @r <= 2
                SET @seat_type = N'VIP';
            IF @r = @total_rows
                SET @seat_type = N'NgườiKhuyếtTật';

            INSERT INTO Seat (
                cinema_id, row_number, col_number, seat_type, status
            )
            VALUES (
                @cinema_id, @row_label, @c, @seat_type, N'Available'
            );

            SET @c += 1;
        END;

        SET @r += 1;
    END;

    FETCH NEXT FROM cinema_cursor INTO @cinema_id, @total_rows, @total_columns;
END;

CLOSE cinema_cursor;
DEALLOCATE cinema_cursor;
GO


select * from Seat