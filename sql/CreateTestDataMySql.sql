-- drop
drop schema if exists calendar;
CREATE SCHEMA calendar;
GRANT ALL ON calendar.* TO apiuser;
USE iRacingCalendar;

-- seasons

insert into seasons (id, name, isactive) 
VALUES (UNHEX(REPLACE('3be735d9-49e7-4ea6-b3c6-707918c23f65', "-","")), '2021 S1', false);

insert into seasons (id, name, isactive) 
VALUES (UNHEX(REPLACE('186d9bf6-630f-46bb-b9e5-f2be727c2bca', "-","")), '2021 S2', true);

-- series

insert into series(id, name, seasonid, homepage, logourl) 
VALUES (UNHEX(REPLACE('acffe1bf-a312-43dc-ae2c-ad8e90135955', "-","")), 'Test serie 1', UNHEX(REPLACE('3be735d9-49e7-4ea6-b3c6-707918c23f65', "-","")), '', '');

insert into series(id, name, seasonid, homepage, logourl) 
VALUES (UNHEX(REPLACE('3f70ee36-c232-4afd-9806-1a456af5e644', "-","")), 'Test serie 2', UNHEX(REPLACE('186d9bf6-630f-46bb-b9e5-f2be727c2bca', "-","")), '', '');

insert into series(id, name, seasonid, homepage, logourl) 
VALUES (UNHEX(REPLACE('6a8a96db-cce4-4aa3-85f2-dcfaf75d8fa6', "-","")), 'Test serie 3', UNHEX(REPLACE('186d9bf6-630f-46bb-b9e5-f2be727c2bca', "-","")), '', '');

-- week entries

insert into weekentries(id, trackname, serieid) 
VALUES (UNHEX(REPLACE(UUID(), "-","")), 'Serie 1 Track 1', UNHEX(REPLACE('acffe1bf-a312-43dc-ae2c-ad8e90135955', "-","")));

insert into weekentries(id, trackname, serieid) 
VALUES (UNHEX(REPLACE(UUID(), "-","")), 'Serie 2 Track 1', UNHEX(REPLACE('3f70ee36-c232-4afd-9806-1a456af5e644', "-","")));

insert into weekentries(id, trackname, serieid) 
VALUES (UNHEX(REPLACE(UUID(), "-","")), 'Serie 2 Track 2', UNHEX(REPLACE('3f70ee36-c232-4afd-9806-1a456af5e644', "-","")));

insert into weekentries(id, trackname, serieid) 
VALUES (UNHEX(REPLACE(UUID(), "-","")), 'Serie 2 Track 3', UNHEX(REPLACE('3f70ee36-c232-4afd-9806-1a456af5e644', "-","")));

insert into weekentries(id, trackname, serieid) 
VALUES (UNHEX(REPLACE(UUID(), "-","")), 'Serie 3 Track 1', UNHEX(REPLACE('6a8a96db-cce4-4aa3-85f2-dcfaf75d8fa6', "-","")));