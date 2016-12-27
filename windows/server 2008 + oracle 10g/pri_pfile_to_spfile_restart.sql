shutdown immediate;
startup nomount pfile='C:\oracle\pfileorcl.ora';
create spfile from pfile='C:\oracle\pfileorcl.ora';
shutdown immediate;
startup;