# FinStock

A script to download stock symbols and stocks data in json or csv format.

* AMEX
* NASDAQ
* NYSE
* S&P500

Please review symbol.txt for symbols supported.

# Requirements

For this you will need:
* Python 3
* Postgresql 9 

Python Modules
* Finsymbols
* Pandas_datareader
* Click
* Tqdm

# Installation

### Get source code from github
```bash
git clone https://github.com/kennylim/FinStock.git
```

### Install required modules

Requirements.txt
```bash
pip install -r requirements.txt
```

Manually
```bash
pip install finsymbols
pip install pandas_datareader
pip install click
pip install tqdm
```

# Usage

Generate stock symbols
```bash
python symbol.py --type json  --out-dir /Volumes/ssd/data/aws-finance/json/
python symbol.py --type csv  --out-dir /Volumes/ssd/data/aws-finance/csv/
```

Generate stock historical data
```bash
python stock.py --type json  --out-dir /Volumes/ssd/data/aws-finance/json/ --start-date 1999-01-01 --end-date 1999-12-31
python stock.py --type csv  --out-dir /Volumes/ssd/data/aws-finance/csv/ --start-date 2017-01-01 --end-date 2017-01-20
```

Load csv file to database
```bash
python load.py --type csv  --data-dir /Volumes/ssd/data/aws-finance/csv/
```

Synch database last update stock up to today
```bash
python sync.py --type csv  --out-dir /Volumes/ssd/data/aws-finance/json/
```


# Further Readings

* https://kennylim.github.io/blog/post/aws-finance/
