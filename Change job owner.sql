--find job owner
select j.name, SUSER_SNAME(j.owner_sid) AS Jobowner
FROM msdb.dbo.sysjobs AS j
WHERE j.name LIKE 'DBA - %'
ORDER BY j.name

--update job owner
EXEC msdb.dbo.sp_update_job
@job_name = N'DBA - Alert For Expired Non-Prod Databases', --change job name
@owner_login_name =N'tfadmin';


--change all job owners except system jobs
DECLARE @JobName SYSNAME;

DECLARE JobCursor CURSOR FAST_FORWARD
FOR
SELECT name
FROM msdb.dbo.sysjobs
WHERE name NOT LIKE 'syspolicy_%';

OPEN JobCursor;

FETCH NEXT FROM JobCursor INTO @JobName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_update_job
        @job_name = @JobName,
        @owner_login_name = N'tfadmin';

    FETCH NEXT FROM JobCursor INTO @JobName;
END

CLOSE JobCursor;
DEALLOCATE JobCursor;