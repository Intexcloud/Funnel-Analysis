--Return Rate by Category
SELECT
    c.category_name,
    COUNT(DISTINCT oi.order_item_id) AS total_order_lines,
    COUNT(DISTINCT r.return_id) AS returned_lines,
    ROUND((COUNT(DISTINCT r.return_id)::NUMERIC / NULLIF(COUNT(DISTINCT oi.order_item_id), 0)) * 100, 2) AS category_return_rate_pct
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY c.category_name
ORDER BY category_return_rate_pct DESC;
