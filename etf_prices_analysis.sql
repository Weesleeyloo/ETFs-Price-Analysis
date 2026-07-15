-- ========================================================================================
-- ETF Price Analysis (2020)
-- Dataset: ETFs.csv & ETF prices.csv 
-- Data Source Website: Kaggle
-- Dataset Link: https://www.kaggle.com/datasets/stefanoleone992/mutual-funds-and-etfs/data
-- Dataset Creator: Stefano Leone (Kaggle ID: stefanoleone992)
-- Tool: PostgreSQL 16 / DBeaver
-- ========================================================================================

-- ========================================================================================
-- Section 1: DATA QUALITY CHECK
-- ========================================================================================

-- Total numbers of ETFs in the metadata table
SELECT
	COUNT(fund_symbol) AS e_count
FROM etfs;

-- Total numbers of daily price records
SELECT
	COUNT(fund_symbol) AS ep_count
FROM etf_prices;

-- Time range of price data
SELECT
	MIN(price_date) AS oldest_date,
	MAX(price_date) AS latest_date
FROM etf_prices;

-- Coverage check: number of unique ETFs in each table,
-- and number of ETFs present in both tables
SELECT
	COUNT(DISTINCT e.fund_symbol) AS e_count,
	COUNT(DISTINCT ep.fund_Symbol) AS ep_count,
	COUNT(DISTINCT
		CASE
			WHEN e.fund_symbol IS NOT NULL
			AND ep.fund_symbol IS NOT NULL
			THEN e.fund_symbol END
	) AS both_tables_count
FROM etf_prices ep 
FULL JOIN etfs e ON ep.fund_symbol = e.fund_symbol;

-- Missing values check for key fields in ETFs.csv:
-- fund_category, total_net_assets, expense_ratio
SELECT
	(SELECT
		COUNT(*)
		FROM etfs e
		WHERE e.fund_category IS NULL OR e.fund_category = ''
	) AS null_fund_category,
	(SELECT
		COUNT(*)
		FROM etfs e
		WHERE e.total_net_assets  IS NULL
	) AS null_net_assets,
	(SELECT
		COUNT(*)
		FROM etfs e
		WHERE e.category_annual_report_net_expense_ratio IS NULL
	) AS null_expense_ratio;

-- Duplicate check: identify any ETF with more than one
-- price record on the same date
SELECT
	fund_symbol,
	price_date,
	COUNT(*) AS duplicate
FROM etf_prices
GROUP BY fund_symbol, price_date
HAVING COUNT(*) > 1;

-- Abnormal value check: identify price records with
-- zero or negative closing price
SELECT *
FROM etf_prices ep 
WHERE close <= 0;


-- ========================================================================================
-- SECTION 2: DESCRIPTIVE ANALYSIS
-- ========================================================================================

-- Top 10 ETFs by total net assets
SELECT
	fund_symbol,
	fund_long_name,
	fund_family,
	fund_category,
	total_net_assets
FROM etfs e
ORDER BY e.total_net_assets DESC NULLS LAST
LIMIT 10;

-- Top 5 ETF categories with the lowest average expense ratio
-- (excluding records with missing expense ratio)
SELECT
	e.fund_category,
	COUNT(e.fund_category) AS count_fund_category,
	AVG(e.fund_annual_report_net_expense_ratio) AS avg_expense_ratio
FROM etfs e
WHERE e.fund_annual_report_net_expense_ratio IS NOT NULL
GROUP BY e.fund_category
ORDER BY AVG(e.fund_annual_report_net_expense_ratio) ASC
LIMIT 5;


-- ========================================================================================
-- SECTION 3: PERFORMANCE ANALYSIS (2020)
-- ========================================================================================

-- View: first trading day closing price for each ETF in 2020
CREATE OR REPLACE VIEW first_day AS (
	SELECT
		ep.fund_symbol,
		ep.close,
		ep.price_date,
		ROW_NUMBER() OVER(
			PARTITION BY ep.fund_symbol
			ORDER BY ep.price_date ASC
		) AS rn
	FROM etf_prices ep
	WHERE ep.price_date > '2019-12-31'
		AND ep.price_date < '2021-01-01'
);

-- View: last trading day closing price for each ETF in 2020
CREATE OR REPLACE VIEW last_day AS (
	SELECT
		ep.fund_symbol,
		ep.close,
		ep.price_date,
		ROW_NUMBER() OVER(
			PARTITION BY ep.fund_symbol
			ORDER BY ep.price_date  DESC
		) AS rn
	FROM etf_prices ep
	WHERE ep.price_date > '2019-12-31'
		AND ep.price_date < '2021-01-01'
);

