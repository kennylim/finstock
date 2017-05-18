
-- create user and database in global level
CREATE USER finstock WITH password 'enter-your-password';
ALTER DATABASE finstock SET search_path TO finstock;

--grant schema aws_finance to finstock;
GRANT CONNECT ON DATABASE finstock TO finstock;

-- create stock stock schema
CREATE SCHEMA stock;
GRANT USAGE ON SCHEMA stock TO finstock;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA stock TO finstock;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA stock TO finstock;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA stock TO finstock;

--  create audit schema
CREATE SCHEMA audit;
GRANT USAGE ON SCHEMA audit TO finstock;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit TO finstock;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA audit TO finstock;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA audit TO finstock;

# check if extension list exist in database
SELECT * FROM pg_available_extensions;

# install extensions
create extension hstore schema stock;
create extension hstore schema audit;
create extension pgcrypto schema stock;
create extension pgcrypto schema audit;
--create extension uuid_ossp schema stock;
--create extension uuid_ossp schema audit;

