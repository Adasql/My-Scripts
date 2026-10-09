USE [master]
GO
CREATE LOGIN [ZCLOUD\sadvharnesspoc] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE [HarnessPOC]
GO
CREATE USER [ZCLOUD\sadvharnesspoc] FOR LOGIN [ZCLOUD\sadvharnesspoc]
GO
USE [HarnessPOC]
GO
ALTER ROLE [Platform HarnessPOC_DV] ADD MEMBER [ZCLOUD\sadvharnesspoc]
GO