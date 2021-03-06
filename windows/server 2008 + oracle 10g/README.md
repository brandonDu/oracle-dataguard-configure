# Oracle dataguard 快速配置(脚本篇)

[TOC]

```markdown
主库：
ip: 192.168.0.2
db_name: orcl
db_unique_name: primary
备机：
ip: 192.168.0.3
db_name: orcl
db_unique_name: standby
注意：请对外开启端口，添加例外或和关闭防火墙。
```

1. 主库安装*oracle*和*database*
2. 备库仅仅安装*oracle*软件，不创建*database*
3. 备库执行*create_instance_orcl.bat*  `创建实例并创建目录结构`

### 主库设置(primary)

1. 查看主库安装信息，执行脚本`pri_check_info_primary.bat`。 调用`pri_check_info_primary.sql`
2. 创建密码文件，执行脚本`pri_orapwd.bat`。 (**总是出现循环错误，建议打开文件，手动执行里面的命令行**)
3. 启动强制归档并查看联机日志信息，执行脚本`pri_enable_logging_redo.bat`。调用`pri_enable_logging_redo.sql`
4. 根据查询信息，调整`pri_con_stdby_redo.sql` 中的联机日志编号， 调用`pri_con_stdby_redo.bat`
5. 设置主库归档模式，执行脚本`pri_enable_archiving.bat`。 调用`pri_enable_archiving.sql`
6. 设置主库初始化参数。调用脚本创建目录以及创建pfile文件。执行脚本`pri_create_archive_dir.bat`。调用`pri_create_primary_pfile.sql`
7. 在pfile文件结尾添加一下内容，如有调整，适量修改`C:\oracle\pfileorcl.ora`。

```ora
db_name='orcl'
db_unique_name='primary'
LOG_ARCHIVE_CONFIG='DG_CONFIG=(primary,standby)'
LOG_ARCHIVE_DEST_1= 'LOCATION=C:\oracle\archive VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=primary'
LOG_ARCHIVE_DEST_2= 'SERVICE=standby LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=standby'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
LOG_ARCHIVE_FORMAT=log_%t_%s_%r.arc
LOG_ARCHIVE_MAX_PROCESSES=30

fal_server=standby
fal_client=primary
standby_file_management=auto
db_file_name_convert='standby','primary'
log_file_name_convert='C:\oracle\product\10.2.0\oradata\orcl','C:\oracle\product\10.2.0\oradata\orcl'
```

8. 根据pfile创建spfile文件，并restart oracle，执行脚本`pri_pfile_to_spfile_restart.bat`。调用`pri_pfile_to_spfile_restart.sql`
9. 为备库创建控制文件，执行脚本`pri_create_control_file.bat`。调用`pri_create_control_file.sql`。
10. 配置C:\oracle\product\10.2.0\db_1\NETWORK\ADMIN下的listener.ora和tsname.ora文件。

**Listener.ora**

```
# listener.ora Network Configuration File: C:\oracle\product\10.2.0\db_1\network\admin\listener.ora
# Generated by Oracle configuration tools.

SID_LIST_LISTENER =
  (SID_LIST =    
    (SID_DESC =
      (GLOBAL_DBNAME = orcl_DGMGRL)
      (ORACLE_HOME = C:\oracle\product\10.2.0\db_1)
      (SID_NAME = orcl)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.2)(PORT = 1521))
    )
  )
```

**Tsname.ora**

```
# tnsnames.ora Network Configuration File: C:\oracle\product\10.2.0\db_1\network\admin\tnsnames.ora
# Generated by Oracle configuration tools.

primary =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.2)(PORT = 1521))
    (CONNECT_DATA =
      (SID=ORCL)
    )
  )
standby =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.3)(PORT = 1521))
    (CONNECT_DATA =
       (SID=ORCL)
    )
  )

EXTPROC_CONNECTION_DATA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
    )
    (CONNECT_DATA =
      (SID = PLSExtProc)
      (PRESENTATION = RO)
    )
  )
```

---

**此处涉及拷贝，请先shutdown主库oracle**

