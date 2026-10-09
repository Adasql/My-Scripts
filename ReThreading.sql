--DBCC TRACEON(3459, -1)
SELECT 'Alter Database ' + QUOTENAME(name) + ' SET HADR SUSPEND;',
       'Alter Database ' + QUOTENAME(name) + ' SET HADR Resume;',
       'Use ' + QUOTENAME(name)
       + '
       CREATE TABLE dmr_test(f1 CHAR(1))
INSERT dbo.dmr_test (   f1) VALUES(''a''    )
DROP TABLE dmr_test',
       num_parallel_redo_threads
FROM sys.dm_hadr_db_threads
ORDER BY num_parallel_redo_threads DESC;

--DBCC TRACEOFF(3459, -1)

