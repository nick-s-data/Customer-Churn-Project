- =============================================================================
-- TELCO CUSTOMER CHURN – Full Cleaning + EDA
-- =============================================================================

-- ============================
-- 1. ORGANIZING AND CLEANING
-- ============================
SELECT * FROM `wa_fn-usec_-telco-customer-churn`;

CREATE TABLE Telco_customer
LIKE `wa_fn-usec_-telco-customer-churn`;

SELECT * FROM Telco_customer;

INSERT telco_customer
SELECT * FROM `wa_fn-usec_-telco-customer-churn`;

-- Preview
SELECT * FROM
telco_customer
WHERE OnlineBackup LIKE "No%";

-- Standardize all "No internet service" / "No phone service" → "No"
UPDATE telco_customer
SET OnlineSecurity = "No"
WHERE OnlineSecurity LIKE "No%";

UPDATE telco_customer
SET OnlineBackup = "No"
WHERE OnlineBackup LIKE "No%";

UPDATE telco_customer
SET DeviceProtection = "No"
WHERE DeviceProtection LIKE "No%";

UPDATE telco_customer
SET TechSupport = "No"
WHERE TechSupport LIKE "No%";

UPDATE telco_customer
SET StreamingTV = "No"
WHERE StreamingTV LIKE "No%";

UPDATE telco_customer
SET StreamingMovies = "No"
WHERE StreamingMovies LIKE "No%";

UPDATE telco_customer
SET MultipleLines = "No"
WHERE MultipleLines LIKE "No%";

SELECT *, row_number() OVER(PARTITION BY customerID) AS row_num
FROM Telco_customer;

-- Create final clean table with proper schema
CREATE TABLE `telco_customer2` (
  `customerID` VARCHAR(10) PRIMARY KEY,
  `gender` VARCHAR(10) NOT NULL,
  `SeniorCitizen` INT NOT NULL,
  `Partner` ENUM('Yes', 'No') NOT NULL,
  `Dependents` VARCHAR(3) NOT NULL,
  `tenure` INT NOT NULL,
  `PhoneService` VARCHAR(3) NOT NULL,
  `MultipleLines` VARCHAR(20) NOT NULL,
  `InternetService` VARCHAR(20) NOT NULL,
  `OnlineSecurity` VARCHAR(20) NOT NULL,
  `OnlineBackup` VARCHAR(20) NOT NULL,
  `DeviceProtection` VARCHAR(20) NOT NULL,
  `TechSupport` VARCHAR(20) NOT NULL,
  `StreamingTV` VARCHAR(20) NOT NULL,
  `StreamingMovies` VARCHAR(20) NOT NULL,
  `Contract` VARCHAR(20) NOT NULL,
  `PaperlessBilling` VARCHAR(3) NOT NULL,
  `PaymentMethod` VARCHAR(50) NOT NULL,
  `MonthlyCharges` DOUBLE NOT NULL,
  `TotalCharges` DOUBLE NOT NULL,
  `Churn` ENUM('Yes', 'No') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM telco_customer2;

ALTER TABLE telco_customer2
ADD row_num INT;

-- Insert data + deduplication check
INSERT INTO telco_customer2
SELECT *, row_number() OVER(PARTITION BY customerID, gender, SeniorCitizen, Partner, tenure, PhoneService,
MultipleLines, InternetService, OnlineSecurity,OnlineBackup,DeviceProtection,TechSupport, StreamingTV,StreamingMovies,Contract,PaperlessBilling,
PaymentMethod, MonthlyCharges, TotalCharges, Churn) AS row_num
FROM Telco_customer;

-- Confirm no duplicates
SELECT * FROM telco_customer2
WHERE row_num > 1;
-- no duplicates

-- Convert SeniorCitizen 0/1 → Yes/No
ALTER TABLE telco_customer2
MODIFY COLUMN SeniorCitizen VARCHAR(3);

UPDATE telco_customer2
SET SeniorCitizen = "No"
WHERE SeniorCitizen = '0';

UPDATE telco_customer2
SET SeniorCitizen = "Yes"
WHERE SeniorCitizen = '1';

-- ============================
-- 2. EXPLORATORY DATA ANALYSIS (EDA)
-- ============================

##---- Overall Churn Rate----
SELECT (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID)) * 100 AS Churn_rate
FROM telco_customer2;

-- Churn rate by Payment Method
SELECT PaymentMethod, (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID)) * 100 AS Churn_rate FROM telco_customer2
GROUP BY PaymentMethod;

-- Churn rate by Partner
SELECT Partner, (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID)) * 100 AS Churn_rate FROM telco_customer2
group by Partner;

-- Churn rate by Contract length
SELECT Contract, (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID)) * 100 AS Churn_rate FROM telco_customer2
group by Contract;

