@echo off
DGMGRL.exe sys/sys "show configuration;"
rem standby > primary, if primary > standby ,the name should change.
DGMGRL.exe sys/sys "failover to 'standby'" 
sqlplus / as sysdba @sty_restart.sql
pause