-- ================================================
-- Proc: sp_GetRevenueByDate
-- Mô tả: Lấy doanh thu và số vé bán được theo từng ngày trong khoảng thời gian cho trước
--
-- Đầu vào:
--   @start_date DATETIME  – Ngày/giờ bắt đầu (inclusive)
--   @end_date   DATETIME  – Ngày/giờ kết thúc (inclusive)
--
-- Kết quả trả về (Result set):
--   • [Date]         – Ngày (DATE)
--   • OrdersCount    – Số đơn đã thanh toán trong ngày
--   • TicketsSold    – Tổng số vé bán được (đếm OrderDetail)
--   • TotalRevenue   – Tổng doanh thu (tổng price từ OrderDetail)
--
-- Logic:
--   1. Chỉ xét các Order đã có status = 'ĐãThanhToán'
--   2. Kết nối Order → OrderDetail qua Order.order_id = OrderDetail.order_id
--   3. Lọc theo khoảng thời gian o.order_date BETWEEN @start_date AND @end_date
--   4. Nhóm theo ngày (CAST(o.order_date AS DATE))
--   5. Trả về số đơn, số vé, tổng doanh thu
--
-- Quan hệ:
--   • OrderDetail.order_id → [Order].order_id
--   • [Order].status
-- ================================================
CREATE PROCEDURE sp_GetRevenueByDate
    @start_date DATETIME,
    @end_date   DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- 1. Validate tham số
    ------------------------------------------------------------
    IF @start_date IS NULL OR @end_date IS NULL
    BEGIN
        RAISERROR(N'Bạn phải cung cấp cả @start_date và @end_date.', 16, 1);
        RETURN;
    END
    IF @start_date > @end_date
    BEGIN
        RAISERROR(N'@start_date không được lớn hơn @end_date.', 16, 1);
        RETURN;
    END

    ------------------------------------------------------------
    -- 2. Truy vấn doanh thu theo ngày
    ------------------------------------------------------------
    SELECT
        CAST(o.order_date AS DATE)      AS [Date],
        COUNT(DISTINCT o.order_id)      AS OrdersCount,
        COUNT(od.order_detail_id)       AS TicketsSold,
        SUM(od.price)                   AS TotalRevenue
    FROM dbo.[Order] AS o
    INNER JOIN dbo.OrderDetail AS od
        ON o.order_id = od.order_id      -- Relation: OrderDetail → Order
    WHERE
        o.status = N'ĐãThanhToán'
        AND o.order_date BETWEEN @start_date AND @end_date
    GROUP BY
        CAST(o.order_date AS DATE)
    ORDER BY
        [Date];
END
GO
