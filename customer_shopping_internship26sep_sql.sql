-- ===========================================================================
-- ===================== Dataset Preparation =================================

CREATE DATABASE customer_shopping_db;
USE customer_shopping_db;

-- ===========================================================================
-- ================= Verify Database and Table Structure =====================

-- 1. Verify the selected database
SELECT DATABASE() AS current_database;

-- 2. Check all tables in the database
SHOW TABLES;

-- 3. Inspect the actual table structure
DESCRIBE customer_shopping;

-- 4. Count the imported records
SELECT COUNT(*) AS total_records
FROM customer_shopping;

-- =================================================================================
-- ================= Check Missing Values and Duplicate Records ====================

-- 1. Check missing values in important columns
SELECT
    SUM(invoice_no IS NULL OR TRIM(invoice_no) = '') AS missing_invoices,
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customers,
    SUM(category IS NULL OR TRIM(category) = '') AS missing_categories,
    SUM(price IS NULL OR TRIM(price) = '') AS missing_prices,
    SUM(invoice_date IS NULL OR TRIM(invoice_date) = '') AS missing_dates
FROM customer_shopping;

-- 2. Check repeated invoice numbers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice_no) AS unique_invoices,
    COUNT(*) - COUNT(DISTINCT invoice_no) AS repeated_invoice_rows
FROM customer_shopping;

-- 3. Check exact duplicate records across all 14 columns
SELECT COUNT(*) AS duplicate_row_groups
FROM (
    SELECT
        invoice_no, customer_id, gender, age,
        age_category, age_group, category, quantity,
        price, payment_method, invoice_date, day,
        shopping_mall, region
    FROM customer_shopping
    GROUP BY
        invoice_no, customer_id, gender, age,
        age_category, age_group, category, quantity,
        price, payment_method, invoice_date, day,
        shopping_mall, region
    HAVING COUNT(*) > 1
) AS duplicates;

-- =================================================================================
-- ================= Validate Price and Invoice Date Formats =======================

-- 1. Check price formatting and convertibility
SELECT
    COUNT(*) AS total_records,
    SUM(CASE
        WHEN REPLACE(TRIM(price), ',', '')
             REGEXP '^[0-9]+([.][0-9]+)?$'
        THEN 1 ELSE 0
    END) AS convertible_prices,
    SUM(CASE
        WHEN price IS NULL OR TRIM(price) = ''
        THEN 1 ELSE 0
    END) AS missing_prices,
    SUM(CASE
        WHEN price IS NOT NULL
         AND TRIM(price) <> ''
         AND REPLACE(TRIM(price), ',', '')
             NOT REGEXP '^[0-9]+([.][0-9]+)?$'
        THEN 1 ELSE 0
    END) AS invalid_prices
FROM customer_shopping;

-- 2. Inspect invoice date formats
SELECT DISTINCT invoice_date
FROM customer_shopping
WHERE invoice_date IS NOT NULL
  AND TRIM(invoice_date) <> ''
LIMIT 10;

-- ===========================================================================================================
-- ================= Convert Price and Invoice Date Safely ===================================================

-- ================ create a working table so the original imported data remains unchanged ==================

CREATE TABLE customer_shopping_analysis AS
SELECT
    invoice_no,
    customer_id,
    gender,
    age,
    age_category,
    age_group,
    category,
    quantity,
    CAST(
        REPLACE(TRIM(price), ',', '') AS DECIMAL(12,2)
    ) AS price,
    payment_method,
    STR_TO_DATE(
        TRIM(invoice_date), '%d-%m-%Y'
    ) AS invoice_date,
    day,
    shopping_mall,
    region
FROM customer_shopping;

-- Then validate the conversion --

SELECT
    COUNT(*) AS total_records,
    SUM(price IS NULL) AS missing_prices,
    SUM(invoice_date IS NULL) AS invalid_dates,
    MIN(invoice_date) AS earliest_date,
    MAX(invoice_date) AS latest_date
FROM customer_shopping_analysis;

-- ============================================================================================
-- ============================ Analyze Sales by Product Category ==============================

SELECT
    category,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY category
ORDER BY total_sales DESC;

-- ==============================================================================================
-- ==============================  Analyze Sales by Gender ======================================

SELECT
    gender,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY gender
ORDER BY total_sales DESC;

-- ================================================================================================
-- =============================== Analyze Sales by Payment Method ================================

SELECT
    payment_method,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY payment_method
ORDER BY total_sales DESC;

-- ================================================================================================
-- ========================== Analyze Monthly Sales Trends ========================================

SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    MONTHNAME(invoice_date) AS month_name,
    SUM(price) AS total_sales,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY
    YEAR(invoice_date),
    MONTH(invoice_date),
    MONTHNAME(invoice_date)
ORDER BY
    sales_year,
    sales_month;
    
-- ==========================================================================================
-- ========================== Analyze Sales by Shopping Mall ================================

SELECT
    shopping_mall,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY shopping_mall
ORDER BY total_sales DESC;  

-- ==========================================================================================
-- ========================== Analyze Sales by Region =======================================

SELECT
    region,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY region
ORDER BY total_sales DESC;

-- ===============================================================================================
-- ========================== Identify the Top 10 Customers by Total Spending ====================

SELECT
    customer_id,
    SUM(price) AS total_spending,
    SUM(quantity) AS total_quantity,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 10;

-- ===============================================================================================
-- ========================== Find the Highest and Lowest Transaction Values =====================

SELECT
    MAX(price) AS highest_transaction_value,
    MIN(price) AS lowest_transaction_value,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis;

-- ===============================================================================================
-- ========================== Identify Potential Sales Outliers ==================================

WITH ranked_prices AS (
    SELECT
        price,
        ROW_NUMBER() OVER (ORDER BY price) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM customer_shopping_analysis
),
percentile_value AS (
    SELECT
        MIN(price) AS threshold_95
    FROM ranked_prices
    WHERE row_num >= CEIL(total_rows * 0.95)
)
SELECT
    a.invoice_no,
    a.customer_id,
    a.category,
    a.price,
    a.quantity,
    a.shopping_mall
FROM customer_shopping_analysis AS a
CROSS JOIN percentile_value AS p
WHERE a.price >= p.threshold_95
ORDER BY a.price DESC
LIMIT 20;

-- ===============================================================================================
-- ========================== Analyze Sales by Age Group =========================================

SELECT
    age_group,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis
GROUP BY age_group
ORDER BY total_sales DESC;

-- ===============================================================================================
-- ========================== Analyze Sales by Day of the Week ===================================

SELECT
    day,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY day
ORDER BY total_sales DESC;

-- ===============================================================================================
-- ========================== Analyze Sales by Product Category and Gender =======================

SELECT
    category,
    gender,
    SUM(price) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS transaction_count
FROM customer_shopping_analysis
GROUP BY category, gender
ORDER BY category, total_sales DESC;

-- ===============================================================================================
-- ========================== Compare Average Transaction Value by Payment Method ================

SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(price) AS total_sales,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis
GROUP BY payment_method
ORDER BY average_transaction_value DESC;

-- ==================================================================================================
-- ========================== Analyze Sales by Shopping Mall and Category ===========================

WITH mall_category_sales AS (
    SELECT
        shopping_mall,
        category,
        SUM(price) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY shopping_mall
            ORDER BY SUM(price) DESC
        ) AS category_rank
    FROM customer_shopping_analysis
    GROUP BY shopping_mall, category
)
SELECT
    shopping_mall,
    category,
    total_sales
FROM mall_category_sales
WHERE category_rank = 1
ORDER BY total_sales DESC;

-- ==========================================================================================
-- ===================== Compare Customer Counts by Shopping Mall ===========================

SELECT
    shopping_mall,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS transaction_count,
    SUM(price) AS total_sales
FROM customer_shopping_analysis
GROUP BY shopping_mall
ORDER BY unique_customers DESC;

-- ============================================================================================
-- ============================== SQL JOIN Analysis ===========================================

SELECT
    c.customer_id,
    c.gender,
    c.age,
    s.invoice_no,
    s.category,
    s.price,
    s.shopping_mall
FROM customer_shopping_analysis AS c
INNER JOIN customer_shopping_analysis AS s
    ON c.customer_id = s.customer_id
LIMIT 10;

-- ====================================================================================================
-- ==================== Subquery Analysis: Customers Spending Above Average ===========================

SELECT
    customer_id,
    SUM(price) AS total_spending
FROM customer_shopping_analysis
GROUP BY customer_id
HAVING SUM(price) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            customer_id,
            SUM(price) AS customer_total
        FROM customer_shopping_analysis
        GROUP BY customer_id
    ) AS customer_spending
)
ORDER BY total_spending DESC
LIMIT 10;

-- =================================================================================
-- =============== Find Customers Who Purchased More Than Once =====================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT invoice_no) AS unique_invoices
FROM customer_shopping_analysis;

-- ==========================================================================================
-- ================== Top 5 Categories by Average Transaction Value =========================

