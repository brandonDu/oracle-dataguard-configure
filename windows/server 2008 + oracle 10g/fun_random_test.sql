create table test(id int);
insert into test values(dbms_random.value(0,1000));
commit;
alter system switch logfile;
SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME FROM V$ARCHIVED_LOG ORDER BY SEQUENCE#;