* 将主库的数据文件，控制文件，密码文件，以及pfile拷贝到备机相应目录下。数据文件是指：C:\oracle\product\10.2.0\oradata\orcl下的所有*.dbf文件。
* 控制文件复制三个，修改名字为：CONTROL01.CTL，CONTROL02.CTL，CONTROL03.CTL， 并保存早C:\oracle\product\10.2.0\oradata\orcl下。
* 保存数据文件到C:\oracle\product\10.2.0\oradata\orcl下。
* 保存密码文件到C:\oracle\product\10.2.0\db_1\database下。
* 保存pfile文件到C:\oracle\下。
* 创建路径：C:\oracle\archive

---

### 备库操作(standby)

1. 配置参数文件，修改pfile文件内容。

```
db_name='orcl'
db_unique_name='standby'
LOG_ARCHIVE_CONFIG='DG_CONFIG=(primary,standby)'
LOG_ARCHIVE_DEST_1= 'LOCATION=C:\oracle\archive VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=standby'
LOG_ARCHIVE_DEST_2= 'SERVICE=primary LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=primary'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
LOG_ARCHIVE_FORMAT=log_%t_%s_%r.arc
LOG_ARCHIVE_MAX_PROCESSES=30

fal_server=primary
fal_client=standby
standby_file_management=auto
db_file_name_convert='primary','standby'
log_file_name_convert='c:\oracle\product\10.2.0\oradata\orcl','c:\oracle\product\10.2.0\oradata\orcl'
```

2. 配置C:\oracle\product\10.2.0\db_1\NETWORK\ADMIN下的listener.ora和tsname.ora文件。

**Listener.ora**

```
# listener.ora Network Configuration File: C:\oracle\product\10.2.0\db_1\network\admin\listener.ora
# Generated by Oracle configuration tools.

SID_LIST_LISTENER =
  (SID_LIST =    
    (SID_DESC =
      (GLOBAL_DBNAME = orcl_DGMGRL)
      (ORACLE_HOME = C:\oracle\product\10.2.0\db_1)
      (SID_NAME = orcl)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.3)(PORT = 1521))
    )
  )
```

**Tnsname.ora**

```
# tnsnames.ora Network Configuration File: C:\oracle\product\10.2.0\db_1\network\admin\tnsnames.ora
# Generated by Oracle configuration tools.

primary =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.2)(PORT = 1521))
    (CONNECT_DATA =
      (SID=ORCL)
    )
  )
standby =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.3)(PORT = 1521))
    (CONNECT_DATA =
      (SID=ORCL)
    )
  )

EXTPROC_CONNECTION_DATA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
    )
    (CONNECT_DATA =
      (SID = PLSExtProc)
      (PRESENTATION = RO)
    )
  )
```

3. 生成spfile文件，执行脚本`std_create_spfile.bat`。调用`std_spfile_from_pfile.sql`
4. 挂载数据库。

```plsql
备库执行：SQL> startup mount;
主库执行：SQL> alter system switch logfile; (如果没有启动，需要新startup;)
```

5. 备机和主机都执行lsnrctl stop然后执行lsnrctl start，最后进行tnsping primary 和tnsping standby查看是否都ok。
6. 备库添加redo日志。执行脚本 `std_cre_redo_log.bat`，调用`std_add_redo_log.sql`(可以多次执行此bat文件)
7. 主库执行测试脚本`create_table_insert_random.bat`，调用`fun_random_test.sql`
8. 备库执行sql查询

```plsql
SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME FROM V$ARCHIVED_LOG ORDER BY SEQUENCE#; --查看和主库是否一致，如果不一致，从第四步进行重新执行。如果未关闭请进行关闭。
```

8. 查询备库数据是否插入，执行脚本`std_check_insert.bat` ， 调用`std_open_see.sql`


### 同步后的一些参考语句

1. 调用`std_restart_index.bat`, 执行`std_mount_disconnect.sql`(如果出现问题可以进行使用，或者把此*.bat文件永久添加到开机启动项)

#### 一些参考语句

```plsql
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE NODELAY;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
--查看是否开启实时应用
SELECT  DEST_NAME , STATUS , RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS;
--开启实时应用
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
-- cancleing a time delay;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE NODELAY;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE;
-- check the archive if applied.
SELECT NAME FROM V$ARCHIVED_LOG WHERE APPLIED='YES' AND NAME IS NOT NULL AND DEST_ID=1; 
```

#### 以后可能用到

