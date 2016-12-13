@ECHO OFF
ECHO CONNECT ORACLE...

lsnrctl start
sqlplus sys/sys as sysdba @std_mount_disconnect.sql

ECHO FINISHED...