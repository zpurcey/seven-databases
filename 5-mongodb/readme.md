# Chapter 5 - MongoDB

This is the VM for chapter 5. On first boot it will provision Java for you and unpack the MongoDB archive.

To boot the VM image, cd into this folder and type `vagrant up`.

When the VM is ready you can type `vagrant ssh` to connect to it. 

**Note:** There is a bug in Vagrant v1.0.4 and earlier which sometimes prevents the provisioning process from completing cleanly. If you can see `Done!` in the output then you can press Ctrl+C twice to exit the process, then type `vagrant ssh`.

## Chapter Summary

Mongo is a JSON/BSON document database that allows nested documents for collecting like information instead of table joins.  A set of documents is called a collection in Mongo.  Mongo is incredibly flexible handling complex denormalised documents with just as flexible storage strategy.  Great for storing data with unknown or changing qualities.

It feels friendly to users familiar with relational databases and is very popular because of this.

It's flexibility can be dangerous - add old value of any type into any collection, typos etc.  Do you need the flexibility? You may already have a data model locked down.

**Who uses it?**
Foursquare, bit.ly, CERN, Disney has a 1400 node cluster too:
Disney (Richard Glew) - 1 Year with Mongo at Disney:

http://www.10gen.com/presentations/mongosv-2011/a-year-with-mongodb-running-operations-to-keep-the-game-magic-alive

**Installation**

Can it be simplier?  It seems so well designed to be plug and play.  Deploying and configuring was a pleasure especially compared to HBASE.

**ObjectIDs**
Each document includes a serial number (ObjectID) that is made up of timestamp, client machine ID, client process ID and a counter.  This allows for distributed id generation without conflicts.

**JavaScript**
JavaScript is the platform language.  Fantastic help() functions provide hints on all available functions for a given object.  All commands are just Javascript functions.  Leaving off the trailing () will return the actual JavaScript Code for the command.  Fantastic ability to see both high level commands and low level (driver) sys commands.

You can also incorporate JavaScript functions directly from the shell or using JavaScript file.

**References**
Use $ref to reference another non-nested document.  Closest thing to a join.

**Noob Warning**
Mongo is very friendly in that it will let you create a new DB or document even if you mis-spelt the name of an existing object.  Imagine hours of debugging the code logic only to realise a small typo has been sending it to another doc or db.

Day 2 Summary
Indexes
Aggregated Queries - count(), distinct(), group()
Server side commands with Eval
MapReduce + a side order of Finalize

Day 3 Summary
**Replica**
You should rarely run a single Mongo instance in production but rather replicate the stored data across multiple services.

**Sharding**
Horizontal distribution by value ranges.

**GeoSpatial Queries**

**GridFS**
Is cool - a way to easily make adhoc files available and replicated across a Mongo cluster.

Simple: mongofiles -h localhost:27020 put my_file.txt


## Day 1 Study Notes
> Since Mongo is schema- less, there is no need to define anything up front; merely using it is enough.
Love it!!

>The ObjectId is always 12 bytes, composed of a timestamp, client machine ID, client process ID, and a 3-byte incremented counter. Bytes are laid out as depicted in Figure 21, An ObjectId layout example, on page 139.
Whats great about this autonumbering scheme is that each process on every machine can handle its own ID generation without colliding with other mongod instances. This design choice gives a hint of Mongos distributed nature.
+1

Why does .findone() return more formatted response than just .find()?

## Day 1 Exercises

### Find
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



### Do
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

`$ mongo blogger`

or from the shell:

`use blogger`

```
db.articles.insert ( {
	author: "Andrew Purcell",
	email: "andrew@purcellshouse.com",
	creation_date: new Date(),
	text: "THIS IS MY BLOG",
	}
)
```

5. Update the article with an array of comments, containing a comment with an author and text.

