startup nomount pfile='C:\oracle\pfileorcl.ora';
alter database mount standby database;
create spfile from pfile='C:\oracle\pfileorcl.ora';
shutdown immediate;
