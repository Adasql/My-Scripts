
--query to run
USE Albert;
GO
ALTER DATABASE [Albert] ADD FILEGROUP [fg2028];

ALTER DATABASE [Albert]
ADD FILE
    (
        NAME = N'f2028',
        FILENAME = N'D:\SQL\Data\Albert_f2028.ndf',
        SIZE = 10240MB,
        FILEGROWTH = 1024MB
    )
TO FILEGROUP [fg2028];

ALTER PARTITION SCHEME [psYear]
NEXT USED [fg2028];

ALTER PARTITION FUNCTION pfYear ()
SPLIT RANGE
      ('2028-01-01 00:00:00.000');

--partition queries
SELECT
    pf.name AS PartitionFunction,
    pf.type_desc,
    pf.boundary_value_on_right,
    prv.boundary_id,
    CONVERT(varchar(30), prv.value) AS BoundaryValue
FROM sys.partition_functions pf
JOIN sys.partition_range_values prv
    ON pf.function_id = prv.function_id
WHERE pf.name = 'pfYear'
ORDER BY prv.boundary_id;

SELECT
    name,
    CASE boundary_value_on_right
        WHEN 1 THEN 'RANGE RIGHT'
        ELSE 'RANGE LEFT'
    END AS RangeType
FROM sys.partition_functions
WHERE name = 'pfYear';

SELECT
    fg.name AS FileGroup,
    df.name AS LogicalFileName,
    df.physical_name,
    df.size/128.0 AS SizeMB
FROM sys.filegroups fg
JOIN sys.database_files df
    ON fg.data_space_id = df.data_space_id
ORDER BY fg.name;

SELECT
    ps.name,
    fg.name AS FileGroupName,
    dds.destination_id
FROM sys.partition_schemes ps
JOIN sys.destination_data_spaces dds
    ON ps.data_space_id = dds.partition_scheme_id
JOIN sys.filegroups fg
    ON dds.data_space_id = fg.data_space_id
WHERE ps.name = 'psYear'
ORDER BY dds.destination_id;

SELECT
    pf.name AS PartitionFunction,
    ps.name AS PartitionScheme,
    prv.boundary_id,
    CONVERT(varchar(30), prv.value) AS BoundaryValue,
    fg.name AS FileGroup
FROM sys.partition_functions pf
JOIN sys.partition_schemes ps
    ON pf.function_id = ps.function_id
JOIN sys.destination_data_spaces dds
    ON ps.data_space_id = dds.partition_scheme_id
JOIN sys.filegroups fg
    ON dds.data_space_id = fg.data_space_id
LEFT JOIN sys.partition_range_values prv
    ON pf.function_id = prv.function_id
    AND dds.destination_id = prv.boundary_id + 1
WHERE pf.name = 'pfYear'
ORDER BY dds.destination_id;