```
db.articles.update(
{ _id : ObjectId("50740b0a6cddc761cf3db4b2") }, { 
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


## Day 2 Study Notes


P153 - book error?
> populatePhones( 905, 5550000, 5650000 )
db.phones.find({display: "+1 905-5650001"}).explain()

Although the books shows the find matches a record we only created data for numbers up to 5650000.  I adjusted the find to 5550001.



> If you prefer that the mapreducer just output the results, rather than out- putting to a collection, you can set the out value to { inline : 1 }, but bear in mind there is a limit to the size of a result you can output. As of Mongo 2.0, that limit is 16MB.

Is the limit just on output to screen? Assume so.


## Day 2 Exercises

### Find
1. A shortcut for admin commands.

http://docs.mongodb.org/manual/reference/commands/

2. The online documentation for queries and cursors.

http://www.mongodb.org/display/DOCS/Queries+and+Cursors


3. The MongoDB documentation for mapreduce.

http://www.mongodb.org/display/DOCS/MapReduce


4. Through the JavaScript interface, investigate the code for three collections
functions: help(), findOne(), and stats().

```
> db.book.findOne
function (query, fields) {
    var cursor = this._mongo.find(this._fullName, this._massageObject(query) || {}, fields, -1, 0, 0, 0);
    if (!cursor.hasNext()) {
        return null;
    }
    var ret = cursor.next();
    if (cursor.hasNext()) {
        throw "findOne has more than 1 result!";
    }
    if (ret.$err) {
        throw "error " + tojson(ret);
    }
    return ret;
}
```
```
> db.book.stats
function (scale) {
    return this._db.runCommand({collstats:this._shortName, scale:scale});
}
```
```
> db.book.help
function () {
    var shortName = this.getName();
    print("DBCollection help");
    print("\tdb." + shortName + ".find().help() - show DBCursor help");
    print("\tdb." + shortName + ".count()");
    print("\tdb." + shortName + ".dataSize()");
    print("\tdb." + shortName + ".distinct( key ) - eg. db." + shortName + ".distinct( 'x' )");
    print("\tdb." + shortName + ".drop() drop the collection");
    print("\tdb." + shortName + ".dropIndex(name)");
    print("\tdb." + shortName + ".dropIndexes()");
    print("\tdb." + shortName + ".ensureIndex(keypattern[,options]) - options is an object with these possible fields: name, unique, dropDups");
    print("\tdb." + shortName + ".reIndex()");
    print("\tdb." + shortName + ".find([query],[fields]) - query is an optional query filter. fields is optional set of fields to return.");
    print("\t                                              e.g. db." + shortName + ".find( {x:77} , {name:1, x:1} )");
    print("\tdb." + shortName + ".find(...).count()");
    print("\tdb." + shortName + ".find(...).limit(n)");
    print("\tdb." + shortName + ".find(...).skip(n)");
    print("\tdb." + shortName + ".find(...).sort(...)");
    print("\tdb." + shortName + ".findOne([query])");
    print("\tdb." + shortName + ".findAndModify( { update : ... , remove : bool [, query: {}, sort: {}, 'new': false] } )");
    print("\tdb." + shortName + ".getDB() get DB object associated with collection");
    print("\tdb." + shortName + ".getIndexes()");
    print("\tdb." + shortName + ".group( { key : ..., initial: ..., reduce : ...[, cond: ...] } )");
    print("\tdb." + shortName + ".mapReduce( mapFunction , reduceFunction , <optional params> )");
    print("\tdb." + shortName + ".remove(query)");
    print("\tdb." + shortName + ".renameCollection( newName , <dropTarget> ) renames the collection.");
    print("\tdb." + shortName + ".runCommand( name , <options> ) runs a db command with the given name where the first param is the collection name");
    print("\tdb." + shortName + ".save(obj)");
    print("\tdb." + shortName + ".stats()");
    print("\tdb." + shortName + ".storageSize() - includes free space allocated to this collection");
    print("\tdb." + shortName + ".totalIndexSize() - size in bytes of all the indexes");
    print("\tdb." + shortName + ".totalSize() - storage allocated for all data and indexes");
    print("\tdb." + shortName + ".update(query, object[, upsert_bool, multi_bool])");
    print("\tdb." + shortName + ".validate( <full> ) - SLOW");
    print("\tdb." + shortName + ".getShardVersion() - only for use with sharding");
    print("\tdb." + shortName + ".getShardDistribution() - prints statistics about data distribution in the cluster");
    return __magicNoPrint;
}
```

### Do
1. Implement a finalize method to output the count as the total.

```
finalize = function(key, values) {
  return { total: value.count };
}

results = db.runCommand({
    mapReduce: 'phones',
    map: map,
    reduce: reduce,
    finalize: finalize,
    out: 'phones.report'
})
```

2. Install a Mongo driver for a language of your choice, and connect to the database. Populate a collection through it, and index one of the fields.

Python Mongo Engine:

```
sudo apt-get install build-essential python-dev
sudo apt-get install python-pip
pip install pymongo
pip install mongoengine
```

Based on tutorial here:

```
http://mongoengine-odm.readthedocs.org/en/latest/tutorial.html
```

Added Index to tags on Post collection below using:

```
...
	meta = { 'indexes': [ 'tags' ] }
```

Confirmed it was created:

```
> db.system.indexes.find()
{ "v" : 1, "key" : { "_id" : 1 }, "ns" : "mongoengine.user", "name" : "_id_" }
{ "v" : 1, "key" : { "_types" : 1 }, "ns" : "mongoengine.user", "background" : false, "name" : "_types_1" }
{ "v" : 1, "key" : { "_id" : 1 }, "ns" : "mongoengine.post", "name" : "_id_" }
{ "v" : 1, "key" : { "tags" : 1 }, "ns" : "mongoengine.post", "background" : false, "name" : "tags_1" }
{ "v" : 1, "key" : { "_types" : 1 }, "ns" : "mongoengine.post", "background" : false, "name" : "_types_1" }
```

create_collection.py

```
from mongoengine import *

