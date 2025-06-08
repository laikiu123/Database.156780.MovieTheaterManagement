-- ================================================
-- View: vw_DailyRevenue
-- Mô tả: Hiển thị doanh thu và số vé bán được theo từng ngày
--
-- Quan hệ:
--   • [Order].order_id      → OrderDetail.order_id
--   • OrderDetail.showtime_id, seat_id → (không dùng trực tiếp ở view này)
--   • [Order].status = 'ĐãThanhToán' để chỉ tính các đơn đã hoàn thành
--
-- Cột trả về:
--   • [Date]        – Ngày (DATE)
--   • OrdersCount   – Số đơn đã thanh toán trong ngày
--   • TicketsSold   – Tổng số vé bán được (số bản ghi OrderDetail)
--   • TotalRevenue  – Tổng doanh thu (tổng price từ OrderDetail)
-- ================================================
-- ================================================
-- Sửa lại View: vw_DailyRevenue
-- Lưu ý: Trong VIEW không được phép sử dụng ORDER BY trừ khi có TOP/OFFSET/FOR XML.
-- Để đảm bảo tính hợp lệ, ta sẽ loại bỏ ORDER BY; 
-- Việc sắp xếp kết quả nên thực hiện khi SELECT từ view này.
-- ================================================
IF OBJECT_ID('dbo.vw_DailyRevenue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DailyRevenue;
GO

CREATE VIEW dbo.vw_DailyRevenue
AS
SELECT
    CAST(o.order_date AS DATE)       AS [Date],
    COUNT(DISTINCT o.order_id)       AS OrdersCount,
    COUNT(od.order_detail_id)        AS TicketsSold,
    SUM(od.price)                    AS TotalRevenue
FROM dbo.[Order] AS o
INNER JOIN dbo.OrderDetail AS od
    ON o.order_id = od.order_id       -- FK: OrderDetail → Order
WHERE
    o.status = N'ĐãThanhToán'         -- Chỉ tính các đơn đã thanh toán
GROUP BY
    CAST(o.order_date AS DATE);
GO

select * from dbo.vw_DailyRevenue