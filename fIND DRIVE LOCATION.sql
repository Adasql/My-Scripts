--FIND DRIVE LOCATION

SELECT
    DB_NAME(database_id) AS DatabaseName,
    type_desc AS FileType,
    physical_name,
    LEFT(physical_name, 1) AS DriveLetter
FROM sys.master_files
ORDER BY DatabaseName, FileType;

--FIND WHICH DRIVES ARE BEING USED
SELECT
    LEFT(physical_name, 1) AS DriveLetter,
    COUNT(*) AS FileCount
FROM sys.master_files
GROUP BY LEFT(physical_name, 1)
ORDER BY DriveLetter;

--FIND DRIVE FOR A PARTICULAR DB
SELECT
    DB_NAME(database_id) AS DatabaseName,
    type_desc,
    physical_name
FROM sys.master_files
WHERE DB_NAME(database_id) = 'YourDatabaseName';

---CHECK DEFAULT DB AND LOG FILES
SELECT
    SERVERPROPERTY('InstanceDefaultDataPath') AS DefaultDataPath,
    SERVERPROPERTY('InstanceDefaultLogPath') AS DefaultLogPath;

    --check for just system dbs
    SELECT
    DB_NAME(database_id) AS DatabaseName,
    type_desc AS FileType,
    physical_name
FROM sys.master_files
WHERE DB_NAME(database_id) IN ('master','model','msdb') --removed tempdb
ORDER BY DatabaseName, FileType;

SELECT
    DB_NAME(database_id) AS DatabaseName,
    type_desc AS FileType,
    physical_name,
    LEFT(physical_name, 1) AS DriveLetter
FROM sys.master_files
WHERE database_id <= 4 
ORDER BY DatabaseName, FileType;