-- * SUPPLY CHAIN MEGA PROJECT USING SQL - MASTER SCHEMA SCRIPT
---------------------------------------------------
IF OBJECT_ID('dbo.fact_post_invoice_deductions', 'U') IS NOT NULL
    DROP TABLE dbo.fact_post_invoice_deductions;

IF OBJECT_ID('dbo.fact_pre_invoice_deductions', 'U') IS NOT NULL
    DROP TABLE dbo.fact_pre_invoice_deductions;

IF OBJECT_ID('dbo.fact_freight_cost', 'U') IS NOT NULL
    DROP TABLE dbo.fact_freight_cost;

IF OBJECT_ID('dbo.fact_manufacturing_cost', 'U') IS NOT NULL
    DROP TABLE dbo.fact_manufacturing_cost;

IF OBJECT_ID('dbo.fact_gross_price', 'U') IS NOT NULL
    DROP TABLE dbo.fact_gross_price;

IF OBJECT_ID('dbo.fact_forecast_monthly', 'U') IS NOT NULL
    DROP TABLE dbo.fact_forecast_monthly;

IF OBJECT_ID('dbo.fact_sales_monthly', 'U') IS NOT NULL
    DROP TABLE dbo.fact_sales_monthly;

IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL
    DROP TABLE dbo.dim_product;

IF OBJECT_ID('dbo.dim_customer', 'U') IS NOT NULL
    DROP TABLE dbo.dim_customer;
GO


/************************************************************************************
 * 2. CREATE DIMENSION TABLES
 ************************************************************************************/
---------------------------------------------------
-- 2.1 dim_customer
---------------------------------------------------
CREATE TABLE dbo.dim_customer (
    customer_code INT           NOT NULL PRIMARY KEY,
    customer      VARCHAR(100)  NOT NULL,   -- Customer name
    platform      VARCHAR(50)   NOT NULL,   -- e.g. 'AtliQ e-Store', 'Retailer'
    channel       VARCHAR(50)   NOT NULL,   -- e.g. 'E-Commerce', 'Offline'
    market        VARCHAR(50)   NOT NULL,   -- e.g. 'India', 'USA', 'Germany'
    sub_zone      VARCHAR(50)   NULL,       -- e.g. 'ANZ', 'NA', 'SE Asia'
    region        VARCHAR(50)   NULL        -- e.g. 'APAC', 'EU', 'LATAM'
);
GO
---------------------------------------------------
-- 2.2 dim_product
---------------------------------------------------
CREATE TABLE dbo.dim_product (
    product_code VARCHAR(20)   NOT NULL PRIMARY KEY,
    division     VARCHAR(50)   NOT NULL,  
    category     VARCHAR(100)  NOT NULL,   
    product      VARCHAR(100)  NOT NULL,   
    variant      VARCHAR(100)  NOT NULL    -
);
GO
---------------------------------------------------
-- 3.1 fact_sales_monthly
---------------------------------------------------
CREATE TABLE dbo.fact_sales_monthly (
    date          DATE         NOT NULL,  
    fiscal_year   INT          NOT NULL,
    product_code  VARCHAR(20)  NOT NULL,
    customer_code INT          NOT NULL,
    sold_quantity INT          NOT NULL,

    CONSTRAINT PK_fact_sales_monthly
        PRIMARY KEY (date, product_code, customer_code),

    CONSTRAINT FK_sales_product
        FOREIGN KEY (product_code)
        REFERENCES dbo.dim_product(product_code),

    CONSTRAINT FK_sales_customer
        FOREIGN KEY (customer_code)
        REFERENCES dbo.dim_customer(customer_code)
);
GO
---------------------------------------------------
-- 3.2 fact_forecast_monthly
---------------------------------------------------
CREATE TABLE dbo.fact_forecast_monthly (
    date              DATE         NOT NULL,
    fiscal_year       INT          NOT NULL,
    product_code      VARCHAR(20)  NOT NULL,
    customer_code     INT          NOT NULL,
    forecast_quantity INT          NOT NULL,

    CONSTRAINT PK_fact_forecast_monthly
        PRIMARY KEY (date, product_code, customer_code),

    CONSTRAINT FK_forecast_product
        FOREIGN KEY (product_code)
        REFERENCES dbo.dim_product(product_code),

    CONSTRAINT FK_forecast_customer
        FOREIGN KEY (customer_code)
        REFERENCES dbo.dim_customer(customer_code)
);
GO
---------------------------------------------------
-- 3.3 fact_gross_price
---------------------------------------------------
CREATE TABLE dbo.fact_gross_price (
    product_code VARCHAR(20)    NOT NULL,
    fiscal_year  INT            NOT NULL,
    gross_price  DECIMAL(10,4)  NOT NULL,

    CONSTRAINT PK_fact_gross_price
        PRIMARY KEY (product_code, fiscal_year),

    CONSTRAINT FK_gross_product
        FOREIGN KEY (product_code)
        REFERENCES dbo.dim_product(product_code)
);
GO
---------------------------------------------------
-- 3.4 fact_manufacturing_cost
---------------------------------------------------
CREATE TABLE dbo.fact_manufacturing_cost (
    product_code       VARCHAR(20)    NOT NULL,
    cost_year          INT            NOT NULL,
    manufacturing_cost DECIMAL(10,4)  NOT NULL,

    CONSTRAINT PK_fact_manufacturing_cost
        PRIMARY KEY (product_code, cost_year),

    CONSTRAINT FK_mfg_product
        FOREIGN KEY (product_code)
        REFERENCES dbo.dim_product(product_code)
);
GO
---------------------------------------------------
-- 3.5 fact_freight_cost
---------------------------------------------------
CREATE TABLE dbo.fact_freight_cost (
    market      VARCHAR(50)   NOT NULL,    -- e.g. 'India', 'USA'
    fiscal_year INT           NOT NULL,
    freight_pct DECIMAL(10,4) NOT NULL,    -- as percentage of sales, etc.

    CONSTRAINT PK_fact_freight_cost
        PRIMARY KEY (market, fiscal_year)
);
GO
---------------------------------------------------
-- 3.6 fact_pre_invoice_deductions
---------------------------------------------------
CREATE TABLE dbo.fact_pre_invoice_deductions (
    customer_code            INT           NOT NULL,
    fiscal_year              INT           NOT NULL,
    pre_invoice_discount_pct DECIMAL(10,4) NOT NULL,

    CONSTRAINT PK_fact_pre_invoice
        PRIMARY KEY (customer_code, fiscal_year),

    CONSTRAINT FK_preinv_customer
        FOREIGN KEY (customer_code)
        REFERENCES dbo.dim_customer(customer_code)
);
GO
---------------------------------------------------
-- 3.7 fact_post_invoice_deductions
---------------------------------------------------
CREATE TABLE dbo.fact_post_invoice_deductions (
    customer_code        INT           NOT NULL,
    product_code         VARCHAR(20)   NOT NULL,
    date                 DATE          NOT NULL,
    fiscal_year          INT           NOT NULL,
    discounts_pct        DECIMAL(10,4) NOT NULL,
    other_deductions_pct DECIMAL(10,4) NOT NULL,

    CONSTRAINT PK_fact_post_invoice
        PRIMARY KEY (customer_code, product_code, date),

    CONSTRAINT FK_postinv_customer
        FOREIGN KEY (customer_code)
        REFERENCES dbo.dim_customer(customer_code),

    CONSTRAINT FK_postinv_product
        FOREIGN KEY (product_code)
        REFERENCES dbo.dim_product(product_code)
);
GO
/************************************************************************************
TASK 2
 ************************************************************************************/
