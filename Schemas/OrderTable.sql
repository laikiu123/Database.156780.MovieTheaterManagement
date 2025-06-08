-- ================================================
-- 7. TẠO BẢNG [Order]
-- Lưu thông tin giao dịch đặt vé
-- ================================================
CREATE TABLE [Order] (
    order_id        INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    customer_id     INT             NOT NULL
        CONSTRAINT fk_order_customer 
        REFERENCES Customer(customer_id),
        -- Khóa ngoại tới Customer (người đặt vé)
    employee_id     INT             NULL
        CONSTRAINT fk_order_employee 
        REFERENCES Employee(employee_id),
        -- Khóa ngoại tới Employee (nếu đơn được xử lý offline)
    order_date      DATETIME        NOT NULL DEFAULT GETDATE(),
        -- Thời điểm tạo đơn
    total_amount    DECIMAL(12,2)   NOT NULL CHECK (total_amount >= 0),
        -- Tổng tiền đơn (tự tính trong SP)
    status          NVARCHAR(20)    NOT NULL
        CONSTRAINT chk_order_status 
        CHECK (status IN (N'ChưaThanhToán', N'ĐãThanhToán', N'ĐãHuỷ')),
        -- Trạng thái: ChưaThanhToán, ĐãThanhToán, ĐãHuỷ
    payment_method  NVARCHAR(20)    NULL
        CONSTRAINT chk_payment_method 
        CHECK (payment_method IN (N'TiềnMặt', N'Thẻ', N'Ví')),
        -- Phương thức thanh toán (sau khi thanh toán mới có giá trị)
    payment_date    DATETIME        NULL
        -- Thời điểm thanh toán (NULL nếu chưa thanh toán)
);
GO

-- Khởi tạo một số giá trị
-- Nếu mua online thì customer_id = NULL
-- Chèn các đơn hàng (Order) hiện tại
INSERT INTO [Order]
    (customer_id, employee_id, order_date,       total_amount, status,            payment_method, payment_date)
VALUES
    -- 1. Khách 1 mua 2 vé suất Joker (showtime_id=3, 85.000₫/vé) → 170.000₫, thanh toán Thẻ online
    (1,   NULL, '2025-06-08 19:30:00', 170000.00, N'ĐãThanhToán', N'Thẻ',  '2025-06-08 19:35:00'),

    -- 2. Khách 2 mua 3 vé suất Avengers (showtime_id=2, 100.000₫/vé) → 300.000₫, thanh toán TiềnMặt tại quầy Rạp 1 (emp_rap1 = 2)
    (2,      2, '2025-06-09 14:15:00', 300000.00, N'ĐãThanhToán', N'TiềnMặt', '2025-06-09 14:20:00'),

    -- 3. Khách 3 mua 1 vé suất Coco (showtime_id=5, 85.000₫/vé) →  85.000₫, thanh toán Ví online
    (3,   NULL, '2025-06-09 11:00:00',  85000.00, N'ĐãThanhToán', N'Ví',   '2025-06-09 11:05:00'),

    -- 4. Khách 4 giữ 4 vé suất Avengers (showtime_id=8, 120.000₫/vé) → 480.000₫, chưa thanh toán
    (4,   NULL, '2025-06-10 13:00:00', 480000.00, N'ChưaThanhToán', NULL,    NULL),

    -- 5. Khách 5 đặt 1 vé suất La La Land (showtime_id=10, 80.000₫/vé) →  80.000₫, đã huỷ
    (5,   NULL, '2025-06-10 10:30:00',  80000.00, N'ĐãHuỷ',        NULL,    NULL),

    -- 6. Khách 6 mua 2 vé suất Parasite (showtime_id=7, 90.000₫/vé) → 180.000₫, thanh toán TiềnMặt tại quầy Rạp 3 (emp_rap3 = 6)
    (6,      6, '2025-06-10 09:10:00', 180000.00, N'ĐãThanhToán', N'TiềnMặt','2025-06-10 09:15:00'),

    -- 7. Khách 7 giữ 3 vé suất Frozen II (showtime_id=12, 90.000₫/vé) → 270.000₫, chưa thanh toán
    (7,   NULL, '2025-06-10 20:10:00', 270000.00, N'ChưaThanhToán', NULL,    NULL),

    -- 8. Khách 8 mua 1 vé suất Parasite (showtime_id=1, 75.000₫/vé) →  75.000₫, thanh toán Ví online
    (8,   NULL, '2025-06-10 08:00:00',  75000.00, N'ĐãThanhToán', N'Ví',   '2025-06-10 08:05:00'),

    -- 9. Khách 9 mua 2 vé suất Coco (showtime_id=11, 85.000₫/vé) → 170.000₫, thanh toán TiềnMặt tại quầy Rạp 4 (emp_rap4 = 8)
    (9,      8, '2025-06-11 15:00:00', 170000.00, N'ĐãThanhToán', N'TiềnMặt','2025-06-11 15:05:00'),

    -- 10. Khách 10 giữ 2 vé suất La La Land (showtime_id=4, 75.000₫/vé) → 150.000₫, chưa thanh toán
    (10,  NULL, '2025-06-11 08:45:00', 150000.00, N'ChưaThanhToán', NULL,    NULL);
GO

-- Chèn thêm các đơn hàng (Order) lịch sử cho showtimes 13–22
INSERT INTO [Order]
    (customer_id, employee_id, order_date,       total_amount, status,            payment_method, payment_date)
