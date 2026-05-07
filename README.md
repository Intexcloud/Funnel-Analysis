# 📦 Funnel Analysis — E-Commerce Order Analytics

End-to-end order funnel analysis covering conversion rates, cancellations, returns, revenue, and AOV by product category. Built for Google Colab.

---

## 📁 Project Structure

```
├── Funnel_Analysis_Fixed.ipynb       # Main analysis notebook
├── README.md                         # This file
├── sql_queries/
│   ├── Order_Distribution.sql
│   ├── Conversion_Rate_Orders_By_Stage.sql
│   ├── Cancel_Rate_per_Payment_Method.sql
│   ├── Return_Rate_by_Category.sql
│   ├── Revenue_by_Category.sql
│   └── Average_Order_Value_by_Category.sql
└── data/
    ├── categories.csv
    ├── customers.csv
    ├── orders.csv
    ├── order_items.csv
    ├── products.csv
    └── returns.csv
```

---

## 🗄️ Data Schema

The analysis requires 6 CSV files with the following structure:

| Table | Key Columns |
|-------|-------------|
| `orders` | `order_id`, `customer_id`, `order_status`, `payment_method` |
| `order_items` | `order_item_id`, `order_id`, `product_id`, `quantity`, `unit_price` |
| `products` | `product_id`, `category_id` |
| `categories` | `category_id`, `category_name` |
| `customers` | `customer_id` |
| `returns` | `order_item_id` |

> **Note:** Revenue is calculated as `quantity × unit_price`. Make sure both columns are present in `order_items`.

---

## 🚀 Getting Started

### Run on Google Colab

