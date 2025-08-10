/*===========================================================
 Q1: Exposure at Risk (EaR) Computation
 ------------------------------------------------------------
 Goal:
   - Compute the top 3 clients with the highest Exposure at Risk (EaR) 
     over the last 30 days.
 Formula:
   EaR = SUM(NotionalUSD * RiskWeight of Instrument)
 Output:
   ClientName, Country, Total_EaR
===========================================================*/
SELECT 
    p.ClientID,
    c.ClientName,
    c.Country,
    SUM(p.NotionalUSD * i.RiskWeight) AS Total_EaR
FROM positions p
JOIN instruments i 
    ON p.InstrumentID = i.InstrumentID
JOIN clients c 
    ON p.ClientID = c.ClientID
WHERE DATEDIFF(day, p.PositionDate, CAST(GETDATE() AS date)) <= 30
GROUP BY p.ClientID, c.ClientName, c.Country
ORDER BY Total_EaR DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;


 /*===========================================================
 Q2: Abnormal Trading Pattern Detection
 ------------------------------------------------------------
 Goal:
   - Identify clients who:
       • Traded in 3 or more asset classes in the past 10 days
       • Have at least one position with notional over $2M
 Output:
   ClientID, ClientName, Count_AssetClasses, MaxNotionalUSD
===========================================================*/
WITH asset_class_cte AS (
    SELECT 
        p.ClientID,
        c.ClientName,
        COUNT(DISTINCT i.AssetClass) AS asset_class_count
    FROM positions p
    JOIN instruments i 
        ON p.InstrumentID = i.InstrumentID
    JOIN clients c 
        ON p.ClientID = c.ClientID
    WHERE DATEDIFF(day, p.PositionDate, CAST(GETDATE() AS date)) <= 10
    GROUP BY p.ClientID, c.ClientName
),
notional_cte AS (
    SELECT 
        ClientID,
        MAX(NotionalUSD) AS max_notional_usd
    FROM positions
    WHERE DATEDIFF(day, PositionDate, CAST(GETDATE() AS date)) <= 10
    GROUP BY ClientID
)
SELECT 
    a.ClientID,
    a.ClientName,
    a.asset_class_count,
    n.max_notional_usd
FROM asset_class_cte a
JOIN notional_cte n 
    ON a.ClientID = n.ClientID
WHERE a.asset_class_count >= 3
  AND n.max_notional_usd > 2000000;


 /*===========================================================
 Q3: Unrealized Gain/Loss
 ------------------------------------------------------------
 Goal:
   - For each position on 2025-07-01, calculate Unrealized P&L:
     Unrealized P&L = (MarketPriceUSD * Quantity) - NotionalUSD
   - Return only positions with absolute P&L greater than $50,000.
 Output:
   PositionID, ClientID, unrealized_P_L
===========================================================*/
SELECT 
    p.PositionID,
    p.ClientID,
    ((p.Quantity * m.MarketPriceUSD) - p.NotionalUSD) AS unrealized_P_L
FROM positions p
JOIN market_data m 
    ON p.InstrumentID = m.InstrumentID
WHERE m.Date = '2025-07-01'
  AND ABS((p.Quantity * m.MarketPriceUSD) - p.NotionalUSD) > 50000
ORDER BY unrealized_P_L DESC;


 /*===========================================================
 Q4: Risk-Weighted Concentration
 ------------------------------------------------------------
 Goal:
   - Find the top 2 instruments with the highest weighted exposure 
     for High-Risk clients.
 Formula:
   Weighted Exposure = NotionalUSD * RiskWeight
 Output:
   InstrumentName, TotalWeightedExposure, CountClients
===========================================================*/
SELECT TOP 2
    i.InstrumentName,
    SUM(p.NotionalUSD * i.RiskWeight) AS TotalWeightedExposure,
    COUNT(DISTINCT p.ClientID) AS CountClients
FROM positions p
JOIN instruments i 
    ON p.InstrumentID = i.InstrumentID
JOIN clients c 
    ON p.ClientID = c.ClientID
WHERE c.RiskCategory = 'High'
GROUP BY i.InstrumentName
ORDER BY TotalWeightedExposure DESC;


 /*===========================================================
 Q5: Cross-Currency Exposure
 ------------------------------------------------------------
 Goal:
   - For each client with exposure in more than 2 currencies, calculate:
       • Total Notional by currency
       • Number of instruments held
   - Order results by client and currency.
 Output:
   ClientID, ClientName, Currency, TotalNotional, NumInstruments
===========================================================*/
WITH cte_1 AS (
    SELECT 
        p.ClientID,
        c.ClientName
    FROM positions p 
    JOIN instruments i 
        ON p.InstrumentID = i.InstrumentID
    JOIN clients c 
        ON p.ClientID = c.ClientID
    GROUP BY p.ClientID, c.ClientName
    HAVING COUNT(DISTINCT i.Currency) > 2
),
cte_2 AS (
    SELECT 
        c.ClientID,
        c.ClientName,
        i.Currency,
        p.NotionalUSD,
        i.InstrumentID
    FROM cte_1 c
    JOIN positions p 
        ON c.ClientID = p.ClientID
    JOIN instruments i 
        ON i.InstrumentID = p.InstrumentID
)
SELECT 
    ClientID,
    ClientName,
    Currency,
    SUM(NotionalUSD) AS TotalNotional,
    COUNT(InstrumentID) AS NumInstruments
FROM cte_2
GROUP BY ClientID, ClientName, Currency
ORDER BY ClientID, Currency;
