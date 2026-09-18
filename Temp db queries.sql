
SELECT
s.session_id,
s.status,
s.login_name,
s.host_name,
s.program_name,
s.last_request_start_time,
s.last_request_end_time
FROM sys.dm_exec_sessions s
WHERE s.session_id = 63;

SELECT *
FROM sys.dm_exec_requests
WHERE session_id = 63;


SELECT
r.session_id,
t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id = 63;

SELECT
session_id,
blocking_session_id,
wait_type
FROM sys.dm_exec_requests
WHERE session_id = 63;

USE tempdb;

SELECT
SUM(unallocated_extent_page_count) * 8 / 1024 AS FreeSpaceMB
FROM sys.dm_db_file_space_usage;




SELECT
s.session_id,
s.status,
s.login_name,
s.host_name,
s.program_name,
s.last_request_start_time,
s.last_request_end_time
FROM sys.dm_exec_sessions s
WHERE s.session_id = 63;

SELECT *
FROM sys.dm_exec_requests
WHERE session_id = 63;


SELECT
r.session_id,
t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id = 63;

SELECT
session_id,
blocking_session_id,
wait_type
FROM sys.dm_exec_requests
WHERE session_id = 63;

USE tempdb;

SELECT
SUM(unallocated_extent_page_count) * 8 / 1024 AS FreeSpaceMB
FROM sys.dm_db_file_space_usage;


kill 63 with statusonly