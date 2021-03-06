ALTER SYSTEM SET UNDO_RETENTION=3600 SCOPE=SPFILE;
ALTER SYSTEM SET UNDO_MANAGEMENT='AUTO' SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE FLASHBACK ON;
ALTER DATABASE OPEN;


--scn
SELECT TO_CHAR(STANDBY_BECAME_PRIMARY_SCN) FROM V$DATABASE;
--primary;
startup mount;
flashback database to scn 5003411; -- from standby scn
ALTER DATABASE FLASHBACK OFF;
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;