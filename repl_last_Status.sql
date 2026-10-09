--Run against the distributor SQL021
SELECT
      agt.publication
      ,ms2.srvname Publisher
     ,ms.srvname Subscriber
     ,DH.start_time
     ,DH.time
     ,DH.duration
     ,DH.comments
     ,DH.xact_seqno
     ,DH.delivered_transactions
     ,DH.delivered_commands
FROM
      
      distribution.dbo.msdistribution_agents agt
      INNER JOIN  distribution.dbo.MSreplservers ms  ON agt.subscriber_id = ms.srvid
      INNER JOIN distribution.dbo.MSreplservers ms2 ON ms2.srvid = agt.publisher_id
      INNER JOIN distribution.[dbo].[MSdistribution_history] DH
            ON DH.agent_id = agt.id
            INNER JOIN (SELECT agent_id, max(time) htime FROM distribution.[dbo].[MSdistribution_history] GROUP BY agent_id) dhm ON dh.agent_id = dhm.agent_id
            AND dh.time = dhm.htime
WHERE
      agt.publication <> 'All'
      AND subscriber_db <> 'virtual'
      AND comments NOT LIKE '<stats%'
      AND time > getdate() - 2
ORDER BY
      agt.publication
     ,ms.srvname
     ,time DESC    