USE SupplyChainFinanceManagement;
GO

INSERT INTO dbo.dim_customer (customer_code, customer, platform, channel, market, sub_zone, region)
VALUES
(70020016, 'AtliQ E-Store India',     'AtliQ E-Store', 'E-Commerce',     'India',   'IN-North',  'APAC'),
(70020017, 'Croma India',             'Retailer',      'Brick & Mortar', 'India',   'IN-West',   'APAC'),
(70020018, 'Amazon India',            'Marketplace',   'E-Commerce',     'India',   'IN-South',  'APAC'),
(70020019, 'BestBuy USA',             'Retailer',      'Brick & Mortar', 'USA',     'US-East',   'NA'),
(70020020, 'Amazon USA',              'Marketplace',   'E-Commerce',     'USA',     'US-West',   'NA'),
(70020021, 'MediaMarkt Germany',      'Retailer',      'Brick & Mortar', 'Germany', 'DE-South',  'EU');
GO

INSERT INTO dbo.dim_product (product_code, division, category, product, variant)
VALUES
('AQ_MSE_01', 'Peripherals', 'Mouse',         'AtliQ Wireless Mouse',         'AQ WM 01 Black'),
('AQ_KBD_01', 'Peripherals', 'Keyboard',      'AtliQ Gaming Keyboard',        'AQ GK 01 RGB'),
('AQ_LTP_01', 'Systems',     'Laptop',        'AtliQ Ultrabook 13"',          'AQ U13 8GB/512GB'),
('AQ_MON_01', 'Displays',    'Monitor',       'AtliQ 24" FHD Monitor',        'AQ FHD 24'),
('AQ_PRN_01', 'Peripherals', 'Printer',       'AtliQ Laser Printer',          'AQ LP 101'),
('AQ_HDD_01', 'Storage',     'External Drive','AtliQ 1TB External HDD',      'AQ HDD 1TB');
GO

INSERT INTO dbo.fact_gross_price (product_code, fiscal_year, gross_price)
VALUES
('AQ_MSE_01', 2022, 30.00),
('AQ_MSE_01', 2023, 32.00),
('AQ_KBD_01', 2022, 60.00),
('AQ_KBD_01', 2023, 65.00),
('AQ_LTP_01', 2022, 900.00),
('AQ_LTP_01', 2023, 950.00),
('AQ_MON_01', 2022, 150.00),
('AQ_MON_01', 2023, 155.00),
('AQ_PRN_01', 2022, 200.00),
('AQ_PRN_01', 2023, 210.00),
('AQ_HDD_01', 2022, 80.00),
('AQ_HDD_01', 2023, 85.00);
GO

INSERT INTO dbo.fact_manufacturing_cost (product_code, cost_year, manufacturing_cost)
VALUES
('AQ_MSE_01', 2022, 18.00),
('AQ_MSE_01', 2023, 19.00),
('AQ_KBD_01', 2022, 35.00),
('AQ_KBD_01', 2023, 36.50),
('AQ_LTP_01', 2022, 650.00),
('AQ_LTP_01', 2023, 670.00),
('AQ_MON_01', 2022, 95.00),
('AQ_MON_01', 2023, 98.00),
('AQ_PRN_01', 2022, 130.00),
('AQ_PRN_01', 2023, 135.00),
('AQ_HDD_01', 2022, 50.00),
('AQ_HDD_01', 2023, 52.00);
GO

INSERT INTO dbo.fact_freight_cost (market, fiscal_year, freight_pct)
VALUES
('India',   2022, 0.0300),
('India',   2023, 0.0325),
('USA',     2022, 0.0250),
('USA',     2023, 0.0260),
('Germany', 2022, 0.0280),
('Germany', 2023, 0.0290);
GO

INSERT INTO dbo.fact_pre_invoice_deductions (customer_code, fiscal_year, pre_invoice_discount_pct)
VALUES
(70020016, 2022, 0.0500),  
(70020016, 2023, 0.0600),  
(70020017, 2022, 0.0400),
(70020017, 2023, 0.0450),
(70020018, 2022, 0.0300),
(70020018, 2023, 0.0350),
(70020019, 2022, 0.0250),
(70020019, 2023, 0.0300),
(70020020, 2022, 0.0200),
(70020020, 2023, 0.0250),
(70020021, 2022, 0.0300),
(70020021, 2023, 0.0320);
GO

INSERT INTO dbo.fact_post_invoice_deductions
    (customer_code, product_code, date, fiscal_year, discounts_pct, other_deductions_pct)
VALUES
(70020016, 'AQ_MSE_01', '2023-01-01', 2023, 0.0500, 0.0200), -- promo + placement
(70020016, 'AQ_KBD_01', '2023-01-01', 2023, 0.0400, 0.0150),
(70020016, 'AQ_MSE_01', '2023-02-01', 2023, 0.0300, 0.0150),
(70020017, 'AQ_MSE_01', '2023-01-01', 2023, 0.0400, 0.0100),
(70020018, 'AQ_LTP_01', '2023-01-01', 2023, 0.0250, 0.0200),
(70020019, 'AQ_MON_01', '2023-01-01', 2023, 0.0200, 0.0100);
GO

INSERT INTO dbo.fact_sales_monthly
    (date, fiscal_year, product_code, customer_code, sold_quantity)
VALUES
-- AtliQ E-Store India (70020016) – 2023
('2023-01-01', 2023, 'AQ_MSE_01', 70020016, 1200),
('2023-01-01', 2023, 'AQ_KBD_01', 70020016,  800),
('2023-02-01', 2023, 'AQ_MSE_01', 70020016, 1500),
('2023-02-01', 2023, 'AQ_KBD_01', 70020016,  900),
('2023-03-01', 2023, 'AQ_MSE_01', 70020016, 1400),
('2023-03-01', 2023, 'AQ_LTP_01', 70020016,  200),

-- Croma India (70020017) – 2023
('2023-01-01', 2023, 'AQ_MSE_01', 70020017,  600),
('2023-01-01', 2023, 'AQ_MON_01', 70020017,  250),
('2023-02-01', 2023, 'AQ_MSE_01', 70020017,  700),
('2023-02-01', 2023, 'AQ_MON_01', 70020017,  260),

-- Amazon India (70020018) – 2023
('2023-01-01', 2023, 'AQ_LTP_01', 70020018,  150),
('2023-02-01', 2023, 'AQ_LTP_01', 70020018,  180),

-- BestBuy USA (70020019) – 2023
('2023-01-01', 2023, 'AQ_MON_01', 70020019,  400),
('2023-01-01', 2023, 'AQ_PRN_01', 70020019,  150),

-- Amazon USA (70020020) – 2023
('2023-01-01', 2023, 'AQ_HDD_01', 70020020,  500),
('2023-02-01', 2023, 'AQ_HDD_01', 70020020,  550);
GO

INSERT INTO dbo.fact_forecast_monthly
    (date, fiscal_year, product_code, customer_code, forecast_quantity)
VALUES
-- AtliQ E-Store India (70020016) – 2023 forecast
('2023-01-01', 2023, 'AQ_MSE_01', 70020016, 1300),
('2023-01-01', 2023, 'AQ_KBD_01', 70020016,  850),
('2023-02-01', 2023, 'AQ_MSE_01', 70020016, 1450),
('2023-02-01', 2023, 'AQ_KBD_01', 70020016,  950),
('2023-03-01', 2023, 'AQ_MSE_01', 70020016, 1500),
('2023-03-01', 2023, 'AQ_LTP_01', 70020016,  220),

