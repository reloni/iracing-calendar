DROP DATABASE IF EXISTS iracingcalendardev WITH (FORCE);
DROP ROLE IF EXISTS apiuser;

CREATE DATABASE iracingcalendardev
WITH OWNER adminuser;

 \connect iracingcalendardev;

CREATE SCHEMA calendar;

CREATE ROLE apiuser 
LOGIN
PASSWORD '123456';

GRANT ALL ON SCHEMA calendar TO apiuser;

ALTER USER apiuser SET search_path = calendar;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA calendar;