```basic
--delete_dg_archivelog
cd D:\archivelogdel
d: 
sqlplus / as sysdba @delete_archive.sql 
echo rman target / cmdfile=rman_checkcross.rman>>delete_archivelog.bat 
delete_archivelog.bat >>delete_dg_archivelog_%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%".log 
exit 

--delete_archive.sql 
set lines 150 
col name for a150 
set pagesize 0 feedback off verify off heading off echo off 
spool delete_archivelog.bat 
select 'del '||name from v$archived_log where APPLIED='YES' AND NAME IS NOT NULL and DEST_ID=1; 
spool off 
exit; 

--rman_checkcross.rman 
crosscheck archivelog all; 
delete noprompt expired archivelog all; 
exit 
```



### 开启flashback

1. PRIMARY执行以下命令：

```sql
-- Mount the database, configure flashback retention
-- start flashback database and open the database.
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;
SQL> ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=1440; --此处是分钟数，表示故障时间限制。
-- Set up for 24 hour retention 
SQL> ALTER DATABASE FLASHBACK ON;
-- 如何此处出现错误，请使用startup restrict命令。
SQL> ALTER DATABASE OPEN;
-- 可以使用：select flashback_on from v$database; 查看是否开启flashback.
```

1. STANDBY 执行以下命令，**注意先取消redo apply**

```sql
-- Stop redo apply, configure flashback retention
-- start flashback database, open the database and start redo apply (Is active DG).
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SQL> ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=1440;
SQL> ALTER DATABASE FLASHBACK ON;
SQL> select flashback_on from v$database;
SQL> ALTER DATABASE OPEN;
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
-- 可以使用：select flashback_on from v$database; 查看是否开启flashback.
```

### 创建broker

1. 首先保证*primary, standby*的主备环境，可以采用`alter system switch logfile`在主机和备机看看是否同步。

2. 如果主备环境也就是**Dataguard** 环境完整，则进行**Broker**的环境创建。

3. 在主备均执行SQL语句：

   ```plsql
   Alter system set dg_broker_start=True scope=both;
   ```

4. *primary*执行

```vb
C:\> dgmgrl
```

5.  进入*GDMGRL*命令后，创建*Broker*

```sql
DGMGRL> connect sys/sys
DGMGRL> create configuration 'broker1' as primary database is 'primary' connect identifier is primary; 
-- 'primary' in Connect identifier is the service name through which the broker is connected to the PRIMARY database

DGMGRL> Add database 'standby' as connect identifier is standby maintained as physical;
-- 'standby' in Connect identifier is the service name through which the broker is connected to the STANDBY database

DGMGRL> show configuration;
-- Configuration
-- Name:                  broker1
-- Enabled:               NO
-- Protection Mode:       MaxPerformance
-- Fast-Start Failover:   DISABLE
-- Databases:
--   primary - Physical standby database
--   standby - Primary database
-- Current status for "broker1":
-- DISABLE
DGMGRL> enable configuration;
DGMGRL> show configuration;
-- Name:                  broker1
-- Enabled:               YES
-- Protection Mode:       MaxPerformance
-- Fast-Start Failover:   DISABLE
-- Databases:
--   primary - Physical standby database
--   standby - Primary database
--Current status for "broker1":
--SUCCESS

-- （注意，一定要等待出现success才可以后续执行。）
```

1. **注意：等一会哦(Then wait for some time...)**
2. 后边的操作在于检验是否配置成功.

```sql
SQL> select flashback_on from v$database;
c:\dgmgrl
DGMGRL> connect sys/sys@primary;
DGMGRL> show configuration;
--下面的操作只有在测试验证时可以进行，部署生产环境禁止使用。
-- 备机执行
c:\dgmgrl
DGMGRL> connect sys/sys@standby;
DGMGRL> show configuration;
DGMGRL> failover to 'standby'; -- new machine is standby, standby become the primary
c:\> sqlplus / as sysdba;
SQL> startup;

-- 你需要等一大会，或者插入一些原来主机没有的东东。

-- if the primary restart, then reconnect the dgmgrl cli.
-- 首先将原来的故障主机，转为备机。
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;
SQL> ALTER DATABASE CONVERT TO PHYSICAL STANDBY;
SQL> SELECT DATABASE_ROLE FROM V$DATABASE;
-- PHYSICAL STANDBY

-- 故障主机进行重启，并进入MOUNT模式
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;
-- 新主机执行，最好重新tnsping一下，同时重新连接一下dgmgrl
C:\> LSNRCTL STOP
C:\> LSNRCTL START
-- 主备均执行一次，切记！
C:\> TNSPING PRIMARY
C:\> TNSPING STANDBY -- 查看primary和standby是否监听都通畅
-- 新主机执行
c:\dgmgrl
DGMGRL> connect sys/sys@standby;
DGMGRL> reinstate database 'primary'; -- 恢复主机database

-- if succeed! then cogratulation!
-- 重启备机数据库，并使其应用realtime redo apply
-- you succeed! ,此时备库是实时应用。
-- 备机执行(恢复的故障原主机) [optional]，just to make sure the environment safe。
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SQL> ALTER DATABASE OPEN;
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
```

