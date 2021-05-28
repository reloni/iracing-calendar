-- drop table seasonseriepivot;
drop table series;
drop table seasons;
drop table _fluent_migrations;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- seasons
insert into seasons (id, name, isactive) 
VALUES (uuid_generate_v4(), '2021 S1', true);

select * from seasons;

-- series
insert into series(id, name, homepage, logourl) 
VALUES (uuid_generate_v4(), 'Test serie 3', '', '');

select * from series;

-- season serie rel
select * from "season-serie-pivot"

INSERT INTO seasonseriepivot (id, seasonid, serieid)
VALUES (uuid_generate_v4(), '89456e17-7774-4ed1-882a-7ef85dd20685', 'c9a50a7f-19b0-4765-ab3a-018b6e84bdd1')

select season.name, serie.name
from series as serie
JOIN seasonseriepivot as pivot on serie.id = pivot.serieid
JOIN seasons as season on pivot.seasonid = season.id
