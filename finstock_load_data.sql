-- load csv symbol
 TRUNCATE TABLE stock.symbol_stg;

COPY stock.symbol_stg (SOURCE, sector, industry, company, symbol)
FROM '/Volumes/ssd/data/aws-finance/csv/symbol.csv'
DELIMITER ',' CSV HEADER;


SELECT *
FROM stock.symbol_stg;


INSERT INTO stock.symbol (SOURCE, sector, industry, company, symbol)
SELECT SOURCE,
       sector,
       industry,
       company,
       symbol
FROM stock.symbol_stg
WHERE flag IS NULL
  SELECT *
  FROM stock.symbol;

-- load csv stock
 TRUNCATE TABLE stock.history_stg;

COPY stock.history_stg (date, OPEN, high, low, CLOSE, volume, adj_close, symbol, SOURCE)
FROM '/Volumes/ssd/data/aws-finance/csv/prices_20170113_to_20170206.csv'
DELIMITER ',' CSV HEADER;

SELECT *
FROM stock.history_stg;

INSERT INTO stock.history (date, OPEN, high, low, CLOSE, volume, adj_close, symbol, SOURCE)
SELECT date::timestamptz,
       OPEN::decimal,
       high::decimal,
       low::decimal,
       CLOSE::decimal,
       volume::decimal,
       adj_close::decimal,
       symbol,
       SOURCE
FROM stock.history_stg
WHERE flag IS NULL;

SELECT *
FROM stock.history
LIMIT 5;

-- check current date from history file

SELECT max(date)
FROM stock.history;

-- check staging count

SELECT count(*)
FROM stock.history_stg;

-- count all load jobs

SELECT created_at,
       count(created_at)
FROM stock.history
GROUP BY created_at
ORDER BY created_at;

-- check load count from staging to table

SELECT count(*)
FROM stock.history
WHERE date IN
    (SELECT max(created_at)
     FROM stock.history);

-- load json symbol
 -- copy symbol csv file to symbol staging table
COPY stock.symbol_json_stg(symbol)
FROM '/Volumes/ssd/data/aws-finance/symbol.json';

-- copy the_table(jsonfield)
-- from '/path/to/jsondata'
--csv quote e'\x01' delimiter e'\x02';

SELECT symbol
FROM stock.symbol_json_stg;

-- insert json data from symbol staging to table

INSERT INTO stock.symbol_json (symbol)
SELECT to_json(symbol)
FROM stock.symbol_json_stg;


SELECT count(*)
FROM stock.symbol_json;


SELECT count(*)
FROM stock.symbol_json_stg;


SELECT *
FROM stock.symbol_json;

-- copy symbol json file to stock staging table
 COPY stock.history_json(stock)
FROM '/Volumes/ssd/data/aws-finance/stock.json';

-- insert json data from stock staging to table

INSERT INTO stock.history_json (symbol)
SELECT to_json(stock)
FROM stock.symbol_stg;


SELECT count(*)
FROM stock.stock_json;


SELECT count(*)
FROM stock.stock_json_staging;


SELECT *
FROM stock.stock_json;

-- validation
 --Tag: 1=insert, 2=update, 3=ignore, 0=bad record
--IF id not exist, then tag as insert
--IF id exist but different (minus) then tag as update
--IF id exist and the same (intersect) then tag as ignore
--If new record is invalid then tag as bad record
 -- find duplicate symbol for each source

SELECT SOURCE,
       symbol,
       ROW_NUMBER() OVER(PARTITION BY SOURCE, symbol
                         ORDER BY symbol ASC) AS ROW
FROM stock.stock_symbol_staging ) dups
WHERE dups.Row > 1
  UPDATE stock.stock_symbol_staging WHERE -- todo:
-- decode n/a to null
--2 = if exist but are different (minus) then tag as update
--4 = if new record is invalid (i.e. null on required column) then tag as bad record

  UPDATE stock.stock_symbol_staging
  SET flag = 1
  FROM
    (SELECT SOURCE,
            sector,
            industry,
            company,
            symbol
     FROM stock.stock_symbol_staging
     EXCEPT SELECT SOURCE,
                   sector,
                   industry,
                   company,
                   symbol
     FROM stock.stock_symbol) AS subquery ;

-- 1 = unique and id does not exist then tag as insert
--truncate table stock.stock_symbol;

INSERT INTO stock.stock_symbol (SOURCE, sector, industry, company, symbol)
SELECT SOURCE,
       sector,
       industry,
       company,
       symbol
FROM stock.stock_symbol_staging AS s
WHERE s.flag = 1;

--3 = if exist and are the same (intersect) then tag as ignore

UPDATE stock.stock_symbol_staging
SET flag = 3
FROM
  (SELECT SOURCE,
          sector,
          industry,
          company,
          symbol
   FROM stock.stock_symbol_staging INTERSECT SELECT SOURCE,
                                                    sector,
                                                    industry,
                                                    company,
                                                    symbol
   FROM stock.stock_symbol) AS subquery ;

SELECT *
FROM stock.stock_symbol
ORDER BY SOURCE;

-- total break down by source

SELECT SOURCE,
       count(SOURCE)
FROM stock.stock_symbol
GROUP BY SOURCE
ORDER BY COUNT DESC;