SELECT
    category,
    COUNT(DISTINCT invoice_no) AS total_transactions,
    SUM(price) AS total_sales,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis
GROUP BY category
ORDER BY average_transaction_value DESC
LIMIT 5;

-- ==========================================================================================
-- ================= Category Contribution to Total Sales (%) ===============================

SELECT
    category,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(
        SUM(price) * 100.0 /
        (SELECT SUM(price)
         FROM customer_shopping_analysis),
        2
    ) AS sales_percentage
FROM customer_shopping_analysis
GROUP BY category
ORDER BY sales_percentage DESC;

-- ============================================================================================
-- ================= Join Category Sales with Overall Sales Summary ===========================

WITH category_sales AS (
    SELECT
        category,
        SUM(price) AS total_sales
    FROM customer_shopping_analysis
    GROUP BY category
),
overall_sales AS (
    SELECT
        SUM(price) AS overall_sales
    FROM customer_shopping_analysis
)
SELECT
    cs.category,
    ROUND(cs.total_sales, 2) AS total_sales,
    ROUND(os.overall_sales, 2) AS overall_sales,
    ROUND(cs.total_sales * 100.0 / os.overall_sales, 2) AS sales_percentage
FROM category_sales AS cs
CROSS JOIN overall_sales AS os
ORDER BY cs.total_sales DESC;


-- ===================================================================================================
--                                              BUSINESS INSIGHTS
--                                      Customer Shopping Behavior Analysis
-- ===================================================================================================


-- Business Question 1:
-- Which category contributes the most to total sales?

SELECT
    category,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(
        SUM(price) * 100.0 /
        (SELECT SUM(price)
         FROM customer_shopping_analysis),
        2
    ) AS sales_percentage
FROM customer_shopping_analysis
GROUP BY category
ORDER BY total_sales DESC
LIMIT 3;

-- Finding:
-- Clothing contributes the highest share of total sales (45.33%).


-- Business Question 2:
-- Which shopping mall generates the highest sales?

SELECT
    shopping_mall,
    ROUND(SUM(price), 2) AS total_sales
FROM customer_shopping_analysis
GROUP BY shopping_mall
ORDER BY total_sales DESC
LIMIT 3;

-- Finding:
-- Mall of Istanbul has the highest sales among the malls in this dataset.


-- Business Question 3:
-- Which category has the highest average transaction value?

SELECT
    category,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis
GROUP BY category
ORDER BY average_transaction_value DESC
LIMIT 3;

-- Finding:
-- Technology has the highest average transaction value (3156.94).


-- Business Question 4:
-- Which payment method generates the highest sales?

SELECT
    payment_method,
    COUNT(DISTINCT invoice_no) AS total_transactions,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(
        SUM(price) * 100.0 /
        (SELECT SUM(price)
         FROM customer_shopping_analysis),
        2
    ) AS sales_percentage
FROM customer_shopping_analysis
GROUP BY payment_method
ORDER BY total_sales DESC;

-- Finding
-- Cash generates the highest sales at 30,705,030.98, contributing approximately 44.79% of total sales, followed by credit card and debit card payments.


-- BUSINESS QUESTION 5:
-- Which age group generates the highest sales?

SELECT
    age_group,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(AVG(price), 2) AS average_transaction_value,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY age_group
ORDER BY total_sales DESC;

-- FINDING:
-- The 35-40 age group generates the highest total sales.
-- The 15-20 age group generates the lowest total sales.
-- The 40-45 age group has the highest average transaction value.


-- BUSINESS QUESTION 6:
-- Which day of the week generates the highest sales?

SELECT
    day,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY day
ORDER BY total_sales DESC;

-- FINDING:
-- Monday generates the highest sales at 10,119,164.19.
-- Saturday generates the lowest sales at 9,644,341.36.


-- BUSINESS QUESTION 7:
-- Which region generates the highest sales?

SELECT
    region,
    ROUND(SUM(price), 2) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY region
ORDER BY total_sales DESC;

-- FINDING:
-- Central has the highest sales at 30,904,056.17.
-- North-West has the lowest sales at 3,336,073.82
-- among the listed regions.


-- BUSINESS QUESTION 8:
-- Which gender contributes the most to total sales?

SELECT
    gender,
    ROUND(SUM(price), 2) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY gender
ORDER BY total_sales DESC;

-- FINDING:
-- Female customers contribute 40,931,801.62 in sales,
-- compared with 27,619,564.29 from male customers.


-- BUSINESS QUESTION 9:
-- Which category performs best in each shopping mall?

