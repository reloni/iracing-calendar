drop table seasonseriepivot;
drop table series;
drop table seasons;
drop table _fluent_migrations;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- seasons
insert into seasons (id, name) 
VALUES (uuid_generate_v4(), '2021 S1');

select * from seasons;

-- series
insert into series(id, name, homepage, logourl) 
VALUES (uuid_generate_v4(), 'Test serie', '', '');

select * from series;

-- season serie rel
select * from "season-serie-pivot"

INSERT INTO seasonseriepivot (id, seasonid, serieid)
VALUES (uuid_generate_v4(), '0f616f9e-e17c-40ce-8d30-e1321ce74e0f', 'bd67a6b5-813e-4abb-90ea-eca58c8f316f')

select season.name, serie.name
from series as serie
JOIN seasonseriepivot as pivot on serie.id = pivot.serieid
JOIN seasons as season on pivot.seasonid = season.id
