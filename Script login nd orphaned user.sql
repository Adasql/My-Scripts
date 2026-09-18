--script login from source

SELECT
    'CREATE LOGIN [' + sp.name + '] ' +
    CASE
        WHEN sp.type_desc = 'SQL_LOGIN'
        THEN 'WITH PASSWORD = 0x' +
             CONVERT(VARCHAR(MAX), sl.password_hash, 2) +
             ' HASHED, SID = 0x' +
             CONVERT(VARCHAR(MAX), sp.sid, 2) +
             ', CHECK_POLICY = OFF;'
        ELSE '-- Windows Login: [' + sp.name + ']'
    END AS CreateLoginScript
FROM sys.server_principals sp
LEFT JOIN sys.sql_logins sl
    ON sp.principal_id = sl.principal_id
WHERE sp.type IN ('S','U','G')
  AND sp.name NOT LIKE '##%';


  --user 
  USE _HamiltonReserving;
GO

SELECT
    'CREATE USER [' + dp.name + '] FOR LOGIN [' + sp.name + '];'
FROM sys.database_principals dp
JOIN sys.server_principals sp
    ON dp.sid = sp.sid
WHERE dp.type IN ('S','U','G')
  AND dp.principal_id > 4;

  --find orphaned user
  USE [_HamiltonReserving_Q2-2026Audit];
GO

SELECT dp.name
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp
    ON dp.sid = sp.sid
WHERE dp.type IN ('S','U','G')
  AND dp.principal_id > 4
  AND sp.sid IS NULL;