class User(Document):
    email = StringField(required=True)
    first_name = StringField(max_length=50)
    last_name = StringField(max_length=50)

class Comment(EmbeddedDocument):
    content = StringField()
    name = StringField(max_length=120)

class Post(Document):
    title = StringField(max_length=120, required=True)
    author = ReferenceField(User)
    tags = ListField(StringField(max_length=30))
    comments = ListField(EmbeddedDocumentField(Comment))
    meta = { 'indexes': [ 'tags' ] }

class TextPost(Post):
    content = StringField()

class ImagePost(Post):
    image_path = StringField()

class LinkPost(Post):
    link_url = StringField()

#Connect
connect('mongoengine')
Post.drop_collection()
User.drop_collection()

#Populate Collection
john = User(email='jdoe@example.com', first_name='John', last_name='Doe')
john.save()

post1 = TextPost(title='Fun with MongoEngine', author=john)
post1.content = 'Took a look at MongoEngine today, looks pretty cool.'
post1.tags = ['mongodb', 'mongoengine']
post1.save()

post2 = LinkPost(title='MongoEngine Documentation', author=john)
post2.link_url = 'http://tractiondigital.com/labs/mongoengine/docs'
post2.tags = ['mongoengine']
post2.save()

#Retrieve Collection
for post in Post.objects:
    print post.title
    print '=' * len(post.title)

    if isinstance(post, TextPost):
        print post.content

    if isinstance(post, LinkPost):
        print 'Link:', post.link_url

    print

#Create a query set using objects:
for post in Post.objects(tags='mongodb'):
    print post.title

#Aggregation function applied to the queryset to count the records with mongodb tag:
num_posts = Post.objects(tags='mongodb').count()
print 'Found %d posts with tag "mongodb"' % num_posts

```

run:
```
$ python -W ignore::FutureWarning mongoengine_retrieve_collection.py 
Fun with MongoEngine
====================
Took a look at MongoEngine today, looks pretty cool.

MongoEngine Documentation
=========================
Link: http://tractiondigital.com/labs/mongoengine/docs

Fun with MongoEngine
Found 1 posts with tag "mongodb"
```

## Day 3 Notes

**** You should rarely run a single Mongo instance in production but rather replicate the stored data across multiple services.

> The message not master is letting us know that we cannot write to a secondary node. Nor can you directly read from it. There is only one master per replica set, and you must interact with it. It is the gatekeeper to the set.

Can only write (or read directly) through the master - the other replicas are for read only!

> Go ahead and shut down the current master. Remember, when we did this with three nodes, one of the others just got promoted to be the new master. But this time something dif- ferent happened. The output of the last remaining server will be something like this:
[ReplSetHealthPollTask] replSet info localhost:27012 is now down (or... [rs Manager] replSet can't see a majority, will not try to elect self
This comes down to the Mongo philosophy of server setups and the reason we should always have an odd number of servers (three, five, and so on).


Why odd number of nodes?
> MongoDB expects an odd number of total nodes in the replica set. Consider a five-node network, for example. If connection issues split it into a three- node fragment and a two-node fragment, the larger fragment has a clear majority and can elect a master and continue servicing requests. With no clear majority, a quorum couldnt be reached.

> Some databases (e.g., CouchDB) are built to allow multiple masters, but Mongo is not, and so it isnt prepared to resolve data updates between them. MongoDB deals with conflicts between multiple masters by simply not allowing them.

> Unlike with Riak, where availability and partitioning are functions of the properties set on buckets, MongoDB requires the whole topology to be explicitly configured.


## Day 3 Exercises

### Find
1. Read the full replica set configuration options in the online docs.

http://docs.mongodb.org/manual/reference/replica-configuration/


2. Find out how to create a spherical geo index.

http://www.mongodb.org/display/DOCS/Geospatial+Indexing#GeospatialIndexing-TheEarthisRoundbutMapsareFlat

```
db.places.ensureIndex( { loc : "2d" } , { min : -500 , max : 500 } )
```

### Do
1. Mongo has support for bounding shapes (namely, squares and circles). Find all cities within a 50-mile box around the center of London.

1. Convert data set:
sed -e 's/^\(.*\)latitude\(.*\), *longitude\([^}]*\)}\(.*\)$/\1longitude\3, latitude\2}\4/' \
mongo_cities1000.json > mongo_cities1000_lon_lat.json

```
var result = db.runCommand(
    { geoNear: "cities",
      near: centre,
      spherical: true,
      num: db.cities.count(),
      maxDistance: range/earthRadius } )
```


2. Run six servers: three servers in a replica set, and each replica set is one of two shards. Run a config server and mongos. Run GridFS across them (this is the final exam).
