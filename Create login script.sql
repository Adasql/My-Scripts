SELECT
    'CREATE LOGIN ' + QUOTENAME(name) +
    ' WITH PASSWORD = ' +
    CONVERT(VARCHAR(MAX), LOGINPROPERTY(name, 'PasswordHash'), 1) +
    ' HASHED, SID = ' +
    CONVERT(VARCHAR(MAX), sid, 1) +
    ', CHECK_POLICY = ' +
    CASE WHEN is_policy_checked = 1 THEN 'ON' ELSE 'OFF' END +
    ', CHECK_EXPIRATION = ' +
    CASE WHEN is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END +
    ';' AS CreateLoginStatement
FROM sys.sql_logins
WHERE name = N'svc_ataccama_stg';