WITH mall_category_sales AS (
    SELECT
        shopping_mall,
        category,
        SUM(price) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY shopping_mall
            ORDER BY SUM(price) DESC
        ) AS category_rank
    FROM customer_shopping_analysis
    GROUP BY shopping_mall, category
)
SELECT
    shopping_mall,
    category,
    ROUND(total_sales, 2) AS total_sales
FROM mall_category_sales
WHERE category_rank = 1
ORDER BY total_sales DESC;

-- FINDING:
-- Clothing is the highest-selling category in every shopping mall.


-- BUSINESS QUESTION 10:
-- Which shopping mall generates the highest sales?

SELECT
    shopping_mall,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY shopping_mall
ORDER BY total_sales DESC;

-- FINDING:
-- Mall of Istanbul has the highest sales at 13,851,737.62.
-- Forum Istanbul has the lowest sales at 3,336,073.82.


-- BUSINESS QUESTION 11:
-- Which months have the highest and lowest sales?

SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS sales_month,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY total_sales DESC;

-- FINDING:
-- July 2021 has the highest monthly sales.
-- March 2023 has the lowest recorded monthly sales,
-- but the dataset ends on 8 March 2023, so that month is incomplete.


-- BUSINESS QUESTION 12:
-- Which categories have the lowest sales contribution?

SELECT
    category,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(
        SUM(price) * 100.0 /
        (SELECT SUM(price)
         FROM customer_shopping_analysis),
        2
    ) AS sales_percentage
FROM customer_shopping_analysis
GROUP BY category
ORDER BY total_sales ASC
LIMIT 3;

-- FINDING:
-- Souvenir has the lowest sales at 174,436.83 (0.25%).
-- Books and Food & Beverage are also among the lowest-selling
-- categories by total sales.


-- BUSINESS QUESTION 13:
-- Which transactions should be reviewed as potential high-value outliers?

SELECT
    invoice_no,
    customer_id,
    category,
    shopping_mall,
    price
FROM customer_shopping_analysis
WHERE price >= 5250
ORDER BY price DESC
LIMIT 20;

-- FINDING:
-- Transactions valued at 5,250 are among the highest-value
-- transactions in the dataset and may be reviewed.
-- A high value alone does not prove that a transaction is an error.


-- BUSINESS QUESTION 14:
-- Which payment method has the highest average transaction value?

SELECT
    payment_method,
    COUNT(DISTINCT invoice_no) AS total_transactions,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis
GROUP BY payment_method
ORDER BY average_transaction_value DESC;

-- FINDING:
-- Cash has the highest average transaction value at 690.82,
-- followed by credit card at 688.54 and debit card at 687.03.


-- ======================================================================================================
--                                      CUSTOMER SHOPPING BEHAVIOR ANALYSIS
--                                          FINAL PROJECT DOCUMENTATION
--                                            OVERALL DATASET SUMMARY
-- ======================================================================================================


-- 1. PROJECT OBJECTIVE
-- Analyze customer shopping transactions to understand
-- sales performance, category trends, payment preferences,
-- customer segments, and shopping mall performance.


-- 2. DATASET SUMMARY

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT invoice_no) AS unique_invoices,
    ROUND(SUM(price), 2) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    ROUND(AVG(price), 2) AS average_transaction_value,
    MIN(invoice_date) AS first_transaction_date,
    MAX(invoice_date) AS last_transaction_date
FROM customer_shopping_analysis;

-- VERIFIED FINDING:
-- 99,457 records, 99,457 unique customers,
-- 99,457 unique invoices, total sales of 68,551,365.91,
-- quantity sold of 298,712, average transaction value
-- of 689.26, and dates from 2021-01-01 to 2023-03-08.


-- 3. DATA QUALITY VALIDATION

SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END)
        AS missing_prices,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END)
        AS invalid_dates,
    MIN(invoice_date) AS earliest_date,
    MAX(invoice_date) AS latest_date
FROM customer_shopping_analysis;

-- VERIFIED FINDING:
-- All 99,457 prices were convertible and no invalid dates
-- were found in the analysis table.


-- 4. CATEGORY SALES PERFORMANCE

SELECT
    category,
    ROUND(SUM(price), 2) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(
        SUM(price) * 100.0 /
        (SELECT SUM(price)
         FROM customer_shopping_analysis),
        2
    ) AS sales_percentage
FROM customer_shopping_analysis
GROUP BY category
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- Clothing contributes the highest sales at 45.33%.
-- Shoes contributes 26.46%, and Technology contributes 23.01%.
-- Souvenir has the lowest sales contribution at 0.25%.


-- 5. PAYMENT METHOD ANALYSIS

