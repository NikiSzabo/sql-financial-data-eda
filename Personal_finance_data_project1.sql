#SQL Portfolio - Personal Finance Data (Source: Kaggle)
# This file contains a collection of SQL queries grouped by topic, showcasing data analysis, cleaning, and reporting techniques. Each section includes real-world use cases.

#Topics Covered
# - data cleaning
# - aggregations and filtering
# - EDA

SELECT * 
FROM finance_project1.finance_data
;

-- ====================================
-- DATA CLEANING EXAMPLES
-- ====================================

ALTER TABLE finance_data RENAME COLUMN `ï»¿Date / Time` TO `Date / Time`;

#separating the date elements - ====================================
SELECT `Date / Time`,
SUBSTRING_INDEX(`Date / Time`, ',', 1) AS Day_Name,
CONCAT(
    SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', 1), ' ',
    SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', -1), ', ',
    TRIM(SUBSTRING_INDEX(`Date / Time`, ',', -1))
  ) AS Full_Date,
SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', 1) AS Month,
SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', -1) AS Day,
TRIM(SUBSTRING_INDEX(`Date / Time`, ',', -1)) AS Year
FROM finance_data
;

#adding columns to each date elements - ====================================
ALTER TABLE finance_data
ADD COLUMN Full_Date DATE AFTER `Date / Time`,
ADD COLUMN Month VARCHAR(50) AFTER Full_Date,
ADD COLUMN Day INT AFTER Month,
ADD COLUMN Year YEAR AFTER Day
;

ALTER TABLE finance_data
ADD COLUMN Day_Name VARCHAR(50) AFTER Full_Date
;

#updating the columns with data -- ====================================
UPDATE finance_data
SET Full_Date = STR_TO_DATE(CONCAT(
    SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', 1), ' ',
    SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', -1), ', ',
    TRIM(SUBSTRING_INDEX(`Date / Time`, ',', -1))
  ), '%M %e, %Y' )
;

UPDATE finance_data
SET Day_Name = SUBSTRING_INDEX(`Date / Time`, ',', 1)
;

UPDATE finance_data
SET Month = SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', 1)
;

