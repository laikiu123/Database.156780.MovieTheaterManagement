-- ================================================
-- 8. TẠO BẢNG OrderDetail
-- Lưu chi tiết từng ghế đã đặt trong một Order
-- ================================================
CREATE TABLE OrderDetail (
    order_detail_id    INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    order_id           INT               NOT NULL
        CONSTRAINT fk_od_order 
        REFERENCES [Order](order_id),
        -- Khóa ngoại tới Order
    showtime_id        INT               NOT NULL
        CONSTRAINT fk_od_showtime 
        REFERENCES Showtime(showtime_id),
        -- Khóa ngoại tới Showtime
    seat_id            INT               NOT NULL
        CONSTRAINT fk_od_seat 
        REFERENCES Seat(seat_id),
        -- Khóa ngoại tới Seat
    price              DECIMAL(10,2)     NOT NULL CHECK (price >= 0),
        -- Giá vé của ghế tại thời điểm đặt
    created_at         DATETIME          NOT NULL DEFAULT GETDATE()
        -- Thời điểm thêm chi tiết (có thể dùng để audit)
);
-- Tạo UNIQUE constraint để đảm bảo mỗi ghế chỉ đặt 1 lần cho cùng 1 suất
ALTER TABLE OrderDetail
ADD CONSTRAINT uq_od_showtime_seat 
UNIQUE (showtime_id, seat_id);
GO

-- Khởi tạo một số giá trị
-- Chèn chi tiết (OrderDetail) cho các đơn hàng hiện tại
INSERT INTO OrderDetail
    (order_id, showtime_id, seat_id, price)
VALUES
    -- Order 1: 2 vé Joker (showtime_id=3)
    (1, 3, 1,  85000.00),
    (1, 3, 2,  85000.00),

    -- Order 2: 3 vé Avengers (showtime_id=2)
    (2, 2, 3, 100000.00),
    (2, 2, 4, 100000.00),
    (2, 2, 5, 100000.00),

    -- Order 3: 1 vé Coco (showtime_id=5)
    (3, 5, 193, 85000.00),

    -- Order 4: 4 vé Avengers (showtime_id=8)
    (4, 8, 333, 120000.00),
    (4, 8, 334, 120000.00),
    (4, 8, 335, 120000.00),
    (4, 8, 336, 120000.00),

    -- Order 5: 1 vé La La Land (showtime_id=10)
    (5, 10, 633, 80000.00),

    -- Order 6: 2 vé Parasite (showtime_id=7)
    (6, 7, 337,  90000.00),
    (6, 7, 338,  90000.00),

    -- Order 7: 3 vé Frozen II (showtime_id=12)
    (7, 12, 633,  90000.00),
    (7, 12, 634,  90000.00),
    (7, 12, 635,  90000.00),

    -- Order 8: 1 vé Parasite (showtime_id=1)
    (8, 1, 6,   75000.00),

    -- Order 9: 2 vé Coco (showtime_id=11)
    (9, 11, 636, 85000.00),
    (9, 11, 637, 85000.00),

    -- Order 10: 2 vé La La Land (showtime_id=4)
    (10, 4, 194, 75000.00),
    (10, 4, 195, 75000.00);
GO

-- Chèn chi tiết (OrderDetail) cho các đơn hàng lịch sử
INSERT INTO OrderDetail
    (order_id, showtime_id, seat_id, price)
VALUES
    -- Order 11: showtime 13 tại Rạp 1
    (11, 13, 1,  70000.00),
    (11, 13, 2,  70000.00),

    -- Order 12: showtime 14 tại Rạp 1
    (12, 14, 3,  80000.00),
    (12, 14, 4,  80000.00),

    -- Order 13: showtime 15 tại Rạp 2
    (13, 15, 193, 90000.00),
    (13, 15, 194, 90000.00),
    (13, 15, 195, 90000.00),

    -- Order 14: showtime 16 tại Rạp 2
    (14, 16, 196, 95000.00),

    -- Order 15: showtime 17 tại Rạp 3
    (15, 17, 333, 85000.00),
    (15, 17, 334, 85000.00),

    -- Order 16: showtime 18 tại Rạp 3
    (16, 18, 335, 75000.00),
    (16, 18, 336, 75000.00),
    (16, 18, 337, 75000.00),

    -- Order 17: showtime 19 tại Rạp 4
    (17, 19, 633, 80000.00),

    -- Order 18: showtime 20 tại Rạp 4
    (18, 20, 634, 70000.00),
    (18, 20, 635, 70000.00),

    -- Order 19: showtime 21 tại Rạp 1
    (19, 21, 5,   65000.00),
    (19, 21, 6,   65000.00),

    -- Order 20: showtime 22 tại Rạp 4
    (20, 22, 636, 80000.00);
GO

-- Chèn chi tiết (OrderDetail) cho các đơn hàng tương lai
INSERT INTO OrderDetail
    (order_id, showtime_id, seat_id, price)
VALUES
    (21, 23,  10,  80000.00),
    (21, 23,  11,  80000.00),

    (22, 24, 193,110000.00),
    (22, 24, 194,110000.00),
    (22, 24, 195,110000.00),

    (23, 25, 333,  90000.00),

    (24, 26, 633,  70000.00),
    (24, 26, 634,  70000.00),

    (25, 27,  12,  85000.00),
    (25, 27,  13,  85000.00),
    (25, 27,  14,  85000.00),

    (26, 28, 196,  80000.00),

    (27, 29, 338,  95000.00),
    (27, 29, 339,  95000.00),

    (28, 30, 637, 120000.00),
    (28, 30, 638, 120000.00);
GO


select * from OrderDetail

