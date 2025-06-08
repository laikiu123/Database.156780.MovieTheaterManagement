-- ================================================
-- Test Script Part 1: Khởi tạo schema & dữ liệu mẫu
-- Mô tả: Xóa nếu tồn tại, tạo lại các bảng, index và seed data cơ bản
-- Chạy trong database ứng dụng (ví dụ: CinemaDB)
-- ================================================

CREATE DATABASE MovieTheaterManagement
GO

USE MovieTheaterManagement;
GO

-- ================================================
-- 1. Drop các bảng theo thứ tự để tránh FK errors
-- ================================================
IF OBJECT_ID('dbo.OrderDetail','U') IS NOT NULL DROP TABLE dbo.OrderDetail;
IF OBJECT_ID('dbo.[Order]','U')      IS NOT NULL DROP TABLE dbo.[Order];
IF OBJECT_ID('dbo.Employee','U')     IS NOT NULL DROP TABLE dbo.Employee;
IF OBJECT_ID('dbo.Customer','U')     IS NOT NULL DROP TABLE dbo.Customer;
IF OBJECT_ID('dbo.Showtime','U')     IS NOT NULL DROP TABLE dbo.Showtime;
IF OBJECT_ID('dbo.Seat','U')         IS NOT NULL DROP TABLE dbo.Seat;
IF OBJECT_ID('dbo.Cinema','U')       IS NOT NULL DROP TABLE dbo.Cinema;
IF OBJECT_ID('dbo.Movie','U')        IS NOT NULL DROP TABLE dbo.Movie;
GO

-- ================================================
-- 2. Tạo các bảng
-- ================================================
-- Bảng Movie
CREATE TABLE Movie (
    movie_id          INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh (1, 2, 3, …)
    title             NVARCHAR(200)    NOT NULL,
        -- Tiêu đề phim, không cho phép NULL
    genre             NVARCHAR(100)    NULL,
        -- Thể loại phim, cho phép NULL nếu chưa phân loại
    duration_minutes  INT              NOT NULL 
        CHECK (duration_minutes > 0),
        -- Thời lượng (phút), bắt buộc >0
    language          NVARCHAR(50)     NULL,
        -- Ngôn ngữ chính của phim
    description       NVARCHAR(MAX)    NULL,
        -- Mô tả dài, có thể để trống
    status            NVARCHAR(20)     NOT NULL 
        CONSTRAINT chk_movie_status 
        CHECK (status IN (N'ĐangChiếu', N'NgừngChiếu')),
        -- Trạng thái hiện tại (đang chiếu hoặc ngừng chiếu)
    poster_url        NVARCHAR(500)    NULL,
        -- Đường dẫn hình bìa phim
    created_at        DATETIME         NOT NULL DEFAULT GETDATE(),
        -- Thời điểm thêm bản ghi
    updated_at        DATETIME         NOT NULL DEFAULT GETDATE()
        -- Thời điểm cập nhật lần cuối (có thể dùng trigger để tự động cập nhật)
);
GO


-- Bảng Cinema
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

-- Bảng Seat
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

-- Bảng Showtime
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

-- Bảng Customer
CREATE TABLE Customer (
    customer_id     INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    username        NVARCHAR(50)    NOT NULL
        CONSTRAINT uq_customer_username UNIQUE,
        -- Tên đăng nhập (phải duy nhất)
    password_hash   VARBINARY(64)   NOT NULL,
        -- Hash mật khẩu (ví dụ SHA2_256 trả về 32 bytes)
    full_name       NVARCHAR(100)   NOT NULL,
        -- Họ và tên khách hàng
    email           NVARCHAR(150)   NOT NULL
        CONSTRAINT uq_customer_email UNIQUE,
        -- Email liên hệ (phải duy nhất)
    phone           NVARCHAR(20)    NULL,
        -- Số điện thoại (có thể để NULL)
    dob             DATE            NULL,
        -- Ngày sinh (có thể để NULL)
    created_at      DATETIME        NOT NULL DEFAULT GETDATE(),
        -- Ngày tạo hồ sơ
    updated_at      DATETIME        NOT NULL DEFAULT GETDATE()
        -- Ngày cập nhật cuối (có thể dùng trigger để auto cập nhật)
);
GO

-- Bảng Employee
CREATE TABLE Employee (
    employee_id     INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh
    username        NVARCHAR(50)    NOT NULL
        CONSTRAINT uq_employee_username UNIQUE,
        -- Tên đăng nhập (phải duy nhất)
    password_hash   VARBINARY(64)   NOT NULL,
        -- Hash mật khẩu
    full_name       NVARCHAR(100)   NOT NULL,
        -- Họ và tên nhân viên
    email           NVARCHAR(150)   NOT NULL
        CONSTRAINT uq_employee_email UNIQUE,
        -- Email liên hệ (phải duy nhất)
    phone           NVARCHAR(20)    NULL,
        -- Số điện thoại
    role            NVARCHAR(20)    NOT NULL
        CONSTRAINT chk_employee_role 
        CHECK (role IN (N'Employee', N'Admin')),
        -- Phân quyền: Employee (bán vé) hoặc Admin (quản trị)
    cinema_id       INT             NULL
        CONSTRAINT fk_employee_cinema 
        REFERENCES Cinema(cinema_id),
        -- Nếu nhân viên được gán quản lý rạp cụ thể
    created_at      DATETIME        NOT NULL DEFAULT GETDATE()
        -- Ngày tạo hồ sơ
);
GO

