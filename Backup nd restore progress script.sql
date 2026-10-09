SELECT
    r.session_id,
    r.command,
    DB_NAME(r.database_id) AS DatabaseName,
    r.start_time,

    r.percent_complete,

    DATEADD(second,
        r.estimated_completion_time / 1000,
        GETDATE()) AS EstimatedCompletionTime,

    r.total_elapsed_time / 1000 AS ElapsedSeconds,
    r.estimated_completion_time / 1000 AS RemainingSeconds,

    CAST(r.total_elapsed_time / 60000.0 AS DECIMAL(10,2)) AS ElapsedMinutes,
    CAST(r.estimated_completion_time / 60000.0 AS DECIMAL(10,2)) AS RemainingMinutes,

    r.wait_type,
    r.wait_time,
    r.last_wait_type
FROM sys.dm_exec_requests r
WHERE r.command IN
(
    'BACKUP DATABASE',
    'BACKUP LOG',
    'RESTORE DATABASE',
    'RESTORE LOG',
    'RESTORE FILELISTONLY'
)
ORDER BY r.start_time;
