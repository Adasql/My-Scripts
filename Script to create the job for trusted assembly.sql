
/*this scripts out the database and assemblies and lets me know which ones needs to be added to trust*/
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#Assemblies') IS NOT NuLL
DROP TABLE #Assemblies;

CREATE TABLE #Assemblies
(
DatabaseName sysname,
AssemblyName sysname,
Description nvarchar(4000),
Hashvalue varbinary(64)
);

DECLARE @DB sysname;
DECLARE @SQL nvarchar(MAX);

DECLARE db_cursor CURSOR FAST_FORWARD
FOR
SELECT name 
FROM sys.databases WHERE database_id > 4
AND state_desc= 'ONLINE';

OPEN db_cursor;

FETCH NEXT FROM db_cursor INTO @DB;
WHILE @@FETCH_STATUS =0
BEGIN

SET @SQL='
USE ' + QUOTENAME(@DB) + ';
INSERT INTO #Assemblies
SELECT 
DB_NAME(), a.name,a.clr_name,
HASHBYTES(''SHA2_512'', af.content)
FROM sys.assemblies a
JOIN sys.assembly_files af
ON a.assembly_id = af.assembly_id
WHERE a.is_user_defined =1
AND af.file_id=1;';


BEGIN TRY
EXEC (@SQL);
END TRY
BEGIN CATCH
PRINT 'Skipping ' + @DB + ' _ ' + ERROR_MESSAGE();
END CATCH

FETCH NEXT FROM db_cursor INTO @DB;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
SELECT
Databasename, Assemblyname, a.Description,
CASE 
WHEN ta.hash IS NULL THEN 'Would run:EXEC master.sys.sp_add_trusted_assembly for this assembly.'
ELSE
'No action required.'

END as Action
from #Assemblies a
LEFT JOIN master.sys.trusted_assemblies ta
ON a.hashvalue =ta.hash
ORDER BY Databasename, Assemblyname;


/*this will be added to the job to add  the assemblies */
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#Assemblies') IS NOT NuLL
DROP TABLE #Assemblies;

CREATE TABLE #Assemblies
(
DatabaseName sysname,
AssemblyName sysname,
Description nvarchar(4000),
Hashvalue varbinary(64)
);

DECLARE @DB sysname;
DECLARE @SQL nvarchar(MAX);

DECLARE db_cursor CURSOR FAST_FORWARD
FOR
SELECT name 
FROM sys.databases WHERE database_id > 4
AND state_desc= 'ONLINE';

OPEN db_cursor;

FETCH NEXT FROM db_cursor INTO @DB;
WHILE @@FETCH_STATUS =0
BEGIN

SET @SQL='
USE ' + QUOTENAME(@DB) + ';
INSERT INTO #Assemblies
SELECT 
DB_NAME(), a.name,a.clr_name,
HASHBYTES(''SHA2_512'', af.content)
FROM sys.assemblies a
JOIN sys.assembly_files af
ON a.assembly_id = af.assembly_id
WHERE a.is_user_defined =1
AND af.file_id=1;';


BEGIN TRY
EXEC (@SQL);
END TRY
BEGIN CATCH
PRINT 'Skipping ' + @DB + ' _ ' + ERROR_MESSAGE();
END CATCH

FETCH NEXT FROM db_cursor INTO @DB;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

DECLARE
@Hash varbinary(64),
@description nvarchar (4000),
@Assemblyname sysname,
@Databasename sysname;

DECLARE AssemblyCursor CURSOR FAST_FORWARD
FOR
SELECT DISTINCT
Hashvalue,
Description,
Assemblyname,
Databasename
FROM #Assemblies 
WHERE Hashvalue NOT IN
(
SELECT hash FROM master.sys.trusted_assemblies);
OPEN AssemblyCursor;
FETCH NEXT FROM AssemblyCursor
INTO @Hash, @Description, @AssemblyName, @DatabaseName;

WHILE @@FETCH_STATUS =0
BEGIN

PRINT  'Adding trust for assembly'
+ @Assemblyname + 'from database'
+@DatabaseName;

EXEC master.sys.sp_add_trusted_assembly 
@hash=@Hash,
@description=@Description;

FETCH NEXT FROM AssemblyCursor
into @hash, @Description, @AssemblyName, @Databasename;

END
CLOSE AssemblyCursor;
DEALLOCATE AssemblyCursor;

PRINT 'COMPLETED successfully'




