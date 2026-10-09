Alter database remitdata_ods_2026 MODIFY FILE (NAME='remitdata_ods_2022' , FILEGROWTH=64MB);
Alter database remitdata_ods_2026 MODIFY FILE (NAME='remitdata_ods_20223' , FILEGROWTH=64MB);


exec xp_fixeddrives


select name, physical_name, size/128.0 as size_mb
from remitdata_ods_2026.sys.database_files order by size desc