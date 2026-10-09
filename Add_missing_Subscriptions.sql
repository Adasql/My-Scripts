--Run against the Publisher NOT distribution

-- if this returns any resulst - further actions need to be taken 
-- check with Anthony J.


:SetVar Publication General

IF OBJECT_ID('tempdb..#ExpectedResults') IS NOT NULL DROP TABLE #ExpectedResults
CREATE TABLE #ExpectedResults (Subscriber sysname, Publication sysname, ArticleSchema sysname, Article sysname);


IF OBJECT_ID('tempdb..#ActualResults') IS NOT NULL DROP TABLE #ActualResults
CREATE TABLE #ActualResults (Subscriber sysname, Publication sysname, ArticleSchema sysname, Article sysname);


WITH cte_Subscribers AS (SELECT DISTINCT  s.srvname Subscriber
                            FROM
                              dbo.sysarticles                 A
                              INNER JOIN dbo.syspublications  p
                                 ON A.pubid=p.pubid
                              INNER JOIN dbo.syssubscriptions s
                                 ON s.artid=A.artid
                            WHERE
                            s.dest_db<>'virtual' AND  p.name='$(Publication)')
, cte_article AS (SELECT
                     p.name                      PubName
                   , OBJECT_SCHEMA_NAME(A.objid) ObjectSchemaName
                   , A.name                      ArtName
                     FROM
                     dbo.sysarticles                A
                     INNER JOIN dbo.syspublications p
                        ON A.pubid=p.pubid
                     WHERE p.name='$(Publication)')
INSERT   #ExpectedResults(Subscriber, Publication, ArticleSchema, Article)
   SELECT
      Sub.Subscriber
    , art.PubName
    , art.ObjectSchemaName
    , art.ArtName
      FROM
      cte_Subscribers        Sub
      CROSS JOIN cte_article art;


INSERT   #ActualResults(Subscriber, Publication, ArticleSchema, Article)
   SELECT
      S.srvname
    , p.name
    , OBJECT_SCHEMA_NAME(A.objid)
    , A.name
      FROM
      dbo.sysarticles                 A
      INNER JOIN dbo.syspublications  p
         ON A.pubid=p.pubid
      INNER JOIN dbo.syssubscriptions S
         ON S.artid=A.artid
      WHERE p.name='$(Publication)'


SELECT         
         'EXEC sys.sp_addsubscription
   @publication=N'''+er.Publication+'''
 , @subscriber=N'''+er.Subscriber+'''
 , @destination_db=N''General''
 , @subscription_type=N''Push''
 , @sync_type=N''automatic''
 , @article=N''all''
 , @update_mode=N''read only''
 , @subscriber_type=0'
   FROM  #ExpectedResults er
   WHERE
   NOT EXISTS (SELECT   1
                  FROM  #ActualResults ar
                  WHERE
                  er.Subscriber=ar.Subscriber AND  er.Publication=ar.Publication AND er.Subscriber=ar.Subscriber
                  AND er.ArticleSchema=ar.ArticleSchema AND  er.Article=ar.Article)
GROUP BY      'EXEC sys.sp_addsubscription
   @publication=N'''+er.Publication+'''
 , @subscriber=N'''+er.Subscriber+'''
 , @destination_db=N''General''
 , @subscription_type=N''Push''
 , @sync_type=N''automatic''
 , @article=N''all''
 , @update_mode=N''read only''
 , @subscriber_type=0'
                  


