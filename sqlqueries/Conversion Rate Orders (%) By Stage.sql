--Conversion Rate Orders (%) By Stage
WITH total AS (
    SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders
),
delivered AS (
    SELECT COUNT(DISTINCT order_id) AS delivered_orders
    FROM orders
    WHERE order_status = 'Delivered'
),
returned AS (
    SELECT COUNT(DISTINCT oi.order_id) AS returned_orders
    FROM returns r
    JOIN order_items oi ON r.order_item_id = oi.order_item_id
)
SELECT
    'Total Orders' AS stage,
    total_orders AS count,
    100.0 AS conversion_rate
FROM total
UNION ALL
SELECT
    'Delivered' AS stage,
    delivered_orders,
    ROUND(delivered_orders * 100.0 / total_orders, 2)
FROM total, delivered
UNION ALL
SELECT
    'Completed (Delivered & No Return)' AS stage,
    delivered_orders - returned_orders,
    ROUND((delivered_orders - returned_orders) * 100.0 / total_orders, 2)
FROM total, delivered, returned
UNION ALL
SELECT
    'Returned' AS stage,
    returned_orders,
    ROUND(returned_orders * 100.0 / total_orders, 2)
FROM total, returned
ORDER BY count DESC;
