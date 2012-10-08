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