# SQL Data Analytics – Risk & Exposure Analysis

## 📌 Project Overview
This project demonstrates **SQL-based data analytics** for financial risk management.  
It contains **five advanced queries** for analyzing client trading behavior, market exposure, and portfolio risk.  
The dataset is assumed to include `clients`, `positions`, `instruments`, and `market_data` tables.

---

## ⚙️ Tech Stack
- **Database:** Microsoft SQL Server
- **Language:** SQL
- **Concepts Used:**  
  - Common Table Expressions (CTEs)  
  - Aggregations & Grouping  
  - Filtering with `DATEDIFF` & `ABS`  
  - Joins (INNER JOIN, CTE joins)  
  - Ordering & Limiting results  

---

## 📊 Problem Statements & Queries

### **Q1: Exposure at Risk (EaR) Computation**
**Task:** Compute the top 3 clients with the highest Exposure at Risk (EaR) over the last 30 days. 
 
### **Q2: Abnormal Trading Pattern Detection**
**Task:** Identify clients who:  
- Traded in 3 or more asset classes in the past 10 days  
- Have at least one position with notional over **$2M**

### **Q3: Unrealized Gain/Loss**
**Task:** For each position on `2025-07-01`, calculate the **Unrealized P&L**:
Only return positions with **absolute P&L greater than $50,000**.

### **Q4: Risk-Weighted Concentration**
**Task:** Find the top 2 instruments contributing the highest **Weighted Exposure** for **High-Risk** clients.

### **Q5: Cross-Currency Exposure**
**Task:** For each client with exposure in more than 2 currencies, calculate:  
- Total Notional by currency  
- Number of instruments held
