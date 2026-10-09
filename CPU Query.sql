/*==============================================================
  SQL SERVER CPU / MEMORY CAPACITY CHECK
  Run during the reported high-CPU period.
==============================================================*/

SET NOCOUNT ON;

PRINT '======================================================';
PRINT '1. SERVER CPU AND MEMORY CONFIGURATION';
PRINT '======================================================';

SELECT
    @@SERVERNAME AS ServerName,
    osi.cpu_count AS LogicalCPUCount,
    osi.scheduler_count AS SchedulerCount,
    osi.socket_count AS SocketCount,
    osi.cores_per_socket AS CoresPerSocket,
    osi.numa_node_count AS NUMANodeCount,
    osi.hyperthread_ratio AS HyperthreadRatio,
    CAST(osi.physical_memory_kb / 1024.0 / 1024 AS DECIMAL(10,2))
        AS PhysicalMemoryGB,
    osi.sqlserver_start_time AS SQLServerStartTime
FROM sys.dm_os_sys_info AS osi;


PRINT '======================================================';
PRINT '2. SQL SERVER CPU VS OTHER PROCESSES';
PRINT '======================================================';

DECLARE @ts_now BIGINT =
(
    SELECT cpu_ticks / (cpu_ticks / ms_ticks)
    FROM sys.dm_os_sys_info
);

SELECT TOP (60)
    DATEADD
    (
        ms,
        -1 * (@ts_now - rb.timestamp),
        GETDATE()
    ) AS EventTime,
    x.value
    (
        '(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',
        'INT'
    ) AS SQLServerCPUPercent,
    x.value
    (
        '(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]',
        'INT'
    ) AS SystemIdlePercent,
    100
      - x.value
        (
            '(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]',
            'INT'
        )
      - x.value
        (
            '(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',
            'INT'
        ) AS OtherProcessCPUPercent
FROM sys.dm_os_ring_buffers AS rb
CROSS APPLY
(
    SELECT CONVERT(XML, rb.record)
) AS ca(x)
WHERE rb.ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
  AND rb.record LIKE '%<SystemHealth>%'
ORDER BY EventTime DESC;


PRINT '======================================================';
PRINT '3. CURRENT SCHEDULER PRESSURE';
PRINT '======================================================';

SELECT
    scheduler_id,
    cpu_id,
    parent_node_id AS NUMANode,
    current_tasks_count,
    runnable_tasks_count,
    current_workers_count,
    active_workers_count,
    work_queue_count,
    pending_disk_io_count,
    load_factor
FROM sys.dm_os_schedulers
WHERE status = N'VISIBLE ONLINE'
ORDER BY runnable_tasks_count DESC, scheduler_id;


PRINT '======================================================';
PRINT '4. SUMMARY OF RUNNABLE TASKS';
PRINT '======================================================';

SELECT
    SUM(runnable_tasks_count) AS TotalRunnableTasks,
    MAX(runnable_tasks_count) AS HighestQueueOnOneScheduler,
    SUM(current_tasks_count) AS TotalCurrentTasks,
    SUM(active_workers_count) AS TotalActiveWorkers,
    COUNT(*) AS OnlineSchedulers
FROM sys.dm_os_schedulers
WHERE status = N'VISIBLE ONLINE';


PRINT '======================================================';
PRINT '5. SIGNAL WAIT PERCENTAGE';
PRINT '======================================================';

SELECT
    CAST(SUM(signal_wait_time_ms) / 1000.0 AS DECIMAL(18,2))
        AS SignalWaitSeconds,
    CAST(SUM(wait_time_ms) / 1000.0 AS DECIMAL(18,2))
        AS TotalWaitSeconds,
    CAST
    (
        100.0 * SUM(signal_wait_time_ms) /
        NULLIF(SUM(wait_time_ms), 0)
        AS DECIMAL(10,2)
    ) AS SignalWaitPercent
FROM sys.dm_os_wait_stats;


PRINT '======================================================';
PRINT '6. RELEVANT CPU AND WORKER WAITS';
PRINT '======================================================';

SELECT
    wait_type,
    waiting_tasks_count,
    CAST(wait_time_ms / 1000.0 AS DECIMAL(18,2)) AS WaitSeconds,
    CAST(signal_wait_time_ms / 1000.0 AS DECIMAL(18,2))
        AS SignalWaitSeconds
FROM sys.dm_os_wait_stats
WHERE wait_type IN
(
    N'SOS_SCHEDULER_YIELD',
    N'THREADPOOL',
    N'CXPACKET',
    N'CXCONSUMER',
    N'RESOURCE_SEMAPHORE',
    N'RESOURCE_SEMAPHORE_QUERY_COMPILE'
)
ORDER BY wait_time_ms DESC;


