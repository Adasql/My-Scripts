-- Good overview of AG health and status (Query 17) (AG Status)
SELECT ag.name AS [AG Name], ar.replica_server_name, ar.availability_mode_desc, adc.[database_name], 
       drs.is_local, drs.is_primary_replica, drs.synchronization_state_desc, drs.is_commit_participant, 
    drs.synchronization_health_desc, drs.recovery_lsn, drs.truncation_lsn, drs.last_sent_lsn, 
    drs.last_sent_time, drs.last_received_lsn, drs.last_received_time, drs.last_hardened_lsn, 
    drs.last_hardened_time, drs.last_redone_lsn, drs.last_redone_time, drs.log_send_queue_size, 
    drs.log_send_rate, drs.redo_queue_size, drs.redo_rate, drs.filestream_send_rate, 
    drs.end_of_log_lsn, drs.last_commit_lsn, drs.last_commit_time, drs.database_state_desc 
FROM sys.dm_hadr_database_replica_states AS drs WITH (NOLOCK)
INNER JOIN sys.availability_databases_cluster AS adc WITH (NOLOCK)
ON drs.group_id = adc.group_id 
AND drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag WITH (NOLOCK)
ON ag.group_id = drs.group_id
INNER JOIN sys.availability_replicas AS ar WITH (NOLOCK)
ON drs.group_id = ar.group_id 
AND drs.replica_id = ar.replica_id
ORDER BY ag.name, ar.replica_server_name, adc.[database_name] OPTION (RECOMPILE);


--check latency
WITH AG_Latency AS
(
    SELECT
        ag.name                          AS AGName,
        ar.replica_server_name           AS ReplicaServer,
        drs.database_id,
        DB_NAME(drs.database_id)         AS DBName,
        drs.is_primary_replica,
        drs.last_commit_time
    FROM sys.dm_hadr_database_replica_states drs
    JOIN sys.availability_replicas ar
        ON drs.replica_id = ar.replica_id
    JOIN sys.availability_groups ag
        ON ar.group_id = ag.group_id
)
SELECT
    p.ReplicaServer                    AS ServerName,
    p.ReplicaServer                    AS primary_replica,
    s.ReplicaServer                    AS secondary_replica,
    p.DBName,
    DATEDIFF(SECOND, s.last_commit_time, p.last_commit_time) AS Sync_Lag_Secs
FROM AG_Latency p
JOIN AG_Latency s
    ON p.database_id = s.database_id
WHERE
    p.is_primary_replica = 1
    AND s.is_primary_replica = 0
ORDER BY Sync_Lag_Secs DESC;



--show latency with redo size etc
WITH AG_Status AS
(
    SELECT
        ag.name AS AGName,
        ar.replica_server_name,
        drs.database_id,
        DB_NAME(drs.database_id) AS DBName,
        drs.is_primary_replica,
        drs.last_commit_time,
        drs.redo_queue_size, -- KB
        drs.redo_rate        -- KB/sec
    FROM sys.dm_hadr_database_replica_states drs
    JOIN sys.availability_replicas ar
        ON drs.replica_id = ar.replica_id
    JOIN sys.availability_groups ag
        ON ar.group_id = ag.group_id
)
SELECT
    p.replica_server_name                    AS primary_replica,
    s.replica_server_name                    AS secondary_replica,
    p.DBName,

    -- Commit latency
    DATEDIFF(SECOND, s.last_commit_time, p.last_commit_time) 
        AS Sync_Lag_Secs,

    -- Redo backlog
    CAST(s.redo_queue_size / 1024.0 AS DECIMAL(10,2)) 
        AS RedoQueue_MB,

    -- Redo speed
    CAST(s.redo_rate / 1024.0 AS DECIMAL(10,2)) 
        AS RedoRate_MB_per_sec,

    -- Estimated time to fully catch up
    CASE 
        WHEN s.redo_rate > 0 
        THEN CAST(s.redo_queue_size * 1.0 / s.redo_rate AS INT)
        ELSE NULL
    END AS Estimated_Catchup_Secs
FROM AG_Status p
JOIN AG_Status s
    ON p.database_id = s.database_id
WHERE
    p.is_primary_replica = 1
    AND s.is_primary_replica = 0
ORDER BY Sync_Lag_Secs DESC;