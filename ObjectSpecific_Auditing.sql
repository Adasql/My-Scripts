:SetVar VIP DVSQL087
--To get your data
USE DBMonitor

--SELECT * FROM fn_get_audit_file('\\louprbk002\Backups\SQLAudit\Audit$(VIP)_*.sqlaudit',default,default);
SELECT * FROM fn_get_audit_file('\\louprbk002\Backups\SQLAudit\AuditDVSQL002_*.sqlaudit',default,default) Where session_server_principal_name <> 'ZCLOUD\sadvarcloginapi';

--Sql002.General.SEcurity.AllUsrCust
USE Master;
CREATE SERVER AUDIT [Audit$(VIP)]
TO FILE 
(   FILEPATH = N'\\louprbk002\Backups\SQLAudit'
    ,MAXSIZE = 100 MB
    ,MAX_ROLLOVER_FILES = 50
    ,RESERVE_DISK_SPACE = OFF
)

WITH
(   QUEUE_DELAY = 1000
    ,ON_FAILURE = CONTINUE
)

GO
ALTER SERVER AUDIT  [Audit$(VIP)] WITH (STATE = ON);  
GO


USE DBMonitor
GO

CREATE DATABASE AUDIT SPECIFICATION [Audit$(VIP)_USRDetail]  
FOR SERVER AUDIT [Audit$(VIP)]  
ADD ( INSERT, UPDATE, DELETE  ON Object::[security].[Usr] BY [Public] )  
,ADD (INSERT, UPDATE, DELETE  ON Object::[security].[UsrDetail] BY [Public])
WITH (STATE = ON) ;    





-- Trigger the audit event by selecting from tables  
--SELECT ID, DataField FROM DataSchema.GeneralData;  
--SELECT ID, DataField FROM DataSchema.SensitiveData;  
GO  
-- Check the audit for the filtered content  
--SELECT * FROM fn_get_audit_file('\\louprbk002\Backups\SQLAudit\AuditGeneral_*.sqlaudit',default,default);  
GO
