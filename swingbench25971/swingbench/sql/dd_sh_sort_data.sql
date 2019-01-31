
-- Sort Data 

-- Suppress Warnings

DROP TABLE CUSTOMERS_T;

-- End Suppress Warnings

CREATE TABLE CUSTOMERS_T AS
SELECT *
FROM customers
ORDER BY CUST_INCOME_LEVEL,
  CUST_STATE_PROVINCE,
  CUST_CITY;

DROP TABLE CUSTOMERS;

RENAME customers_t TO customers;

-- Suppress Warnings

DROP TABLE SUPPLEMENTARY_DEMOGRAPHICS_T;

-- End Suppress Warnings

CREATE TABLE SUPPLEMENTARY_DEMOGRAPHICS_T AS
SELECT *
FROM SUPPLEMENTARY_DEMOGRAPHICS
ORDER BY EDUCATION,
  OCCUPATION;

DROP TABLE SUPPLEMENTARY_DEMOGRAPHICS;

RENAME SUPPLEMENTARY_DEMOGRAPHICS_t TO SUPPLEMENTARY_DEMOGRAPHICS;

-- Suppress Warnings

DROP TABLE SALES_T;

-- End Suppress Warnings

CREATE TABLE SALES_T AS
SELECT *
FROM SALES
ORDER BY TIME_ID,
  SELLER;

DROP TABLE SALES;

RENAME SALES_T TO SALES;

-- End Script
