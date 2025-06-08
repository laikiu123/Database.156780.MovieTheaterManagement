-- ================================================
-- Proc: sp_Login
-- Mô tả: Xác thực người dùng chung (Customer hoặc Employee)
-- Đầu vào:
--   @username        NVARCHAR(50)    – tên đăng nhập
--   @password_hash   VARBINARY(64)   – hash mật khẩu (ví dụ SHA2_256)
-- Đầu ra:
--   @user_id_out     INT OUTPUT      – customer_id hoặc employee_id
--   @role_out        NVARCHAR(20) OUTPUT – 'Customer', 'Employee' hoặc 'Admin'
-- Logic:
--   1. Kiểm tra bảng Employee trước: nếu tìm thấy username + hash khớp → trả employee_id và role từ bảng Employee
--   2. Nếu không, kiểm tra bảng Customer: nếu tìm thấy username + hash khớp → trả customer_id và role = 'Customer'
--   3. Nếu không tìm thấy ở cả hai → lỗi đăng nhập
-- Liên kết:
--   – Bảng Employee có cột role (Employee/Admin)
--   – Bảng Customer đăng nhập với role mặc định 'Customer'
-- ================================================
CREATE PROCEDURE sp_Login
    @username        NVARCHAR(50),
    @password_hash   VARBINARY(64),
    @user_id_out     INT           OUTPUT,
    @role_out        NVARCHAR(20)  OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Thử xác thực với bảng Employee
        ------------------------------------------------------------
        DECLARE @empId INT,
                @empRole NVARCHAR(20);

        SELECT TOP 1
            @empId   = employee_id,
            @empRole = role
        FROM Employee
        WHERE username      = @username
          AND password_hash = @password_hash;

        IF @empId IS NOT NULL
        BEGIN
            -- Tìm thấy tài khoản nhân viên
            SET @user_id_out = @empId;
            SET @role_out    = @empRole;  -- 'Employee' hoặc 'Admin'
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Thử xác thực với bảng Customer
        ------------------------------------------------------------
        DECLARE @custId INT;

        SELECT TOP 1
            @custId = customer_id
        FROM Customer
        WHERE username      = @username
          AND password_hash = @password_hash;

        IF @custId IS NOT NULL
        BEGIN
            -- Tìm thấy tài khoản khách hàng
            SET @user_id_out = @custId;
            SET @role_out    = N'Customer';
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Nếu không tìm thấy ở cả hai bảng → đăng nhập thất bại
        ------------------------------------------------------------
        RAISERROR(
            N'Login failed: invalid username or password.',
            16, 1
        );
    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Bắt lỗi và báo ngược ra ngoài
        ------------------------------------------------------------
        DECLARE
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();

        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH
END
GO
