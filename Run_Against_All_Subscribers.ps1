
# used for a template to help resolve issues -- not production ready

$SQLQuery = "SELECT DISTINCT  s.srvname Subscriber
                            FROM
                              dbo.sysarticles                 A
                              INNER JOIN dbo.syspublications  p
                                 ON A.pubid=p.pubid
                              INNER JOIN dbo.syssubscriptions s
                                 ON s.artid=A.artid
                            WHERE
                            s.dest_db<>'virtual' AND  p.name='General'"
                            
$FTPUSRQry = "
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_SCHEMA = 'Security' AND TABLE_NAME = 'FTPUsr' AND COLUMN_NAME = 'Password')
ALTER TABLE Security.FTPUsr DROP COLUMN Password
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_SCHEMA = 'Security' AND TABLE_NAME = 'UsrSettings' AND COLUMN_NAME = 'isSSOUser')
ALTER TABLE Security.UsrSettings ADD isSSOUser bit NULL
GO
"

$Subscribers = (Invoke-Sqlcmd -ServerInstance "DVSQL002" -Database General -Query $SQLQuery).Subscriber

ForEach ($Subscriber in $Subscribers)
{
Invoke-Sqlcmd -ServerInstance $Subscriber -Database General -Query $FTPUSRQry
}