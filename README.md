# ETF-Prices-Analysis (2020)

## Project Overview
A SQL-based analysis of 2,310 U.S. ETFs using PostgreSQL, covering data quality validation, performance benchmarking, risk assessment, and multi-criteria screening.

## Data Source from Kaggle
- **Dataset**: US Funds dataset from Yahoo Finance - 23k+ Mutual Funds and 2k+ ETFs scraped from Yahoo Finance https://www.kaggle.com/datasets/stefanoleone992/mutual-funds-and-etfs/data
- **Creator**: Stefano Leone (Kaggle ID: stefanoleone992) https://www.kaggle.com/stefanoleone992
- **Files used**: `ETFs.csv`, `ETF prices.csv`
- **Coverage**: 2,310 ETFs, 3,866,030 daily price records (1993-2021)
- **Analysis period**: 2020 (most recent complete year in the dataset)


## Tools
- **PostgreSQL**
- **DBeaver**

## Analysis Structure

### Section 01 Data Quality Check
This project begins with an assessment of the dataset's scale, time range, and data quality.
The dataset contains 2,310 ETF tickers with daily price records spanning from 1993-01-29 to 2021-11-30, totalling 3,866,030 entries. Thanks to the original contributor, the dataset is largely clean with minimal missing or mismatched data.
This project focuses on 2020 price data, as it is the most recent complete year available in the dataset. (The dataset was last updated approximately 5 years ago and the 2021 price data is incomplete.)

Key findings from the data quality check on `ETFs.csv`:
- 623 missing `fund_category` values
- 30 missing `total_net_assets` values
- 624 missing ``

### Section 02
### Section 03
### Section 04
### Section 05


## License
The dataset used in this project is published under [CC0: Public Domain](https://creativecommons.org/publicdomain/zero/1.0/) 
by Stefano Leone on Kaggle. No restrictions on use.