VALUES
    -- Order 11: 2 vé The Shawshank Redemption (showtime_id=13, 70.000₫/vé) → 140.000₫, thanh toán Thẻ online
    (1,   NULL, '2025-01-15 09:50:00', 140000.00, N'ĐãThanhToán', N'Thẻ',  '2025-01-15 09:55:00'),

    -- Order 12: 2 vé The Godfather (showtime_id=14, 80.000₫/vé) → 160.000₫, thanh toán TiềnMặt tại quầy Rạp 1 (emp_rap1 = 2)
    (2,      2, '2025-02-20 13:50:00', 160000.00, N'ĐãThanhToán', N'TiềnMặt', '2025-02-20 14:00:00'),

    -- Order 13: 3 vé The Dark Knight (showtime_id=15, 90.000₫/vé) → 270.000₫, thanh toán Ví online
    (3,   NULL, '2025-03-05 16:00:00', 270000.00, N'ĐãThanhToán', N'Ví',   '2025-03-05 16:40:00'),

    -- Order 14: 1 vé Inception (showtime_id=16, 95.000₫/vé) →  95.000₫, đã huỷ
    (4,   NULL, '2025-01-25 18:45:00',  95000.00, N'ĐãHuỷ',        NULL,    NULL),

    -- Order 15: 2 vé Interstellar (showtime_id=17, 85.000₫/vé) → 170.000₫, thanh toán TiềnMặt tại quầy Rạp 3 (emp_rap3 = 6)
    (5,      6, '2025-04-10 10:55:00', 170000.00, N'ĐãThanhToán', N'TiềnMặt','2025-04-10 11:05:00'),

    -- Order 16: 3 vé Titanic (showtime_id=18, 75.000₫/vé) → 225.000₫, thanh toán Thẻ online
    (6,   NULL, '2025-05-12 12:50:00', 225000.00, N'ĐãThanhToán', N'Thẻ',  '2025-05-12 12:55:00'),

    -- Order 17: 1 vé Spirited Away (showtime_id=19, 80.000₫/vé) →  80.000₫, chưa thanh toán
    (7,   NULL, '2025-02-28 16:45:00',  80000.00, N'ChưaThanhToán', NULL,    NULL),

    -- Order 18: 2 vé Your Name (showtime_id=20, 70.000₫/vé) → 140.000₫, thanh toán TiềnMặt tại quầy Rạp 4 (emp_rap4 = 8)
    (8,      8, '2025-03-15 19:45:00', 140000.00, N'ĐãThanhToán', N'TiềnMặt','2025-03-15 19:50:00'),

    -- Order 19: 2 vé The Lion King (showtime_id=21, 65.000₫/vé) → 130.000₫, thanh toán Ví online
    (9,   NULL, '2025-04-22 09:10:00', 130000.00, N'ĐãThanhToán', N'Ví',   '2025-04-22 09:15:00'),

    -- Order 20: 1 vé The Godfather (showtime_id=22, 80.000₫/vé) →  80.000₫, chưa thanh toán
    (10,  NULL, '2025-05-30 18:30:00',  80000.00, N'ChưaThanhToán', NULL,    NULL);
GO

-- Chèn thêm các đơn hàng (Order) “trong tương lai” 
INSERT INTO [Order]
    (customer_id, employee_id, order_date,       total_amount, status,            payment_method, payment_date)
VALUES
    -- Order 21: Parasite @ Rạp 1, suất 23 (12:00 11-Jun), thanh toán Ví
    (2,   NULL, '2025-06-10 10:00:00', 160000.00, N'ĐãThanhToán', N'Ví',    '2025-06-10 10:02:00'),
    -- Order 22: Avengers Endgame @ Rạp 2, suất 24 (17:00 11-Jun), thanh toán TiềnMặt
    (3,      4, '2025-06-11 16:45:00', 330000.00, N'ĐãThanhToán', N'TiềnMặt','2025-06-11 16:50:00'),
    -- Order 23: Joker @ Rạp 3, suất 25 (20:00 12-Jun), chưa thanh toán
    (4,   NULL, '2025-06-11 19:30:00',  90000.00, N'ChưaThanhToán', NULL,    NULL),
    -- Order 24: La La Land @ Rạp 4, suất 26 (14:00 12-Jun), đã huỷ
    (5,   NULL, '2025-06-12 14:10:00', 140000.00, N'ĐãHuỷ',        NULL,    NULL),
    -- Order 25: Coco @ Rạp 1, suất 27 (16:00 13-Jun), thanh toán Thẻ
    (6,   NULL, '2025-06-12 15:50:00', 255000.00, N'ĐãThanhToán', N'Thẻ',   '2025-06-12 15:55:00'),
    -- Order 26: Frozen II @ Rạp 2, suất 28 (11:00 13-Jun), thanh toán TiềnMặt
    (7,      4, '2025-06-12 11:05:00',  80000.00, N'ĐãThanhToán', N'TiềnMặt','2025-06-12 11:10:00'),
    -- Order 27: Parasite @ Rạp 3, suất 29 (19:00 14-Jun), chưa thanh toán
    (8,   NULL, '2025-06-13 18:45:00', 190000.00, N'ChưaThanhToán', NULL,    NULL),
    -- Order 28: Avengers Endgame @ Rạp 4, suất 30 (21:00 14-Jun), thanh toán Ví trước suất
    (9,   NULL, '2025-06-14 20:50:00', 240000.00, N'ĐãThanhToán', N'Ví',    '2025-06-14 20:55:00');
GO

select * from [Order]