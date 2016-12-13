@ECHO OFF
ECHO START CREATE INSTANCE ORCL...
oradim -new -sid orcl
SET orcle_sid=orcl
ECHO FINISH INSTANCE...
ECHO CREATE DIRECTORY...
CD C:\oracle\product\10.2.0\
MD admin\orcl flash_recovery_area\ORCL\ONLINELOG oradata\orcl
CD admin\orcl
MD adump bdump cdump dpdump pfile udump
ECHO FINISH DIRECTORY...
REM C:\oracle\product\10.2.0\admin
REM C:\oracle\product\10.2.0\admin\orcl
REM C:\oracle\product\10.2.0\admin\orcl\adump
REM C:\oracle\product\10.2.0\admin\orcl\bdump
REM C:\oracle\product\10.2.0\admin\orcl\cdump
REM C:\oracle\product\10.2.0\admin\orcl\dpdump
REM C:\oracle\product\10.2.0\admin\orcl\pfile
REM C:\oracle\product\10.2.0\admin\orcl\udump
REM C:\oracle\product\10.2.0\flash_recovery_area
REM C:\oracle\product\10.2.0\flash_recovery_area\ORCL
REM C:\oracle\product\10.2.0\flash_recovery_area\ORCL\ONLINELOG
REM C:\oracle\product\10.2.0\oradata
REM C:\oracle\product\10.2.0\oradata\orcl
