SELECT s.server_name, 
s.database_name, 
CASE s.[type] 
WHEN 'D' THEN 'Full'
WHEN 'I' THEN 'Differential'
WHEN 'F' THEN 'Filegroup'
WHEN 'L' THEN 'Transaction Log'
END as BackupType,  
CAST (DATEDIFF(second,s.backup_start_date , s.backup_finish_date)AS VARCHAR(max))+' '+'Seconds' TimeTaken,
s.backup_start_date, datepart(year,s.backup_start_date) as Year, datepart(MONTH,s.backup_start_date) as Month,datepart(DAY,s.backup_start_date) as Day,
s.recovery_model, 
convert(decimal(18, 2), s.backup_size / 1024 / 1024) as BackupSizeMB,
convert(decimal(18, 2), s.backup_size / 1024 / 1024 / 1024) as BackupSizeGB,
convert(decimal(18, 2), s.backup_size / 1024 / 1024 / 1024 / 1024) as BackupSizeTB,
s.type, 
s.backup_set_id, 
m.physical_device_name
FROM msdb.dbo.backupset s 
inner join msdb.dbo.backupmediafamily m
ON s.media_set_id = m.media_set_id
WHERE s.database_name = (SELECT DB_NAME()) and s.backup_start_date >= '2022-01-01 00:00:00.000'
ORDER BY backup_start_date desc