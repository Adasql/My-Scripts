
SELECT @@servername AS connectedserver, DB_NAME() AS connecteddatabase, SYSUTCDATETIME() AS verificationtimeutc

SELECT
DB_NAME() AS DatabaseName,
CAST(
SUM(size) * 8.0 / 1024 / 1024
AS decimal(18,2)
) AS AllocatedSizeGB
FROM sys.database_files;


SELECT
DB_NAME() AS DatabaseName,
CAST(SUM(size) * 8.0 / 1024 / 1024 AS decimal(18,2))
AS AllocatedSizeGB,
CAST(SUM(FILEPROPERTY(name, 'SpaceUsed')) * 8.0 / 1024 / 1024
AS decimal(18,2)) AS UsedSizeGB,
CAST(
(
SUM(size) -
SUM(FILEPROPERTY(name, 'SpaceUsed'))
) * 8.0 / 1024 / 1024
AS decimal(18,2)
) AS FreeSpaceInsideFilesGB
FROM sys.database_files
WHERE type_desc = 'ROWS';


SELECT
DB_NAME(database_id) AS DatabaseName,
edition AS ServiceTier,
service_objective AS ServiceObjective,
elastic_pool_name AS ElasticPoolName
FROM sys.database_service_objectives
WHERE database_id = DB_ID();


USE master;
GO

SELECT
N'mint-integration' AS SourceDatabase,
N'mint-integration-bacpac-copy' AS CopyDatabase,
SYSUTCDATETIME() AS CopyRequestedTimeUTC;
GO

--create copy
CREATE DATABASE [mint-integration-bacpac-copy]
AS COPY OF [mint-integration];
GO


SELECT
DB_NAME() AS ConnectedDatabase,
SYSUTCDATETIME() AS ValidationTimeUTC;

select COUNT(*) AS Usertablecount FROM sys.tables --14 for copy nd original

--verification
SELECT
name AS DatabaseName,
state_desc AS DatabaseState,
create_date AS CreatedDate
FROM sys.databases
WHERE name = N'mint-integration-bacpac-copy';
