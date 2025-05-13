# sql-financial-data-eda
# Personal Finance SQL Analysis 🧾

This project is a SQL-based exploratory data analysis (EDA) of a personal finance dataset. It simulates real-world budgeting scenarios by analyzing income and expense data over time using SQL queries.

---

## 📁 Dataset

**Source**: [Kaggle - Personal Finance Dataset by Abhilasha Yagyaseni](https://www.kaggle.com/datasets/abhilashayagyaseni/personal-finance-dataset)

The dataset includes one year of categorized income and expense transactions with columns for:
- Date
- Transaction Type (Income or Expense)
- Amount
- Category

---

## 📊 Key Questions Answered

- What is the total income, expense, and net savings for the year?
- How do monthly income and expenses compare?
- What are the top spending categories?
- In which months did the user save or overspend?
- What is the average transaction amount by type?
- Are there unusually large or suspicious transactions?

---

## 🧠 SQL Concepts Used

- `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`
- `CASE WHEN` for conditional logic
- Aggregations: `SUM()`, `AVG()`
- Date parsing and formatting
- `IFNULL()` and `ROLLUP` for totals
- Subtraction and ratio calculations
- Data cleaning and formatting

---

## 📌 Sample Queries

```sql
-- Total income and expenses by month
SELECT 
  Month,
  SUM(CASE WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` ELSE 0 END) AS Total_Income,
  SUM(CASE WHEN `Income/Expense` = 'Expense' THEN `Debit/Credit` ELSE 0 END) AS Total_Expense,
  SUM(CASE WHEN `Income/Expense` = 'Income' THEN `Debit/Credit` ELSE -`Debit/Credit` END) AS Net_Savings
FROM finance_data
GROUP BY Month
ORDER BY Month;