-- Bảng [Order]
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

-- Bảng OrderDetail
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

-- ================================================
-- 3. Tạo Index
-- ================================================
CREATE INDEX idx_movie_status             ON dbo.Movie(status);
CREATE INDEX idx_showtime_movie_start     ON dbo.Showtime(movie_id, start_time);
CREATE INDEX idx_showtime_cinema_start    ON dbo.Showtime(cinema_id, start_time);
CREATE INDEX idx_seat_cinema              ON dbo.Seat(cinema_id);
CREATE INDEX idx_order_customer_date      ON dbo.[Order](customer_id, order_date);
CREATE INDEX idx_order_status_date        ON dbo.[Order](status, order_date);
CREATE INDEX idx_od_order                 ON dbo.OrderDetail(order_id);
GO

-- ================================================
-- 4. Seed Data mẫu
-- ================================================
-- 4.1 Cinemas
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

-- 4.2 Seats 
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

-- 4.3 Movies
INSERT INTO Movie
    (title, genre, duration_minutes, language, description, status, poster_url)
VALUES
    (N'The Shawshank Redemption', N'Chính kịch', 142, N'Tiếng Anh',
     N'Một câu chuyện về hy vọng và tình bạn trong nhà tù Shawshank.',
     N'NgừngChiếu', N'https://example.com/posters/shawshank.jpg'),
    (N'The Godfather', N'Tội phạm', 175, N'Tiếng Anh',
     N'Cuộc đời của gia đình mafia Corleone và những âm mưu quyền lực.',
     N'NgừngChiếu', N'https://example.com/posters/godfather.jpg'),
    (N'The Dark Knight', N'Hành động', 152, N'Tiếng Anh',
     N'Batman đối đầu với kẻ ác Joker trong một thành phố hỗn loạn.',
     N'NgừngChiếu', N'https://example.com/posters/dark_knight.jpg'),
    (N'Inception', N'Giả tưởng', 148, N'Tiếng Anh',
     N'Một nhóm chuyên lấy cắp ý tưởng qua giấc mơ kết hợp thực tại.',
     N'NgừngChiếu', N'https://example.com/posters/inception.jpg'),
    (N'Interstellar', N'Khoa học viễn tưởng', 169, N'Tiếng Anh',
     N'Hành trình vũ trụ tìm kiếm hành tinh mới cho nhân loại.',
     N'NgừngChiếu', N'https://example.com/posters/interstellar.jpg'),
    (N'Parasite', N'Tâm lý xã hội', 132, N'Tiếng Hàn Quốc',
     N'Cuộc sống đối lập giữa hai gia đình giàu-nghèo tại Seoul.',
     N'ĐangChiếu', N'https://example.com/posters/parasite.jpg'),
    (N'Avengers: Endgame', N'Hành động', 181, N'Tiếng Anh',
     N'Avengers tập hợp lại để đảo ngược thảm họa do Thanos gây ra.',
     N'ĐangChiếu', N'https://example.com/posters/avengers_endgame.jpg'),
    (N'Titanic', N'Lãng mạn', 195, N'Tiếng Anh',
     N'Câu chuyện tình yêu trên con tàu huyền thoại RMS Titanic.',
     N'NgừngChiếu', N'https://example.com/posters/titanic.jpg'),
    (N'Joker', N'Tâm lý tội phạm', 122, N'Tiếng Anh',
     N'Nguồn gốc và hành trình biến chất của nhân vật Joker.',
     N'ĐangChiếu', N'https://example.com/posters/joker.jpg'),
    (N'Spirited Away', N'Hoạt hình', 125, N'Tiếng Nhật',
     N'Một cô bé lạc vào thế giới linh hồn và tìm đường trở về.',
     N'NgừngChiếu', N'https://example.com/posters/spirited_away.jpg'),
    (N'La La Land', N'Âm nhạc', 128, N'Tiếng Anh',
     N'Chuyện tình lãng mạn giữa nghệ sĩ piano và sao nữ Hollywood.',
     N'ĐangChiếu', N'https://example.com/posters/la_la_land.jpg'),
    (N'Coco', N'Hoạt hình', 105, N'Tiếng Anh',
     N'Chuyến phiêu lưu đến Vùng Đất Linh Hồn của cậu bé Miguel.',
     N'ĐangChiếu', N'https://example.com/posters/coco.jpg'),
    (N'Your Name', N'Romance/Giả tưởng', 106, N'Tiếng Nhật',
     N'Hai bạn trẻ tráo đổi cơ thể và gắn kết qua không gian–thời gian.',
     N'NgừngChiếu', N'https://example.com/posters/your_name.jpg'),
    (N'The Lion King', N'Hoạt hình', 88, N'Tiếng Anh',
     N'Hành trình trưởng thành của sư tử con Simba tại Pride Lands.',
     N'NgừngChiếu', N'https://example.com/posters/lion_king.jpg'),
    (N'Frozen II', N'Hoạt hình', 103, N'Tiếng Anh',
     N'Anna và Elsa cùng bạn bè giải mã bí ẩn vương quốc băng giá.',
     N'ĐangChiếu', N'https://example.com/posters/frozen_2.jpg');
