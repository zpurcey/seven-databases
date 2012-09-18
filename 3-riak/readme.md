# Chapter 3 - Riak

## Provisioning Tips


This is the VM for chapter 3. On first boot it will provision Erlang and Riak for you (from source) and build the Riak developer environment.

To boot the VM image, cd into this folder and type `vagrant up`.

When the VM is ready (which can take 20-30 minutes the first time) you can type `vagrant ssh` to connect to it. 

**Note:** There is a bug in Vagrant v1.0.4 and earlier which sometimes prevents the provisioning process from completing cleanly. If you can see `Done!` in the output then you can press Ctrl+C twice to exit the process, then type `vagrant ssh`.

Once you are connected via SSH you can cd into the `riak-1.2.0` folder, skip the make step in the book and start launching Riak instances e.g. enter `dev/dev1/bin/riak start`

### riak-admin join -> riak-admin cluster join

Instead of `riak-admin join` use `riak-admin cluster join`.
And once all your nodes are in the cluster do:

```
riak-admin cluster plan
riak-admin cluster commit
```

You can use: `riak2-admin member-status` to confirm that the ring is setup correctly.  (doesn't become important until day 2)

`curl localhost:8091` should show an equal distribution of vnodes across the 3 members similar to:

```
"ring_ownership": "[{'dev3@127.0.0.1',21},{'dev2@127.0.0.1',21},{'dev1@127.0.0.1',22}]"
```


### Install Helper App - HTTPie

We start to use a lot of CURL in this chapter.  If you find yourself wanting some syntax highlighting of the output or get tired of typing the long arguments, check out HTTPie: https://github.com/jkbr/httpie

Install it on the VM like this:

```
sudo apt-get install python-pip -y
sudo pip install -U httpie
```

E.g. instead of:

```
curl -i -X POST http://localhost:8091/riak/animals -H "Content-Type: application/json" -d '{"nickname" : "Sergeant Stubby", "breed" : "Terrier"}'
```

Try this:

```
http POST http://localhost:8091/riak/animals nickname="Sergeant Stubby" breed="Terrier"
```


### Setup Browser Access

To get my host web browser going:

I modified Vagrantfile adding:

`config.vm.forward_port 8091, 8090`

Vagrant halt / vagrant up stalled so I ended up having to destroy but it did work once rebuilt.  Perhaps suspend/resume might work?

Then I updated the 127.0.0.1 ip in dev/dev1/etc/app.config:

```
%% http is a list of IP addresses and TCP ports that the Riak
%% HTTP interface will bind.
  {http, [ {"0.0.0.0", 8091 } ]},
```

This change is necessary as the port forward won't work unless Riak is configured to listen on all adaptors instead of just localhost.

Restarted dev1 instance:

```
dev/dev1/bin/riak stop
dev/dev1/bin/riak start

```

It seemed to pick up the config change and apply it to the cluster by just cycling the dev1 instance.

You can then just browse to:

`http://localhost:8090/riak/favs/db`


## Notes and Questions

Putting this in my browser won't return the pic:

```
http://localhost:8091/riak/animals/polly/_,photo,_
```

This works fine:
```
http://localhost:8091/riak/photos/polly.jpg
```
Here's the setup: 
```
vagrant@precise32:~/riak-1.2.0$ http http://localhost:8091/riak/animals/polly
HTTP/1.1 200 OK
Content-Length: 59
Content-Type: application/json
Date: Tue, 18 Sep 2012 04:58:15 GMT
ETag: "6jexkI4rYU43NGESr2DiAY"
Last-Modified: Tue, 18 Sep 2012 03:41:58 GMT
Link: </riak/photos/polly.jpg>; riaktag="photo", </riak/medicines/antibiotics>; riaktag="medicine", </riak/animals>; rel="up"
Server: MochiWeb/1.1 WebMachine/1.9.0 (someone had painted it blue)
Vary: Accept-Encoding
X-Riak-Vclock: a85hYGBgzGDKBVIcR4M2cgeE9/dkMCWy5rEyWFSdOcmXBQA=

{
    "breed": "Purebred", 
    "nickname": "Sweet Polly Purebred"
}
```
What am I doing wrong? Or is it not supposed to work this way?

The headers are different:

Works in Chrome:
```
vagrant@precise32:~/riak-1.2.0$ http http://localhost:8091/riak/photos/polly.jpg
HTTP/1.1 200 OK
Content-Length: 13251
Content-Type: image/jpeg
Date: Tue, 18 Sep 2012 09:04:45 GMT
ETag: "fKdYT9WshlZ2kLAEe2gsU"
Last-Modified: Mon, 17 Sep 2012 23:27:06 GMT
Link: </riak/animals/polly>; riaktag="photo", </riak/photos>; rel="up"
Server: MochiWeb/1.1 WebMachine/1.9.0 (someone had painted it blue)
Vary: Accept-Encoding
X-Riak-Vclock: a85hYGBgzGDKBVIcR4M2cgeE9/dkMCUy5bEynNI9c5IvCwA=

+-----------------------------------------+
| NOTE: binary data not shown in terminal |
+-----------------------------------------+
```

Doesn't work in Chrome:
```
vagrant@precise32:~/riak-1.2.0$ http http://localhost:8091/riak/animals/polly/_,photo,_
HTTP/1.1 200 OK
Content-Length: 13730
Content-Type: multipart/mixed; boundary=5aW1ABkGrZqLiLE9vr3t7jAErk4
Date: Tue, 18 Sep 2012 09:04:35 GMT
Expires: Tue, 18 Sep 2012 09:14:35 GMT
Server: MochiWeb/1.1 WebMachine/1.9.0 (someone had painted it blue)

+-----------------------------------------+
| NOTE: binary data not shown in terminal |
+-----------------------------------------+
```

**Ah the key is here:**

`Content-Type: multipart/mixed;`

Likely need a client to process this and chrome doesn't want to directly.

### Day 1 Questions 

**Find**
1. Bookmark the online Riak project documentation and discover the REST API documentation.

`http://wiki.basho.com/Developers.html`
`http://wiki.basho.com/HTTP-API.html` HTTP REsT API


2. Find a good list of browser-supported MIME types.

```
http://www.iana.org/assignments/media-types/
http://www.webmaster-toolkit.com/mime-types.shtml
http://www.htmlquick.com/reference/mime-types.html
```

3. Read the example Riak config dev/dev1/etc/app.config, and compare it to the other dev configurations.

They are all configured to pop up on different ports.  I stopped dev1 and found it stopped listening on the 8091.  I sent a request to 8092 and received a valid response.

This means my browser will work with the current config if dev1 instance is running.  Would have been better to configure all instances for 0.0.0.0 in app.config and port forwarding extra ports.

**Do**
1. Using PUT, update animals/polly to have a Link pointing to photos/polly.jpg.

Cage 1 linked to polly
Link: </riak/bucket/key>; riaktag=\"whatever\"

curl -X PUT http://localhost:8091/riak/cages/1 \
  -H "Content-Type: application/json" \
  -H "Link: </riak/animals/polly>; riaktag=\"contains\"" \
  -d '{"room" : 101}'

```
curl -v -X PUT http://localhost:8091/riak/animals/polly?returnbody=true \
  -H "Content-Type: application/json" \
  -H "Link: </riak/photos/polly.jpg>; riaktag=\"photo\", </riak/medicines/antibiotics>; riaktag=\"medicine\"" \
  -d '{"nickname" : "Sweet Polly Purebred", "breed" : "Purebred"}'
```
  
Checked with http://localhost:8091/riak/animals/polly/photos,_,_ true but found it wasn't interpreted by the browser correctly :(..  wanted to just download a file photos,_,_


2. POST a file of a MIME type we havent tried (such as application/pdf), find the generated key, and hit that URL from a web browser.

```
curl -X PUT http://localhost:8091/riak/docs/7dbs_w3_q2.pdf \
  -H "Content-type: application/pdf" \
  --data-binary @7dbs_w3_q2.pdf
```
Test with browser:

`http://localhost:8091/riak/docs/7dbs_w3_q2.pdf`

3. Create a new bucket type called medicines, PUT a JPEG image value (with the proper MIME type) keyed as antibiotics, and link to the animal Ace (poor, sick puppy).

```
curl -X PUT http://localhost:8091/riak/medicines/antibiotics \
  -H "Content-type: image/jpeg" \
  -H "Link: </riak/animals/ace>; riaktag=\"sick puppy\"" \
  --data-binary @superbug.jpg

```

Checked it:
`http http://localhost:8091/riak/medicines?keys=true`

