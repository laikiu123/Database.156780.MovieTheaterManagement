-- ================================================
-- View: vw_MonthlyRevenue
-- Mô tả: Hiển thị doanh thu và số vé bán được theo từng tháng
--
-- Quan hệ:
--   • [Order].order_id      → OrderDetail.order_id
--   • OrderDetail.showtime_id → (không dùng trực tiếp ở view này)
--   • [Order].status = 'ĐãThanhToán' để chỉ tính các đơn đã hoàn thành
--
-- Cột trả về:
--   • [Year]        – Năm (INT)
--   • [Month]       – Tháng (INT)
--   • OrdersCount   – Số đơn đã thanh toán trong tháng
--   • TicketsSold   – Tổng số vé bán được (số bản ghi OrderDetail)
--   • TotalRevenue  – Tổng doanh thu (tổng price từ OrderDetail)
-- ================================================
IF OBJECT_ID('dbo.vw_MonthlyRevenue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_MonthlyRevenue;
GO

CREATE VIEW dbo.vw_MonthlyRevenue
AS
SELECT
    YEAR(o.order_date)            AS [Year],
    MONTH(o.order_date)           AS [Month],
    COUNT(DISTINCT o.order_id)    AS OrdersCount,
    COUNT(od.order_detail_id)     AS TicketsSold,
    SUM(od.price)                 AS TotalRevenue
FROM dbo.[Order] AS o
INNER JOIN dbo.OrderDetail AS od
    ON o.order_id = od.order_id     -- FK: OrderDetail → Order
WHERE
    o.status = N'ĐãThanhToán'       -- Chỉ tính các đơn đã thanh toán
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date);
GO

select * from dbo.vw_MonthlyRevenue