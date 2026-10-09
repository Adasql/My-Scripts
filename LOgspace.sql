DBCC SQLPERF(LOGSPACE);

SELECT
    name,
    log_reuse_wait_desc
FROM sys.databases;



SELECT
    name,
    size * 8 / 1024 AS size_mb,
    FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024 AS used_mb
FROM sys.database_files
WHERE type_desc = 'LOG';



SELECT
    name AS database_name,
    log_reuse_wait_desc
FROM sys.databases;


SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    at.transaction_id,
    at.transaction_begin_time,
    DATEDIFF(MINUTE, at.transaction_begin_time, GETDATE()) AS tran_minutes,
    s.status
FROM sys.dm_tran_active_transactions at
JOIN sys.dm_tran_session_transactions st
    ON at.transaction_id = st.transaction_id
JOIN sys.dm_exec_sessions s
    ON st.session_id = s.session_id
ORDER BY tran_minutes DESC;