-- ================================================
-- 6. TẠO BẢNG Employee
-- Lưu thông tin nhân viên bán vé và quản trị
-- ================================================
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

-- Khởi tạo một số giá trị
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

select * from Employee