-- drop
drop schema if exists iRacingCalendar;

-- create

CREATE SCHEMA iRacingCalendar;

CREATE USER apiuser 
IDENTIFIED BY '123456'
REQUIRE SSL;

GRANT ALL ON iRacingCalendar.* TO apiuser;