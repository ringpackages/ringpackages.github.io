# Entity Framework Core: migrations of an existing database file
load "dotnet.ring"

using { "System.IO" "RingDotNet.Data" }

func main

	cFile = new Path().Combine([new Path().GetTempPath(),"ringdotnet_docs_migrate.db"])
	if new File().Exists(cFile)
		new File().Delete(cFile)
	ok
	cConnection = "Data Source=" + cFile

	# version 1 of the program
	oDb = new RingDatabase(cConnection,[ ["Users",[["Id","int",1],["Name","string",0]]] ])
	oDb.insert("Users",[["Name","Ann"]])
	oDb.close()

	# version 2: a new column and a new table
	oDb = new RingDatabase(cConnection,[
		["Users",[["Id","int",1],["Name","string",0],["Email","string",0],["Level","int",0,[["default",3]]]]],
		["Notes",[["Id","int",1],["Text","string",0],["UserId","int",0,[["references","Users"]]]]]
	])
	? "migrating:"
	aChanges = oDb.migrate()
	for cChange in aChanges
		? "  " + cChange
	next
	aRow = oDb.byKey("Users",1)
	? "existing row: " + dbValue(aRow,"Name") + ", level " + dbValue(aRow,"Level")

	? "named change applied: " + oDb.apply("001-promote","UPDATE Users SET Level = 9")
	? "applied again:        " + oDb.apply("001-promote","UPDATE Users SET Level = 1")
	oDb.discard()						# byKey returns the tracked row: forget it to read what the SQL changed
	? "level now: " + dbValue(oDb.byKey("Users",1),"Level")
	oDb.close()
	new File().Delete(cFile)
