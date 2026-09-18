use SICS_PROD

SELECT dp.name , dp.type_desc FROM sys.database_principals dp
WHERE dp.name ='HAMILTONBM\svc_hre_pbi_prd'

SELECT u.name as username, r.name as rolename FROM sys.database_role_members drm JOIN sys.database_principals r

on drm.role_principal_id =r.principal_id
JOIN sys.database_principals u
ON drm.member_principal_id = u.principal_id where u.name ='HAMILTONBM\svc_hre_pbi_prd'


EXECUTE AS USER ='HAMILTONBM\svc_hre_pbi_prd'
SELECT TOP (1) * FROM dbo.AttributeChar
REVERT
GO