-- Croma India (70020017) – 2023 forecast
('2023-01-01', 2023, 'AQ_MSE_01', 70020017,  650),
('2023-01-01', 2023, 'AQ_MON_01', 70020017,  260),
('2023-02-01', 2023, 'AQ_MSE_01', 70020017,  750),
('2023-02-01', 2023, 'AQ_MON_01', 70020017,  270),

-- Amazon India (70020018) – 2023 forecast
('2023-01-01', 2023, 'AQ_LTP_01', 70020018,  160),
('2023-02-01', 2023, 'AQ_LTP_01', 70020018,  190);
GO

USE SupplyChainFinanceManagement;
GO
---------------------------------------------------
-- 1A) Create scalar function: fn_get_fiscal_year
---------------------------------------------------
IF OBJECT_ID('dbo.fn_get_fiscal_year', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_get_fiscal_year;
GO

CREATE FUNCTION dbo.fn_get_fiscal_year
(
    @calendar_date DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @fy INT;

    IF MONTH(@calendar_date) >= 9
        SET @fy = YEAR(@calendar_date);
    ELSE
        SET @fy = YEAR(@calendar_date) - 1;

    RETURN @fy;
END;
GO
---------------------------------------------------
-- 1B) Apply the function to '2023-07-15'
---------------------------------------------------
DECLARE @calendar_date DATE = '2023-07-15';

SELECT 
    @calendar_date AS calendar_date,
    dbo.fn_get_fiscal_year(@calendar_date) AS fiscal_year_result;
GO
/************************************************************************************
 * Q2) Analyzing Gross Sales: Monthly Product Transactions Report
 ************************************************************************************/
---------------------------------------------------
-- 2A) Monthly Product Transactions Report
---------------------------------------------------
SELECT
    s.date                             AS txn_date,
    s.fiscal_year,
    s.customer_code,
    c.customer                         AS customer_name,
    s.product_code,
    p.product                          AS product_name,
    p.variant                          AS product_variant,
    s.sold_quantity,
    gp.gross_price,
    (s.sold_quantity * gp.gross_price) AS gross_price_total
FROM dbo.fact_sales_monthly     AS s
INNER JOIN dbo.dim_product      AS p
    ON s.product_code = p.product_code
INNER JOIN dbo.fact_gross_price AS gp
    ON s.product_code = gp.product_code
   AND s.fiscal_year  = gp.fiscal_year
INNER JOIN dbo.dim_customer     AS c
    ON s.customer_code = c.customer_code
WHERE
    s.customer_code = 70020016   -- filter by customer
    AND s.fiscal_year = 2023     -- filter by fiscal year
ORDER BY
    s.date,
    s.product_code;
GO

/************************************************************************************
 TASK 4: ANALYTICAL QUERIES
 ************************************************************************************/

USE SupplyChainFinanceManagement;
GO
/************************************************************************************
 * 1) SALES TREND ANALYSIS
 *    "Query the fact_monthly_sales table to identify the monthly sales trend for each product.
 *     How do the sales volumes fluctuate over time?"
 ************************************************************************************/
---------------------------------------------------
-- 1A) Monthly sales trend per product (quantity)
---------------------------------------------------
SELECT
    s.product_code,
    p.product                      AS product_name,
    FORMAT(s.date, 'yyyy-MM')      AS year_month,
    SUM(s.sold_quantity)           AS total_sold_qty
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_product        AS p ON s.product_code = p.product_code
GROUP BY
    s.product_code,
    p.product,
    FORMAT(s.date, 'yyyy-MM')
ORDER BY
    s.product_code,
    year_month;
GO
/************************************************************************************
 * 2) CUSTOMER SEGMENTATION
 *    "Segment customers based on their purchasing behavior.
 *     Which customer segments contribute the most to sales revenue?"
 ************************************************************************************/
---------------------------------------------------
-- 2A) Revenue by customer segment (channel + market)
---------------------------------------------------
SELECT
    c.channel,
    c.market,
    SUM(s.sold_quantity * gp.gross_price) AS total_revenue
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_customer      AS c  ON s.customer_code = c.customer_code
JOIN dbo.fact_gross_price  AS gp ON s.product_code = gp.product_code
                                 AND s.fiscal_year  = gp.fiscal_year
GROUP BY
    c.channel,
    c.market
ORDER BY
    total_revenue DESC;
GO
---------------------------------------------------
-- 2B) Top customers by total revenue (for extra insight)
---------------------------------------------------
SELECT
    c.customer_code,
    c.customer,
    c.channel,
    c.market,
    SUM(s.sold_quantity * gp.gross_price) AS total_revenue
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_customer      AS c  ON s.customer_code = c.customer_code
JOIN dbo.fact_gross_price  AS gp ON s.product_code = gp.product_code
                                 AND s.fiscal_year  = gp.fiscal_year
GROUP BY
    c.customer_code,
    c.customer,
    c.channel,
    c.market
ORDER BY
    total_revenue DESC;
GO
/************************************************************************************
 * 3) PRODUCT PERFORMANCE COMPARISON
 *    "Compare the performance of products in terms of sales quantity and revenue."
 ************************************************************************************/
---------------------------------------------------
-- 3A) Product performance: total quantity and revenue
---------------------------------------------------
SELECT
    s.product_code,
    p.product        AS product_name,
    p.variant        AS product_variant,
    SUM(s.sold_quantity)                     AS total_sold_qty,
    SUM(s.sold_quantity * gp.gross_price)    AS total_revenue
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_product        AS p  ON s.product_code = p.product_code
JOIN dbo.fact_gross_price   AS gp ON s.product_code = gp.product_code
                                  AND s.fiscal_year  = gp.fiscal_year
GROUP BY
    s.product_code,
    p.product,
    p.variant
ORDER BY
    total_revenue DESC;
GO
/************************************************************************************
 * 4) MARKET EXPANSION OPPORTUNITIES
 *    "Analyze fact_forecast_monthly to identify markets with highest forecasted demand growth."
 ************************************************************************************/
---------------------------------------------------
-- 4A) Forecasted demand per market & fiscal year
---------------------------------------------------
WITH forecast_by_market AS (
    SELECT
        f.fiscal_year,
        c.market,
        SUM(f.forecast_quantity) AS total_forecast_qty
    FROM dbo.fact_forecast_monthly AS f
    JOIN dbo.dim_customer         AS c ON f.customer_code = c.customer_code
    GROUP BY
        f.fiscal_year,
        c.market
),
growth_calc AS (
    SELECT
        market,
        fiscal_year,
        total_forecast_qty,
        LAG(total_forecast_qty) OVER (PARTITION BY market ORDER BY fiscal_year) AS prev_year_qty
    FROM forecast_by_market
)
SELECT
    market,
    fiscal_year,
    total_forecast_qty,
    prev_year_qty,
    CASE
        WHEN prev_year_qty IS NULL OR prev_year_qty = 0 THEN NULL
        ELSE ( (total_forecast_qty - prev_year_qty) * 100.0 / prev_year_qty )
    END AS forecast_growth_pct
FROM growth_calc
ORDER BY
    market,
    fiscal_year;
GO
/************************************************************************************
 * 5) COST ANALYSIS
 *    "Calculate the total manufacturing cost for each product and compare it with the gross price to determine profitability. Which products have the highest profit margins?"
 ************************************************************************************/
