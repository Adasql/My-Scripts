DECLARE @DBName sysname;
DECLARE @SQL nvarchar(max);

DECLARE db_cursor CURSOR FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE database_id > 4
AND state_desc = 'ONLINE';

OPEN db_cursor;

FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL =
        'BACKUP DATABASE [' + @DBName + ']
         TO DISK = ''R:\MSSQL\Backup\' + @DBName + '.bak''
         WITH COPY_ONLY, INIT, STATS = 10';

    PRINT @SQL;
    EXEC (@SQL);

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;