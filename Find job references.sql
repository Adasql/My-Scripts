DECLARE @DatabaseName sysname = N'Supporttool16';

SELECT
    j.name                AS JobName,
    j.enabled             AS JobEnabled,
    js.step_id            AS StepID,
    js.step_name          AS StepName,
    js.subsystem          AS Subsystem,
    js.database_name      AS StepDatabaseContext,
    js.command            AS CommandText
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps js
    ON j.job_id = js.job_id

WHERE
      js.command LIKE '%' + @DatabaseName + '%'
   OR js.database_name = @DatabaseName
AND j.enabled = 1
ORDER BY j.name, js.step_id

--WHERE
--    js.command LIKE '%[' + @DatabaseName + ']%'
-- OR js.command LIKE '%USE ' + @DatabaseName + '%'
-- OR js.database_name = @DatabaseName