### 配置fast-start failover

根据现场情况，三台机器可以配置。

```sql
DGMGRL> connect sys/sys@primary 

DGMGRL> help edit 

Primary:
DGMGRL> edit database primary set property LogXptMode='SYNC';
Standby:
DGMGRL> edit database standby set property LogXptMode='SYNC';

Primary:
DGMGRL> edit configuration set protection mode as MaxAvailability; 
Succeeded.
DGMGRL> show configuration;

SQL> select open_mode,database_role,log_mode,flashback_on from v$database; 
 
OPEN_MODE            DATABASE_ROLE    LOG_MODE     FLASHBACK_ON 
-------------------- ---------------- ------------ ------------------ 
READ WRITE           PRIMARY          ARCHIVELOG   YES 
--flashback的配置目录与大小 
SQL> show parameter recovery

Standby:
SQL> select open_mode,database_role,log_mode,flashback_on from v$database; 
 
OPEN_MODE            DATABASE_ROLE    LOG_MODE     FLASHBACK_ON 
-------------------- ---------------- ------------ ------------------ 
READ ONLY WITH APPLY PHYSICAL STANDBY ARCHIVELOG   YES 

DGMGRL> edit database primary set property FastStartFailoverTarget=standby; 
Property "faststartfailovertarget" updated 
DGMGRL> edit database standby set property  FastStartFailoverTarget=primary; 
Property "faststartfailovertarget" updated 

--FastStartFailoverPmyShutdown

--FastStartFailoverLagLimit

--FastStartFailoverAutoReinstate

--ObserverConnectIdentifier

DGMGRL> show configuration verbose;

DGMGRL> enable fast_start failover;
-- 主机如果运行，则当实例断开后，切换备库过程中报出无法启动错误。
-- 故此命令在备机运行。
$dgmgrl sys/sys@primary "start observer" -- 断网测试失败，实例无法启动。

$dgmgrl sys/sys@standby "start observer" -- 
```

### 关于主备的一些问题

1. 因为主备机是两个机器，无论把观察者放在哪个机器，都会出现监听断掉无法连接的问题。

2. 对于某些已经测试问题，在此解答：

   * 关于主备机切换的问题。
     * 如果进行主备切换，需要同时连接主备，主备角色调换，可以采用Broker实现。
   * 如果出现failover，则备机切换成主机。
     * 由于主机故障(断网、宕机)，备机可以执行本地命令，切换为主机。SQLPLUS命令或者DGMGRL命令均可以实现。
   * 如果故障主机恢复，重新构建主备环境，是否必须开启flash back？
     * 重建主备环境有多种方法，可以重新复制数据文件和控制文件等进行DataGuard环境构建。
     * 也可以采用RMAN命令进行远程数据文件复制拷贝，重新构建控制文件等。
     * 如果开启flash back， 则可以进行从节点恢复，而不必拷贝整个数据库，所以建议开启flash back ，缺点是会占用一定的存储空间，大小由设置需求决定。
   * 如果开启了flash back，则恢复方案有哪些？
     * 可以采用SQLPLUS执行SQL命令，获取原来备机的SCN号，进行恢复，恢复过程比较复杂同时由于本地机器故障恢复，并不一定可以执行远程命令，来进行DG环境恢复。
     * 可以构建Broker，当主机恢复后，在主机进行角色切换，转为备机，在备机执行DGMGRL命令，自动进行主机连接和DG环境恢复。

3. 由于测试时间比较短，所以对于某些问题缺乏测试，问题如下：

   * 如果配置**

