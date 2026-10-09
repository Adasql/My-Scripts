-- Set your DB name here,find location
DECLARE @DB sysname = N'Supporttool';

SELECT
    DB_NAME(mf.database_id) AS DatabaseName,
    mf.name                 AS LogicalName,
    mf.type_desc            AS FileType,
    mf.physical_name        AS PhysicalPath,
    mf.state_desc           AS FileState,
    mf.size * 8 / 1024      AS SizeMB
FROM sys.master_files AS mf
WHERE mf.database_id = DB_ID(@DB)
ORDER BY mf.type_desc, mf.file_id;


--take a full backup of the database
BACKUP DATABASE [SupportTool116] TO  DISK = N'D:\SQL\OLTP\Backup\Supporttool116.bak' WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N'SupportTool116-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO


--remove db from AG
-- Run on PRIMARY
ALTER AVAILABILITY GROUP qasql116
REMOVE DATABASE [Supporttool116];

--Check the state first on each secondary node then drop
Select name, state_desc from sys.databases where name='Supporttool116'


--drop from secondary
DROP database SupportTool116

/*rename on the Primary*/
--Set database to single user mode to ensure no active connections
--detach the database first then rename in OS Level.

ALTER DATABASE [Supporttool116]
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

ALTER DATABASE Supporttool116
MODIFY NAME = SupportTool;

ALTER DATABASE SupportTool
SET MULTI_USER;

--Rename MDF/LDF files
USE [master];
GO

ALTER DATABASE [SupportTool]
MODIFY FILE ( NAME = N'SupportTool116', 
              FILENAME = N'D:\SQLData\SupportTool.mdf' );

ALTER DATABASE [SupportTool]
MODIFY FILE ( NAME = N'SupportTool116_log', 
              FILENAME = N'D:\SQLLogs\SupportTool_log.ldf' );
GO

/*rename files in OS level
Start by detaching the database then rename on OS level and reattach*/




--Attach
USE [master]
GO
CREATE DATABASE [SupportTool] ON 
( FILENAME = N'D:\SQL\OLTP\Data\SupportTool.mdf' ),
( FILENAME = N'L:\SQL\OLTP\Log\SupportTool.ldf' ),
( FILENAME = N'D:\SQL\OLTP\Data\SupportTool.ndf' )
 FOR ATTACH
GO


/*Add the database back to the AG
Backup the database first */
BACKUP DATABASE [SupportTool] TO  DISK = N'D:\SQL\OLTP\Backup\Supporttool.bak' WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N'SupportTool-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--Readd the database to the AG
ALTER AVAILABILITY GROUP [dvsql116]
ADD DATABASE [SupportTool];

--used Autoseeding

/*On each secondary replica run the below*/--CONFIRM IF I CAN USE AUTOSEEDING FIRST
-- Restore full backup WITH NORECOVERY first
--RESTORE DATABASE [SupportTool]
--FROM DISK = N'\\BackupShare\Supporttool_Full.bak'
--WITH NORECOVERY;

---- Then join it to the AG
--ALTER DATABASE [SupportTool]
--SET HADR AVAILABILITY GROUP = [dvsql116];

--Validate
SELECT
    d.name,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc
FROM sys.dm_hadr_database_replica_states drs
JOIN sys.databases d
    ON drs.database_id = d.database_id
WHERE d.name = 'SupportTool';

/* Update any hardcoded DB references */
SELECT OBJECT_NAME(object_id),  definition FROM sys.sql_modules WHERE definition LIKE '%Supporttool%'