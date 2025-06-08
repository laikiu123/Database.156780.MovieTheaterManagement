-- ================================================
-- 5. TẠO BẢNG Customer
-- Lưu thông tin khách hàng (User đi mua vé)
-- ================================================
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

-- Khởi tạo một số giá trị
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

select * from Customer
