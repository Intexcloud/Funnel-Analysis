-- Average Order Value by Category
SELECT
    c.category_name,
    ROUND(AVG(order_total), 2) AS aov
FROM (
    SELECT
        oi.order_id,
        p.category_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY oi.order_id, p.category_id
) sub
JOIN categories c ON sub.category_id = c.category_id
GROUP BY c.category_name
ORDER BY aov DESC;
