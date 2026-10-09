/*	https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/configure-read-only-routing-for-an-availability-group-sql-server?view=sql-server-ver15
	To determine if Read-Only is in use, connect to the VIP and run this query
		SELECT replica_server_name
			, read_only_routing_url
			, secondary_role_allow_connections_desc
		FROM sys.availability_replicas
	If the 'read_only_routing_url' column is populated, you will need to configure RO-routing on new node.
*/
USE master

:SETVAR AGName "PrSql022"
:SETVAR Replica1 "LouPrSql022c"
:SETVAR Replica2 "LouPrSql022d"
:SETVAR Replica3 "CinPrSql022c"

-- The following applies to the primary
-- if we have ALLOW_CONNECTIONS = READ_WRITE ("allow read/write connection" in dropdown) then connections where ApplicationIntent=ReadOnly are disallowed, hence adding them to end of read_only_routing_list doesn't make sense
-- if we have ALLOW_CONNECTIONS = ALL ("allow all connections" in dropdown) then need to test if ApplicationIntent=ReadOnly only allows read only to primary


-- The following applies to the secondary
--if we have ALLOW_CONNECTIONS = NO ("no" in dropdown) then secondary is not readable at all
--if we have ALLOW_CONNECTIONS = READ_ONLY ("read_intent_only" in dropdown) then connection string has to contain ApplicationIntent=ReadOnly to be able to read from secondary
--if we have ALLOW_CONNECTIONS = ALL ("yes" in dropdown) then connection string does not need ApplicationIntent=ReadOnly to be able to read from secondary
ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica1)' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica1)' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://$(Replica1).zcloud.com:1433'));

ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica2)' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica2)' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://$(Replica2).zcloud.com:1433'));

ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica3)' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica3)' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://$(Replica3).zcloud.com:1433'));

--only include the secondaries in the order that you want them read from
ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica1)' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('$(Replica2)','$(Replica3)','$(Replica1)')));

ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica2)' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('$(Replica1)','$(Replica3)','$(Replica2)')));

ALTER AVAILABILITY GROUP $(AGName)
	MODIFY REPLICA ON
		N'$(Replica3)' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('$(Replica1)','$(Replica2)','$(Replica3)')));

/*
SELECT   AVGSrc.replica_server_name AS SourceReplica
 , AVGRepl.replica_server_name AS ReadOnlyReplica
 , AVGRepl.read_only_routing_url AS RoutingURL
 , AVGRL.routing_priority AS RoutingPriority
 FROM sys.availability_read_only_routing_lists AVGRL
 INNER JOIN sys.availability_replicas AVGSrc ON AVGRL.replica_id = AVGSrc.replica_id
 INNER JOIN sys.availability_replicas AVGRepl ON AVGRL.read_only_replica_id = AVGRepl.replica_id
 INNER JOIN sys.availability_groups AV ON AV.group_id = AVGSrc.group_id
 ORDER BY SourceReplica
 */



