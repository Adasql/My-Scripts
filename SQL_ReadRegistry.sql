SELECT
   value_name
 , value_data
   FROM  sys.dm_server_registry
   WHERE
   value_name IN ('TcpPort', 'IpAddress', 'TcpDynamicPorts')
   GROUP BY
   value_name
 , value_data
 GO
 :Connect QASQL059
 SELECT
   value_name
 , value_data
   FROM  sys.dm_server_registry
   WHERE
   value_name IN ('TcpPort', 'IpAddress', 'TcpDynamicPorts')
   GROUP BY
   value_name
 , value_data
 GO