---------------------------------------------------
-- 5A) Product-level profitability (using manufacturing cost)
---------------------------------------------------
WITH sales_revenue AS (
    SELECT
        s.product_code,
        s.fiscal_year,
        SUM(s.sold_quantity) AS total_qty
    FROM dbo.fact_sales_monthly AS s
    GROUP BY
        s.product_code,
        s.fiscal_year
)
SELECT
    sr.product_code,
    p.product  AS product_name,
    p.variant  AS product_variant,
    sr.fiscal_year,
    sr.total_qty,
    gp.gross_price,
    mc.manufacturing_cost,
    (sr.total_qty * gp.gross_price)            AS total_revenue,
    (sr.total_qty * mc.manufacturing_cost)     AS total_mfg_cost,
    (sr.total_qty * gp.gross_price) -
    (sr.total_qty * mc.manufacturing_cost)     AS gross_profit,
    CASE
        WHEN (sr.total_qty * gp.gross_price) = 0 THEN NULL
        ELSE (( (sr.total_qty * gp.gross_price) -
                (sr.total_qty * mc.manufacturing_cost)
              ) * 100.0 / (sr.total_qty * gp.gross_price))
    END AS gross_margin_pct
FROM sales_revenue          AS sr
JOIN dbo.dim_product        AS p  ON sr.product_code = p.product_code
JOIN dbo.fact_gross_price   AS gp ON sr.product_code = gp.product_code
                                  AND sr.fiscal_year = gp.fiscal_year
JOIN dbo.fact_manufacturing_cost AS mc
                              ON sr.product_code = mc.product_code
                             AND sr.fiscal_year = mc.cost_year
ORDER BY
    gross_margin_pct DESC;
GO
/************************************************************************************
 * 6) DISCOUNT IMPACT ANALYSIS
 *    "Assess the impact of pre-invoice discounts on sales revenue."
 ************************************************************************************/
---------------------------------------------------
-- 6A) Impact of pre-invoice discounts per customer & year
---------------------------------------------------
SELECT
    s.fiscal_year,
    c.customer_code,
    c.customer,
    SUM(s.sold_quantity * gp.gross_price) AS gross_revenue,
    SUM(
        s.sold_quantity * gp.gross_price
        * (1 - pid.pre_invoice_discount_pct)
    ) AS net_invoice_revenue,
    SUM(s.sold_quantity * gp.gross_price)
    - SUM(
        s.sold_quantity * gp.gross_price
        * (1 - pid.pre_invoice_discount_pct)
      ) AS discount_impact_amount
FROM dbo.fact_sales_monthly         AS s
JOIN dbo.dim_customer               AS c   ON s.customer_code = c.customer_code
JOIN dbo.fact_gross_price           AS gp  ON s.product_code = gp.product_code
                                           AND s.fiscal_year = gp.fiscal_year
JOIN dbo.fact_pre_invoice_deductions AS pid ON s.customer_code = pid.customer_code
                                           AND s.fiscal_year   = pid.fiscal_year
GROUP BY
    s.fiscal_year,
    c.customer_code,
    c.customer
ORDER BY
    gross_revenue DESC;
GO
/************************************************************************************
 * 7) MARKET-SPECIFIC FREIGHT COSTS
 *    "Determine the average freight costs for different markets over the years."
 ************************************************************************************/
---------------------------------------------------
-- 7A) Average freight % per market by year
---------------------------------------------------
SELECT
    market,
    fiscal_year,
    AVG(freight_pct) AS avg_freight_pct
FROM dbo.fact_freight_cost
GROUP BY
    market,
    fiscal_year
ORDER BY
    market,
    fiscal_year;
GO
/************************************************************************************
 * 8) SEASONAL SALES PATTERNS
 *    "Explore fact_sales_monthly to identify seasonal sales patterns."
 ************************************************************************************/
---------------------------------------------------
-- 8A) Total sold quantity per month-of-year (all products)
---------------------------------------------------
SELECT
    MONTH(date)                    AS month_no,
    DATENAME(MONTH, date)          AS month_name,
    SUM(sold_quantity)             AS total_sold_qty
FROM dbo.fact_sales_monthly
GROUP BY
    MONTH(date),
    DATENAME(MONTH, date)
ORDER BY
    month_no;
GO
---------------------------------------------------
-- 8B) Seasonal pattern per product (optional, more detailed)
---------------------------------------------------
SELECT
    product_code,
    MONTH(date)                    AS month_no,
    DATENAME(MONTH, date)          AS month_name,
    SUM(sold_quantity)             AS total_sold_qty
FROM dbo.fact_sales_monthly
GROUP BY
    product_code,
    MONTH(date),
    DATENAME(MONTH, date)
ORDER BY
    product_code,
    month_no;
GO
/************************************************************************************
 * 9) CUSTOMER LOYALTY ANALYSIS
 *    "Analyze customer purchase frequency and retention rates over time."
 *
************************************************************************************/
---------------------------------------------------
-- 9A) Customer purchase frequency (distinct active months) & quantity
---------------------------------------------------
SELECT
    c.customer_code,
    c.customer,
    COUNT(DISTINCT FORMAT(s.date, 'yyyy-MM')) AS active_months,
    SUM(s.sold_quantity)                      AS total_sold_qty
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_customer       AS c ON s.customer_code = c.customer_code
GROUP BY
    c.customer_code,
    c.customer
ORDER BY
    active_months DESC,
    total_sold_qty DESC;
GO
/************************************************************************************
 * 10) FORECAST ACCURACY EVALUATION
 *     "Evaluate the accuracy of sales forecasts by comparing forecasted quantities with actual sales data."
 ************************************************************************************/
---------------------------------------------------
-- 10A) Forecast vs Actual per product, customer, month
---------------------------------------------------
SELECT
    f.fiscal_year,
    f.date,
    f.product_code,
    p.product              AS product_name,
    f.customer_code,
    c.customer             AS customer_name,
    f.forecast_quantity,
    ISNULL(s.actual_qty, 0) AS actual_sold_qty,
    CASE
        WHEN f.forecast_quantity = 0 THEN NULL
        ELSE (ISNULL(s.actual_qty,0) * 100.0 / f.forecast_quantity)
    END AS forecast_accuracy_pct
FROM dbo.fact_forecast_monthly AS f
JOIN dbo.dim_product           AS p ON f.product_code  = p.product_code
JOIN dbo.dim_customer          AS c ON f.customer_code = c.customer_code
LEFT JOIN (
    SELECT
        fiscal_year,
        date,
        product_code,
        customer_code,
        SUM(sold_quantity) AS actual_qty
    FROM dbo.fact_sales_monthly
    GROUP BY
        fiscal_year,
        date,
        product_code,
        customer_code
) AS s
    ON  f.fiscal_year   = s.fiscal_year
    AND f.date          = s.date
    AND f.product_code  = s.product_code
    AND f.customer_code = s.customer_code
ORDER BY
    f.fiscal_year,
    f.date,
    f.product_code,
    f.customer_code;
GO
/************************************************************************************
 * 11) CHANNEL PERFORMANCE ASSESSMENT
 *     "Compare sales performance across different sales channels."
 ************************************************************************************/
---------------------------------------------------
-- 11A) Sales revenue by channel
---------------------------------------------------
SELECT
    c.channel,
    SUM(s.sold_quantity * gp.gross_price) AS total_revenue,
    SUM(s.sold_quantity)                  AS total_units
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_customer       AS c  ON s.customer_code = c.customer_code
JOIN dbo.fact_gross_price   AS gp ON s.product_code  = gp.product_code
                                  AND s.fiscal_year  = gp.fiscal_year
GROUP BY
    c.channel
ORDER BY
    total_revenue DESC;
GO



/************************************************************************************
 * 12) GEOGRAPHICAL SALES DISTRIBUTION
 *     "Analyze sales distribution across different geographical regions."
 ************************************************************************************/