UPDATE finance_data
SET Day = SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date / Time`, ',', 2), ',', -1)), ' ', -1)
;

UPDATE finance_data
SET Year = TRIM(SUBSTRING_INDEX(`Date / Time`, ',', -1))
;

#deleting the original date/time column as it is not needed anymore -- ====================================
ALTER TABLE finance_data
DROP COLUMN `Date / Time`
;

ALTER TABLE finance_data
DROP COLUMN Mode
;

-- ====================================
--  EDA
-- ====================================
SELECT * 
FROM finance_project1.finance_data
;

#Total Income
SELECT SUM(`Debit/Credit`) AS Total_Income
FROM finance_data
WHERE `Income/Expense` = 'Income'
;

#Total Expense
SELECT SUM(`Debit/Credit`) AS Total_Expense
FROM finance_data
WHERE `Income/Expense` = 'Expense'
;

#Total Income by Month
SELECT Month, SUM(`Debit/Credit`) AS Income
FROM finance_data
WHERE `Income/Expense` = 'Income'
GROUP BY Month
ORDER BY Month;

#Total Expense by Month
SELECT Month, SUM(`Debit/Credit`) AS Expense
FROM finance_data
WHERE `Income/Expense` = 'Expense'
GROUP BY Month
ORDER BY Month;

#How does income and spending vary by month? -- ==========================
SELECT IFNULL(Month, 'Total') AS Month, 
  SUM(CASE 
        WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` 
        ELSE 0 
      END) AS Total_Income,
  SUM(CASE 
        WHEN `Income/Expense` = 'Expense' THEN `Debit/Credit` 
        ELSE 0 
      END) AS Total_Expense,
 ( SUM(CASE WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` ELSE 0 END)
  - 
  SUM(CASE WHEN `Income/Expense` = 'Expense' THEN `Debit/Credit` ELSE 0 END))
  AS Net_Savings
FROM finance_data
GROUP BY Month WITH ROLLUP
;

# What is the total income, total expense, and net savings for the year? -- ==========================
SELECT Year, 
  SUM(CASE 
        WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` 
        ELSE 0 
      END) AS Total_Income,
  SUM(CASE 
        WHEN `Income/Expense` = 'Expense' THEN `Debit/Credit` 
        ELSE 0 
      END) AS Total_Expense,
 ( SUM(CASE WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` ELSE 0 END)
  - 
  SUM(CASE WHEN `Income/Expense` = 'Expense' THEN `Debit/Credit` ELSE 0 END))
  AS Net_Savings
FROM finance_data
GROUP BY Year
;

#Which expense categories contribute most to overall spending? -- ==========================
SELECT 
  Category,
  SUM(`Debit/Credit`) AS Total_Spent
FROM finance_data
WHERE `Income/Expense` = 'Expense'
GROUP BY Category
ORDER BY Total_Spent DESC
LIMIT 1
;

#What are the income sources? -- ==========================
SELECT 
  Category,
  `Sub category`,
  SUM(`Debit/Credit`) AS income_resource
FROM finance_data
WHERE `Income/Expense` = 'Income'
GROUP BY Category, `Sub category`
ORDER BY income_resource DESC
LIMIT 5
;

#What are the highest and lowest months for income and expenses? -- ==========================
#Highest Month Income
SELECT Month, SUM(`Debit/Credit`) AS Income
FROM finance_data
WHERE `Income/Expense` = 'Income'
GROUP BY Month
ORDER BY Income DESC;

#Lowest Month Income
SELECT Month, SUM(`Debit/Credit`) AS Income
FROM finance_data
WHERE `Income/Expense` = 'Income'
GROUP BY Month
ORDER BY Income ASC;

#Highest Month Expense
SELECT Month, SUM(`Debit/Credit`) AS Expense
FROM finance_data
WHERE `Income/Expense` = 'Expense'
GROUP BY Month
ORDER BY Expense DESC;

#Lowest Month Expense
SELECT Month, SUM(`Debit/Credit`) AS Expense
FROM finance_data
WHERE `Income/Expense` = 'Expense'
GROUP BY Month
ORDER BY Expense ASC;

WITH monthly_summary AS (
  SELECT
    Month,
    SUM(CASE WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` ELSE 0 END) AS Total_Income,
    SUM(CASE WHEN `Income/Expense` = 'Expense' THEN `Debit/Credit` ELSE 0 END) AS Total_Expense
  FROM finance_data
  GROUP BY Month
)
SELECT
  (SELECT Month FROM monthly_summary ORDER BY Total_Income DESC LIMIT 1) AS Highest_Income_Month,
  (SELECT Month FROM monthly_summary ORDER BY Total_Income ASC LIMIT 1) AS Lowest_Income_Month,
  (SELECT Month FROM monthly_summary ORDER BY Total_Expense DESC LIMIT 1) AS Highest_Expense_Month,
  (SELECT Month FROM monthly_summary ORDER BY Total_Expense ASC LIMIT 1) AS Lowest_Expense_Month;

#Are there unusually large or suspicious transactions? -- ==========================
WITH stats AS (
  SELECT
    AVG(ABS(`Debit/Credit`)) AS avg_amount,
    STDDEV(ABS(`Debit/Credit`)) AS std_dev
  FROM finance_data
),
flagged AS (
  SELECT *,
         ABS(`Debit/Credit`) AS abs_amount
  FROM finance_data
)
SELECT f.*
FROM flagged f
JOIN stats s
  ON f.abs_amount > s.avg_amount + 2 * s.std_dev
ORDER BY f.abs_amount DESC;

#What is the average transaction amount by type and category? -- ==========================
SELECT Category, `Income/Expense`, ROUND(AVG(`Debit/Credit`),1) AS avg_transaction
FROM finance_data
GROUP BY Category, `Income/Expense`
;