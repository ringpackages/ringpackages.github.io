# Entity Framework Core: queries as LINQ expression trees, aggregates and SQL of any shape
load "dotnet.ring"

using { "RingDotNet.Data" }

func main

	oDb = new RingDatabase("Data Source=:memory:",[
		["People",[["Id","int",1],["Name","string",0],["Age","int",0],["City","string",0],["Score","double",0]]]
	])
	oDb.insert("People",[["Name","Ann"],["Age",31],["City","Cairo"],["Score",8.5]])
	oDb.insert("People",[["Name","Bob"],["Age",17],["City","Oslo"],["Score",6]])
	oDb.insert("People",[["Name","Cy"],["Age",45],["City","Cairo"],["Score",9]])
	oDb.insert("People",[["Name","Dee"],["Age",28],["City","Giza"],["Score",7.5]])

	aRows = oDb.query("People",[
		["where",["and",["Age",">",20],["City","in",["Cairo","Giza"]]]],
		["orderby",[["Age","desc"]]],
		["take",2],
		["select",["Name","Age"]]
	])
	? "top two adults in Cairo or Giza:"
	for aRow in aRows
		? "  " + dbValue(aRow,"Name") + " " + dbValue(aRow,"Age")
	next

	? nl + "count   : " + oDb.countWhere("People",["City","=","Cairo"])
	? "sum age : " + oDb.sum("People","Age",[])
	? "average : " + oDb.average("People","Score",[])
	? "max     : " + oDb.max("People","Score",[])

	? nl + "people per city:"
	for aGroup in oDb.groupCount("People","City",[])
		? "  " + aGroup[1] + ": " + aGroup[2]
	next

	? nl + "any SELECT shape:"
	for aRow in oDb.sqlRows("SELECT City, COUNT(*) AS N, AVG(Age) AS AvgAge FROM People WHERE Age > {0} GROUP BY City ORDER BY City",[18])
		? "  " + dbValue(aRow,"City") + " n=" + dbValue(aRow,"N") + " avg=" + dbValue(aRow,"AvgAge")
	next
	oDb.close()
