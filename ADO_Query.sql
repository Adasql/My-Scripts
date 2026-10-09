--SELECT	TOP 10 *
--FROM	dbo.ADObjects ao
--WHERE PartitionId = 1
--AND TeamFoundationId = '1889D019-E2E8-43CF-9180-28AE8E947BFF'
--TeamFoundationID
--SELECT	*
--FROM	dbo.Constants c
--WHERE PartitionId = 1
--AND TeamFoundationId = '1889D019-E2E8-43CF-9180-28AE8E947BFF'

--SELECT	TOP 10 *
--FROM	dbo.ADObjectMemberships aom
--WHERE PartitionId = 1
--AND aom.ObjectSID = 'S-1-9-1551374245-2642478100-4202779208-2992234030-678841395-1-1649909737-3748462912-2723689538-1741600172'

--SELECT	TOP 10 *
--FROM	dbo.ADObjectMemberships aom
--WHERE PartitionId = 1
--AND aom.MemberObjectSID = 'S-1-5-21-1787752667-1276763097-1452947151-17560'
USE Work
GO
--CREATE VIEW ADO_Members_By_Team as
SELECT
   ao.SamAccountName TeamName
 , *
   FROM
   AzureDevOps_Waystar.dbo.ADObjects                      ao
   INNER JOIN AzureDevOps_Waystar.dbo.ADObjectMemberships aom
      ON aom.PartitionId=ao.PartitionId AND  aom.ObjectSID=ao.ObjectSID
   INNER JOIN AzureDevOps_Waystar.dbo.ADObjects           ao2
      ON aom.MemberObjectSID=ao2.ObjectSID
         AND  aom.PartitionId=ao.PartitionId
   WHERE ao.SamAccountName NOT IN ('Allemployees','Contributors','Domain Admins')
   And ao2.SamAccountName ='Deana.Ritter'

--TeamFoundationID