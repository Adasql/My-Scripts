

set NOCOUNT ON
--Run IN SQLCMD mode

use General -- this may chage to check to be sure the db name is correct


:SetVar Publication General
:SetVar ObjectSchemaName Security
:SetVar TableName VendorUsrCust

:SetVar Debug 1

--These should not be changed without approval
:SetVar AllowMulti 0
:SetVar SchemaOption 0x0000C344081F50DF
declare
   @AllowMulti bit=0
 , @OtherPublication sysname
declare
   @PublicationName sysname
 , @DestinationDB sysname
 , @Subscriber sysname
declare @sSQL varchar(max)
declare @msg varchar(255)


if not exists (select   1
                  from
                  dbo.sysarticles                A
                  inner join dbo.syspublications p
                     on A.pubid=p.pubid
                  where
                  object_schema_name(A.objid)='$(ObjectSchemaName)' and A.name='$(TableName)'
                  and  @AllowMulti=$(AllowMulti))
begin
   if($(Debug)=0)
   begin
      exec sys.sp_addarticle
         @publication=N'$(Publication)'
       , @article=N'$(TableName)'
       , @source_owner='$(ObjectSchemaName)'
       , @source_object=N'$(TableName)'
       , @type=N'logbased'
       , @description=N'$(ObjectSchemaName).$(TableName)'
       , @creation_script=N''
       , @pre_creation_cmd=N'truncate'
       , @schema_option=$(SchemaOption)
       , @identityrangemanagementoption=N'manual'
       , @destination_table=N'$(TableName)'
       , @destination_owner=N'$(ObjectSchemaName)'
       , @status=24
       , @vertical_partition=N'false'
       , @ins_cmd=N'CALL [sp_MSins_$(ObjectSchemaName)$(TableName)]'
       , @del_cmd=N'CALL [sp_MSdel_$(ObjectSchemaName)$(TableName)]'
       , @upd_cmd=N'SCALL [sp_MSupd_$(ObjectSchemaName)$(TableName)]'
       , @force_invalidate_snapshot=1
   END
   ELSE
   BEGIN
      SELECT
         'EXEC sys.sp_addarticle
         @publication=N''$(Publication)''
       , @article=N''$(TableName)''
       , @source_owner=''$(ObjectSchemaName)''
       , @source_object=N''$(TableName)''
       , @type=N''logbased''
       , @description=N''$(ObjectSchemaName).$(TableName)''
       , @creation_script=N''''
       , @pre_creation_cmd=N''truncate''
       , @schema_option=$(SchemaOption)
       , @identityrangemanagementoption=N''manual''
       , @destination_table=N''$(TableName)''
       , @destination_owner=N''$(ObjectSchemaName)''
       , @status=24
       , @vertical_partition=N''false''
       , @ins_cmd=N''CALL [sp_MSins_$(ObjectSchemaName)$(TableName)]''
       , @del_cmd=N''CALL [sp_MSdel_$(ObjectSchemaName)$(TableName)]''
       , @upd_cmd=N''SCALL [sp_MSupd_$(ObjectSchemaName)$(TableName)]''
       , @force_invalidate_snapshot=1'
   END


   DECLARE AddSubScriber_Cursor CURSOR FOR
   SELECT
      p.name
    , s.dest_db
    , s.srvname
      FROM
      dbo.sysarticles                 A
      INNER JOIN dbo.syspublications  p
         ON A.pubid=p.pubid
      INNER JOIN dbo.syssubscriptions s
         ON s.artid=A.artid
      WHERE
      s.dest_db<>'virtual' AND p.name='$(Publication)'
      GROUP BY
      p.name
    , s.dest_db
    , s.srvname
      ORDER BY s.srvname


   OPEN AddSubScriber_Cursor;


   FETCH NEXT FROM AddSubScriber_Cursor
   INTO
      @PublicationName
    , @DestinationDB
    , @Subscriber;


   WHILE @@FETCH_STATUS=0
   BEGIN
      SELECT
         @sSQL='EXEC sys.sp_addsubscription
   @publication=N'''+@PublicationName+'''
 , @subscriber=N'''+@Subscriber+'''
 , @destination_db=N'''+@DestinationDB
               +'''
 , @subscription_type=N''Push''
 , @sync_type=N''automatic''
 , @article=N''all''
 , @update_mode=N''read only''
 , @subscriber_type=0'


      IF($(Debug))=1 PRINT @sSQL ELSE 
      begin
      set @msg='Executing: '+@sSQL
      

      RAISERROR(@msg, 0, 1) WITH NOWAIT


      EXEC(@sSQL)
      end

      FETCH NEXT FROM AddSubScriber_Cursor
      INTO
         @PublicationName
       , @DestinationDB
       , @Subscriber;
   END;


   CLOSE AddSubScriber_Cursor;
   DEALLOCATE AddSubScriber_Cursor;
END
ELSE
BEGIN
   SELECT   @OtherPublication=STRING_AGG(p.name, ' & ')
      FROM
      dbo.sysarticles                A
      INNER JOIN dbo.syspublications p
         ON A.pubid=p.pubid
      WHERE
      OBJECT_SCHEMA_NAME(A.objid)='$(ObjectSchemaName)' AND A.name='$(TableName)'


   SELECT
      @msg='Object already belongs to '+@OtherPublication
           +' Publication either drop from other publication or set "allow multi publications"'


   RAISERROR(@msg, 0, 1) WITH NOWAIT
END