1. Open [colab.research.google.com](https://colab.research.google.com)
2. Go to **File → Upload notebook** and select `Funnel-analysis.ipynb`
3. Run all cells top to bottom (**Runtime → Run all**)
4. When prompted in **Cell 3**, upload all 6 CSV files at once

### Run Locally

```bash
pip install pandas numpy matplotlib seaborn scipy

jupyter notebook Funnel_Analysis_Fixed.ipynb
```

For local runs, place all CSV files in the same directory as the notebook and replace the upload cell with:

```python
categories  = pd.read_csv("categories.csv")
customers   = pd.read_csv("customers.csv")
orders      = pd.read_csv("orders.csv")
order_items = pd.read_csv("order_items.csv")
products    = pd.read_csv("products.csv")
returns     = pd.read_csv("returns.csv")
```

---

## 📊 Analysis Overview

### 1. Key Metrics
Computes top-level business KPIs:
- Total customers vs purchasing customers (customer conversion rate)
- Total orders, delivered, returned, and completed counts
- Overall order return rate

### 2. Order Conversion Funnel
Tracks order progression across 4 stages:

```
Total Orders → Delivered → Completed (no return) → Returned
```

Conversion rate at each stage is measured relative to Total Orders.

### 3. Order Status Distribution
Pie chart breakdown of all order statuses (Delivered, Canceled, Shipped, Processing, etc.).

### 4. Cancel Rate by Payment Method
Identifies which payment methods have the highest cancellation rates. Useful for spotting friction in the checkout or payment flow.

```
cancel_rate = canceled_orders / total_orders × 100
```

### 5. Return Rate by Category *(Delivered orders only)*
Measures return rate per product category, restricted to delivered orders to avoid counting unrelated statuses.

```
return_rate = returned_orders / total_delivered_orders × 100
```

### 6. Revenue by Category
Total revenue contribution per category, with percentage share. Revenue is computed as:

```
revenue = quantity × unit_price
```

### 7. Average Order Value (AOV) by Category
Average amount spent per order, broken down by product category:

```
AOV = mean(sum(revenue) per order per category)
```

### 8. A/B Test — Digital vs Non-Digital Payment
Tests whether digital payment methods (Credit Card, Debit Card, E-Wallet, Bank Transfer) yield a statistically higher delivery rate than non-digital / COD methods, using a **two-proportion z-test**.

```
H₀ : delivery_rate(Digital) = delivery_rate(Non-Digital)
H₁ : delivery_rate(Digital) ≠ delivery_rate(Non-Digital)
α  = 0.05
```

---

## 🗃️ SQL Queries

All queries are in the `sql_queries/` folder and mirror the metrics computed in the notebook. Compatible with PostgreSQL, MySQL, and BigQuery with minor syntax adjustments.

---

### Order_Distribution.sql
Counts how many orders exist per status and their percentage share of total orders.

```sql
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id)                                    AS total_orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0
        / (SELECT COUNT(DISTINCT order_id) FROM orders),
        2
    )                                                             AS percentage
FROM orders o
GROUP BY o.order_status
ORDER BY total_orders DESC;
```

---

### Conversion_Rate_Orders_By_Stage.sql
Funnel conversion rate across 4 stages — Total Orders, Delivered, Completed (Delivered & no return), and Returned — all expressed as a percentage of total orders.

```sql
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
    JOIN orders o       ON oi.order_id     = o.order_id       -- fix: filter to Delivered only
    WHERE o.order_status = 'Delivered'
)
SELECT 'Total Orders'                     AS stage, total_orders    AS count, 100.0                                                             AS conversion_rate FROM total
UNION ALL
SELECT 'Delivered',                                delivered_orders,           ROUND(delivered_orders * 100.0 / total_orders, 2)                FROM total, delivered
UNION ALL
SELECT 'Completed (Delivered & No Return)',         delivered_orders - returned_orders, ROUND((delivered_orders - returned_orders) * 100.0 / total_orders, 2) FROM total, delivered, returned
UNION ALL
SELECT 'Returned',                                  returned_orders,            ROUND(returned_orders * 100.0 / total_orders, 2)                FROM total, returned
ORDER BY count DESC;
```

---

### Cancel_Rate_per_Payment_Method.sql
Cancel rate per payment method, sorted highest to lowest.

```sql
SELECT
    o.payment_method,
    COUNT(DISTINCT o.order_id)                                                          AS total_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Canceled' THEN o.order_id END)          AS canceled_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_status = 'Canceled' THEN o.order_id END) * 100.0
        / COUNT(DISTINCT o.order_id),
        2
    )                                                                                   AS cancel_rate
FROM orders o
GROUP BY o.payment_method
ORDER BY cancel_rate DESC;
```

---

### Return_Rate_by_Category.sql
Return rate per product category, restricted to delivered orders only.

```sql
WITH delivered_order_items AS (
    SELECT DISTINCT o.order_id, oi.product_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
),
order_category AS (
    SELECT doi.order_id, c.category_name
    FROM delivered_order_items doi
    JOIN products p   ON doi.product_id  = p.product_id
    JOIN categories c ON p.category_id   = c.category_id
),
returned_orders AS (                                    -- fix: join orders to restrict to Delivered
    SELECT DISTINCT oi.order_id
    FROM returns r
    JOIN order_items oi ON r.order_item_id = oi.order_item_id
    JOIN orders o       ON oi.order_id     = o.order_id
    WHERE o.order_status = 'Delivered'
)
SELECT
    oc.category_name,
    COUNT(DISTINCT oc.order_id)                                                         AS total_delivered_orders,
    COUNT(DISTINCT ro.order_id)                                                         AS returned_orders,
    ROUND(
        COUNT(DISTINCT ro.order_id) * 100.0 / COUNT(DISTINCT oc.order_id),
        2
    )                                                                                   AS return_rate
FROM order_category oc
LEFT JOIN returned_orders ro ON oc.order_id = ro.order_id
GROUP BY oc.category_name
ORDER BY return_rate DESC;
```

---

### Revenue_by_Category.sql
Total revenue and percentage share per category. Uses `quantity × unit_price`.

```sql
SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price)                                                    AS total_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0
        / SUM(SUM(oi.quantity * oi.unit_price)) OVER(),
        2
    )                                                                                   AS revenue_percentage
FROM order_items oi
JOIN products    p ON oi.product_id  = p.product_id
JOIN categories  c ON p.category_id  = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;
```

---

### Average_Order_Value_by_Category.sql
Average order value (AOV) per category — computed per `order_id × category` combination, then averaged.

```sql
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
```

---

## 📤 Outputs

Each section saves a PNG chart automatically:

| File | Chart |
|------|-------|
| `01_funnel.png` | Order conversion funnel |
| `02_status_distribution.png` | Order status pie chart |
| `03_cancel_rate.png` | Cancel rate by payment method |
| `04_return_rate.png` | Return rate by category |
| `05_revenue_category.png` | Revenue by category |
| `06_aov_category.png` | AOV by category |
| `07_ab_test.png` | A/B test delivery rate comparison |

> On Google Colab, charts are displayed inline. To download, use **Files panel → right-click → Download**.

---

## 📦 Dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| `pandas` | ≥ 1.5 | Data manipulation |
| `numpy` | ≥ 1.23 | Numerical operations |
| `matplotlib` | ≥ 3.6 | Chart rendering |
| `seaborn` | ≥ 0.12 | Statistical visualizations |
| `scipy` | ≥ 1.9 | Z-test for A/B testing |

All libraries come pre-installed on Google Colab.

---

