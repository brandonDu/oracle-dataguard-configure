SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;
SELECT DATABASE_ROLE FROM V$DATABASE;
-- PHYSICAL STANDBY
-- 故障主机进行重启，并进入MOUNT模式
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
QUIT;