# Entity Framework Core: hooks, query filters, converters, transactions
load "dotnet.ring"

using { "RingDotNet.Data" }

aSql = []

func main

	oDb = new RingDatabase("Data Source=:memory:",[
		["Notes",[["Id","int",1],["Text","string",0,[["convert","upper"]]],["Deleted","int",0]],[["filter",["Deleted","=",0]]]]
	])
	oDb.onSaving(dnCallback("beforeSave"))
	oDb.onLog(dnCallback("logSql"))

	oDb.insert("Notes",[["Text","keep me"],["Deleted",0]])
	oDb.insert("Notes",[["Text","soft deleted"],["Deleted",1]])
	? "stored in uppercase: " + dbValue(oDb.sqlRows("SELECT Text FROM Notes",[])[1],"Text")
	? "visible notes (global filter): " + len(oDb.all("Notes"))
	? "all notes: " + len(oDb.query("Notes",[ ["ignorefilters",1] ]))

	try
		oDb.insert("Notes",[["Text","forbidden"],["Deleted",0]])
	catch
		? "the saving hook cancelled the save"
	done
	? "notes after the cancelled save: " + oDb.count("Notes")

	oDb.begin()
	oDb.insert("Notes",[["Text","inside a transaction"],["Deleted",0]])
	oDb.rollback()
	? "after rollback: " + oDb.count("Notes")
	? "SQL statements logged: " + len(aSql)
	oDb.close()

func beforeSave aArgs

	for aChange in aArgs[1]
		if dbValue(aChange[3],"Text") = "forbidden"
			return "forbidden text"
		ok
	next
	return ""

func logSql aArgs

	aSql + aArgs[1]
