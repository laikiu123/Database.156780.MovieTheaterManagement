-- ================================================
-- 2. TẠO BẢNG Cinema
-- Lưu thông tin về rạp (phòng chiếu)
-- ================================================
CREATE TABLE Cinema (
    cinema_id      INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    name           NVARCHAR(100)    NOT NULL,
        -- Tên rạp (ví dụ: Rạp 1, Rạp 2…)
    location       NVARCHAR(200)    NULL,
        -- Địa điểm hoặc mô tả vị trí
    total_rows     INT              NOT NULL 
        CHECK (total_rows > 0),
        -- Số hàng ghế, bắt buộc >0
    total_columns  INT              NOT NULL 
        CHECK (total_columns > 0),
        -- Số cột ghế, bắt buộc >0
    created_at     DATETIME         NOT NULL DEFAULT GETDATE()
        -- Thời điểm tạo bản ghi
);
GO

-- Khởi tạo một số giá trị
INSERT INTO Cinema
    (name, location, total_rows, total_columns)
VALUES
    (N'Rạp 1',  N'106 Láng Hạ, Ba Đình, Hà Nội',    12, 16),
    (N'Rạp 2',  N'3A Cầu Giấy, Cầu Giấy, Hà Nội',    10, 14),
    (N'Rạp 3',  N'23 Nguyễn Trãi, Thanh Xuân, Hà Nội',15, 20),
    (N'Rạp 4',  N'50 Lý Thái Tổ, Hoàn Kiếm, Hà Nội',  8, 12),
    (N'Rạp 5',  N'88 Trần Duy Hưng, Cầu Giấy, Hà Nội',18, 22),
    (N'Rạp 6',  N'120 Nguyễn Văn Cừ, Long Biên, Hà Nội',14, 18),
    (N'Rạp 7',  N'215 Trần Phú, Hà Đông, Hà Nội',     10, 16),
    (N'Rạp 8',  N'66 Tây Sơn, Đống Đa, Hà Nội',        16, 24);
GO

select * from Cinema
