select name, is_disabled from sys.server_principals where name='Enrolluser'

ALTER LOGIN [Enrolluser] disable;