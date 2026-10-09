USE FiveTran

DROP TABLE #StandardSet
CREATE TABLE #StandardSet
(
    chn_name VARCHAR(25)
);
INSERT #StandardSet
(
    chn_name
)
SELECT hlgm.chn_name
FROM dbo.hvr_loc_group_member AS hlgm
WHERE hlgm.grp_name = 'Target'
      AND hlgm.delete_tstamp IS NULL
      --AND hlgm.hub_name = devsql
GROUP BY hlgm.chn_name
HAVING COUNT(hlgm.loc_name) =
(
    SELECT TOP 1
           COUNT(loc_name)
    FROM dbo.hvr_loc_group_member
    WHERE grp_name = 'Target'
          AND delete_tstamp IS NULL
          --AND hub_name = devsql
    GROUP BY chn_name
    ORDER BY COUNT(loc_name) DESC
);
--SELECT * FROM #StandardSet
SELECT ht.tbl_base_name, ht.tbl_group
FROM dbo.hvr_table AS ht
    INNER JOIN #StandardSet AS ss
        ON ht.chn_name = ss.chn_name
WHERE ht.delete_tstamp IS null
