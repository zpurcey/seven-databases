# Chapter 3 - HBase

This is the VM for chapter 4. On first boot it will provision Java for you and unpack the HBase archive.

To boot the VM image, cd into this folder and type `vagrant up`.

When the VM is ready you can type `vagrant ssh` to connect to it. 

**Note:** There is a bug in Vagrant v1.0.4 and earlier which sometimes prevents the provisioning process from completing cleanly. If you can see `Done!` in the output then you can press Ctrl+C twice to exit the process, then type `vagrant ssh`.


## Week 4 Day 1 Notes
Everything worked well just needed to add the network config as detailed in the book for the local interface.



## Week 4 Day 1 Questions
*Find*
1. Figure out how to use the shell to do the following:

> a. Delete individual column values in a row

http://wiki.apache.org/hadoop/Hbase/Shell
delete    Put a delete cell value at specified table/row/column and optionally
           timestamp coordinates.  Deletes must match the deleted cell's
           coordinates exactly.  When scanning, a delete cell suppresses older
           versions. Takes arguments like the 'put' command described below
           
ANSWER:

`delete 'wiki', 'Home', 'revision:author'`

Deletes the revision:author key:value pair


> b. Delete an entire row

http://wiki.apache.org/hadoop/Hbase/Shell
deleteall Delete all cells in a given row; pass a table name, row, and optionally
           a column and timestamp

ANSWER:

`deleteall 'wiki', 'Home'`

Deletes entire wiki home row including all key:value pairs

2. Bookmark the HBase API documentation for the version of HBase youre using.

Couldn't find 0.94.1 doco but found 0.95 here:

`http://hbase.apache.org/apidocs/index.html`

*Do*

1. Create a function called put_many() that creates a Put instance, adds any number of column-value pairs to it, and commits it to a table. The signature should look like this:

```
def put_many( table_name, row, column_values ) # your code here
end
```


```
import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'

def jbytes( *args )
  args.map { |arg| arg.to_s.to_java_bytes }
end

def put_many( table_name, row, column_values )
  table = HTable.new( @hbase.configuration, table_name )

  p = Put.new( *jbytes( row ) )

  p.add( *jbytes( column_values ) )

  table.put( p )
end
```

Don't know enough JRuby so stole the answer for handling multiple values in the column_values arg:

```
  column_values.each do |k, v|
    (kf, kn) = k.split(':')
    kn ||= ""
    p.add( *jbytes( kf, kn, v ))
  end
```

Final:

```
import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'

def jbytes( *args )
  args.map { |arg| arg.to_s.to_java_bytes }
end

def put_many( table_name, row, column_values )
  table = HTable.new( @hbase.configuration, table_name )

  p = Put.new( *jbytes( row ) )

  column_values.each do |k, v|
    (kf, kn) = k.split(':')
    kn ||= ""
    p.add( *jbytes( kf, kn, v ))
  end

  table.put( p )
end

```

Needed to convert my tabs to spaces or I'd get weird shell issues

2. Define your put_many() function by pasting it in the HBase shell, and then call it like so:

```
put_many 'wiki', 'Some title', { "text:" => "Some article text", "revision:author" => "jschmoe", "revision:comment" => "no comment" }
```

Check my answer:
```
get 'wiki', 'Some title'
```

Installing thrift:
sudo apt-get install libboost-dev libboost-test-dev libboost-program-options-dev libevent-dev automake libtool flex bison pkg-config g++ libssl-dev

Forced me to create ../data directory after upstream merge
There was a problem with the configuration of Vagrant. The error message(s)
are printed below:

vm:
* Shared folder host path for 'v-data' doesn't exist: ../data



#################

MONGO SETUP

#################

Source: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

$ sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" > /etc/apt/sources.list.d/10gen.list

$ sudo apt-get update

$ sudo apt-get install mongodb-10gen


Day 1 Notes:
> Since Mongo is schema- less, there is no need to define anything up front; merely using it is enough.
Love it!!

```
db.towns.insert({
name: "New York",
population: 22200000,
last_census: ISODate("2009-07-31"), famous_for: [ "statue of liberty", "food" ], mayor : {
name : "Michael Bloomberg",
party : "I" }
})
```


>The ObjectId is always 12 bytes, composed of a timestamp, client machine ID, client process ID, and a 3-byte incremented counter. Bytes are laid out as depicted in Figure 21, An ObjectId layout example, on page 139.
Whats great about this autonumbering scheme is that each process on every machine can handle its own ID generation without colliding with other mongod instances. This design choice gives a hint of Mongos distributed nature.
+1

