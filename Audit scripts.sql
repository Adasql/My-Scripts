select name as Auditname, type_desc as Auditdestination
, is_state_enabled , queue_delay, on_failure_desc from sys.server_audits

select audit_id, name, type, type_desc, on_failure_desc, is_state_enabled from sys.server_audits

select name, is_state_enabled, audit_guid, create_date, modify_date from sys.server_audit_specifications

EXEC sp_MSforeachdb '
use [?];

select DB_NAME() AS Databasename, name AS Auditspecification, is_state_enabled, create_date, modify_date  FROM sys.database_audit_specifications 
';

SELECT
sas.name AS AuditSpecification,
sas.is_state_enabled,
sad.audit_action_name,
sad.audited_result
FROM sys.server_audit_specifications AS sas
JOIN sys.server_audit_specification_details AS sad
ON sas.server_specification_id = sad.server_specification_id
ORDER BY sas.name, sad.audit_action_name;

select name, type_desc, is_state_enabled, on_failure_desc FROM sys.server_audits WHERE name ='audit-SQLServerBase'

SELECT servicename, service_account, status_desc FROM sys.dm_server_services WHERE servicename LIKE 'sql sERVER (%';

SecurityEvent
| distinct Computer , EventSourceName
| where EventSourceName == "MSSQLSERVER$AUDIT"

ALTER SERVER AUDIT [Audit-SQLServerBase] WITH (STATE = OFF)
GO
ALTER SERVER AUDIT [Audit-SQLServerBase] WITH (STATE = ON)
GO 

--verify audit is actually running
select a.name, a.is_state_enabled, s.status_desc, s.status_time FROM sys.server_audits a
LEFT JOIN sys.dm_server_audit_status s
ON a.audit_id = s.audit_id
where a.name = 'audit-SQLServerBase'

--Check configured actions

SELECT s.name as Auditspec, d.audit_action_name, d.audited_result
FROM sys.server_audit_specifications s JOIN sys.server_audit_specification_details d
ON s.server_specification_id = d.server_specification_id

order by S.NAME, D.AUDIT_ACTION_NAME