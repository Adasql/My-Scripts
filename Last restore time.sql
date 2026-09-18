;WITH LatestRestore AS
(
   SELECT MAX(backup_set_id) AS backup_set_id, max(restore_date) as restore_date, destination_database_name 
   FROM msdb..restorehistory 
   GROUP BY  Destination_Database_Name
)
SELECT 
   lr.backup_set_id,
   lr.destination_database_name,
   rh.restore_date,
   bs.media_set_id,
   bmf.physical_device_name                AS source_backup_file_name,
   bs.backup_start_date                    AS source_backup_start_date,
   bs.backup_finish_date                   AS source_backup_finish_date,    
   bs.server_name                          AS source_backup_server_name,
   rh.user_name							   AS restoreuser
FROM LatestRestore lr
INNER JOIN msdb..restorehistory rh
   ON lr.backup_set_id = rh.backup_set_id 
   and lr.restore_date = rh.restore_date
INNER JOIN msdb..backupset bs
   ON lr.backup_set_id = bs.backup_set_id
INNER JOIN msdb..backupmediafamily bmf
   ON bs.media_set_id = bmf.media_set_id
ORDER BY rh.restore_date desc