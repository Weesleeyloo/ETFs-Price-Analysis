# ETF-Prices-Analysis (2020)
## Project Overview
This Project is a SQL-based analysis of 2,310 U.S. ETFs using PostgreSQL, covering data quality validation, performance benchmarking, risk assessment, and multi-criteria screening.

## Data Source from Kaggle
- **Dataset**: US Funds dataset from Yahoo Finance - 23k+ Mutual Funds and 2k+ ETFs scraped from Yahoo Finance [US Funds dataset from Yahoo Finance](https://www.kaggle.com/datasets/stefanoleone992/mutual-funds-and-etfs/data)
- **Creator**: Stefano Leone [stefanoleone992](https://www.kaggle.com/stefanoleone992)
- **Files used**: `ETFs.csv`, `ETF prices.csv`
- **Coverage**: 2,310 ETFs, 3,866,030 daily price records (1993-2021)
- **Analysis period**: 2020 (most recent complete year in the dataset)

## Tools
- **PostgreSQL**
- **DBeaver**

## Analysis Structure
### Section 01: Data Quality Check
This project begins with an assessment of the dataset's scale, time range, and data quality.

The dataset contains 2,310 ETF tickers with daily price records spanning from 1993-01-29 to 2021-11-30, totalling 3,866,030 entries. Thanks to the original contributor, the dataset is largely clean with minimal missing or mismatched data.
This project focuses on 2020 price data, as it is the most recent complete year available in the dataset. (The dataset was last updated approximately 5 years ago and the 2021 price data is incomplete.)

Key findings from the data quality check on `ETFs.csv`:
- 623 missing `fund_category` values
- 30 missing `total_net_assets` values
- 624 missing `category_annual_report_net_expense_ratio` values

The price data in `ETF Prices.csv` is highly complete that no duplicate records were found. However, 8 entries contain zero values across all price fields (open, high, low, close) and volume, likely representing tickers on their first trading day with no activity yet recorded. These entries were excluded from analysis.  

### Section 02: Descriptive Analysis
**Table 1: Top 10 ETFs by Total Net Assets**

| Fund Symbol | Fund Category | Total Net Assets (USD) |
| --- | --- | --- |
| VOO | Large Blend | 753,409,982,464 |
| VXUS | Foreign Large Blend | 404,728,872,960 |
| SPY | Large Blend | 374,031,319,040 |
| BND | Intermediate-Term Bond | 312,150,884,352 |
| IVV | Large Blend | 286,994,399,232 |
| QQQ	| Large Growth | 174,510,718,976 |
| BNDX | | 116,407,050,240 |
| IEFA | Foreign Large Blend | 95,780,700,160 |
| IWM | Small Blend | 69,794,029,568 |
| IWF | Large Growth | 69,161,877,504 |

> Note: `fund_long_name` in the dataset appears mismatched with `fund_symbol`. 
> Fund identity should be referenced by `fund_symbol` only.

**Table 2: Top 5 ETF Categories by Lowest Average Expense Ratio**

| Fund Category | ETF Count | Avg Expense Ratio |
| --- | --- | --- |
| Long-Term Bond | 5 | 0.0580% |
| Diversified Pacific/Asia | 1 | 0.0900% |
| Inflation-Protected Bond | 12 | 0.1308% |
| Intermediate Government | 12 | 0.1392% |
| Corporate Bond | 26 | 0.1638% |

### Section 03: Performance Analysis (2020)
**Table 3: Top 10 Best-Performing ETFs in 2020**

| Fund Symbol | Category | 2020 Return* |
| --- | --- | --- |
| FRAK | Equity Energy | 585.3943%** |
| FNGU | Trading--Leveraged Equity | 339.7239% |
| TAN | Miscellaneous Sector | 221.7282% |
| FNGO | Trading--Leveraged Equity | 219.2937% |
| ARKG | Health | 179.6402% |
| QCLN | Miscellaneous Sector | 177.6987% |
| ARKW | Technology | 148.6578% |
| ARKK | Mid-Cap Growth | 146.5149% |
| PBD | Miscellaneous Sector | 138.9959% |
| CNRG | Equity Energy | 137.3219% |

> *Data Limitation: Return calculations are based on raw closing prices from the source dataset. For ETFs that underwent stock splits during or prior to 2020, the calculated returns may be significantly distorted due to inconsistent price adjustments in the source data.

> **FRAK underwent a 1-for-10 stock split. Its calculated return of 585% does not reflect actual market performance. Results should be interpreted with this limitation in mind.

> Stock Split within the year can be found at [Yahoo Finance Stock Split Calendar](https://finance.yahoo.com/calendar/splits/?day=2020-01-01).

**Table 4: Top 5 Categories by Average 2020 Return**

| Fund Category | Avg 2020 Return* |
| --- | --- |
| Miscellaneous Sector | 60.2908% |
| Convertibles | 48.9819% |
| Technology | 48.9600% |
| Consumer Cyclical | 40.2633% |
| Foreign Small/Mid Growth | 40.2107% |

> *Data Limitation: Return calculations are based on raw closing prices from the source dataset. For ETFs that underwent stock splits during or prior to 2020, the calculated returns may be significantly distorted due to inconsistent price adjustments in the source data.

### Section 04: Risk Analysis
**Table 5: Top 10 ETFs by 3-Year Sharpe Ratio**

| Fund Symbol | Category | Sharpe Ratio (3y) | 2020 Return* |
| --- | --- | --- | --- |
| MBSD | Intermediate Government | 1.77 | 2.3394% |
| BSV | Short-Term Bond | 1.76 | 2.7643% |
| ISTB | Short-Term Bond | 1.72 | 2.3994% |
| STIP | Inflation-Protected Bond | 1.58 | 3.5293% |
| VTIP | Inflation-Protected Bond | 1.54 | 3.6301% |
| PBTP | Inflation-Protected Bond | 1.47 | 3.4772% |
| TDTT | Inflation-Protected Bond | 1.45 | 5.4568% |
| TIPX | Inflation-Protected Bond | 1.44 | 6.2500% |
| STPZ | Inflation-Protected Bond | 1.42 | 3.1803% |
| GVI | Intermediate-Term Bond | 1.42 | 4.2169% |

> *Data Limitation: Return calculations are based on raw closing prices from the source dataset. For ETFs that underwent stock splits during or prior to 2020, the calculated returns may be significantly distorted due to inconsistent price adjustments in the source data.

**Table 6: High Beta, Low Volatility ETFs**

To identify ETFs with high market sensitivity but relatively stable daily price movements, ETFs were filtered using two criteria: 3-year beta > 1.2 (above-market sensitivity) and 2020 daily return standard deviation < 1% (low intraday volatility). 
`65` ETFs met both criteria.

| Fund Symbol | Fund Beta (3y) | Avg 2020 Return** | Stddev 2020 Return*** |
| --- | --- | --- | --- |
| EVGBC | 1.32 | -0.0002% | 0.0038% |
| FXY* | 5.12 | -0.0270% | 0.2708% |
| FXF* | 4.32 | -0.0283% | 0.2814% |
| FXC* | 6.25 | 0.0074% | 0.3137% |
| IEF | 1.29 | -0.0183% | 0.3216% |
| IGOV | 1.22 | 0.0021% | 0.3679% |
| FXB* | 4.7 | -0.0077% | 0.4134% |
| FLMB | 1.24 | -0.02675% | 0.41799% |
| IG | 1.63 | -0.0626% | 0.4476% |
| IGEB |1.6 | -0.0026% | 0.4757% |

> *ETFs with ticker prefix "FX" are currency ETFs. Their elevated beta values may not be directly comparable to equity ETFs and should be interpreted with caution.

> **Data Limitation: Return calculations are based on raw closing prices from the source dataset. For ETFs that underwent stock splits during or prior to 2020, the calculated returns may be significantly distorted due to inconsistent price adjustments in the source data.

> ***Data Limitation: The Standard Deviation of annual return is based on the calculated annual return thus likely to be distorted due to inconsistent price adjustments in the source data.


### Section 05: Screening
**Table 7: ETFs with Expense Ratio < 0.5%, Sharpe Ratio (3Y) > 1, Total Net Assets > USD 1 Billion**

48 ETFs met all three screening criteria.

| Fund Symbol | Category | Expense Ratio | Sharpe Ratio (3y) | Total Net Assets | 2020 Return* | 
| --- | --- | --- | --- | --- | --- |
| ARKG | Health | 0.49% | 1.2 | 9,743,135,744 | 179.6402% |
| ARKK | Mid-Cap Growth | 0.46% | 1.15 | 25,520,136,192 | 146.5149% |
| LIT | Natural Resources | 0.48% | 1.01 | 3,639,320,576 | 123.4296% |
| IBUY | Consumer Cyclical | 0.45% | 1.05 | 1,335,256,832 | 119.8462% |
| QQQ | Large Growth | 0.39% | 1.28 | 174,510,718,976 | 45.1425% |
| IMCG | Mid-Cap Growth | 0.46% | 1.04 | 1,209,460,864 | 43.8403% |
| ONEQ | Large Growth | 0.39% | 1.16 | 4,283,771,648 | 41.8033% |
| MGK | Large Growth | 0.39% | 1.19 | 11,397,450,752 | 37.8552% |
| SCHG | Large Growth | 0.39% | 1.19 | 15,159,136,256 | 36.3887% |
| ILCG | Large Growth| 0.39% | 1.12 | 2,045,804,544 | 36.2953% |

> *Data Limitation: Return calculations are based on raw closing prices from the source dataset. For ETFs that underwent stock splits during or prior to 2020, the calculated returns may be significantly distorted due to inconsistent price adjustments in the source data.

## Disclaimer
This project is intended as a SQL practice exercise to demonstrate data querying and analysis techniques using PostgreSQL. The dataset is sourced from Kaggle and has not been independently verified. Certain results may not accurately reflect real-world market performance due to data inconsistencies in the source (e.g., stock split adjustments, mismatched fund metadata). Any findings should be independently verified before being used for investment decisions or other practical purposes.

## License
The dataset used in this project is published under [CC0: Public Domain](https://creativecommons.org/publicdomain/zero/1.0/) by Stefano Leone on Kaggle. No restrictions on use.
