USE DbMonitor
SELECT 
OBJECT_SCHEMA_NAME(object_id) AS Schemaname, name, type_desc FROM sys.objects WHERE name='spA_ReportIdentityValues'

select dp.name, dp.type_desc, dp.authentication_type_desc FROM sys.database_principals dp WHERE dp.name LIKE '%sadvcinjamsejs%'

SELECT USER_NAME(dp.grantee_principal_id) AS Grantee,
OBJECT_SCHEMA_NAME(dp.major_id) AS Schemaname, OBJECT_NAME(dp.major_id) AS ObjectName, 
dp.permission_name, dp.state_desc
FROM sys.database_permissions dp
where OBJECT_NAME(dp.major_id) ='spA_ReportIdentityValues'

EXECUTE AS USER ='zcloud\sadvcinjamsejs'

SELECT 
USER_NAME() AS Databaseuser,
HAS_PERMS_BY_NAME(
'dbo.spA_ReportIdentityValues',
'OBJECT',
'EXECUTE')
AS Hasexecutepermission;
REVERT;
GO



EXECUTE AS USER ='zcloud\sadvcinjamsejs'

EXEC [dbo].[spA_ReportIdentityValues];
REVERT;
GO