-- Churn rate by MonthlyCharges segments
SELECT
    CASE
        WHEN MonthlyCharges < 40 THEN '< 40'
        WHEN MonthlyCharges BETWEEN 40 AND 80 THEN '40 to 80'
        WHEN MonthlyCharges > 80 THEN '> 80'
    END AS MonthlyCharges_Bin,
    ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(customerID),1) AS Churn_Rate_in_Bin
FROM
    telco_customer2
GROUP BY
    MonthlyCharges_Bin;

-- Churn by gender (no correlation!)
SELECT gender, (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID)) * 100 AS Churn_rate
, COUNT(*) AS count FROM telco_customer2
group by gender;

-- Churn rate by InternetService + Contract
SELECT InternetService, Contract, COUNT(*) AS count, 
       ROUND(AVG(Churn = 'Yes') * 100, 2) AS Churn_rate
FROM telco_customer2
GROUP BY InternetService, Contract
ORDER BY InternetService DESC;

-- Senior Citizen churn breakdown
SELECT Churn,
       SUM(CASE WHEN SeniorCitizen = "Yes" THEN 1 ELSE 0 END) AS "above_60",
       SUM(CASE WHEN SeniorCitizen = "No" THEN 1 ELSE 0 END) AS "below_60",
       ROUND(
           SUM(CASE WHEN SeniorCitizen = "Yes" THEN 1 ELSE 0 END) /
           (SELECT SUM(CASE WHEN SeniorCitizen = "Yes" THEN 1 ELSE 0 END) FROM telco_customer2) * 100,
           2
       ) AS "senior_churn_rate",
       ROUND(
           SUM(CASE WHEN SeniorCitizen = "No"  THEN 1 ELSE 0 END) /
           (SELECT SUM(CASE WHEN SeniorCitizen = "No"  THEN 1 ELSE 0 END) FROM telco_customer2) * 100,
           2
       ) AS "Junior_churn_rate"
FROM telco_customer2
WHERE churn = 'Yes'
GROUP BY Churn
ORDER BY Churn ASC;

-- Customers with ALL add-on services
SELECT churn, COUNT(*) FROM telco_customer2
WHERE OnlineSecurity ="Yes" AND OnlineBackup ="Yes"
 AND DeviceProtection ="Yes" AND TechSupport ="Yes"
 AND StreamingTV ="Yes" AND StreamingMovies ="Yes"
 group by Churn;
 
-- Tenure vs Churn (6-month buckets)
 SELECT 
       CONCAT(FLOOR(tenure / 6) * 6, '-', FLOOR(tenure / 6) * 6 + 5) AS tenure_range,
       COUNT(*) AS total_customers,
       ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS churn_rate
FROM telco_customer2
GROUP BY tenure_range
ORDER BY churn_rate DESC;

-- One-year contract but left in <12 months
SELECT  tenure, Contract, churn, MonthlyCharges FROM telco_customer2
WHERE tenure < 12 AND Contract = "One year" AND Churn = "Yes";

-- Std dev of tenure
SELECT stddev(tenure) From telco_customer2;

-- Revenue loss by Contract
SELECT ROUND( avg(MonthlyCharges) * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END), 2) AS Month_churned_Revenueloss,
 ROUND( avg(MonthlyCharges) * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 12, 2) AS Year_Churned_Revenueloss, COUNT(*) AS total_customers, Contract From telco_customer2
 group by Contract
 ORDER BY Contract;
 
-- Revenue loss by InternetService
 SELECT ROUND( avg(MonthlyCharges) * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END), 2) AS Month_churned_Revenueloss,
 ROUND( avg(MonthlyCharges) * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 12, 2) AS Year_Churned_Revenueloss, COUNT(*) AS total_customers, InternetService From telco_customer2
 group by InternetService
 ORDER BY Month_churned_Revenueloss DESC;
 
 -- Revenue loss by tenure year
 SELECT ROUND( avg(MonthlyCharges) * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END), 2) AS Month_churned_Revenueloss,
 ROUND( avg(MonthlyCharges) * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 12, 2) AS Year_Churned_Revenueloss, 
 CONCAT(FLOOR(tenure / 12) * 12, '-', FLOOR(tenure / 12) * 12 + 11) AS tenure_range, COUNT(*) AS total_customers From telco_customer2
 group by tenure_range
 ORDER BY Month_churned_Revenueloss DESC;
 
 -- Churn by MonthlyCharges range
 SELECT 
       CONCAT(FLOOR(MonthlyCharges / 10) * 10, '-', FLOOR(MonthlyCharges / 10) * 10 + 9) AS MonthlyCharges_range,
       COUNT(*) AS total_customers,
       ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS churn_rate
FROM telco_customer2
GROUP BY MonthlyCharges_range
ORDER BY churn_rate DESC ;

-- TechSupport impact
SELECT 
	TechSupport,
    COUNT(*) AS total_customers,
	ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END))) AS churned_customers,
	ROUND((SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) /  COUNT(*)) * 100, 2) AS churn_rate
FROM telco_customer2
WHERE InternetService = "Fiber optic"
GROUP BY TechSupport
;

-- Final table preview
SELECT * FROM telco_customer2;