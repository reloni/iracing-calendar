-- drop
drop schema calendar cascade;
CREATE SCHEMA calendar;
GRANT ALL ON SCHEMA calendar TO apiuser;

-- seasons

insert into seasons (id, name, isactive) 
VALUES ('3be735d9-49e7-4ea6-b3c6-707918c23f65', '2021 S1', false);

insert into seasons (id, name, isactive) 
VALUES ('186d9bf6-630f-46bb-b9e5-f2be727c2bca', '2021 S2', true);

-- series

insert into series(id, name, seasonid, homepage, logourl) 
VALUES ('acffe1bf-a312-43dc-ae2c-ad8e90135955', 'Test serie 1', '3be735d9-49e7-4ea6-b3c6-707918c23f65', '', '');

insert into series(id, name, seasonid, homepage, logourl) 
VALUES ('3f70ee36-c232-4afd-9806-1a456af5e644', 'Test serie 2', '186d9bf6-630f-46bb-b9e5-f2be727c2bca', '', '');

insert into series(id, name, seasonid, homepage, logourl) 
VALUES ('6a8a96db-cce4-4aa3-85f2-dcfaf75d8fa6', 'Test serie 3', '186d9bf6-630f-46bb-b9e5-f2be727c2bca', '', '');

-- week entries

insert into weekentries(id, trackname, serieid) 
VALUES (uuid_generate_v4(), 'Serie 1 Track 1', 'acffe1bf-a312-43dc-ae2c-ad8e90135955');

insert into weekentries(id, trackname, serieid) 
VALUES (uuid_generate_v4(), 'Serie 2 Track 1', '3f70ee36-c232-4afd-9806-1a456af5e644');

insert into weekentries(id, trackname, serieid) 
VALUES (uuid_generate_v4(), 'Serie 2 Track 2', '3f70ee36-c232-4afd-9806-1a456af5e644');

insert into weekentries(id, trackname, serieid) 
VALUES (uuid_generate_v4(), 'Serie 2 Track 3', '3f70ee36-c232-4afd-9806-1a456af5e644');

insert into weekentries(id, trackname, serieid) 
VALUES (uuid_generate_v4(), 'Serie 3 Track 1', '6a8a96db-cce4-4aa3-85f2-dcfaf75d8fa6');