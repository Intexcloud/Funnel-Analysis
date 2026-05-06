--Return Rate by Category (Delivered only)
WITH delivered_order_items AS (
    SELECT DISTINCT
        o.order_id,
        oi.product_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
),

order_category AS (
    SELECT
        doi.order_id,
        c.category_name
    FROM delivered_order_items doi
    JOIN products p ON doi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
),

returned_orders AS (
    SELECT DISTINCT
        oi.order_id
    FROM returns r
    JOIN order_items oi ON r.order_item_id = oi.order_item_id
)

SELECT
    oc.category_name,
    COUNT(DISTINCT oc.order_id) AS total_delivered_orders,
    COUNT(DISTINCT ro.order_id) AS returned_orders,
    ROUND(
        COUNT(DISTINCT ro.order_id) * 100.0 / COUNT(DISTINCT oc.order_id),
        2
    ) AS return_rate
FROM order_category oc
LEFT JOIN returned_orders ro ON oc.order_id = ro.order_id
GROUP BY oc.category_name
ORDER BY return_rate DESC;
