--This took 9 hours to run
USE General
CREATE TABLE #MasterList
    (
        DatabaseName             sysname NULL
      , ObjectSchema             sysname
      , ObjectName               sysname
      , ChildObjectName          sysname NULL
      , ObjectType               sysname
      , ObjectID                 BIGINT
      , FullyQualifiedObjectName sysname
    )
INSERT #MasterList
    (
        ObjectSchema
      , ObjectName
      , ChildObjectName
      , ObjectType
      , ObjectID
      , FullyQualifiedObjectName
    )
       SELECT
               OBJECT_SCHEMA_NAME (sed.referencing_id)                                          ObjectSchema
             , OBJECT_NAME (sed.referencing_id)                                                 ObjectName
             , NULL                                                                             AS ChildObjectName
             , ao.type_desc                                                                     ObjectType
             , sed.referencing_id
             , OBJECT_SCHEMA_NAME (sed.referencing_id) + '.' + OBJECT_NAME (sed.referencing_id) FullyQualifiedObjectName
       FROM
               General.sys.sql_expression_dependencies sed
           INNER JOIN
               Work.dbo.General_DBMove_TableBuckets    gdmtb
                   ON gdmtb.ObjectID = sed.referenced_id
           INNER JOIN
               sys.all_objects                         ao
                   ON sed.referencing_id = ao.object_id
       WHERE
                   OBJECT_NAME (sed.referencing_id) NOT LIKE 'sp_ms%'
               AND OBJECT_NAME (sed.referencing_id) NOT LIKE 'syncobj%'
               AND ao.is_ms_shipped = 0
               AND OBJECT_NAME (sed.referencing_id) NOT IN (
                       N'sp_alterdiagram', N'sp_creatediagram', N'sp_dropdiagram', N'sp_helpdiagramdefinition', N'sp_helpdiagrams', N'sp_renamediagram', N'sp_upgraddiagrams', N'fn_diagramobjects' )
       GROUP BY
               OBJECT_SCHEMA_NAME (sed.referencing_id)
             , OBJECT_NAME (sed.referencing_id)
             , ao.type_desc
             , sed.referencing_id
INSERT #MasterList
    (
        ObjectSchema
      , ObjectName
      , ChildObjectName
      , ObjectType
      , ObjectID
      , FullyQualifiedObjectName
    )
       SELECT
               OBJECT_SCHEMA_NAME (t.parent_id)
             , OBJECT_NAME (t.parent_id)
             , t.name
             , t.type_desc
             , t.object_id
             , OBJECT_SCHEMA_NAME (t.parent_id) + '.' + OBJECT_NAME (t.parent_id) + '.' + t.name
       FROM
               General.sys.triggers                 t
           INNER JOIN
               Work.dbo.General_DBMove_TableBuckets gdmtb
                   ON t.parent_id = gdmtb.ObjectID
       
DECLARE @ObjectName sysname
CREATE TABLE #MasterList2
    (
        ObjectSchema             sysname
      , ObjectName               sysname
      , ChildObjectName          sysname NULL
      , ObjectType               sysname
      , ObjectID                 BIGINT
      , FullyQualifiedObjectName sysname
    )
DECLARE DBA_Cursor CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT
        '%' + gdmtb.ObjectSchemaName + '.' + gdmtb.TableName + '%'
    FROM
        Work.dbo.General_DBMove_TableBuckets gdmtb
   
OPEN DBA_Cursor;
FETCH NEXT FROM DBA_Cursor
INTO
    @ObjectName;
WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT #MasterList2
               SELECT
                   OBJECT_SCHEMA_NAME (sm.object_id)
                 , OBJECT_NAME (sm.object_id)
                 , 'Dynamic SQL'
                 , 'SQL Modules'
                 , sm.object_id
                 , OBJECT_SCHEMA_NAME (sm.object_id) + '.' + OBJECT_NAME (sm.object_id)
               FROM
                   sys.sql_modules sm
               WHERE
                   REPLACE ((REPLACE ((REPLACE ((REPLACE (sm.definition, '[', '')), ']', '')), CHAR (10), SPACE (1))), CHAR (13), SPACE (1)) LIKE @ObjectName
        FETCH NEXT FROM DBA_Cursor
        INTO
            @ObjectName;
    END;
