-- drop table seasonseriepivot;
-- drop table weekentries;
-- drop table series;
-- drop table seasons;
-- drop table _fluent_migrations;

drop schema calendar cascade;
CREATE SCHEMA calendar;
GRANT ALL ON SCHEMA calendar TO apiuser;
GRANT ALL ON SCHEMA calendar TO postgres;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- seasons
insert into seasons (id, name, isactive) 
VALUES (uuid_generate_v4(), '2021 S1', false);

insert into seasons (id, name, isactive) 
VALUES (uuid_generate_v4(), '2021 S2', true);

select * from seasons;

-- series
insert into series(id, name, seasonid, homepage, logourl) 
VALUES (uuid_generate_v4(), 'Test serie 1', '89775b78-9626-4c07-aab9-8e9a6c5b34b7', '', '');

select * from series;

-- week entries

insert into weekentries(id, trackname, serieid) 
VALUES (uuid_generate_v4(), 'Week 2', 'fd940986-df00-4cac-9826-a84e9a23eb5c');

select * from weekentries;

truncate table users cascade;

select * from users;
select * from accesstokens;
select * from userseriepivot;

select * from pg_indexes
where schemaname = 'calendar';

insert into userseriepivot(id, userid, serieid) 
VALUES (uuid_generate_v4(), 'cf433890-1641-4d40-bda7-9b1d5d6c26b1', '6a8a96db-cce4-4aa3-85f2-dcfaf75d8fa6');