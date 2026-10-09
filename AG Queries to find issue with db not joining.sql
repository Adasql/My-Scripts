
--status of databases in the AG
SELECT
    ar.replica_server_name,
    DB_NAME(drs.database_id) AS DatabaseName,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.is_suspended,
    drs.suspend_reason_desc,
    drs.log_send_queue_size,
    drs.redo_queue_size
FROM sys.dm_hadr_database_replica_states drs
JOIN sys.availability_replicas ar
    ON drs.replica_id = ar.replica_id
ORDER BY DatabaseName;

--CHECK STATE 
SELECT
    DB_NAME(database_id) AS DatabaseName,
    state_desc,
    user_access_desc,
    recovery_model_desc
FROM sys.databases
WHERE name = 'Reporting';

--check percent 
SELECT
    command,
    percent_complete,
    estimated_completion_time / 1000 / 60 AS ETA_Minutes,
    start_time,
    status
FROM sys.dm_exec_requests
WHERE command IN ('DB STARTUP','RESTORE DATABASE','RESTORE LOG','RECOVERY DATABASE');

SELECT
    session_id,
    command,
    percent_complete,
    estimated_completion_time/1000/60 AS ETA_Minutes,
    wait_type
FROM sys.dm_exec_requests
WHERE command IN
(
    'DB STARTUP',
    'RECOVERY DATABASE',
    'RESTORE DATABASE',
    'RESTORE LOG'
);

SELECT
    r.session_id,
    r.command,
    r.status,
    r.percent_complete,
    r.wait_type,
    r.wait_time,
    DB_NAME(r.database_id) AS DatabaseName
FROM sys.dm_exec_requests r
WHERE r.database_id = DB_ID('Reporting');

SELECT
    DB_NAME(database_id) AS DatabaseName,
    synchronization_state_desc,
    synchronization_health_desc,
    is_suspended,
    suspend_reason_desc
FROM sys.dm_hadr_database_replica_states
WHERE database_id = DB_ID('Reporting');


SELECT name,state_desc FROM sys.databases WHERE name = 'Reporting';

SELECT * 
FROM sys.dm_hadr_database_replica_states
WHERE database_id = DB_ID('Reporting');

--Monitor
SELECT
    session_id,
    command,
    percent_complete,
    estimated_completion_time/1000/60 AS ETA_Minutes,
    wait_type
FROM sys.dm_exec_requests
WHERE session_id IN (40,41);

--More monitoring
SELECT
    session_id,
    command,
    percent_complete
FROM sys.dm_exec_requests
WHERE command = 'DB STARTUP';


SELECT
    session_id,
    command,
    percent_complete,
    estimated_completion_time / 1000 / 60 AS ETA_Minutes,
    wait_type,
    wait_time,
    cpu_time,
    reads,
    writes
FROM sys.dm_exec_requests
WHERE session_id = 121;

