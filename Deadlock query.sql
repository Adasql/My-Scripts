SELECT 
    CAST(event_data AS XML).value('(event/@timestamp)[1]', 'datetime') AS DeadlockTime,
    CAST(event_data AS XML).query('/event/data/value/deadlock') AS DeadlockGraph
FROM sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
WHERE object_name = 'xml_deadlock_report'
ORDER BY DeadlockTime DESC;