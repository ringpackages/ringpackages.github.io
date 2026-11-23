# Entity Framework Core: a table, rows, SQL conditions
load "dotnet.ring"

using { "RingDotNet.Data" }

func main

	oDb = new RingDatabase("Data Source=:memory:",[
		["Customers",[
			["Id","int",1],
			["Name","string",0,[["required",1],["maxlength",40]]],
			["Age","int",0,[["nullable",1]]],
			["City","string",0,[["index",1]]]
		]]
	])

	nAnn = oDb.insert("Customers",[["Name","Ann"],["Age",31],["City","Cairo"]])
	nBob = oDb.insert("Customers",[["Name","Bob"],["Age",17],["City","Oslo"]])
	oDb.insert("Customers",[["Name","Cy"],["Age",45],["City","Cairo"]])
	? "keys generated: " + nAnn + ", " + nBob
	? "rows: " + oDb.count("Customers")

	aRow = oDb.byKey("Customers",nAnn)
	? "row 1: " + dbValue(aRow,"Name") + ", " + dbValue(aRow,"Age") + ", " + dbValue(aRow,"City")

	? nl + "adults in Cairo:"
	for aCustomer in oDb.where("Customers","Age >= {0} AND City = {1}",[18,"Cairo"])
		? "  " + dbValue(aCustomer,"Name") + " (" + dbValue(aCustomer,"Age") + ")"
	next

	oDb.update("Customers",nBob,[["Age",18],["City","Bergen"]])
	? nl + "Bob now: " + dbValue(oDb.byKey("Customers",nBob),"City")
	oDb.remove("Customers",nAnn)
	? "after delete: " + oDb.count("Customers") + " rows"
	? "missing row: [" + oDb.byKey("Customers",99) + "]"
	oDb.close()