4. 如果一直tnsping不通，则考虑防火墙或者是否添加例外端口。

   ​

### 过程总结

__关于sqlplus远程连接的问题:__

* 如果在**primary**采用如下命令：

   `sqlplus sys/sys  as sysdba@standby `

  则执行的会进入本地SQL交互，不要问为什么，记住，可能是因为**as sysdba **的问题 。

* 远程连接调用sqlplus 命令可以通过以下几种方式进入：

  * `sqlplus sys/sys@[service-name] as sysdba`  
  * `sqlplus sys/sys@[//][server-name/server-ip]:1521/standby as sysdba`  

* 如果远程的机器的oracle关闭

  * 远程命令`sqlplus sys/sys@[service-name] as sysdba` 无法连接。
  * 本地执行 `sqlplus / as sysdba` 可以连接。
  * 本地执行 `sqlplus sys/sys as sysdba` 可以连接。

* 如果想进行远程操作另一台机器的重启，建议在windows下采用PsExec工具，如果是linux，可以使用SSH。因为如果不是系统级的通信连接，则oracle的重启会断开oracle的监听。

### 补充材料

1. primary:  *configure the flashback, and enable flashback*

```
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;
SQL> alter system set DB_RECOVERY_FILE_DEST_SIZE=2g scope=both;
SQL> alter system set db_recovery_file_dest='+DATA' scope=both;
SQL> ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=240; # Set up for 4 hour retention 
SQL> ALTER DATABASE FLASHBACK ON;
SQL> ALTER DATABASE OPEN;
```

2: standby:

```
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SQL> alter system set DB_RECOVERY_FILE_DEST_SIZE=2g scope=both;
SQL> alter system set db_recovery_file_dest='+DATA' scope=both;
SQL> ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=240;
SQL> ALTER DATABASE FLASHBACK ON;
SQL> ALTER DATABASE OPEN;
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
```

3. rman: 

```
$rman target sys@standby auxiliary sys@primary
RMAN> RUN
{
allocate channel c1 device type disk;
allocate auxiliary channel a1 device type DISK;
DUPLICATE TARGET DATABASE
FOR STANDBY FROM ACTIVE DATABASE
NOFILENAMECHECK;
}
RMAN> exit;
```

### 关于broker

按照以上配置，总会出现，`reinstate database **` 过程中报错，原因是什么呢？纠结了很久，探索了long time, 最终在[某个好心人](https://oracle-base.com/articles/12c/data-guard-setup-using-broker-12cr1) 那里找到了原因，以往测试过程，总是存在偶尔成功，偶尔失败的问题，一直知道是监听的问题，而有时监听restart 会成功 _reinstate_, 一直摸不到原因，大约查找跟踪问题有两周时间，就是spend 这上面了。终于在某个帮助文档中，虽然是**oracle 12c**的版本，不过有段话需要记住。

```
Entries for the primary and standby databases are needed in the "$ORACLE_HOME/network/admin/tnsnames.ora" files on both servers. You can create these using the Network Configuration Utility (netca) or manually. The following entries were used during this setup. Notice the use of the SID, rather than the SERVICE_NAME in the entries. This is important as the broker will need to connect to the databases when they are down, so the services will not be present.
```

 在 _tnsname.ora_ 中，需要 记录的不是 _service_name_, 而是 _sid_。 所以配置修改参照以下内容：

```
primary =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.8)(PORT = 1521))
    (CONNECT_DATA =
      (SID=ORCL)
    )
  )
standby =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.9)(PORT = 1521))
    (CONNECT_DATA =
      (SID=ORCL)
    )
  )
```

而同样需要修改 _listener.ora_ ，主要是需要加标识，如果你是调用了域名，则进行需要配置域。配置参考下面：

```
SID_LIST_LISTENER =
  (SID_LIST =    
    (SID_DESC =
      (GLOBAL_DBNAME = orcl_DGMGRL)
      (ORACLE_HOME = C:\oracle\product\10.2.0\db_1)
      (SID_NAME = orcl)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.9)(PORT = 1521))
    )
  )
```

此处记录如下，主要是因为以前配置的在 _dataguard_ 环境成功，但是在_broker_下失败的问题。已经修改上述配置，但是此处需要记录一下问题原因。





