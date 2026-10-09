use [NAccountSentara]
GO
GRANT SELECT TO [ZCLOUD\sa_prAMRBilling]
GO
 
USE [NAccountSentara];
GO
GRANT EXECUTE TO [AMLogiMonitor];
GO
USE [NAccountSentara];
GO
GRANT SELECT TO [AMLogiMonitor];
GO
 
USE [NAccountSentara];
GO
CREATE ROLE [LogitoLooker_Prod];
GO
USE [NAccountSentara];
GO
GRANT EXECUTE TO [LogitoLooker_Prod] AS [dbo];
GO
USE [NAccountSentara];
GO
GRANT SELECT TO [LogitoLooker_Prod] AS [dbo];
GO
use [NAccountSentara]
GO
GRANT SHOWPLAN TO [InternalReporting]
GO
use [NAccountSentara]
GO
GRANT VIEW DEFINITION TO [LogitoLooker_Prod]
GO
 
 
use [NAccountSentara]
GO
GRANT SHOWPLAN TO [InternalReporting]
GO
 
use [NAccountSentara]
GO
GRANT VIEW DEFINITION TO [LogitoLooker_Prod]
GO
use [NAccountSentara]
GO
GRANT EXECUTE TO [zcloud\sa_ConSSRS]
GO
use [NAccountSentara]
GO
GRANT SELECT TO [zcloud\sa_ConSSRS]
GO
use [NAccountSentara]
GO
GRANT UPDATE TO [zcloud\sa_ConSSRS]
GO
use [NAccountSentara]
GO
GRANT EXECUTE TO [saamrlooker]
GO
use [NAccountSentara]
GO
GRANT SELECT TO [saamrlooker]
GO
use [NAccountSentara]
GO
GRANT SHOWPLAN TO [InternalReporting]
GO
use [NAccountSentara]
GO
GRANT SELECT TO [ZCLOUD\sa_prAMRBilling]
GO