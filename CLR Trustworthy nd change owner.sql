
--Find user for a database
SELECT SUSER_SNAME(owner_sid) AS db_owner FROM sys.DATABASEs WHERE name='HAMILTON_iaf_Warehouse';

--change owner to sa or whatever sa is called
ALTER AUTHORIZATION ON DATABASE::HAMILTON_iaf_Warehouse TO tfadmin;

SELECT REPLACE(Reporting.ConcatenateDistinct(o.CurrencyCode), ',', '/') OriginalCurrenciesConcat
  FROM dbo.Currencies o

  ALTER DATABASE [Hamilton_Iaf_Warehouse] SET TRUSTWORTHY ON;

