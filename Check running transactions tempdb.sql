use tempdb
go


--SELECT
--    SUM(user_object_reserved_page_count) * 8 / 1024 AS user_objects_mb,
--    SUM(internal_object_reserved_page_count) * 8 / 1024 AS internal_objects_mb,
--    SUM(version_store_reserved_page_count) * 8 / 1024 AS version_store_mb,
--    SUM(unallocated_extent_page_count) * 8 / 1024 AS free_space_mb
--FROM sys.dm_db_file_space_usage;

--transactions running in tempdb
--SELECT
--    s.session_id,
--    s.login_name,
--    s.host_name,
--    s.program_name,
--    t.transaction_id,
--    t.transaction_begin_time,
--    DATEDIFF(MINUTE, t.transaction_begin_time, GETDATE()) AS tran_minutes
--FROM sys.dm_tran_active_transactions t
--JOIN sys.dm_tran_session_transactions st
--    ON t.transaction_id = st.transaction_id
--JOIN sys.dm_exec_sessions s
--    ON st.session_id = s.session_id
--ORDER BY tran_minutes DESC;

--consuming most space in tempdb

--SELECT
--    s.session_id,
--    s.login_name,
--    s.host_name,
--    s.program_name,
--    su.user_objects_alloc_page_count * 8 / 1024 AS user_objects_mb,
--    su.internal_objects_alloc_page_count * 8 / 1024 AS internal_objects_mb
--FROM sys.dm_db_session_space_usage su
--JOIN sys.dm_exec_sessions s
--    ON su.session_id = s.session_id
--ORDER BY
--    (su.user_objects_alloc_page_count + su.internal_objects_alloc_page_count) DESC;


SELECT
    r.session_id,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.total_elapsed_time / 1000 AS elapsed_sec,
    r.reads,
    r.writes,
    r.logical_reads,
    SUBSTRING(t.text, r.statement_start_offset/2,
        (CASE WHEN r.statement_end_offset = -1
              THEN LEN(t.text)
              ELSE r.statement_end_offset END - r.statement_start_offset)/2) AS running_sql
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50
ORDER BY r.total_elapsed_time DESC;

SELECT
    r.session_id,
    r.status,
    r.command,
    r.wait_type,
    r.total_elapsed_time / 1000 AS elapsed_sec,
    SUBSTRING(t.text,
        r.statement_start_offset/2,
        (CASE WHEN r.statement_end_offset = -1
              THEN LEN(t.text)
              ELSE r.statement_end_offset END - r.statement_start_offset)/2
    ) AS running_sql
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id IN (
    SELECT st.session_id
    FROM sys.dm_tran_session_transactions st
);