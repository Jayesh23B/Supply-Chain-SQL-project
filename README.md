# Supply Chain Management System (SQL) 📦

## Project Overview
This project implements a SQL-based Supply Chain Management System to analyze sales, forecasts, pricing, costs, and inventory using structured data.

## Business Problem
Organizations often face challenges due to disconnected sales, forecast, and inventory data, leading to poor demand planning and inefficient inventory management.

## Project Scope
- Design dimension and fact tables
- Load customer, product, sales, and forecast data
- Implement inventory control using SQL triggers
- Perform demand planning and supply chain analytics
- Compare forecasted vs actual sales

## SQL Concepts Used
- DDL & DML
- Star Schema (Fact & Dimension Tables)
- Joins & CTEs
- Aggregations & Pivot Analysis
- Stored Procedures
- Triggers for inventory control

  ## Query Categories
- Schema Design (DDL)
- Data Loading (DML)
- Analytical Queries
- Validation & Control Logic
- Reporting Queries
- 
## Assumptions & Constraints
- Inventory quantities are updated at a monthly level.
- Forecast data is assumed to be pre-validated.
- Sales transactions are processed sequentially for inventory control.

## Key Insights
- Forecast vs actual sales comparison improves demand accuracy
- Inventory control logic prevents overselling
- Identifies demand trends and top-performing products
- Supports better procurement and supply planning

## Key Business Questions Answered
- How accurate are sales forecasts compared to actual sales?
- Which products experience frequent overstock or stockouts?
- What are the top-performing products and markets?
- How does inventory availability impact sales performance?

## Data Integrity & Validation
Inventory control is enforced using SQL triggers that prevent overselling and maintain consistent stock levels across transactions.

## Project Highlights
- Star schema design
- Inventory control using triggers
- Forecast vs actual demand analysis

## Tools Used
- SQL Server
- Microsoft PowerPoint

## Repository Structure
- `sql/` – Supply chain database & analytical queries
- `presentation/` – Project explanation and insights

## Future Enhancements
- Machine learning-based forecasting
- Real-time inventory tracking
- Power BI / Tableau dashboards
