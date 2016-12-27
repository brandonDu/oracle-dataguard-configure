ALTER DATABASE ADD STANDBY LOGFILE GROUP 4 ('C:\oracle\product\10.2.0\oradata\orcl\redo04.log') size 50M;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 5 ('C:\oracle\product\10.2.0\oradata\orcl\redo05.log') size 50M;
ALTER DATABASE ADD STANDBY LOGFILE GROUP 6 ('C:\oracle\product\10.2.0\oradata\orcl\redo06.log') size 50M;
select * from v$logfile;