```
function insertCity(
name, population, last_census, famous_for, mayor_info
){ db.towns.insert({
    name:name,
    population:population,
    last_census: ISODate(last_census),
    famous_for:famous_for,
    mayor : mayor_info
}); }
```

```
insertCity("Punxsutawney", 6200, '2008-31-01', ["phil the groundhog"], { name : "Jim Wehrle" }
)
insertCity("Portland", 582000, '2007-20-09',
["beer", "food"], { name : "Sam Adams", party : "D" }
)
```

```
db.countries.insert({
	_id : "us",
	name : "United States",
	exports : {
		foods : [
			{ name : "bacon", tasty : true },
			{ name : "burgers" }
		]
	}
})

db.countries.insert({
	_id : "ca",
	name : "Canada",
	exports : {
		foods : [
			{ name : "bacon", tasty : false },
			{ name : "syrup", tasty : true }
		]
	}
})

db.countries.insert({
	_id : "mx",
	name : "Mexico",
	exports : {
		foods : [{
			name : "salsa",
			tasty : true,
			condiment : true
		}]
	}
})
```

Remember to use your own object id:
```
db.towns.update(
{ _id : ObjectId("507292bc9d89c19f4c1b1d42") }, { $set : { "state" : "OR" } }
);
```

```
db.towns.update(
{ _id : ObjectId("507292bc9d89c19f4c1b1d42") }, { $inc : { population : 1000} }
)
```

```
db.towns.update(
{ _id : ObjectId("507292bc9d89c19f4c1b1d42") },
{ $set : { country: { $ref: "countries", $id: "us" } } }
)
```

```
var portland = db.towns.findOne({ _id : ObjectId("507292bc9d89c19f4c1b1d42") })
```
```
var bad_bacon = {
	'exports.foods' : {
		$elemMatch : { name : 'bacon', tasty : false }
	}
}
db.countries.find( bad_bacon )
db.countries.remove( bad_bacon )
db.countries.count()
```

Why does .findone() return more formatted response than just .find()?

*Day 1 Homework*
Find
1. Bookmark the online MongoDB documentation.

http://docs.mongodb.org/manual/

2. Look up how to construct regular expressions in Mongo.

http://docs.mongodb.org/manual/reference/operator/regex/

```
db.collection.find( { field: /acme.*corp/i } );
db.collection.find( { field: { $regex: 'acme.*corp', $options: 'i' } } );
```

3. Acquaint yourself with command-line db.help() and db.collections.help() output.

Love this - code hints for any collection/object.  Sweet way to integrate context based hints/help.


4. Find a Mongo driver in your programming language of choice (Ruby, Java,PHP, and so on).

http://www.mongodb.org/display/DOCS/Drivers

My pick - python driver: http://mongoengine.org/



Do
1. Print a JSON document containing { "hello" : "world" }.

`tojson({ "hello": "world" });`


2. Select a town via a case-insensitive regular expression containing the word new.

```
db.towns.find( {
	name : /new/i
})
```
OR

```
db.towns.find(
	{ name : { $regex: 'new', $options: 'i' } }
)
```


3. Find all cities whose names contain an e and are famous for food or beer.

```
db.towns.find(
	{ name : { $regex: 'e', $options: 'i' },
		$or : [
			{ famous_for : "food" },
			{	famous_for : "beer" }
		] 
	}
)
```
Should return New York only

```
db.towns.find(
	{ name : { $regex: 'e', $options: 'i' },
		$or : [
			{	famous_for : "phil the groundhog" },
			{ famous_for : "food" },
			{	famous_for : "beer" }
		] 
	}
)
```
Testing - should return New York and Punxsutawney


4. Create a new database named blogger with a collection named articles insert a new article with an author name and email, creation date, and text.

$ mongo blogger

db.articles.insert ( {
	author: "Andrew Purcell",
	email: "andrew@purcellshouse.com",
	creation_date: new Date(),
	text: "THIS IS MY BLOG",
	}
)


5. Update the article with an array of comments, containing a comment with an author and text.

```
db.articles.update(
{ _id : ObjectId("5072b922874d35d991de65e8") }, { 
	$set: { comments: [
		{ comment_author: "Minie Mouse", comment: "Call me!"},
		{ comment_author: "Mickey Mouse", comment: "Squeak squeak"}
	]}
	}
);
```

`db.articles.findOne()`

6. Run a query from an external JavaScript file.


```
$ vi Wk5D1Q6.js
print(tojson(db.articles.findOne()));
printjson(db.articles.findOne());
```


```
$ mongo blogger Wk5D1Q6.js
```
