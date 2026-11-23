# Entity Framework Core with real entity classes: navigation properties, tracking, include
load "dotnet.ring"

using { "RingDotNet.Data" }

func main

	oDb = new RingEntityDb("Data Source=:memory:",[
		["Authors",[["Id","int",1],["Name","string",0]]],
		["Books",[["Id","int",1],["Title","string",0],["Year","int",0],["AuthorId","int",0,[["references","Authors"]]]]]
	])
	cProperties = ""
	for cProperty in oDb.properties("Books")
		cProperties += cProperty + " "
	next
	? "properties of Books: " + cProperties

	oTolkien = oDb.newEntity("Authors")
	oTolkien.setProp("Name","Tolkien")
	oDb.add(oTolkien)
	? "author key: " + oTolkien.getProp("Id")

	oBook = oDb.newEntity("Books")
	oDb.fill(oBook,[["Title","The Hobbit"],["Year",1937]])
	oBook.setProp("Author",oTolkien)               # a navigation property sets the foreign key
	oDb.add(oBook)
	? "AuthorId of the book: " + oBook.getProp("AuthorId")

	for oB in oDb.query("Books",[ ["include",["Author"]], ["where",["Year","<",1950]] ])
		? oB.getProp("Title") + " by " + oB.getProp("Author").getProp("Name")
	next

	oBook.setProp("Title","The Hobbit (1st edition)")      # tracked: saved by save()
	oDb.save()
	oDb.discard()
	? "after save: " + oDb.getValue(oDb.find("Books",1),"Title")

	aAuthors = oDb.query("Authors",[ ["include",["Books"]] ])
	? "books of the author: " + aAuthors[1].getProp("Books").getProp("Count")
	oDb.close()
