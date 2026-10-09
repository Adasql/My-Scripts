
/*AG Replica and Syn Health*/
SELECT
    ag.name                    AS AG_Name,
    ar.replica_server_name     AS Replica,
    ars.role_desc              AS Role,
    ars.connected_state_desc   AS ConnectionState,
    ars.synchronization_health_desc AS SyncHealth,
    ars.last_connect_error_description AS LastError
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar
    ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states ars
    ON ar.replica_id = ars.replica_id
ORDER BY ag.name, ar.replica_server_name;


/*Database‑level Synchronization Status*/
SELECT
    ag.name AS AG_Name,
    db.name AS DatabaseName,
    ar.replica_server_name AS Replica,
    drs.database_state_desc,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.log_send_queue_size,
    drs.redo_queue_size,
    drs.last_commit_time
FROM sys.dm_hadr_database_replica_states drs
JOIN sys.availability_replicas ar
    ON drs.replica_id = ar.replica_id
JOIN sys.availability_groups ag
    ON ar.group_id = ag.group_id
JOIN sys.databases db
    ON drs.database_id = db.database_id
ORDER BY ag.name, db.name, ar.replica_server_name;

/*Primary vs Secondary & Failover Readiness*/
SELECT
    ag.name AS AG_Name,
    ar.replica_server_name,
    ar.availability_mode_desc,
    ar.failover_mode_desc,
    ars.role_desc
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar
    ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states ars
    ON ar.replica_id = ars.replica_id
ORDER BY ag.name, ars.role_desc DESC;


/*summary*/
SELECT
    ag.name AS AG_Name,
    CASE 
        WHEN ars.synchronization_health_desc <> 'HEALTHY'
             OR ars.connected_state_desc <> 'CONNECTED'
        THEN 'RED'
        ELSE 'GREEN'
    END AS AG_Health
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar
    ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states ars
    ON ar.replica_id = ars.replica_id
GROUP BY ag.name, ars.synchronization_health_desc, ars.connected_state_desc;