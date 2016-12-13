select * from v$standby_log;
alter database add standby logfile group 4 ('C:\oracle\product\10.2.0\oradata\orcl\redo04.log') size 50m;
alter database add standby logfile group 5 ('C:\oracle\product\10.2.0\oradata\orcl\redo05.log') size 50m;
alter database add standby logfile group 6 ('C:\oracle\product\10.2.0\oradata\orcl\redo06.log') size 50m;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