GO

-- 4.4 Showtimes 
INSERT INTO Showtime -- Chèn thêm 8 suất chiếu “ở hiện tại" (2025-06-08)
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
INSERT INTO Showtime -- Chèn thêm 8 suất chiếu “trong tương lai” (trước 2025-06-08)
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

-- 4.5 Customers mẫu
INSERT INTO Customer
    (username, password_hash, full_name, email, phone, dob)
VALUES
    (N'binhnv', HASHBYTES('SHA2_256', N'Password@123'), N'Nguyễn Văn Bình',    N'binh.nguyen@example.com',   N'0987654321', '1988-05-12'),
    (N'hoatt',  HASHBYTES('SHA2_256', N'Hoa#2025'),      N'Trần Thị Hoa',       N'tran.hoa@example.com',      N'0912345678', '1992-11-03'),
    (N'leminht',HASHBYTES('SHA2_256', N'MinhTr0ng!'),    N'Lê Minh Trọng',      N'le.trong@example.com',      N'0977123456', '1995-07-21'),
    (N'lanpt',  HASHBYTES('SHA2_256', N'Lan@321'),       N'Phạm Thị Lan',       N'pham.lan@example.com',       N'0933456789', '1990-02-28'),
    (N'vohung', HASHBYTES('SHA2_256', N'Hung2025!'),     N'Võ Văn Hùng',        N'vo.hung@example.com',        N'0945566778', '1985-12-15'),
    (N'nguyenta',HASHBYTES('SHA2_256',N'Ta#789'),        N'Nguyễn Thị Ánh',     N'nguyen.anh@example.com',     NULL,          '1993-09-09'),
    (N'tranbinh',HASHBYTES('SHA2_256',N'Binh!456'),     N'Trần Bình An',       N'tran.an@example.com',        N'0901122334', NULL),
    (N'phamduc',HASHBYTES('SHA2_256', N'Duc@2025'),      N'Phạm Đức Long',      N'pham.long@example.com',      N'0987001122', '1987-03-30'),
    (N'duongpt',HASHBYTES('SHA2_256', N'Duong#321'),     N'Dương Phương Thảo',  N'duong.thao@example.com',     N'0919001122', '1991-06-17'),
    (N'thanhvn',HASHBYTES('SHA2_256', N'Thanh2025'),     N'Thành Văn Nam',      N'thanh.nam@example.com',      NULL,          NULL);
GO

-- 4.6 Employees mẫu
INSERT INTO Employee
    (username, password_hash, full_name, email, phone, role, cinema_id)
VALUES
    -- Rạp 1
    (N'admin_rap1', HASHBYTES('SHA2_256', N'Adm1n@2025'), N'Nguyễn Thị Hồng',    N'hong.nt@example.com',   N'0911001001', N'Admin',    1),
    (N'emp_rap1',   HASHBYTES('SHA2_256', N'Emp1@2025'),  N'Phạm Văn Bảo',      N'bao.pv@example.com',     N'0911001002', N'Employee', 1),

    -- Rạp 2
    (N'admin_rap2', HASHBYTES('SHA2_256', N'Adm2n@2025'), N'Lê Thị Mai',        N'mai.lt@example.com',     N'0911002001', N'Admin',    2),
    (N'emp_rap2',   HASHBYTES('SHA2_256', N'Emp2@2025'),  N'Võ Đức Minh',       N'minh.vd@example.com',     N'0911002002', N'Employee', 2),

    -- Rạp 3
    (N'admin_rap3', HASHBYTES('SHA2_256', N'Adm3n@2025'), N'Trần Thanh Sơn',    N'son.tt@example.com',      N'0911003001', N'Admin',    3),
    (N'emp_rap3',   HASHBYTES('SHA2_256', N'Emp3@2025'),  N'Đặng Thị Linh',     N'linh.dt@example.com',     N'0911003002', N'Employee', 3),

    -- Rạp 4
    (N'admin_rap4', HASHBYTES('SHA2_256', N'Adm4n@2025'), N'Bùi Quốc Tuấn',     N'tuan.bq@example.com',     N'0911004001', N'Admin',    4),
    (N'emp_rap4',   HASHBYTES('SHA2_256', N'Emp4@2025'),  N'Hoàng Thị Na',      N'na.ht@example.com',       N'0911004002', N'Employee', 4);
GO

-- 4.7 Order mẫu
-- Nếu mua online thì customer_id = NULL
-- Chèn thêm các đơn hàng (Order) hiện tại 
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

-- Chèn thêm các đơn hàng (Order) lịch sử 
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

-- 4.8 OrderDetail mẫu
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

PRINT '=== Schema và dữ liệu mẫu đã sẵn sàng ===';
