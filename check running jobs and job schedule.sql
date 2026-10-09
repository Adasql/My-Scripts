/*check running jobs*/

USE msdb;
GO

/* SQL Server Agent service status */
SELECT
    servicename,
    startup_type_desc,
    status_desc,
    last_startup_time,
    service_account
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server Agent%';
GO

/* Currently running SQL Agent jobs */
DECLARE @CurrentAgentSessionID INT =
(
    SELECT MAX(session_id)
    FROM msdb.dbo.syssessions
);

SELECT
    j.name AS JobName,
    SUSER_SNAME(j.owner_sid) AS JobOwner,
    ja.start_execution_date AS StartTime,
    DATEDIFF(MINUTE, ja.start_execution_date, GETDATE()) AS RunningMinutes,
    ISNULL(js.step_name, 'Unknown') AS CurrentStep,
    ja.last_executed_step_id AS LastCompletedStepID,
    j.enabled AS JobEnabled
FROM msdb.dbo.sysjobactivity AS ja
INNER JOIN msdb.dbo.sysjobs AS j
    ON ja.job_id = j.job_id
LEFT JOIN msdb.dbo.sysjobsteps AS js
    ON ja.job_id = js.job_id
   AND ja.last_executed_step_id + 1 = js.step_id
WHERE ja.session_id = @CurrentAgentSessionID
  AND ja.start_execution_date IS NOT NULL
  AND ja.stop_execution_date IS NULL
ORDER BY ja.start_execution_date;
GO

/*job schedule*/
USE msdb;
GO

SELECT
    j.name AS JobName,
    CASE j.enabled
        WHEN 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS JobStatus,
    SUSER_SNAME(j.owner_sid) AS JobOwner,
    c.name AS JobCategory,
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
    s.freq_interval AS FrequencyInterval,
    s.freq_subday_interval AS SubdayInterval,
    CASE s.freq_subday_type
        WHEN 1 THEN 'At Specified Time'
        WHEN 2 THEN 'Seconds'
        WHEN 4 THEN 'Minutes'
        WHEN 8 THEN 'Hours'
        ELSE 'N/A'
    END AS SubdayType,
    CASE
        WHEN s.active_start_date IS NULL OR s.active_start_date = 0
            THEN NULL
        ELSE CONVERT(date, CONVERT(char(8), s.active_start_date))
    END AS ScheduleStartDate,
    CASE
        WHEN s.active_start_time IS NULL
            THEN NULL
        ELSE STUFF(
                STUFF(
                    RIGHT('000000' + CAST(s.active_start_time AS varchar(6)), 6),
                    3, 0, ':'
                ),
                6, 0, ':'
             )
    END AS ScheduleStartTime,
    CASE
        WHEN js.next_run_date > 0
            THEN msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time)
        ELSE NULL
    END AS NextScheduledRun
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.syscategories AS c
    ON j.category_id = c.category_id
LEFT JOIN msdb.dbo.sysjobschedules AS js
    ON j.job_id = js.job_id
LEFT JOIN msdb.dbo.sysschedules AS s
    ON js.schedule_id = s.schedule_id
ORDER BY j.name, s.name;
GO