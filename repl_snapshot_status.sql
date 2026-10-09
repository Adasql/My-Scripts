--Run against the distributor  SQL021
SELECT
      agt.name Agent_Name
    , agt.publisher_db
    , agt.publication
    , DH.runstatus
    , DH.start_time
    , DH.time
    , DH.duration
    , DH.comments
    , DH.delivered_transactions
    , DH.error_id

FROM
      
      distribution.dbo.MSSnapshot_agents agt
      INNER JOIN distribution.[dbo].[MSSnapshot_history] DH
            ON DH.agent_id = agt.id
WHERE
      agt.publication <> 'All'
      
      AND comments NOT LIKE '<stats%'
      AND time > getdate() - 2
ORDER BY
      agt.publication
     ,time DESC  