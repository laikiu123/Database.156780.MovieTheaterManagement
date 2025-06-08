-- ================================================
-- Proc: sp_AddCustomer
-- Mô tả: Thêm mới một khách hàng vào bảng Customer
-- Yêu cầu:
--   • Không cho phép trùng username hoặc email
--   • Trả về customer_id vừa tạo qua OUTPUT parameter
-- ================================================
CREATE PROCEDURE sp_AddCustomer
    @username        NVARCHAR(50),        -- Tên đăng nhập, bắt buộc, duy nhất
    @password_hash   VARBINARY(64),       -- Hash mật khẩu (SHA2_256)
    @full_name       NVARCHAR(100),       -- Họ và tên khách hàng
    @email           NVARCHAR(150),       -- Email, bắt buộc, duy nhất
    @phone           NVARCHAR(20)   = NULL, -- Số điện thoại (có thể để NULL)
    @dob             DATE           = NULL, -- Ngày sinh (có thể để NULL)
    @customer_id_out INT           OUTPUT  -- OUTPUT: customer_id được sinh ra
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        ------------------------------------------------------------
        -- 1. Kiểm tra trùng username
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM Customer
            WHERE username = @username
        )
        BEGIN
            -- Raise error nếu username đã có trong hệ thống
            RAISERROR(
                N'Username "%s" đã tồn tại. Vui lòng chọn tên khác.',
                16, 1, @username
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Kiểm tra trùng email
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM Customer
            WHERE email = @email
        )
        BEGIN
            -- Raise error nếu email đã có trong hệ thống
            RAISERROR(
                N'Email "%s" đã tồn tại. Vui lòng sử dụng email khác.',
                16, 1, @email
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Thực hiện INSERT vào bảng Customer
        ------------------------------------------------------------
        INSERT INTO Customer (
            username,
            password_hash,
            full_name,
            email,
            phone,
            dob
        )
        VALUES (
            @username,
            @password_hash,
            @full_name,
            @email,
            @phone,
            @dob
        );

        -- Lấy customer_id mới sinh
        SET @customer_id_out = SCOPE_IDENTITY();

    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Bắt và chuyển lỗi (nếu có) ra ngoài
        ------------------------------------------------------------
        DECLARE @err_msg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @err_sev INT         = ERROR_SEVERITY();
        DECLARE @err_state INT       = ERROR_STATE();
        RAISERROR(@err_msg, @err_sev, @err_state);
        RETURN;
    END CATCH;
END
GO