---------------------------------------------------
-- 12A) Revenue by region and market
---------------------------------------------------
SELECT
    c.region,
    c.market,
    SUM(s.sold_quantity * gp.gross_price) AS total_revenue,
    SUM(s.sold_quantity)                  AS total_units
FROM dbo.fact_sales_monthly AS s
JOIN dbo.dim_customer       AS c  ON s.customer_code = c.customer_code
JOIN dbo.fact_gross_price   AS gp ON s.product_code  = gp.product_code
                                  AND s.fiscal_year  = gp.fiscal_year
GROUP BY
    c.region,
    c.market
ORDER BY
    c.region,
    total_revenue DESC;
GO
/************************************************************************************
- TASK 5 (ADVANCED FEATURES)
 ************************************************************************************/
USE SupplyChainFinanceManagement;
GO
/************************************************************************************
 * Q1) UDF: Total Forecasted Quantity for a Product & Fiscal Year
 ************************************************************************************/
IF OBJECT_ID('dbo.fn_total_forecast_qty', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_total_forecast_qty;
GO

CREATE FUNCTION dbo.fn_total_forecast_qty
(
    @product_code VARCHAR(20),
    @fiscal_year  INT
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total = COALESCE(SUM(forecast_quantity), 0)
    FROM dbo.fact_forecast_monthly
    WHERE product_code = @product_code
      AND fiscal_year  = @fiscal_year;

    RETURN @total;
END;
GO
/************************************************************************************
 * Q2) Query: Customers whose purchases exceed average monthly sales quantity
 ************************************************************************************/
;WITH cust_monthly AS (
    SELECT
        s.customer_code,
        FORMAT(s.date, 'yyyy-MM') AS year_month,
        SUM(s.sold_quantity)      AS monthly_qty
    FROM dbo.fact_sales_monthly AS s
    GROUP BY
        s.customer_code,
        FORMAT(s.date, 'yyyy-MM')
),
cust_avg AS (
    SELECT
        customer_code,
        AVG(CAST(monthly_qty AS FLOAT)) AS avg_monthly_qty
    FROM cust_monthly
    GROUP BY
        customer_code
),
global_monthly AS (
    SELECT
        FORMAT(date, 'yyyy-MM') AS year_month,
        SUM(sold_quantity)      AS monthly_qty
    FROM dbo.fact_sales_monthly
    GROUP BY
        FORMAT(date, 'yyyy-MM')
),
global_avg AS (
    SELECT AVG(CAST(monthly_qty AS FLOAT)) AS global_avg_monthly_qty
    FROM global_monthly
)
SELECT
    c.customer_code,
    c.customer,
    ca.avg_monthly_qty,
    g.global_avg_monthly_qty
FROM cust_avg      AS ca
CROSS JOIN global_avg AS g
JOIN dbo.dim_customer AS c
    ON ca.customer_code = c.customer_code
WHERE ca.avg_monthly_qty > g.global_avg_monthly_qty
ORDER BY ca.avg_monthly_qty DESC;
GO
/************************************************************************************
 * Q3) Stored Procedure: Update Gross Price of a Product for a Fiscal Year
 ************************************************************************************/
IF OBJECT_ID('dbo.sp_update_gross_price', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_update_gross_price;
GO

CREATE PROCEDURE dbo.sp_update_gross_price
    @product_code  VARCHAR(20),
    @fiscal_year   INT,
    @new_gross_price DECIMAL(10,4)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.fact_gross_price
        WHERE product_code = @product_code
          AND fiscal_year  = @fiscal_year
    )
    BEGIN
        UPDATE dbo.fact_gross_price
        SET gross_price = @new_gross_price
        WHERE product_code = @product_code
          AND fiscal_year  = @fiscal_year;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.fact_gross_price (product_code, fiscal_year, gross_price)
        VALUES (@product_code, @fiscal_year, @new_gross_price);
    END
END;
GO
/************************************************************************************
 * Q4) Trigger: Audit Log on Insert into Sales Table
 ************************************************************************************/
-- Audit log table
IF OBJECT_ID('dbo.sales_audit_log', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.sales_audit_log (
        audit_id       INT IDENTITY(1,1) PRIMARY KEY,
        audit_time     DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
        action_type    VARCHAR(20)    NOT NULL,
        date           DATE           NOT NULL,
        fiscal_year    INT            NOT NULL,
        product_code   VARCHAR(20)    NOT NULL,
        customer_code  INT            NOT NULL,
        sold_quantity  INT            NOT NULL
    );
END;
GO

-- Trigger
IF OBJECT_ID('dbo.trg_sales_audit', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_sales_audit;
GO

CREATE TRIGGER dbo.trg_sales_audit
ON dbo.fact_sales_monthly
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.sales_audit_log
        (action_type, date, fiscal_year, product_code, customer_code, sold_quantity)
    SELECT
        'INSERT',
        i.date,
        i.fiscal_year,
        i.product_code,
        i.customer_code,
        i.sold_quantity
    FROM inserted AS i;
END;
GO
/************************************************************************************
 * Q5) Window Function: Rank Products by Monthly Sales Quantity (by Fiscal Year)
 ************************************************************************************/
;WITH monthly_qty AS (
    SELECT
        s.fiscal_year,
        s.date,
        s.product_code,
        SUM(s.sold_quantity) AS monthly_sold_qty
    FROM dbo.fact_sales_monthly AS s
    GROUP BY
        s.fiscal_year,
        s.date,
        s.product_code
)
SELECT
    fiscal_year,
    date,
    product_code,
    monthly_sold_qty,
    RANK() OVER (
        PARTITION BY fiscal_year, date
        ORDER BY monthly_sold_qty DESC
    ) AS product_rank_month
FROM monthly_qty
ORDER BY
    fiscal_year,
    date,
    product_rank_month;
GO
/************************************************************************************
 * Q6) Concatenate Customer Names for a Product in a Timeframe
 ************************************************************************************/
DECLARE @product_for_concat VARCHAR(20) = 'AQ_MSE_01';
DECLARE @start_date_concat  DATE        = '2023-01-01';
DECLARE @end_date_concat    DATE        = '2023-03-31';

;WITH cust_list AS (
    SELECT DISTINCT
        c.customer
    FROM dbo.fact_sales_monthly AS s
    JOIN dbo.dim_customer      AS c ON s.customer_code = c.customer_code
    WHERE
        s.product_code = @product_for_concat
        AND s.date BETWEEN @start_date_concat AND @end_date_concat
)
SELECT
    @product_for_concat AS product_code,
    STUFF((
        SELECT ', ' + cl.customer
        FROM cust_list AS cl
        ORDER BY cl.customer
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS customers_who_purchased;
GO
/************************************************************************************
 * Q7) UDF: Total Manufacturing Cost for Product Over Range of Years
 ************************************************************************************/
IF OBJECT_ID('dbo.fn_total_mfg_cost', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_total_mfg_cost;
GO

CREATE FUNCTION dbo.fn_total_mfg_cost
(
    @product_code VARCHAR(20),
    @start_year   INT,
    @end_year     INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @total DECIMAL(18,4);

    SELECT @total = COALESCE((
        SELECT SUM(manufacturing_cost)
        FROM dbo.fact_manufacturing_cost
        WHERE product_code = @product_code
          AND cost_year BETWEEN @start_year AND @end_year
    ), 0);

    RETURN @total;
END;
GO
/************************************************************************************
 * Q8 & Q12) Inventory Constraint + Auto Inventory Update via Trigger and Procedure
 ************************************************************************************/

USE SupplyChainFinanceManagement;
GO

-- 1) Add inventory_qty column if not present
IF COL_LENGTH('dbo.dim_product', 'inventory_qty') IS NULL
BEGIN
    ALTER TABLE dbo.dim_product
    ADD inventory_qty INT NULL;
END;
GO

-- 2) Stored procedure to insert new sales record
IF OBJECT_ID('dbo.sp_insert_sale', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insert_sale;
GO

CREATE PROCEDURE dbo.sp_insert_sale
    @date          DATE,
    @fiscal_year   INT,
    @product_code  VARCHAR(20),
    @customer_code INT,
    @sold_quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.fact_sales_monthly (date, fiscal_year, product_code, customer_code, sold_quantity)
    VALUES (@date, @fiscal_year, @product_code, @customer_code, @sold_quantity);
END;
GO

-- 3) Trigger to enforce quantity <= inventory AND update inventory after sale
IF OBJECT_ID('dbo.trg_sales_inventory_control', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_sales_inventory_control;
GO

CREATE TRIGGER dbo.trg_sales_inventory_control
ON dbo.fact_sales_monthly
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT
                product_code,
                SUM(sold_quantity) AS total_sold_qty
            FROM inserted
            GROUP BY product_code
        ) AS i
        JOIN dbo.dim_product AS p
            ON i.product_code = p.product_code
        WHERE i.total_sold_qty > ISNULL(p.inventory_qty, 0)
    )
    BEGIN
        RAISERROR ('Sold quantity exceeds available inventory.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE p
    SET p.inventory_qty = ISNULL(p.inventory_qty, 0) - i.total_sold_qty
    FROM dbo.dim_product AS p
    JOIN (
        SELECT
            product_code,
            SUM(sold_quantity) AS total_sold_qty
        FROM inserted
        GROUP BY product_code
    ) AS i
        ON p.product_code = i.product_code;
END;
GO
/************************************************************************************
 * Q9) LEAD/LAG: Compare Monthly Sales of a Product with Previous Month
 ************************************************************************************/

DECLARE @product_for_lag VARCHAR(20) = 'AQ_MSE_01';

;WITH monthly AS (
    SELECT
        product_code,
        date,
        SUM(sold_quantity) AS monthly_qty
    FROM dbo.fact_sales_monthly
    WHERE product_code = @product_for_lag
    GROUP BY
        product_code,
        date
)
SELECT
    product_code,
    date,
    monthly_qty,
    LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY date) AS prev_month_qty,
    monthly_qty 
        - LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY date) AS diff_from_prev
FROM monthly
ORDER BY date;
GO
/************************************************************************************
 * Q10) Top-Selling Products in Each Market (Total Sales Quantity)
 ************************************************************************************/

;WITH product_market_qty AS (
    SELECT
        c.market,
        s.product_code,
        p.product        AS product_name,
        SUM(s.sold_quantity) AS total_qty
    FROM dbo.fact_sales_monthly AS s
    JOIN dbo.dim_customer      AS c ON s.customer_code = c.customer_code
    JOIN dbo.dim_product       AS p ON s.product_code  = p.product_code
    GROUP BY
        c.market,
        s.product_code,
        p.product
),
ranked AS (
    SELECT
        market,
        product_code,
        product_name,
        total_qty,
        RANK() OVER (PARTITION BY market ORDER BY total_qty DESC) AS qty_rank
    FROM product_market_qty
)
SELECT *
FROM ranked
WHERE qty_rank = 1
ORDER BY market, product_code;
GO
/************************************************************************************
 * Q11) UDF: Total Freight Cost for Product by Market & Year + Stored Procedure to Update an Overall Cost Table
 ************************************************************************************/

-- Overall cost table
IF OBJECT_ID('dbo.fact_overall_cost', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.fact_overall_cost (
        product_code       VARCHAR(20)  NOT NULL,
        market             VARCHAR(50)  NOT NULL,
        fiscal_year        INT          NOT NULL,
        total_freight_cost DECIMAL(18,4) NOT NULL,
        CONSTRAINT PK_fact_overall_cost
            PRIMARY KEY (product_code, market, fiscal_year)
    );
END;
GO

-- UDF: total freight cost
IF OBJECT_ID('dbo.fn_total_freight_cost', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_total_freight_cost;
GO

CREATE FUNCTION dbo.fn_total_freight_cost
(
    @product_code VARCHAR(20),
    @market       VARCHAR(50),
    @fiscal_year  INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @total DECIMAL(18,4);

    SELECT @total = COALESCE(SUM(
                s.sold_quantity * gp.gross_price * fc.freight_pct
            ), 0)
    FROM dbo.fact_sales_monthly AS s
    JOIN dbo.dim_customer       AS c  ON s.customer_code = c.customer_code
    JOIN dbo.fact_gross_price   AS gp ON s.product_code  = gp.product_code
                                     AND s.fiscal_year   = gp.fiscal_year
    JOIN dbo.fact_freight_cost  AS fc ON c.market        = fc.market
                                     AND s.fiscal_year   = fc.fiscal_year
    WHERE s.product_code = @product_code
      AND c.market       = @market
      AND s.fiscal_year  = @fiscal_year;

    RETURN @total;
END;
GO

-- Stored procedure: update overall freight cost
IF OBJECT_ID('dbo.sp_update_overall_freight_cost', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_update_overall_freight_cost;
GO

CREATE PROCEDURE dbo.sp_update_overall_freight_cost
    @product_code VARCHAR(20),
    @market       VARCHAR(50),
    @fiscal_year  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @total DECIMAL(18,4);

    SET @total = dbo.fn_total_freight_cost(@product_code, @market, @fiscal_year);

    MERGE dbo.fact_overall_cost AS target
    USING (SELECT @product_code AS product_code,
                  @market       AS market,
                  @fiscal_year  AS fiscal_year,
                  @total        AS total_freight_cost) AS src
    ON  target.product_code = src.product_code
    AND target.market       = src.market
    AND target.fiscal_year  = src.fiscal_year
    WHEN MATCHED THEN
        UPDATE SET total_freight_cost = src.total_freight_cost
    WHEN NOT MATCHED THEN
        INSERT (product_code, market, fiscal_year, total_freight_cost)
        VALUES (src.product_code, src.market, src.fiscal_year, src.total_freight_cost);
END;
GO
/************************************************************************************
 * Q13) Trigger: Enforce Referential Integrity for Products in Sales Table
 ************************************************************************************/

IF OBJECT_ID('dbo.trg_sales_product_ref_integrity', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_sales_product_ref_integrity;
GO

CREATE TRIGGER dbo.trg_sales_product_ref_integrity
ON dbo.fact_sales_monthly
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.dim_product p
            WHERE p.product_code = i.product_code
        )
    )
    BEGIN
        RAISERROR ('Invalid product_code: not found in dim_product.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO
/************************************************************************************
 * Q14) Stored Procedure: Month-over-Month Growth Rate of Sales for Each Product
 ************************************************************************************/
IF OBJECT_ID('dbo.sp_mom_sales_growth', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_mom_sales_growth;
GO

CREATE PROCEDURE dbo.sp_mom_sales_growth
    @start_date DATE,
    @end_date   DATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH monthly AS (
        SELECT
            product_code,
            FORMAT(date, 'yyyy-MM') AS year_month,
            MIN(date)               AS month_date,
            SUM(sold_quantity)      AS monthly_qty
        FROM dbo.fact_sales_monthly
        WHERE date BETWEEN @start_date AND @end_date
        GROUP BY
            product_code,
            FORMAT(date, 'yyyy-MM')
    )
    SELECT
        product_code,
        year_month,
        monthly_qty,
        LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY month_date) AS prev_month_qty,
        CASE
            WHEN LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY month_date) = 0
                 OR LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY month_date) IS NULL
            THEN NULL
            ELSE (
                (monthly_qty - LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY month_date))
                * 100.0
                / LAG(monthly_qty) OVER (PARTITION BY product_code ORDER BY month_date)
            )
        END AS mom_growth_pct
    FROM monthly
    ORDER BY
        product_code,
        month_date;
END;
GO
/************************************************************************************
 * Q15) UDF: Average Discount Percentage for a Product
 ************************************************************************************/
IF OBJECT_ID('dbo.fn_avg_discount_pct', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_avg_discount_pct;
GO

CREATE FUNCTION dbo.fn_avg_discount_pct
(
    @product_code VARCHAR(20)
)
RETURNS DECIMAL(10,4)
AS
BEGIN
    DECLARE @avg DECIMAL(10,4);

    SELECT @avg = AVG(CAST(discounts_pct AS DECIMAL(10,4)))
    FROM dbo.fact_post_invoice_deductions
    WHERE product_code = @product_code;

    RETURN COALESCE(@avg, 0);
END;
GO
/************************************************************************************
 * Q16) Customers with Highest Total Purchases in Each Region
 ************************************************************************************/
;WITH cust_region_revenue AS (
    SELECT
        c.region,
        c.customer_code,
        c.customer,
        SUM(s.sold_quantity * gp.gross_price) AS total_revenue
    FROM dbo.fact_sales_monthly AS s
    JOIN dbo.dim_customer      AS c  ON s.customer_code = c.customer_code
    JOIN dbo.fact_gross_price  AS gp ON s.product_code  = gp.product_code
                                     AND s.fiscal_year  = gp.fiscal_year
    GROUP BY
        c.region,
        c.customer_code,
        c.customer
),
ranked AS (
    SELECT
        region,
        customer_code,
        customer,
        total_revenue,
        RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC) AS rev_rank
    FROM cust_region_revenue
)
SELECT
    region,
    customer_code,
    customer,
    total_revenue
FROM ranked
WHERE rev_rank = 1
ORDER BY region, customer_code;
GO
/************************************************************************************
 * Q17) Stored Procedure: Total Revenue for a Given Period
 ************************************************************************************/
IF OBJECT_ID('dbo.sp_total_revenue_period', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_total_revenue_period;
GO

CREATE PROCEDURE dbo.sp_total_revenue_period
    @start_date DATE,
    @end_date   DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SUM(s.sold_quantity * gp.gross_price) AS total_revenue
    FROM dbo.fact_sales_monthly AS s
    JOIN dbo.fact_gross_price   AS gp ON s.product_code = gp.product_code
                                     AND s.fiscal_year  = gp.fiscal_year
    WHERE s.date BETWEEN @start_date AND @end_date;
END;
GO
/************************************************************************************
 * Q18) Trigger: Auto-update Forecast When New Product is Added using a UDF to calculate default forecast
 ************************************************************************************/
IF OBJECT_ID('dbo.fn_default_forecast', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_default_forecast;
GO

CREATE FUNCTION dbo.fn_default_forecast
(
    @product_code VARCHAR(20),
    @fiscal_year  INT
)
RETURNS INT
AS
BEGIN
    DECLARE @default_forecast INT;

    -- Example: use average forecast of all products for that year, or 100 if none
    SELECT @default_forecast = COALESCE(
        (SELECT AVG(forecast_quantity)
         FROM dbo.fact_forecast_monthly
         WHERE fiscal_year = @fiscal_year), 100
    );

    RETURN @default_forecast;
END;
GO
-- Trigger on dim_product to insert default forecast rows for new products
IF OBJECT_ID('dbo.trg_product_default_forecast', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_product_default_forecast;
GO

CREATE TRIGGER dbo.trg_product_default_forecast
ON dbo.dim_product
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- For each new product, create a forecast for each existing fiscal_year & customer
    INSERT INTO dbo.fact_forecast_monthly
        (date, fiscal_year, product_code, customer_code, forecast_quantity)
    SELECT
        DATEFROMPARTS(fy.fiscal_year, 1, 1) AS date,
        fy.fiscal_year,
        i.product_code,
        c.customer_code,
        dbo.fn_default_forecast(i.product_code, fy.fiscal_year) AS forecast_quantity
    FROM inserted AS i
    CROSS JOIN (SELECT DISTINCT fiscal_year FROM dbo.fact_sales_monthly) AS fy
    CROSS JOIN (SELECT DISTINCT customer_code FROM dbo.fact_sales_monthly) AS c;
END;
GO
/************************************************************************************
 * Q19) Trigger: Identify Outliers in Monthly Sales Data (Flag for Investigation)
 ************************************************************************************/
-- Outlier log table
IF OBJECT_ID('dbo.sales_outlier_log', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.sales_outlier_log (
        outlier_id      INT IDENTITY(1,1) PRIMARY KEY,
        log_time        DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
        date            DATE           NOT NULL,
        product_code    VARCHAR(20)    NOT NULL,
        customer_code   INT            NOT NULL,
        sold_quantity   INT            NOT NULL,
        avg_product_qty DECIMAL(18,4)  NOT NULL,
        flag_reason     VARCHAR(255)   NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.trg_sales_outlier_flag', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_sales_outlier_flag;
GO

CREATE TRIGGER dbo.trg_sales_outlier_flag
ON dbo.fact_sales_monthly
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH prod_avg AS (
        SELECT
            i.product_code,
            i.fiscal_year,
            AVG(CAST(s.sold_quantity AS FLOAT)) AS avg_qty
        FROM inserted i
        JOIN dbo.fact_sales_monthly s
            ON i.product_code = s.product_code
           AND i.fiscal_year = s.fiscal_year
        GROUP BY
            i.product_code,
            i.fiscal_year
    )
    INSERT INTO dbo.sales_outlier_log
        (date, product_code, customer_code, sold_quantity, avg_product_qty, flag_reason)
    SELECT
        i.date,
        i.product_code,
        i.customer_code,
        i.sold_quantity,
        pa.avg_qty,
        'Sold quantity > 2x fiscal-year average for this product'
    FROM inserted AS i
    JOIN prod_avg AS pa
        ON i.product_code = pa.product_code
       AND i.fiscal_year = pa.fiscal_year
    WHERE i.sold_quantity > 2 * pa.avg_qty;
END;
GO
/************************************************************************************
 * Q20) Products with Highest Average Gross Price (Across All Fiscal Years)
 ************************************************************************************/
;WITH avg_price AS (
    SELECT
        product_code,
        AVG(gross_price) AS avg_gross_price
    FROM dbo.fact_gross_price
    GROUP BY
        product_code
),
max_price AS (
    SELECT MAX(avg_gross_price) AS max_avg_price
    FROM avg_price
)
SELECT
    ap.product_code,
    p.product,
    ap.avg_gross_price
FROM avg_price ap
CROSS JOIN max_price mp
JOIN dbo.dim_product p
    ON ap.product_code = p.product_code
WHERE ap.avg_gross_price = mp.max_avg_price;
GO
/************************************************************************************
 * SUPPLY CHAIN MEGA PROJECT USING SQL - TASK 6 (FINAL ERROR-FREE VERSION)
 * Monthly Forecast Accuracy Using PIVOT
 ************************************************************************************/

USE SupplyChainFinanceManagement;
GO


/************************************************************************************
 * STEP 0 – Declare product parameter (NO GO after this!)
 ************************************************************************************/
DECLARE @product_code VARCHAR(20) = 'AQ_MSE_01';   -- change as needed
-- DO NOT PUT "GO" HERE — It resets the variable!

USE SupplyChainFinanceManagement;
GO

DECLARE @product_code VARCHAR(20) = 'AQ_MSE_01';  -- choose a valid product_code

WITH forecast_agg AS (
    SELECT
        f.fiscal_year,
        MONTH(f.date) AS month_no,
        DATENAME(MONTH, f.date) AS month_name,
        SUM(f.forecast_quantity) AS forecast_qty
    FROM dbo.fact_forecast_monthly AS f
    WHERE f.product_code = @product_code
    GROUP BY
        f.fiscal_year,
        MONTH(f.date),
        DATENAME(MONTH, f.date)
),
sales_agg AS (
    SELECT
        s.fiscal_year,
        MONTH(s.date) AS month_no,
        SUM(s.sold_quantity) AS actual_qty
    FROM dbo.fact_sales_monthly AS s
    WHERE s.product_code = @product_code
    GROUP BY
        s.fiscal_year,
        MONTH(s.date)
)
SELECT
    fa.fiscal_year,
    fa.month_no,
    fa.month_name,
    fa.forecast_qty,
    ISNULL(sa.actual_qty, 0) AS actual_qty,
    CASE
        WHEN fa.forecast_qty IS NULL OR fa.forecast_qty = 0
            THEN NULL
        ELSE (ISNULL(sa.actual_qty,0) * 100.0 / fa.forecast_qty)
    END AS forecast_accuracy_pct
FROM forecast_agg AS fa
LEFT JOIN sales_agg AS sa
    ON  fa.fiscal_year = sa.fiscal_year
    AND fa.month_no    = sa.month_no
ORDER BY
    fa.fiscal_year,
    fa.month_no;


/************************************************************************************
 * STEP 2 – Final Output: Forecast vs Actual + Accuracy %
 ************************************************************************************/
USE SupplyChainFinanceManagement;
GO

WITH
-- 1) Aggregate FORECAST by fiscal_year + month_no
forecast_agg AS (
    SELECT
        f.fiscal_year,
        MONTH(f.date) AS month_no,
        SUM(f.forecast_quantity) AS forecast_qty
    FROM dbo.fact_forecast_monthly AS f
    WHERE f.product_code = 'AQ_MSE_01'   -- <<< change product if needed
    GROUP BY
        f.fiscal_year,
        MONTH(f.date)
),

-- 2) Pivot forecast_agg so each month (1..12) becomes a column
forecast_pivot AS (
    SELECT
        fiscal_year,
        ISNULL([1],  0) AS [1],
        ISNULL([2],  0) AS [2],
        ISNULL([3],  0) AS [3],
        ISNULL([4],  0) AS [4],
        ISNULL([5],  0) AS [5],
        ISNULL([6],  0) AS [6],
        ISNULL([7],  0) AS [7],
        ISNULL([8],  0) AS [8],
        ISNULL([9],  0) AS [9],
        ISNULL([10], 0) AS [10],
        ISNULL([11], 0) AS [11],
        ISNULL([12], 0) AS [12]
    FROM forecast_agg
    PIVOT (
        SUM(forecast_qty)
        FOR month_no IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
    ) AS p
),

-- 3) Aggregate ACTUAL sales by fiscal_year + month_no
actual_agg AS (
    SELECT
        s.fiscal_year,
        MONTH(s.date) AS month_no,
        SUM(s.sold_quantity) AS actual_qty
    FROM dbo.fact_sales_monthly AS s
    WHERE s.product_code = 'AQ_MSE_01'   -- <<< same product code
    GROUP BY
        s.fiscal_year,
        MONTH(s.date)
),

-- 4) Pivot actual_agg so each month (1..12) becomes a column
actual_pivot AS (
    SELECT
        fiscal_year,
        ISNULL([1],  0) AS [1],
        ISNULL([2],  0) AS [2],
        ISNULL([3],  0) AS [3],
        ISNULL([4],  0) AS [4],
        ISNULL([5],  0) AS [5],
        ISNULL([6],  0) AS [6],
        ISNULL([7],  0) AS [7],
        ISNULL([8],  0) AS [8],
        ISNULL([9],  0) AS [9],
        ISNULL([10], 0) AS [10],
        ISNULL([11], 0) AS [11],
        ISNULL([12], 0) AS [12]
    FROM actual_agg
    PIVOT (
        SUM(actual_qty)
        FOR month_no IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
    ) AS p
)

-- 5) Final SELECT: Forecast vs Actual vs Accuracy for each month
SELECT
    ISNULL(f.fiscal_year, a.fiscal_year) AS fiscal_year,

    -- JAN
    f.[1]  AS Jan_Forecast,
    a.[1]  AS Jan_Actual,
    CASE WHEN f.[1] = 0 THEN NULL ELSE a.[1] * 100.0 / f.[1] END AS Jan_Accuracy,

    -- FEB
    f.[2]  AS Feb_Forecast,
    a.[2]  AS Feb_Actual,
    CASE WHEN f.[2] = 0 THEN NULL ELSE a.[2] * 100.0 / f.[2] END AS Feb_Accuracy,

    -- MAR
    f.[3]  AS Mar_Forecast,
    a.[3]  AS Mar_Actual,
    CASE WHEN f.[3] = 0 THEN NULL ELSE a.[3] * 100.0 / f.[3] END AS Mar_Accuracy,

    -- APR
    f.[4]  AS Apr_Forecast,
    a.[4]  AS Apr_Actual,
    CASE WHEN f.[4] = 0 THEN NULL ELSE a.[4] * 100.0 / f.[4] END AS Apr_Accuracy,

    -- MAY
    f.[5]  AS May_Forecast,
    a.[5]  AS May_Actual,
    CASE WHEN f.[5] = 0 THEN NULL ELSE a.[5] * 100.0 / f.[5] END AS May_Accuracy,

    -- JUN
    f.[6]  AS Jun_Forecast,
    a.[6]  AS Jun_Actual,
    CASE WHEN f.[6] = 0 THEN NULL ELSE a.[6] * 100.0 / f.[6] END AS Jun_Accuracy,

    -- JUL
    f.[7]  AS Jul_Forecast,
    a.[7]  AS Jul_Actual,
    CASE WHEN f.[7] = 0 THEN NULL ELSE a.[7] * 100.0 / f.[7] END AS Jul_Accuracy,

    -- AUG
    f.[8]  AS Aug_Forecast,
    a.[8]  AS Aug_Actual,
    CASE WHEN f.[8] = 0 THEN NULL ELSE a.[8] * 100.0 / f.[8] END AS Aug_Accuracy,

    -- SEP
    f.[9]  AS Sep_Forecast,
    a.[9]  AS Sep_Actual,
    CASE WHEN f.[9] = 0 THEN NULL ELSE a.[9] * 100.0 / f.[9] END AS Sep_Accuracy,

    -- OCT
    f.[10] AS Oct_Forecast,
    a.[10] AS Oct_Actual,
    CASE WHEN f.[10] = 0 THEN NULL ELSE a.[10] * 100.0 / f.[10] END AS Oct_Accuracy,

    -- NOV
    f.[11] AS Nov_Forecast,
    a.[11] AS Nov_Actual,
    CASE WHEN f.[11] = 0 THEN NULL ELSE a.[11] * 100.0 / f.[11] END AS Nov_Accuracy,

    -- DEC
    f.[12] AS Dec_Forecast,
    a.[12] AS Dec_Actual,
    CASE WHEN f.[12] = 0 THEN NULL ELSE a.[12] * 100.0 / f.[12] END AS Dec_Accuracy

FROM forecast_pivot f
FULL OUTER JOIN actual_pivot a
    ON f.fiscal_year = a.fiscal_year
ORDER BY fiscal_year;
