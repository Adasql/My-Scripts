SELECT
    r.session_id,
    r.command,
    r.status,
    DB_NAME(r.database_id) AS DatabaseName,
    r.start_time,
    CAST(r.percent_complete AS DECIMAL(5,2)) AS PercentComplete,
    r.total_elapsed_time / 1000 / 60 AS ElapsedMinutes,
    r.estimated_completion_time / 1000 / 60 AS RemainingMinutes,
    DATEADD(ms, r.estimated_completion_time, GETDATE()) AS EstimatedCompletionTime,
    s.login_name,
    s.host_name
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
WHERE r.command LIKE 'BACKUP%'
   OR r.command LIKE 'RESTORE%'
ORDER BY r.percent_complete DESC;