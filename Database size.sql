DECLARE @DatabaseName sysname = N'supporttool116';  -- set to NULL for all DBs


SELECT
    d.name AS DatabaseName,

    -- Size in KB
    SUM(mf.size) * 8 AS Size_KB,

    -- Size in MB
    SUM(mf.size) * 8 / 1024 AS Size_MB,

    -- Size in GB
    CAST(SUM(mf.size) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS Size_GB
FROM sys.databases d
JOIN sys.master_files mf
    ON d.database_id = mf.database_id
WHERE
    d.state_desc = 'ONLINE'
    AND (@DatabaseName IS NULL OR d.name = @DatabaseName)
GROUP BY d.name
ORDER BY Size_GB DESC;



DECLARE @DatabaseName sysname = N'supporttool116';

SELECT
    DB_NAME(mf.database_id) AS DatabaseName,
    mf.name                AS LogicalFileName,
    mf.type_desc           AS FileType,
    mf.physical_name       AS PhysicalPath,

    -- Sizes
    mf.size * 8 AS Size_KB,
    mf.size * 8 / 1024 AS Size_MB,
    CAST(mf.size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS Size_GB
FROM sys.master_files mf
WHERE
    mf.database_id = DB_ID(@DatabaseName)
ORDER BY mf.type_desc, mf.file_id;