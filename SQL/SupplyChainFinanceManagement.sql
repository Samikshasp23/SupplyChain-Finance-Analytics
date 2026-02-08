
-- Supply Chain Finance Management SQL Server Project
-- Author: Samiksha Pathare
-- Database: SupplyChainFinanceManagement

CREATE DATABASE SupplyChainFinanceManagement;
USE SupplyChainFinanceManagement;

-- =========================
-- Dimension Tables
-- =========================
CREATE TABLE dim_customer (
    customer_code VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    market VARCHAR(50),
    region VARCHAR(50),
    channel VARCHAR(50)
);

CREATE TABLE dim_product (
    product_code VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    variant VARCHAR(50),
    category VARCHAR(50)
);

-- =========================
-- Fact Tables
-- =========================
CREATE TABLE fact_sales_monthly (
    date DATE,
    fiscal_year INT,
    month VARCHAR(15),
    customer_code VARCHAR(20),
    product_code VARCHAR(20),
    sold_quantity INT,
    FOREIGN KEY (customer_code) REFERENCES dim_customer(customer_code),
    FOREIGN KEY (product_code) REFERENCES dim_product(product_code)
);

CREATE TABLE fact_forecast_monthly (
    fiscal_year INT,
    month VARCHAR(15),
    product_code VARCHAR(20),
    forecast_quantity INT,
    FOREIGN KEY (product_code) REFERENCES dim_product(product_code)
);

CREATE TABLE fact_gross_price (
    product_code VARCHAR(20),
    fiscal_year INT,
    gross_price DECIMAL(10,2),
    FOREIGN KEY (product_code) REFERENCES dim_product(product_code)
);

CREATE TABLE fact_pre_invoice_deductions (
    customer_code VARCHAR(20),
    fiscal_year INT,
    discount_pct DECIMAL(5,2),
    FOREIGN KEY (customer_code) REFERENCES dim_customer(customer_code)
);

CREATE TABLE fact_post_invoice_deductions (
    product_code VARCHAR(20),
    fiscal_year INT,
    deductions_amount DECIMAL(10,2),
    FOREIGN KEY (product_code) REFERENCES dim_product(product_code)
);

CREATE TABLE fact_manufacturing_cost (
    product_code VARCHAR(20),
    fiscal_year INT,
    manufacturing_cost DECIMAL(10,2),
    FOREIGN KEY (product_code) REFERENCES dim_product(product_code)
);

CREATE TABLE fact_freight_cost (
    market VARCHAR(50),
    fiscal_year INT,
    freight_cost DECIMAL(10,2)
);

-- =========================
-- Sample Data
-- =========================
INSERT INTO dim_customer VALUES
('C001','Croma','India','APAC','Retail'),
('C002','Amazon','India','APAC','E-Commerce');

INSERT INTO dim_product VALUES
('P001','Wireless Mouse','Standard','Accessories'),
('P002','Mechanical Keyboard','Pro','Accessories');

INSERT INTO fact_sales_monthly VALUES
('2023-07-01',2023,'July','C001','P001',500),
('2023-07-01',2023,'July','C002','P002',300);

INSERT INTO fact_forecast_monthly VALUES
(2023,'July','P001',550),
(2023,'July','P002',320);

INSERT INTO fact_gross_price VALUES
('P001',2023,30.00),
('P002',2023,80.00);

INSERT INTO fact_pre_invoice_deductions VALUES
('C001',2023,5.00),
('C002',2023,6.00);

INSERT INTO fact_post_invoice_deductions VALUES
('P001',2023,3.00),
('P002',2023,5.00);

INSERT INTO fact_manufacturing_cost VALUES
('P001',2023,20.00),
('P002',2023,55.00);

INSERT INTO fact_freight_cost VALUES
('India',2023,2.50);

-- =========================
-- User Defined Function
-- =========================
CREATE FUNCTION fn_total_forecast_qty (
    @product_code VARCHAR(20),
    @fiscal_year INT
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;
    SELECT @total = SUM(forecast_quantity)
    FROM fact_forecast_monthly
    WHERE product_code = @product_code AND fiscal_year = @fiscal_year;
    RETURN @total;
END;

-- =========================
-- Window Function Example
-- =========================
SELECT 
    product_code,
    fiscal_year,
    month,
    sold_quantity,
    RANK() OVER (PARTITION BY fiscal_year ORDER BY sold_quantity DESC) AS sales_rank
FROM fact_sales_monthly;
