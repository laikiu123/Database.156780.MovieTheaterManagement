-- ================================================
-- 4. TẠO BẢNG Showtime
-- Lưu thông tin về mỗi suất chiếu của phim tại rạp
-- ================================================
CREATE TABLE Showtime (
    showtime_id     INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    movie_id        INT              NOT NULL
        CONSTRAINT fk_showtime_movie 
        REFERENCES Movie(movie_id),
        -- Khóa ngoại tới phim
    cinema_id       INT              NOT NULL
        CONSTRAINT fk_showtime_cinema 
        REFERENCES Cinema(cinema_id),
        -- Khóa ngoại tới rạp
    start_time      DATETIME         NOT NULL,
        -- Thời gian bắt đầu chiếu
    price           DECIMAL(10,2)    NOT NULL 
        CHECK (price >= 0),
        -- Giá vé (đơn vị tiền tệ), >= 0
    total_seats     INT              NOT NULL 
        CHECK (total_seats >= 0),
        -- Tổng số ghế của phòng chiếu (có thể khởi tạo = tổng ghế Cinema)
    available_seats INT              NOT NULL 
        CHECK (available_seats >= 0),
        -- Số ghế trống hiện tại, cập nhật khi đặt/hủy vé
    created_at      DATETIME         NOT NULL DEFAULT GETDATE()
        -- Thời điểm tạo bản ghi suất chiếu
);
GO

-- Khởi tạo một số giá trị
INSERT INTO Showtime -- Chèn thêm 8 suất chiếu “trong hiện tại” (2025-06-08)
    (movie_id, cinema_id, start_time, price, total_seats, available_seats)
VALUES
    -- Rạp 1 (12×16 = 192 ghế)
    (6,  1, '2025-06-10 09:00:00',  75000.00, 192, 192),  -- Parasite
    (7,  1, '2025-06-10 14:00:00', 100000.00, 192, 192),  -- Avengers: Endgame
    (9,  1, '2025-06-10 19:00:00',  85000.00, 192, 192),  -- Joker

    -- Rạp 2 (10×14 = 140 ghế)
    (11, 2, '2025-06-10 09:00:00',  75000.00, 140, 140),  -- La La Land
    (12, 2, '2025-06-10 14:00:00',  85000.00, 140, 140),  -- Coco
    (15, 2, '2025-06-10 19:00:00',  85000.00, 140, 140),  -- Frozen II

    -- Rạp 3 (15×20 = 300 ghế)
    (6,  3, '2025-06-10 09:00:00',  90000.00, 300, 300),  -- Parasite
    (7,  3, '2025-06-10 14:00:00', 120000.00, 300, 300),  -- Avengers: Endgame
    (9,  3, '2025-06-10 19:00:00',  95000.00, 300, 300),  -- Joker

    -- Rạp 4 ( 8×12 =  96 ghế)
    (11, 4, '2025-06-10 10:00:00',  80000.00,  96,  96),  -- La La Land
    (12, 4, '2025-06-10 15:00:00',  85000.00,  96,  96),  -- Coco
    (15, 4, '2025-06-10 20:00:00',  90000.00,  96,  96);  -- Frozen II
GO

INSERT INTO Showtime -- Chèn thêm 8 suất chiếu “trong quá khứ” (trước 2025-06-08)
    (movie_id, cinema_id, start_time, price, total_seats, available_seats)
VALUES
    -- The Shawshank Redemption (movie_id=1) tại Rạp 1
    (1,  1, '2025-01-15 10:00:00', 70000.00, 192, 192),
    -- The Godfather (movie_id=2) tại Rạp 1
    (2,  1, '2025-02-20 14:00:00', 80000.00, 192, 192),
    -- The Dark Knight (movie_id=3) tại Rạp 2
    (3,  2, '2025-03-05 16:30:00', 90000.00, 140, 140),
    -- Inception (movie_id=4) tại Rạp 2
    (4,  2, '2025-01-25 19:00:00', 95000.00, 140, 140),
    -- Interstellar (movie_id=5) tại Rạp 3
    (5,  3, '2025-04-10 11:00:00', 85000.00, 300, 300),
    -- Titanic (movie_id=8) tại Rạp 3
    (8,  3, '2025-05-12 13:00:00', 75000.00, 300, 300),
    -- Spirited Away (movie_id=10) tại Rạp 4
    (10, 4, '2025-02-28 17:00:00', 80000.00,  96,  96),
    -- Your Name (movie_id=13) tại Rạp 4
    (13, 4, '2025-03-15 20:00:00', 70000.00,  96,  96),
    -- The Lion King (movie_id=14) tại Rạp 1
    (14, 1, '2025-04-22 09:30:00', 65000.00, 192, 192),
    -- The Godfather (movie_id=2) thêm 1 suất nữa tại Rạp 4
    (2,  4, '2025-05-30 18:45:00', 80000.00,  96,  96);
GO

-- Chèn thêm 8 suất chiếu “trong tương lai” (sau 2025-06-08)
-- Chỉ cho các phim có status = N'ĐangChiếu'
-- total_seats và available_seats khởi tạo = tổng ghế của từng Cinema
INSERT INTO Showtime
    (movie_id, cinema_id, start_time, price, total_seats, available_seats)
VALUES
    -- 1. Parasite tại Rạp 1, trưa 2025-06-11
    (6,  1, '2025-06-11 12:00:00',  80000.00, 192, 192),
    -- 2. Avengers: Endgame tại Rạp 2, chiều 2025-06-11
    (7,  2, '2025-06-11 17:00:00', 110000.00, 140, 140),
    -- 3. Joker tại Rạp 3, tối 2025-06-12
    (9,  3, '2025-06-12 20:00:00',  90000.00, 300, 300),
    -- 4. La La Land tại Rạp 4, chiều 2025-06-12
    (11, 4, '2025-06-12 14:00:00',  70000.00,  96,  96),
    -- 5. Coco tại Rạp 1, chiều 2025-06-13
    (12, 1, '2025-06-13 16:00:00',  85000.00, 192, 192),
    -- 6. Frozen II tại Rạp 2, sáng 2025-06-13
    (15, 2, '2025-06-13 11:00:00',  80000.00, 140, 140),
    -- 7. Parasite tại Rạp 3, tối 2025-06-14
    (6,  3, '2025-06-14 19:00:00',  95000.00, 300, 300),
    -- 8. Avengers: Endgame tại Rạp 4, đêm 2025-06-14
    (7,  4, '2025-06-14 21:00:00', 120000.00,  96,  96);
GO

select * from Showtime