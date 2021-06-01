create table events (
event_type integer not null,
value integer not null,
time timestamp not null,
unique (event_type, time)
);
/
INSERT INTO events VALUES (2,   5, TO_DATE('2015-05-09 12:42:00', 'RRRR-MM-DD HH24:MI:SS'));
INSERT INTO events VALUES (4, -42, TO_DATE('2015-05-09 13:19:57', 'RRRR-MM-DD HH24:MI:SS'));
INSERT INTO events VALUES (2,   2, TO_DATE('2015-05-09 14:48:30', 'RRRR-MM-DD HH24:MI:SS'));
INSERT INTO events VALUES (2,   7, TO_DATE('2015-05-09 12:54:39', 'RRRR-MM-DD HH24:MI:SS'));
INSERT INTO events VALUES (3,  16, TO_DATE('2015-05-09 13:19:57', 'RRRR-MM-DD HH24:MI:SS'));
INSERT INTO events VALUES (3,  20, TO_DATE('2015-05-09 15:01:09', 'RRRR-MM-DD HH24:MI:SS'));
/
SELECT * FROM events;