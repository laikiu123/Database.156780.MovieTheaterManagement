-- ================================================
-- Proc: sp_UpdateEmployee
-- Mô tả: Cập nhật thông tin một nhân viên trong bảng Employee
--
-- Đầu vào:
--   @employee_id     INT               – Mã nhân viên cần cập nhật
--   @username        NVARCHAR(50)  = NULL – Tên đăng nhập mới (NULL nếu không đổi)
--   @password_hash   VARBINARY(64) = NULL – Hash mật khẩu mới (NULL nếu không đổi)
--   @full_name       NVARCHAR(100) = NULL – Họ và tên mới (NULL nếu không đổi)
--   @email           NVARCHAR(150) = NULL – Email mới (NULL nếu không đổi)
--   @phone           NVARCHAR(20)  = NULL – Số điện thoại mới (NULL nếu không đổi)
--   @role            NVARCHAR(20)  = NULL – Vai trò mới: 'Employee' hoặc 'Admin' (NULL nếu không đổi)
--   @cinema_id       INT           = NULL – Mã rạp mới (NULL nếu không đổi)
--
-- Logic:
--   1. Kiểm tra existence của Employee
--   2. Nếu cung cấp @username, kiểm tra không trùng với username của nhân viên khác
--   3. Nếu cung cấp @email, kiểm tra không trùng với email của nhân viên khác
--   4. Nếu cung cấp @role, kiểm tra giá trị hợp lệ ('Employee','Admin')
--   5. Nếu cung cấp @cinema_id, kiểm tra tồn tại trong bảng Cinema
--   6. Cập nhật các trường chỉ khi tham số khác NULL, giữ nguyên giá trị cũ nếu NULL
--
-- Quan hệ:
--   • Employee.cinema_id → Cinema(cinema_id)
-- ================================================
CREATE PROCEDURE dbo.sp_UpdateEmployee
    @employee_id     INT,
    @username        NVARCHAR(50)    = NULL,
    @password_hash   VARBINARY(64)   = NULL,
    @full_name       NVARCHAR(100)   = NULL,
    @email           NVARCHAR(150)   = NULL,
    @phone           NVARCHAR(20)    = NULL,
    @role            NVARCHAR(20)    = NULL,
    @cinema_id       INT             = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra existence của Employee
        ------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Employee
            WHERE employee_id = @employee_id
        )
        BEGIN
            RAISERROR(
                N'Employee với employee_id = %d không tồn tại.',
                16, 1, @employee_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 2. Kiểm tra trùng username (nếu thay đổi)
        ------------------------------------------------------------
        IF @username IS NOT NULL
           AND EXISTS (
               SELECT 1
               FROM dbo.Employee
               WHERE username = @username
                 AND employee_id <> @employee_id
           )
        BEGIN
            RAISERROR(
                N'Username "%s" đã được sử dụng bởi nhân viên khác.',
                16, 1, @username
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Kiểm tra trùng email (nếu thay đổi)
        ------------------------------------------------------------
        IF @email IS NOT NULL
           AND EXISTS (
               SELECT 1
               FROM dbo.Employee
               WHERE email = @email
                 AND employee_id <> @employee_id
           )
        BEGIN
            RAISERROR(
                N'Email "%s" đã được sử dụng bởi nhân viên khác.',
                16, 1, @email
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 4. Validate role (nếu thay đổi)
        ------------------------------------------------------------
        IF @role IS NOT NULL
           AND @role NOT IN (N'Employee', N'Admin')
        BEGIN
            RAISERROR(
                N'Role phải là ''Employee'' hoặc ''Admin'' nếu được cung cấp.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 5. Validate cinema_id (nếu thay đổi)
        ------------------------------------------------------------
        IF @cinema_id IS NOT NULL
           AND NOT EXISTS (
               SELECT 1
               FROM dbo.Cinema
               WHERE cinema_id = @cinema_id
           )
        BEGIN
            RAISERROR(
                N'Cinema với cinema_id = %d không tồn tại.',
                16, 1, @cinema_id
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 6. Thực hiện cập nhật
        ------------------------------------------------------------
        UPDATE dbo.Employee
        SET
            username      = COALESCE(@username, username),
            password_hash = COALESCE(@password_hash, password_hash),
            full_name     = COALESCE(@full_name, full_name),
            email         = COALESCE(@email, email),
            phone         = COALESCE(@phone, phone),
            role          = COALESCE(@role, role),
            cinema_id     = COALESCE(@cinema_id, cinema_id)
        WHERE employee_id = @employee_id;

    END TRY
    BEGIN CATCH
        ------------------------------------------------------------
        -- Bắt lỗi và re-raise
        ------------------------------------------------------------
        DECLARE
            @err_msg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @err_sev   INT            = ERROR_SEVERITY(),
            @err_state INT            = ERROR_STATE();
        RAISERROR(@err_msg, @err_sev, @err_state);
    END CATCH;
END
GO
