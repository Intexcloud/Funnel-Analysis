--Cancel Rate per Payment Method
SELECT
    o.payment_method,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Canceled' THEN o.order_id END) AS canceled_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_status = 'Canceled' THEN o.order_id END) * 100.0
        / COUNT(DISTINCT o.order_id),
        2
    ) AS cancel_rate
FROM orders o
GROUP BY o.payment_method
ORDER BY cancel_rate DESC;


