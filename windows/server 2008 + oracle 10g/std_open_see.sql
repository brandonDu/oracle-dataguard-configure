ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL; 
ALTER DATABASE OPEN;
SELECT * FROM TEST;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;