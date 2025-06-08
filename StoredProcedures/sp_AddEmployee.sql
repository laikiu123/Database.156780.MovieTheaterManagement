-- ================================================
-- Proc: sp_AddEmployee
-- Mô tả: Thêm mới một nhân viên vào bảng Employee
--
-- Đầu vào:
--   @username         NVARCHAR(50)     – Tên đăng nhập (bắt buộc, duy nhất)
--   @password_hash    VARBINARY(64)    – Hash mật khẩu (SHA2_256, bắt buộc)
--   @full_name        NVARCHAR(100)    – Họ và tên nhân viên (bắt buộc)
--   @email            NVARCHAR(150)    – Email (bắt buộc, duy nhất)
--   @phone            NVARCHAR(20)  = NULL – Số điện thoại (tùy chọn)
--   @role             NVARCHAR(20)     – Vai trò: 'Employee' hoặc 'Admin' (bắt buộc)
--   @cinema_id        INT           = NULL – Mã rạp được phân công (tùy chọn)
--   @employee_id_out  INT           OUTPUT – OUTPUT: employee_id sinh ra
--
-- Logic:
--   1. Kiểm tra trùng username và email
--   2. Validate role nằm trong ('Employee','Admin')
--   3. Nếu @cinema_id IS NOT NULL, kiểm tra tồn tại trong bảng Cinema
--   4. Thực hiện INSERT, trả về SCOPE_IDENTITY() qua @employee_id_out
--
-- Quan hệ:
--   • Employee.cinema_id → Cinema(cinema_id)
-- ================================================
CREATE PROCEDURE dbo.sp_AddEmployee
    @username        NVARCHAR(50),
    @password_hash   VARBINARY(64),
    @full_name       NVARCHAR(100),
    @email           NVARCHAR(150),
    @phone           NVARCHAR(20)   = NULL,
    @role            NVARCHAR(20),
    @cinema_id       INT            = NULL,
    @employee_id_out INT            OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        ------------------------------------------------------------
        -- 1. Kiểm tra trùng username
        ------------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM dbo.Employee
            WHERE username = @username
        )
        BEGIN
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
            FROM dbo.Employee
            WHERE email = @email
        )
        BEGIN
            RAISERROR(
                N'Email "%s" đã tồn tại. Vui lòng sử dụng email khác.',
                16, 1, @email
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 3. Validate role
        ------------------------------------------------------------
        IF @role NOT IN (N'Employee', N'Admin')
        BEGIN
            RAISERROR(
                N'Role phải là ''Employee'' hoặc ''Admin''.',
                16, 1
            );
            RETURN;
        END

        ------------------------------------------------------------
        -- 4. Kiểm tra existence của Cinema nếu được cung cấp
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
        -- 5. Thực hiện INSERT vào bảng Employee
        ------------------------------------------------------------
        INSERT INTO dbo.Employee (
            username,
            password_hash,
            full_name,
            email,
            phone,
            role,
            cinema_id
        )
        VALUES (
            @username,
            @password_hash,
            @full_name,
            @email,
            @phone,
            @role,
            @cinema_id
        );

        -- Lấy employee_id mới sinh
        SET @employee_id_out = SCOPE_IDENTITY();
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
