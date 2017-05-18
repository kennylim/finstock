import datetime
import json
import finsymbols
import pandas_datareader.data as web
import click
import os
import sys
import logging
import boto3
import csv
from tqdm import tqdm

'''
usage:
generate stock:
    python finstock.py --type stock --format json  --out-dir /Volumes/ssd/data/aws-finance/json/ --start-date 1999-01-01 --end-date 1999-12-31
    python finstock.py --type stock --format csv  --out-dir /Volumes/ssd/data/aws-finance/csv/ --start-date 2017-01-01 --end-date 2017-01-20

generate symbol:
    python finstock.py --type symbol --format json  --out-dir /Volumes/ssd/data/aws-finance/json/
    python finstock.py --type symbol --format csv  --out-dir /Volumes/ssd/data/aws-finance/csv/
'''

def get_symbols():
    rs = {'symbols': []}
    rs['symbols'].extend([dict(r, **{'source': 'AMEX'})
                          for r in finsymbols.get_amex_symbols()])
    rs['symbols'].extend([dict(r, **{'source': 'NASDAQ'})
                          for r in finsymbols.get_nasdaq_symbols()])
    rs['symbols'].extend([dict(r, **{'source': 'NYSE'})
                          for r in finsymbols.get_nyse_symbols()])
    rs['symbols'].extend([dict(r, **{'source': 'SP500'})
                          for r in finsymbols.get_sp500_symbols()])
    return rs

def delete_files(start_date, end_date, stock_file, log_file, format):
    if os.path.isfile(stock_file):
        print('Delete Existing Data File at ' + stock_file)
        os.remove(stock_file)
    if os.path.isfile(log_file):
        print('Delete Existing Log File at ' + log_file)
        os.remove(log_file)

def write_stock(start_date, end_date, stock_file, format, rs):
    # create stock history header
    with open(stock_file,'w') as f:
        w = csv.writer(f, quotechar='"',  quoting=csv.QUOTE_ALL)
        w.writerow(["date","open","high","low","close"])

    for x in tqdm(rs['symbols']):
        try:
            symbol = x['symbol']
            source = x['source']
            print('Symbol: ' + symbol)
            df = web.DataReader(symbol, 'yahoo', start_date, end_date)
            for x in df:
                # add source and symbol data
                df['symbol'] = symbol
                df['source'] = source
                if format == 'json':
                    # print 'write json == ' + symbol + ' ' + source
                    records = df.to_json(
                        orient='index', date_format='iso', date_unit='s')
                    with open(stock_file, 'a') as f:
                        json.dump(records, f)
                        f.write(os.linesep)
                elif format == 'csv':
                    # print 'write csv == ' + symbol + ' ' + source
                    df.to_csv(stock_file, mode='a', header=False)
                    # print df
        except Exception:
            print('Symbol Exception: ' + symbol)
            e = sys.exc_info()[0]
            logging.error('Symbol Not Found: ' + 'Symbol: ' + symbol + ' Source: ' + source + ' : ' + "%s" % e)
            pass

def write_symbols(format, out_dir, rs):
    if format == 'json':
        click.echo('JSON format: %s' % format)
        # generate symbols in json format
        with open(out_dir + 'symbol.json', 'w') as outfile:
            json.dump(rs['symbols'], outfile, indent=4)
    elif format == 'csv':
        click.echo('CSV format: %s' % format)
        # generate symbols in csv format
        f = csv.writer(
            open(out_dir + "symbol.csv", "wb+"), quoting=csv.QUOTE_ALL)
        f.writerow(["source", "sector", "industry", "company",
                    "symbol"])  # "headquarters"
        for x in rs['symbols']:
            f.writerow([
                x["source"].encode('utf-8'),
                x["sector"].encode('utf-8'),
                x["industry"].encode('utf-8'),
                x["company"].encode('utf-8'),
                # x["headquarters"].encode('utf-8'),
                x["symbol"].encode('utf-8')
            ])

def init_log(log_file):
    logging.basicConfig(level=logging.ERROR,
        format='%(asctime)s %(levelname)s %(message)s',
        filename=log_file,
        filemode='w')


@click.command()
@click.option(
    '--type',
    '-t',
    required='true',
    default='stock',
    type=click.Choice(['stock', 'symbol']),
    help='input source type (default: stock)')
@click.option(
    '--format',
    '-f',
    required='true',
    default='json',
    type=click.Choice(['json', 'csv']),
    help='input source type (default: json)')
@click.option('--start-date', '-s', help='YYYY-MM-DD')
@click.option('--end-date', '-e', help='YYYY-MM-DD')
@click.option(
    '--out-dir',
    '-d',
    default='',
    required='true',
    help=' dump directory (default: "local directory")')
def main(format, type, start_date, end_date, out_dir):

    stock_file = out_dir + 'prices_' + \
        start_date.replace("-", "") + '_to_' + \
        end_date.replace("-", "") + '.' + format

    log_file = out_dir + 'log/' + 'prices_' + \
        start_date.replace("-", "") + '_to_' + \
        end_date.replace("-", "") + '.' + 'log'

    rs = get_symbols()
    delete_files(start_date, end_date, stock_file, log_file, format)
    init_log(log_file)

    if type == "stock":
        print ("Generate historical stocks")
        write_stock(start_date, end_date, stock_file, format, rs)
    elif type == "symbol":
        print("Generate stock symbols")
        write_symbols(format, out_dir, rs)

if __name__ == '__main__':
    main()