CLOSE DBA_Cursor;
DEALLOCATE DBA_Cursor;
INSERT #MasterList
    (
        ObjectSchema
      , ObjectName
      , ChildObjectName
      , ObjectType
      , ObjectID
      , FullyQualifiedObjectName
    )
       SELECT
               ML.ObjectSchema
             , ML.ObjectName
             , ML.ChildObjectName
             , ao.type_desc
             , ML.ObjectID
             , ML.FullyQualifiedObjectName
       FROM
               #MasterList2    ML
           INNER JOIN
               sys.all_objects ao
                   ON ML.ObjectID = ao.object_id
       WHERE
               ao.is_ms_shipped = 0
               AND ML.ObjectName NOT LIKE 'sp_ms%'
               AND NOT EXISTS
           (   SELECT
                   1
               FROM
                   #MasterList ml2
               WHERE
                   ML.ObjectID = ml2.ObjectID)
               AND ML.ObjectName NOT IN (
                       N'sp_alterdiagram', N'sp_creatediagram', N'sp_dropdiagram', N'sp_helpdiagramdefinition', N'sp_helpdiagrams', N'sp_renamediagram', N'sp_upgraddiagrams', N'fn_diagramobjects' )
       GROUP BY
               ML.ObjectSchema
             , ML.ObjectName
             , ML.ChildObjectName
             , ML.ObjectType
             , ML.ObjectID
             , ML.FullyQualifiedObjectName
             , ao.type_desc
UPDATE
    #MasterList
SET
    DatabaseName = 'General'
DECLARE @DBName sysname
DECLARE @sSQL VARCHAR(MAX)
DECLARE DB_Cursor CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT
        name
    FROM
        master.sys.databases
    WHERE
        name NOT IN (
            N'DBMonitor', N'General', N'master', N'model', N'msdb', N'ServerMonitor', N'tempdb' )
    ORDER BY
        name
OPEN DB_Cursor;
FETCH NEXT FROM DB_Cursor
INTO
    @DBName;
WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE OBJ_Cursor CURSOR FAST_FORWARD READ_ONLY FOR
            SELECT
                '%General.' + gdmtb.ObjectSchemaName + '.' + gdmtb.TableName + '%'
            FROM
                Work.dbo.General_DBMove_TableBuckets gdmtb
            
        OPEN OBJ_Cursor;
        FETCH NEXT FROM OBJ_Cursor
        INTO
            @ObjectName;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT
                    @sSQL
                    = 'Use ' + @DBName + ';' + ' SELECT
      '''                   + @DBName + '''
       ,  OBJECT_SCHEMA_NAME(sm.object_id)
       , OBJECT_NAME(sm.object_id)
       , '''                + @ObjectName
                      + '''
       , AO.type_desc
       , sm.object_id
       , OBJECT_SCHEMA_NAME(sm.object_id)+''.''+OBJECT_NAME(sm.object_id)
         FROM  sys.sql_modules sm
         INNER JOIN sys.all_objects ao
         ON sm.object_id=ao.object_id
      WHERE
      ao.is_ms_shipped=0 AND  OBJECT_NAME(sm.object_id)  NOT LIKE ''sp_ms%''      
      AND OBJECT_NAME(sm.object_id)  NOT IN (N''sp_alterdiagram'', N''sp_creatediagram''
           , N''sp_dropdiagram'', N''sp_helpdiagramdefinition''
           , N''sp_helpdiagrams'', N''sp_renamediagram'', N''sp_upgraddiagrams''
           , N''fn_diagramobjects'')
         AND
         REPLACE(
            (REPLACE(
             (REPLACE((REPLACE(sm.definition, ''['', '''')), '']'', '''')), CHAR(10)
             , SPACE(1))), CHAR(13), SPACE(1)) LIKE ''' + @ObjectName + ''''
                --SELECT   @sSQL
                INSERT #MasterList
                    (
                        DatabaseName
                      , ObjectSchema
                      , ObjectName
                      , ChildObjectName
                      , ObjectType
                      , ObjectID
                      , FullyQualifiedObjectName
                    )
                EXEC (@sSQL)
                FETCH NEXT FROM OBJ_Cursor
                INTO
                    @ObjectName;
            END;
        CLOSE OBJ_Cursor;
        DEALLOCATE OBJ_Cursor;
        FETCH NEXT FROM DB_Cursor
        INTO
            @DBName;
    END;
CLOSE DB_Cursor;
DEALLOCATE DB_Cursor;


SELECT
    *
FROM
    #MasterList


--Drop Table #MasterList
--Drop Table #MasterList2