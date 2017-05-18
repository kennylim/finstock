
-- acrynom:
-- stg: staging table, idx: index, pk: primark key, fk: foreign key

-- relational schema

-- symbol staging table
DROP TABLE IF EXISTS stock.symbol_stg;
CREATE TABLE stock.symbol_stg (
  source varchar(100) not null,
  sector varchar(100),
  industry varchar(100),
  company varchar(100),
 -- headquarters varchar(100),
  symbol varchar(100) not null,
  loaded_at timestamptz not null default current_timestamp,
  flag       integer,
  flag_description varchar (255)
  );

-- symbol table
DROP TABLE IF EXISTS stock.symbol;
CREATE TABLE stock.symbol (
  symbol_id bigserial not null,
  source varchar(100) not null,
  sector varchar(100),
  industry varchar(100),
  company varchar(100),
 -- headquarters varchar(100),
  symbol varchar(100) not null,
  defunct boolean, -- flag if the company is active or defunct
  active boolean not null default true, -- flag to indicate this stock already exist
  created_at timestamptz not null default current_timestamp,
  updated_at timestamptz,
 CONSTRAINT symbol_pk PRIMARY KEY (source, symbol));

-- stock staging table
DROP TABLE IF EXISTS stock.history_stg;
CREATE TABLE stock.history_stg (
  date timestamptz not null,
  open double precision not null,
  high double precision not null,
  low double precision not null,
  close double precision not null,
  volume bigint,
  adj_close double precision not null,
  symbol varchar(100) not null,
  source varchar(100) not null,
  loaded_at timestamptz not null default current_timestamp,
  flag       integer,
  flag_description varchar (255)
  );

 -- stock table
 DROP TABLE IF EXISTS stock.history;
 CREATE TABLE stock.history (
   stock_id uuid DEFAULT stock.gen_random_uuid(),
   date timestamptz not null,
   open double precision not null,
   high double precision not null,
   low double precision not null,
   close double precision not null,
   volume bigint,
   adj_close double precision not null,
   symbol varchar(100) not null,
   source varchar(100) not null,
   created_at timestamptz not null default current_timestamp,
   updated_at timestamptz,
  CONSTRAINT stock_id_pk PRIMARY KEY (stock_id));

-- json schema

-- symbol json staging table
DROP TABLE IF EXISTS stock.symbol_json_stg;
create table stock.symbol_json_stg(
  symbol text,
  loaded_at timestamptz not null default current_timestamp,
  flag       integer,
  flag_description varchar (255) default 'load data to staging table');

-- symbol json table
DROP TABLE IF EXISTS stock.symbol_json;
create table stock.symbol_json(
  symbol_key uuid DEFAULT gen_random_uuid(),
  symbol JSONB,
  defunct boolean, -- flag if the company is active or defunct
  active boolean not null default true, -- flag to indicate this stock already exist
  created_at timestamptz not null default current_timestamp,
  updated_at timestamptz,
  CONSTRAINT symbol_key_pk PRIMARY KEY (symbol_key));


-- stock json staging table
DROP TABLE IF EXISTS stock.history_json_stg;
create table stock.history_json_stg(
  stock text,
  loaded_at timestamptz not null default current_timestamp,
  flag       integer,
  flag_description varchar (255) default 'load data to staging table');

-- stock json table
DROP TABLE IF EXISTS stock.history_json;
create table stock.history_json(
  stock_id_json uuid DEFAULT gen_random_uuid(),
  stock JSONB,
  defunct boolean, -- flag if the company is active or defunct
  active boolean not null default true, -- flag to indicate this stock already exist
  created_at timestamptz not null default current_timestamp,
  updated_at timestamptz,
  CONSTRAINT stock_id_json_pk PRIMARY KEY (stock_id_json));