SELECT
    payment_method,
    COUNT(DISTINCT invoice_no) AS total_transactions,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(AVG(price), 2) AS average_transaction_value
FROM customer_shopping_analysis
GROUP BY payment_method
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- Cash generates the highest total sales at 30,705,030.98.
-- Credit card sales are 24,051,476.93.
-- Debit card sales are 13,794,858.00.


-- 6. SHOPPING MALL PERFORMANCE

SELECT
    shopping_mall,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY shopping_mall
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- Mall of Istanbul has the highest sales at 13,851,737.62.
-- Forum Istanbul has the lowest sales at 3,336,073.82.


-- 7. AGE GROUP ANALYSIS

SELECT
    age_group,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(AVG(price), 2) AS average_transaction_value,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY age_group
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- The 35-40 age group has the highest total sales.
-- The 15-20 age group has the lowest total sales.
-- The 40-45 age group has the highest average transaction value.


-- 8. DAY-OF-WEEK ANALYSIS

SELECT
    day,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY day
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- Monday has the highest sales at 10,119,164.19.
-- Saturday has the lowest sales at 9,644,341.36.


-- 9. REGION PERFORMANCE

SELECT
    region,
    ROUND(SUM(price), 2) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY region
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- Central has the highest regional sales at 30,904,056.17.
-- North-West has the lowest regional sales at 3,336,073.82.


-- 10. MONTHLY SALES TREND

SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS sales_month,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM customer_shopping_analysis
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY sales_month;

-- VERIFIED FINDING:
-- July 2021 has the highest monthly sales.
-- March 2023 is incomplete because the dataset ends on March 8, 2023.


-- 11. CATEGORY CONTRIBUTION TO TOTAL SALES

SELECT
    category,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(
        SUM(price) * 100.0 /
        (SELECT SUM(price)
         FROM customer_shopping_analysis),
        2
    ) AS sales_percentage
FROM customer_shopping_analysis
GROUP BY category
ORDER BY sales_percentage DESC;

-- VERIFIED FINDING:
-- Clothing, Shoes, and Technology together contribute
-- approximately 94.80% of total sales.


-- 12. TOP-SELLING CATEGORY IN EACH MALL

WITH mall_category_sales AS (
    SELECT
        shopping_mall,
        category,
        SUM(price) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY shopping_mall
            ORDER BY SUM(price) DESC
        ) AS category_rank
    FROM customer_shopping_analysis
    GROUP BY shopping_mall, category
)
SELECT
    shopping_mall,
    category,
    ROUND(total_sales, 2) AS total_sales
FROM mall_category_sales
WHERE category_rank = 1
ORDER BY total_sales DESC;

-- VERIFIED FINDING:
-- Clothing is the highest-selling category in every mall.


-- 13. CUSTOMER UNIQUENESS CHECK

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT invoice_no) AS unique_invoices
FROM customer_shopping_analysis;

-- VERIFIED FINDING:
-- Every record has a unique customer ID and invoice number.
-- Repeat-purchase behavior cannot be assessed from these records.


-- 14. HIGH-VALUE TRANSACTION REVIEW

SELECT
    invoice_no,
    customer_id,
    category,
    shopping_mall,
    price
FROM customer_shopping_analysis
WHERE price >= 5250
ORDER BY price DESC
LIMIT 20;

-- FINDING:
-- Transactions at the recorded maximum price of 5,250
-- can be reviewed as high-value transactions.
-- High value alone does not establish a data error.


-- 15. BUSINESS RECOMMENDATIONS
-- Recommendation 1:
-- Review Clothing inventory and promotions because it
-- contributes the largest share of total sales.
--
-- Recommendation 2:
-- Investigate factors associated with Mall of Istanbul's
-- higher sales before making resource-allocation decisions.
--
-- Recommendation 3:
-- Review Technology pricing and product mix because this
-- category has the highest average transaction value.
--
-- Recommendation 4:
-- Compare weekday and weekend sales before planning
-- staffing and promotional activities.
--
-- Recommendation 5:
-- Investigate the low sales contribution of Souvenir,
-- Books, and Food & Beverage before changing their stock.
--
-- Note: These are recommendations for further investigation,
-- not proven explanations for the observed sales patterns.


-- 16. PROJECT CONCLUSION
-- SQL analysis was used to validate the dataset and examine
-- category, payment, location, age-group, regional, and
-- time-based sales patterns. Clothing was the largest
-- contributor to sales, Mall of Istanbul led mall sales,
-- and Technology had the highest average transaction value.
-- The findings can support further retail performance analysis.