-- View: 2020 annual return for each ETF,
-- calculated as (last_close - first_close)/first_close
-- ETFs with a first_close of 1 or below are excluded
-- to filter out abnormal or newly listed tickers
CREATE OR REPLACE VIEW etf_return_2020 AS(
	SELECT
		f.fund_symbol,
		f.close AS first_close,
		l.close AS last_close,
		e.fund_category,
		e.fund_long_name,
		(l.close - f.close)/f.close AS return_2020,
		e.fund_family
	FROM first_day f
	JOIN last_day l ON f.fund_symbol = l.fund_symbol
	JOIN etfs e ON f.fund_symbol = e.fund_symbol
	WHERE f.close > 1
		AND f.rn = 1
		AND l.rn = 1
	ORDER BY return_2020 DESC
);

-- View: the single best-performing ETF in 2020
CREATE OR REPLACE VIEW best_etf AS(
	SELECT
		fund_symbol,
		fund_category,
		return_2020
	FROM etf_return_2020
	ORDER BY return_2020 DESC
	LIMIT 1
);

-- View: average 2020 return by ETF category
CREATE OR REPLACE VIEW category_avg AS (
	SELECT
		fund_category,
		AVG(return_2020) AS avg_return_2020
		FROM etf_return_2020
		GROUP BY fund_category
);

-- Compare the best-performing ETF against
-- the average return of its category
SELECT
    be.fund_symbol,
    be.return_2020,
    be.fund_category,
    ca.avg_return_2020 AS avg_category_return
FROM best_etf be
JOIN category_avg ca ON be.fund_category = ca.fund_category;

-- Top 5 fund families by average 2020 return
SELECT
	fund_family,
	AVG(return_2020) AS avg_return_2020
FROM etf_return_2020
GROUP BY fund_family
ORDER BY AVG(return_2020) DESC
LIMIT 5;


-- ========================================================================================
-- SECTION 4: RISK ANALYSIS
-- ========================================================================================

-- Top 10 ETFs by 3-year Sharpe ratio,
-- joined with 2020 return for reference
SELECT
	e.fund_symbol,
	e.fund_category,
	e.fund_family,
	e.fund_sharpe_ratio_3years,
	er.return_2020
FROM etfs e
JOIN etf_return_2020 er ON e.fund_symbol = er.fund_symbol
ORDER BY fund_sharpe_ratio_3years DESC NULLS LAST
LIMIT 10;

-- ETFs with high market sensitivity (beta > 1.2)
-- but low daily price volatility (stddev < 1%)
-- based on 2020 intraday return (close vs. open)
SELECT
	ep.fund_symbol,
	e.fund_beta_3years,
	AVG((ep.close - ep.open)/ep.open) AS avg_return,
	STDDEV((ep.close - ep.open)/ep.open) AS stddev_return
FROM etf_prices ep
JOIN etfs e ON e.fund_symbol = ep.fund_symbol
WHERE ep.open > 0 
	AND ep.open IS NOT NULL
	AND ep.close > 0
	AND DATE_PART('year', ep.price_date) = 2020
GROUP BY ep.fund_symbol, e.fund_beta_3years
HAVING e.fund_beta_3years > 1.2
    AND STDDEV((ep.close - ep.open)/ep.open) < 0.01
ORDER BY STDDEV((ep.close - ep.open)/ep.open) ASC;

-- ========================================================================================
-- SECTION 5: SCREENING
-- ========================================================================================

-- ETFs meeting all three criteria:
-- expense ratio < 0.5%, 3-year Sharpe ratio > 1,
-- total net assets > USD 1 billion
-- sorted by 2020 return (descending)
SELECT
	e.fund_symbol,
	e.fund_category,
	e.fund_family,
	e.category_annual_report_net_expense_ratio,
	e.fund_sharpe_ratio_3years,
	e.total_net_assets,
	er.return_2020
FROM etfs e
JOIN etf_return_2020 er ON e.fund_symbol = er.fund_symbol
WHERE e.category_annual_report_net_expense_ratio < 0.005
	AND e.category_annual_report_net_expense_ratio IS NOT NULL
	AND e.fund_sharpe_ratio_3years > 1
	AND e.fund_sharpe_ratio_3years IS NOT NULL
	AND e.total_net_assets > 1000000000
	AND e.total_net_assets IS NOT NULL
ORDER BY er.return_2020 DESC NULLS LAST;

