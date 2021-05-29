CREATE SCHEMA calendar;

CREATE ROLE apiuser 
LOGIN
PASSWORD '123456'

GRANT ALL ON SCHEMA calendar TO apiuser;

ALTER USER apiuser SET search_path = calendar;