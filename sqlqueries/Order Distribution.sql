-- Order Distribution
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0
        / (SELECT COUNT(DISTINCT order_id) FROM orders),
        2
    ) AS percentage
FROM orders o
GROUP BY o.order_status
ORDER BY total_orders DESC;
