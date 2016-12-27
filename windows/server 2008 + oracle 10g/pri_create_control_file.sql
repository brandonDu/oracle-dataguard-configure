shutdown immediate;
startup mount;
Alter database create standby controlfile as 'C:\oracle\standby.ctl';
ALTER DATABASE OPEN;
shutdown immediate;
