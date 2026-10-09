:SETVAR DatabaseName CRClaimStatus
SELECT @@SERVERNAME
;WITH CTE_Databases
AS (SELECT D.name AS DatabaseName,
           D.database_id
    FROM sys.databases AS D
    WHERE D.name <> 'tempdb'
          AND NOT (D.name IN ( 'master', 'msdb', 'model' ))),
      CTE_FirstAndLast
AS (SELECT 1 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           'IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = ' + QUOTENAME(D.DatabaseName, '''') + ')' AS CommandText
    FROM CTE_Databases AS D
    UNION ALL
    SELECT 2 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           'BEGIN' AS CommandText
    FROM CTE_Databases AS D
    UNION ALL
    SELECT 3 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           ' CREATE DATABASE ' + QUOTENAME(D.DatabaseName) + ' ON ' AS CommandText
    FROM CTE_Databases AS D
    UNION ALL
    SELECT 20 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           '     FOR ATTACH;' AS CommandText
    FROM CTE_Databases AS D
    UNION ALL
    SELECT 90 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           'END' AS CommandText
    FROM CTE_Databases AS D
    UNION ALL
    SELECT 91 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           'GO' AS CommandText
    FROM CTE_Databases AS D
    UNION ALL
    SELECT 92 AS CommandStep,
           0 AS SubStep,
           D.database_id AS DatabaseID,
           D.DatabaseName AS DatabaseName,
           '' AS CommandText
    FROM CTE_Databases AS D),
      CTE_Files
AS (SELECT 10 AS CommandStep,
           ROW_NUMBER() OVER (PARTITION BY F.database_id ORDER BY F.physical_name) AS SubStep,
           F.database_id AS DatabaseID,
           D.DatabaseName,
           CASE
               WHEN ROW_NUMBER() OVER (PARTITION BY F.database_id ORDER BY F.file_id) > 1 THEN
                   '        , '
               ELSE
                   '      '
           END + '(FILENAME = N' + QUOTENAME(F.physical_name, '''') + ')' AS CommandText
    FROM sys.master_files AS F
        INNER JOIN CTE_Databases AS D
            ON D.database_id = F.database_id),
      CTE_AllTogether
AS (SELECT CommandStep,
           SubStep,
           DatabaseID,
           DatabaseName,
           CommandText
    FROM CTE_FirstAndLast
    UNION ALL
    SELECT CommandStep,
           SubStep,
           DatabaseID,
           DatabaseName,
           CommandText
    FROM CTE_Files)
SELECT *
FROM CTE_AllTogether
WHERE DatabaseName = '$(DatabaseName)'
ORDER BY DatabaseID,
         DatabaseName,
         CommandStep,
         SubStep;