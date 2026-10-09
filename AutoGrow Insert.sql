-- Used to create the record for AutoGrowMetaData

USE DBMonitor
GO

INSERT INTO dbo.AutoGrowMetaData (   DBName ,
                                     FileName ,
                                     ShouldAutoGrow ,
                                     MaxDailyGrowthMB ,
                                     GrowSizeMB ,
                                     MinDiskSpaceMB
                                 )
VALUES (   N'Eligibility' ,  -- DBName - nvarchar(128)
           N'Eligibility_tranStoreElr4' ,  -- FileName - nvarchar(128)
           1 , -- ShouldAutoGrow - bit
           20480.00 , -- MaxDailyGrowthMB - decimal(18, 2)
           2048 ,    -- GrowSizeMB - int
           NULL      -- MinDiskSpaceMB - int
       )

INSERT INTO dbo.AutoGrowMetaData (   DBName ,
                                     FileName ,
                                     ShouldAutoGrow ,
                                     MaxDailyGrowthMB ,
                                     GrowSizeMB ,
                                     MinDiskSpaceMB
                                 )
VALUES (   N'Claim' ,  -- DBName - nvarchar(128)
           N'Claim5' ,  -- FileName - nvarchar(128)
           1 , -- ShouldAutoGrow - bit
           20480.00 , -- MaxDailyGrowthMB - decimal(18, 2)
           2048 ,    -- GrowSizeMB - int
           NULL      -- MinDiskSpaceMB - int
       )