select * from Utilities.dbo.databaseexpiry order by createddate desc


use utilities
go


insert into dbo.databaseexpiry values ('Tandem_Synd','2026-09-30 09:26:23.430', '331227', getdate(),'HAMILTONBM\pnwofor-admin')


EXEC Utilities.dbo.DatabasePermissionChange @databaseName = 'Tandem_Synd'; --DBname