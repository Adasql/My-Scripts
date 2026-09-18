
/*i tried to use the env endpoint for this but didnt work and it ended up creating the view definition with _prd so i am manually running it */


--Query to grant view definition database level
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL += '
USE ' + QUOTENAME(name) + ';
IF EXISTS (SELECT 1
           FROM sys.database_principals
           WHERE name = ''svc_ataccama_pre'') 
BEGIN
    GRANT VIEW DEFINITION TO [svc_ataccama_pre];
END;
'
FROM sys.databases
WHERE database_id > 4
  AND state_desc = 'ONLINE';

EXEC(@SQL);

--query to verify if the access was granted, per db
  SELECT dp.name as username, perm.permission_name, perm.state_desc FROM sys.database_permissions perm JOIN sys.database_principals dp
  ON perm.grantee_principal_id = dp.principal_id

WHERE dp.name = 'svc_ataccama_pre' AND perm.permission_name ='VIEW DEFINITION'

--query for all dbs

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL += '
USE ' + QUOTENAME(name) + ';

IF EXISTS
(
SELECT 1
FROM sys.database_principals
WHERE name = ''svc_ataccama_pre''
)
BEGIN
SELECT
DB_NAME() AS DatabaseName,
dp.name AS UserName,
perm.permission_name,
perm.state_desc
FROM sys.database_permissions perm
JOIN sys.database_principals dp
ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name = ''svc_ataccama_pre''
AND perm.permission_name = ''VIEW DEFINITION'';
END;
'
FROM sys.databases
WHERE database_id > 4
AND state_desc = 'ONLINE';

EXEC(@SQL);


--revoke
--revoke
USE InformData_Group;
GO

REVOKE VIEW DEFINITION TO [svc_ataccama_pre];
GO
