@ECHO OFF
ECHO START CREATE SPFILE FROM PFILE...
sqlplus sys/sys as sysdba @pfile_to_spfile.sql
ECHO FINISH...