

--matching job nd step name
SELECT
    j.name AS job_name,
    js.step_id,
    js.step_name,
    sch.name AS schedule_name,
    sch.enabled,
    sch.freq_type,
    sch.freq_interval,
    sch.freq_subday_type,
    sch.freq_subday_interval
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps js
    ON j.job_id = js.job_id
LEFT JOIN msdb.dbo.sysjobschedules jsch
    ON j.job_id = jsch.job_id
LEFT JOIN msdb.dbo.sysschedules sch
    ON jsch.schedule_id = sch.schedule_id
WHERE 
    j.name LIKE '%' + js.step_name + '%'
    OR js.step_name LIKE '%' + j.name + '%';

	--job name similar to step name

	SELECT
    j.job_id,
    j.name       AS job_name,
    js.step_id,
    js.step_name
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps js
    ON j.job_id = js.job_id
WHERE j.name = js.step_name;


--with schedule
SELECT
    j.name AS job_name,
    js.step_id,
    js.step_name,
    sch.name AS schedule_name,
    sch.enabled,
    sch.freq_type,
    sch.freq_interval,
    sch.freq_subday_type,
    sch.freq_subday_interval
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps js
    ON j.job_id = js.job_id
LEFT JOIN msdb.dbo.sysjobschedules jsch
    ON j.job_id = jsch.job_id
LEFT JOIN msdb.dbo.sysschedules sch
    ON jsch.schedule_id = sch.schedule_id
WHERE 
    j.name LIKE '%' + js.step_name + '%'
    OR js.step_name LIKE '%' + j.name + '%';