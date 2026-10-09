--SELECT	*
--FROM	Dashboard.[dbo].[ProjectGroup] [pg]
--INNER JOIN dbo.UserGroup ug ON ug.ProjectGroup_Id = pg.Id
--WHERE ug.UserGroupStatus_Id = 2
--ORDER BY pg.Name

SELECT pg.name, vi.Name , u.UserName, u.[Password]
                       
FROM	[dbo].[UserDatabase] ud
INNER JOIN dbo.UserGroup ug ON ud.[User_Id] = ug.id
--5730
INNER JOIN dbo.Server ss ON ud.Server_Id = ss.Id
--4018
INNER JOIN dbo.ProjectGroup pg ON ug.ProjectGroup_Id = pg.id
INNER JOIN dbo.VirtualIp vi ON ud.VirtualIp_Id = vi.Id
INNER JOIN dbo.[User] u ON u.Id = ud.User_Id
WHERE ug.UserGroupStatus_Id = 2

GROUP BY pg.name, vi.Name , u.UserName, u.[Password]


--SELECT	e.Name, u.UserName, u.[Password], U.Description
--FROM	Dashboard.[dbo].[User] u
--INNER JOIN Dashboard.dbo.Environment e ON e.Id = u.Environment_Id
--WHERE u.IsActive = 1
--AND e.Name = 'Development'
--And u.UserName like 'zcloud%'
--ORDER BY u.UserName