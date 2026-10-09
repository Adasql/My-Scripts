USE AHC_BillEditorI8;
GO

SELECT 
    dp.name AS Principal,
    dp.type_desc,
    perm.permission_name,
    perm.state_desc,
    OBJECT_NAME(perm.major_id) AS ObjectName
FROM sys.database_permissions perm
JOIN sys.database_principals dp 
    ON perm.grantee_principal_id = dp.principal_id
WHERE OBJECT_NAME(perm.major_id) = 'Rules';


USE AHC_BillEditorI8;
GO

GRANT SELECT ON SCHEMA::Rules TO [ZCLOUD\sacinpipefinalizer];


---alter db_chaining
SELECT is_db_chaining_on, name FROM sys.databases
WHERE name LIKE '%KeckMedicine%'

alter database AHC_KeckMedicineUSCUAH_RAW set db_chaining on;

--find users with permission
SELECT
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    perm.permission_name,
    perm.state_desc AS PermissionState,
    s.name AS SchemaName
FROM sys.database_permissions perm
JOIN sys.database_principals dp
    ON perm.grantee_principal_id = dp.principal_id
JOIN sys.schemas s
    ON perm.major_id = s.schema_id
WHERE perm.class_desc = 'SCHEMA'
  AND s.name = 'Rules'
ORDER BY dp.name;

--who can select
SELECT
    dp.name,
    perm.permission_name,
    perm.state_desc
FROM sys.database_permissions perm
JOIN sys.database_principals dp
    ON perm.grantee_principal_id = dp.principal_id
WHERE perm.major_id = SCHEMA_ID('Rules')
  AND perm.permission_name = 'SELECT';


  --script out role membership
SELECT
    'EXEC sp_addrolemember ''' + r.name + ''', ''' + m.name + ''''
FROM sys.database_role_members rm
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id;


