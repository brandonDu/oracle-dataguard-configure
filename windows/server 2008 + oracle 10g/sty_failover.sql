conn sys/sys@standby as sysdba;
alter database recover managed standby database finish force;
alter database commit to switchover to primary;
alter database open;
shutdown immediate;
conn sys/sys as sysdba;
startup;
select database_role from v$database;
