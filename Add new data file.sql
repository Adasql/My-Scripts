--teps and scripts to run (all steps run on all three nodes)
--add file first then
--Set filegrowth to 0
--CHANGE SIZSE TO 16TB
--THEN SET AUTOGROWTH TO 0


--start with ensuring the new data folder is in all the nodes and the sa_prsql has access to the drive on all nodes
	--1. Add new file to new drive and in the filegroup (only on primary)
ALTER DATABASE [Eligibility]
ADD FILE
    (
        NAME = N'Eligibility_tranStoreElr7', --new file name
        FILENAME = N'E:\SQL\OLTP\Data\Eligibility_tranStoreElr7.ndf',
        SIZE = 10240000KB,
        FILEGROWTH = 5120000KB
    )
TO FILEGROUP [TransactionStore_Elr];
GO


	--2. Add the data folder in the new drive (all three nodes)

--Make directory: SQL\OLTP\Data --this will be in the new disk/drive

 --3. grant permissions to service account
--At SQL level add service account with full control

--4.This will only be done in primary
--Turn this file:  Eligibility_tranStoreElr6 to 0 growth

ALTER DATABASE [Eligibility] MODIFY FILE ( NAME = N'Eligibility_tranStoreElr6', FILEGROWTH = 0)
 
 --scripts to run first
 USE [Denials];
GO

SELECT
df.name AS LogicalFileName,
fg.name AS FilegroupName,
df.physical_name AS FilePath,
CAST(df.size / 128.0 / 1024 AS decimal(18,2)) AS FileSizeGB,
CAST(FILEPROPERTY(df.name, 'SpaceUsed') / 128.0 / 1024
AS decimal(18,2)) AS UsedSpaceGB,
CAST((df.size - FILEPROPERTY(df.name, 'SpaceUsed'))
/ 128.0 / 1024 AS decimal(18,2)) AS FreeInsideFileGB,
vs.volume_mount_point AS Drive,
CAST(vs.total_bytes / 1073741824.0
AS decimal(18,2)) AS DriveTotalGB,
CAST(vs.available_bytes / 1073741824.0
AS decimal(18,2)) AS DriveFreeGB
FROM sys.database_files AS df
LEFT JOIN sys.filegroups AS fg
ON df.data_space_id = fg.data_space_id
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), df.file_id) AS vs
WHERE df.type = 0
ORDER BY fg.name, df.file_id;


--script 2
select name as logicalname, physical_name, type_desc, CAST(size/ 120.0/ 1024 as decimal(18,2)) as size_tb,
CASE WHEN is_percent_growth =1 THEN CONCAT(growth, '%')
ELSE CONCAT(growth / 128, 'MB') END AS autogrowth
FROM sys.database_files
ORDER BY FILE_ID

--script 3
USE Denials;
GO

SELECT
    file_id,
    name,
    type_desc,
    physical_name,
    size/128.0 AS SizeMB
FROM sys.database_files
ORDER BY file_id DESC;


--Autogrow scripts
SELECT
    name,
    type_desc,
    CAST(size AS BIGINT) / 128.0 AS SizeMB,
    CAST(FILEPROPERTY(name, 'SpaceUsed') AS BIGINT) / 128.0 AS UsedMB,
    (CAST(size AS BIGINT) - CAST(FILEPROPERTY(name, 'SpaceUsed') AS BIGINT)) / 128.0 AS FreeMB
FROM sys.database_files
ORDER BY file_id;

SELECT
    name,
    type_desc,
    size / 128.0 AS SizeMB,
    CASE
        WHEN growth = 0 THEN 'None'
        WHEN is_percent_growth = 1 THEN CONCAT('By ', growth, '%')
        ELSE CONCAT('By ', CAST(CAST(growth AS BIGINT) * 8 / 1024 AS VARCHAR(20)), ' MB')
    END AS GrowthSetting,
    CASE
        WHEN max_size = -1 THEN 'Unlimited'
        ELSE CONCAT(CAST(CAST(max_size AS BIGINT) * 8 / 1024 AS VARCHAR(20)), ' MB')
    END AS MaxSize
FROM sys.database_files;

USE DBMonitor
SELECT * FROM dbo.AutoGrowMetaData

update dbo.AutoGrowMetaData set shouldautogrow= 0 where filename ='ClaimsWarehouse_Primary_2'