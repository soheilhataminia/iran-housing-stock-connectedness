# Return-Shock Transmission between Stock and Housing Markets in Iran

This repository contains the replication data and EViews code for the paper:

**Return-Shock Transmission between Stock and Housing Markets in Iran: A Diebold–Yilmaz Connectedness Analysis**

## Repository contents

- `data/raw/data.xlsx`: monthly dataset used in the analysis
- `eviews/01_main_replication.prg`: main EViews replication code

## Data

The dataset includes monthly observations from March 2014 to February 2026.

Variables:

- `housingprice`: Tehran apartment transaction price per square meter
- `tedpix`: Tehran Stock Exchange Total Price and Cash Dividend Index
- `cpi`: Consumer Price Index, used for inflation-adjusted robustness checks

Monthly returns are constructed in the EViews code as log differences multiplied by 100.

## Software

The analysis was conducted in EViews.

## License

Code: MIT License
Data: CC BY 4.0
