$Query = "
USE msdb;

DECLARE @Date INT
       ,@Time INT;
DECLARE @CurDate DATE = DATEADD (DAY, -1, GETDATE ());
SET @Date = CAST(FORMAT (@CurDate, 'yyyyMMdd') AS INT);

SELECT  DISTINCT
        @@SERVERNAME AS ServerName
       ,S2.name      AS JobName
FROM    dbo.sysjobhistory S
        JOIN dbo.sysjobs  S2
            ON S2.job_id = S.job_id
WHERE   S.run_date >= @Date
        AND S.step_id = 0
        AND S.run_status = 0;
"

$ServerList = GetSqlServers -Environments "Pr" `
-DC "Lou" `
-VIP_Only $true `
-IgnoreDw $true `
-IgnoreConnance $true `
# -IgnoreHRCM $true `
# -OutputQuery $true

$Results = @()

foreach ( $Server in $ServerList) {
    Write-Host $Server.ServerName
    $Results += Invoke-Sqlcmd -ServerInstance $Server.ServerName -Database "msdb" -Query $Query
}

$Results | Format-Table;