PRINT '======================================================';
PRINT '7. TOP CUMULATIVE CPU-CONSUMING STATEMENTS';
PRINT '======================================================';

SELECT TOP (20)
    DB_NAME(txt.dbid) AS DatabaseName,
    qs.execution_count,
    CAST(qs.total_worker_time / 1000.0 AS DECIMAL(18,2))
        AS TotalCPUms,
    CAST
    (
        qs.total_worker_time /
        NULLIF(qs.execution_count, 0) / 1000.0
        AS DECIMAL(18,2)
    ) AS AverageCPUms,
    CAST(qs.total_elapsed_time / 1000.0 AS DECIMAL(18,2))
        AS TotalElapsedms,
    qs.last_execution_time,
    SUBSTRING
    (
        txt.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(txt.text)
                    ELSE qs.statement_end_offset
                END
                - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS StatementText,
    qp.query_plan AS QueryPlan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS txt
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY qs.total_worker_time DESC;


PRINT '======================================================';
PRINT '8. REQUESTS USING CPU RIGHT NOW';
PRINT '======================================================';

SELECT
    r.session_id,
    r.status,
    DB_NAME(r.database_id) AS DatabaseName,
    r.command,
    r.cpu_time AS CPUTimeMs,
    r.total_elapsed_time AS ElapsedTimeMs,
    r.logical_reads,
    r.reads,
    r.writes,
    r.wait_type,
    r.wait_time AS CurrentWaitMs,
    r.blocking_session_id,
    r.dop,
    s.host_name,
    s.program_name,
    s.login_name,
    SUBSTRING
    (
        txt.text,
        (r.statement_start_offset / 2) + 1,
        (
            (
                CASE r.statement_end_offset
                    WHEN -1 THEN DATALENGTH(txt.text)
                    ELSE r.statement_end_offset
                END
                - r.statement_start_offset
            ) / 2
        ) + 1
    ) AS CurrentStatement
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS txt
WHERE r.session_id <> @@SPID
ORDER BY r.cpu_time DESC;


PRINT '======================================================';
PRINT '9. SQL SERVER MEMORY CONFIGURATION';
PRINT '======================================================';

SELECT
    name,
    value,
    value_in_use,
    description
FROM sys.configurations
WHERE name IN
(
    N'max server memory (MB)',
    N'min server memory (MB)',
    N'max degree of parallelism',
    N'cost threshold for parallelism'
);


PRINT '======================================================';
PRINT '10. OPERATING SYSTEM MEMORY STATUS';
PRINT '======================================================';

SELECT
    CAST(total_physical_memory_kb / 1024.0 AS DECIMAL(18,2))
        AS TotalPhysicalMemoryMB,
    CAST(available_physical_memory_kb / 1024.0 AS DECIMAL(18,2))
        AS AvailablePhysicalMemoryMB,
    CAST(total_page_file_kb / 1024.0 AS DECIMAL(18,2))
        AS TotalPageFileMB,
    CAST(available_page_file_kb / 1024.0 AS DECIMAL(18,2))
        AS AvailablePageFileMB,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;


PRINT '======================================================';
PRINT '11. SQL SERVER PROCESS MEMORY STATUS';
PRINT '======================================================';

SELECT
    CAST(physical_memory_in_use_kb / 1024.0 AS DECIMAL(18,2))
        AS SQLPhysicalMemoryUsedMB,
    CAST(large_page_allocations_kb / 1024.0 AS DECIMAL(18,2))
        AS LargePageAllocationsMB,
    CAST(locked_page_allocations_kb / 1024.0 AS DECIMAL(18,2))
        AS LockedPagesMB,
    memory_utilization_percentage,
    available_commit_limit_kb / 1024 AS AvailableCommitLimitMB,
    process_physical_memory_low,
    process_virtual_memory_low
FROM sys.dm_os_process_memory;


PRINT '======================================================';
PRINT '12. MEMORY GRANTS';
PRINT '======================================================';

SELECT
    cntr_value AS MemoryGrantsPending
FROM sys.dm_os_performance_counters
WHERE object_name LIKE N'%Memory Manager%'
  AND counter_name = N'Memory Grants Pending';


PRINT '======================================================';
PRINT '13. PAGE LIFE EXPECTANCY BY NUMA NODE';
PRINT '======================================================';

SELECT
    instance_name AS NUMANode,
    cntr_value AS PageLifeExpectancySeconds
FROM sys.dm_os_performance_counters
WHERE object_name LIKE N'%Buffer Node%'
  AND counter_name = N'Page life expectancy'
ORDER BY instance_name;