# Entity Framework Core: foreign keys, children, parent, include and delete behaviors
load "dotnet.ring"

using { "RingDotNet.Data" }

func main

	oDb = new RingDatabase("Data Source=:memory:",[
		["Authors",[["Id","int",1],["Name","string",0]]],
		["Books",[["Id","int",1],["Title","string",0],["AuthorId","int",0,[["references","Authors"],["ondelete","cascade"]]]]]
	])
	nTolkien = oDb.insert("Authors",[["Name","Tolkien"]])
	nLewis = oDb.insert("Authors",[["Name","Lewis"]])
	oDb.insert("Books",[["Title","The Hobbit"],["AuthorId",nTolkien]])
	oDb.insert("Books",[["Title","The Silmarillion"],["AuthorId",nTolkien]])
	nNarnia = oDb.insert("Books",[["Title","Narnia"],["AuthorId",nLewis]])

	? "books by Tolkien:"
	aBooks = oDb.children("Authors",nTolkien,"Books")
	for aBook in aBooks
		? "  " + dbValue(aBook,"Title")
	next
	? nl + "Narnia was written by " + dbValue(oDb.parent("Books",nNarnia,"Authors"),"Name")

	? nl + "include:"
	aItems = oDb.include("Authors","Books")
	for aItem in aItems
		? "  " + dbValue(aItem[1],"Name") + " has " + len(aItem[2]) + " book(s)"
	next

	try
		oDb.insert("Books",[["Title","Orphan"],["AuthorId",99]])
	catch
		? nl + "a foreign key to nothing is rejected"
	done

	oDb.remove("Authors",nLewis)
	? "cascade: " + oDb.count("Books") + " books left"
	oDb.close()
