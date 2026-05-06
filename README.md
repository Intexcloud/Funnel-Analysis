# 🛒 E-Commerce Funnel & Category Performance Analysis

## 📌 Project Overview
This project is an end-to-end data analysis for an e-commerce platform, focusing on identifying **revenue leakage** and **high-value opportunities** through the evaluation of the **Conversion Funnel**, **Return Rates**, and **Average Order Value (AOV)**.

The analysis helps business teams understand the effectiveness of the customer journey—from initial visit to final purchase—while identifying which product categories generate the highest revenue relative to their return rates and transaction values.

## 🛠️ Tech Stack
* **Database:** PostgreSQL (pgAdmin) for data extraction and transformation.
* **Data Visualization:** Looker Studio for interactive dashboard creation.
* **Language:** SQL (CTEs, JOINs, Aggregations, Subqueries).

## 📊 Key Business Questions Answered
1. What is the percentage of customers successfully converted into buyers?
2. What is the overall order return rate?
3. Which product categories contribute the most to total revenue?
4. Which product categories have the highest return rates and require Quality Control (QC) evaluation?
5. **What is the Average Order Value (AOV) across different product categories?**

## 💡 Key Insights Generated
Based on the dashboard analysis:
* **Top Revenue:** Food & Beverages is the leading category in total revenue.
* **Quality Flag:** Apparel/Fashion has the highest return rate (10.4%).
* **Funnel Health:** Strong purchase rate (83.2%), with a 16.7% drop-off before checkout.
* **Top AOV:** Electronics yields the highest transaction value per order.

## 📁 SQL Queries Breakdown

The complete SQL code can be found in the `sql_queries/` folder. Below is an explanation of the extracted metrics:

### 1. Funnel Summary & Conversion Rates
This query utilizes CTEs (`WITH FunnelMetrics`) to calculate key global sales funnel metrics:
* Retrieving the total number of unique customers (`total_customers`).
* Counting customers who completed a purchase (`purchasing_customers`).
* Calculating the total number of orders (`total_orders`).
* Counting returned orders by performing a **JOIN** between `orders`, `order_items`, and `returns` tables (`returned_orders`).
* Calculating the **Purchase Conversion Rate (%)** and **Order Return Rate (%)**.

### 2. Category Performance
This query analyzes sales performance at the product category level:
* Counting the total quantity of goods sold (`total_items_sold`).
* Calculating **total revenue** based on unit price and quantity.
* Ranking results by highest revenue to identify the primary business drivers.

### 3. Return Rate by Category
An in-depth investigative query to pinpoint problematic areas:
* Using a `LEFT JOIN` with the `returns` table to calculate the ratio of returned items per category.
* Comparing total order lines (`total_order_lines`) against returned order lines (`returned_lines`).
* Generating the **Category Return Rate (%)** to detect product anomalies.

### 4. Average Order Value (AOV) by Category
This query calculates the average value of transactions across different product categories:
* Calculating total revenue per category and dividing it by the distinct number of orders.
* Highlighting "High-Value" categories (like Electronics) that may have lower sales volume but generate the most revenue per transaction.

## 📈 Dashboard Visualization

![Dashboard Preview](dashboard_preview/dashboard_screenshot.png)

*This dashboard was built using the metrics derived from the queries above to provide real-time interactive monitoring of category performance, funnel health, and transaction values.*

---
**Author:** Sandy Aprilyanto | Data Analyst
