-- Find what already exists in DBMonitor DB
USE DBMonitor
SELECT * FROM dbo.AutoGrowMetaData




-- Used to update records where and adjustment just needs made
USE DBMonitor
UPDATE dbo.AutoGrowMetaData
SET MaxDailyGrowthMB = MaxDailyGrowthMB + 2048.00
WHERE FileName = 'Denials_DenialHistory';