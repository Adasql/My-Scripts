USE msdb;
GO

SET NOCOUNT ON;

DECLARE @CurrentAgentSessionID int;
DECLARE @RunningJobCount int;

SELECT @CurrentAgentSessionID = MAX(session_id)
FROM msdb.dbo.syssessions;

SELECT @RunningJobCount = COUNT(*)
FROM msdb.dbo.sysjobactivity AS ja
WHERE ja.session_id = @CurrentAgentSessionID
  AND ja.start_execution_date IS NOT NULL
  AND ja.stop_execution_date IS NULL;

PRINT '============================================================';
PRINT 'PRE-DR SQL AGENT JOB CHECK';
PRINT 'Server: ' + CONVERT(varchar(128), SERVERPROPERTY('ServerName'));
PRINT 'Generated: ' + CONVERT(varchar(30), GETDATE(), 120);
PRINT '============================================================';
PRINT '';

IF @RunningJobCount > 0
BEGIN
    PRINT 'WARNING: SQL AGENT JOBS ARE CURRENTLY RUNNING.';
    PRINT 'Disable commands were not generated.';
    PRINT 'Review the running jobs before proceeding.';
    PRINT '';

    SELECT
        j.name AS RunningJobName,
        ja.start_execution_date AS StartTime,
        DATEDIFF
        (
            MINUTE,
            ja.start_execution_date,
            GETDATE()
        ) AS RunningMinutes,
        ISNULL(js.step_name, 'Unable to determine') AS CurrentStep,
        ja.last_executed_step_id AS LastCompletedStepID,
        SUSER_SNAME(j.owner_sid) AS JobOwner
    FROM msdb.dbo.sysjobactivity AS ja
    INNER JOIN msdb.dbo.sysjobs AS j
        ON ja.job_id = j.job_id
    LEFT JOIN msdb.dbo.sysjobsteps AS js
        ON ja.job_id = js.job_id
       AND js.step_id = ja.last_executed_step_id + 1
    WHERE ja.session_id = @CurrentAgentSessionID
      AND ja.start_execution_date IS NOT NULL
      AND ja.stop_execution_date IS NULL
    ORDER BY ja.start_execution_date;

    RETURN;
END;

PRINT 'No SQL Agent jobs are currently running.';
PRINT 'Save both the disable and enable commands before proceeding.';
PRINT '';

SELECT
    j.name AS JobName,

    'EXEC msdb.dbo.sp_update_job ' +
    '@job_name = N''' +
    REPLACE(j.name, '''', '''''') +
    ''', @enabled = 0;'
        AS [Pre-DR Disable Command],

    'EXEC msdb.dbo.sp_update_job ' +
    '@job_name = N''' +
    REPLACE(j.name, '''', '''''') +
    ''', @enabled = 1;'
        AS [Post-DR Enable Command]

FROM msdb.dbo.sysjobs AS j
WHERE j.enabled = 1
ORDER BY j.name;
GO


/*post dr verification script*- use only if needed cause the first script still generates enable script, 
also only do this if the job schedules show it will run during the dr test period
USE msdb;
GO

SET NOCOUNT ON;

PRINT '============================================================';
PRINT 'POST-DR SQL AGENT VERIFICATION';
PRINT 'Server: ' + CONVERT(varchar(128), SERVERPROPERTY('ServerName'));
PRINT 'Verification time: ' + CONVERT(varchar(30), GETDATE(), 120);
PRINT '============================================================';
PRINT '';

/* 1. SQL Server Agent service status */
SELECT
    servicename AS ServiceName,
    status_desc AS CurrentStatus,
    startup_type_desc AS StartupType,
    last_startup_time AS LastStartupTime,
    service_account AS ServiceAccount
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server Agent%';

/* 2. Currently running jobs */
DECLARE @CurrentAgentSessionID int;

SELECT @CurrentAgentSessionID = MAX(session_id)
FROM msdb.dbo.syssessions;

SELECT
    j.name AS RunningJobName,
    ja.start_execution_date AS StartTime,
    DATEDIFF
    (
        MINUTE,
        ja.start_execution_date,
        GETDATE()
    ) AS RunningMinutes,
    ISNULL(js.step_name, 'Unable to determine') AS CurrentStep
FROM msdb.dbo.sysjobactivity AS ja
INNER JOIN msdb.dbo.sysjobs AS j
    ON ja.job_id = j.job_id
LEFT JOIN msdb.dbo.sysjobsteps AS js
    ON ja.job_id = js.job_id
   AND js.step_id = ja.last_executed_step_id + 1
WHERE ja.session_id = @CurrentAgentSessionID
  AND ja.start_execution_date IS NOT NULL
  AND ja.stop_execution_date IS NULL
ORDER BY ja.start_execution_date;

/* 3. Current enabled/disabled job status */
SELECT
    j.name AS JobName,
    CASE j.enabled
        WHEN 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS JobStatus,
    SUSER_SNAME(j.owner_sid) AS JobOwner,
    c.name AS JobCategory
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.syscategories AS c
    ON j.category_id = c.category_id
ORDER BY j.enabled DESC, j.name;

/* 4. Job schedules and next scheduled run */
SELECT
    j.name AS JobName,
    CASE j.enabled
        WHEN 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS JobStatus,
    ISNULL(s.name, 'No Schedule') AS ScheduleName,
    CASE
        WHEN s.schedule_id IS NULL THEN 'Not Scheduled'
        WHEN s.enabled = 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS ScheduleStatus,
    CASE s.freq_type
        WHEN 1   THEN 'One Time'
        WHEN 4   THEN 'Daily'
        WHEN 8   THEN 'Weekly'
        WHEN 16  THEN 'Monthly'
        WHEN 32  THEN 'Monthly Relative'
        WHEN 64  THEN 'When SQL Agent Starts'
        WHEN 128 THEN 'When Computer Is Idle'
        ELSE 'Not Scheduled'
    END AS FrequencyType,
    CASE
        WHEN js.next_run_date > 0
            THEN msdb.dbo.agent_datetime
                 (
                     js.next_run_date,
                     js.next_run_time
                 )
        ELSE NULL
    END AS NextScheduledRun
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.sysjobschedules AS js
    ON j.job_id = js.job_id
LEFT JOIN msdb.dbo.sysschedules AS s
    ON js.schedule_id = s.schedule_id
ORDER BY j.name, s.name;

/* 5. Recent job failures during the last 24 hours */
SELECT
    j.name AS JobName,
    msdb.dbo.agent_datetime
    (
        h.run_date,
        h.run_time
    ) AS ExecutionDate,
    h.step_id AS StepID,
    h.step_name AS StepName,
    h.message AS FailureMessage
FROM msdb.dbo.sysjobhistory AS h
INNER JOIN msdb.dbo.sysjobs AS j
    ON h.job_id = j.job_id
WHERE h.run_status = 0
  AND msdb.dbo.agent_datetime
      (
          h.run_date,
          h.run_time
      ) >= DATEADD(HOUR, -24, GETDATE())
ORDER BY ExecutionDate DESC;
GO
*/