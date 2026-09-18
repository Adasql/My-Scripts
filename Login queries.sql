
--Identify the login
select NAME, TYPE_DESC, DEFAULT_DATABASE_NAME
FROM sys.server_principals
where name ='xray_app'

--determine server permissions
select * from sys.server_permissions
WHERE grantee_principal_id =
(
SELECT principal_id
FROM sys.server_principals
WHERE name='xray_app')

--determine role memberships

SELECT r.name AS Rolename,
m.name as LoginName
from sys.server_role_members srm
JOIN sys.server_principals r
ON srm.role_principal_id = r.principal_id
JOIN sys.server_principals m
ON srm.member_principal_id = m.principal_id
WHERE m.name ='xray_app'

--script used to generate the login statement  with SID
SELECT 'CREATE LOGIN [' + name + ' ] ' + 
'WITH PASSWORD = ' +
CONVERT(VARCHAR(MAX), LOGINPROPERTY(name, 'PasswordHash'), 1) +
'HASHED, SID = ' +
CONVERT(VARCHAR(MAX), sid, 1) + ';'
AS Createloginstatement
FROM sys.sql_logins
WHERE name ='xray_app'
