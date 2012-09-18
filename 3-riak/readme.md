# Chapter 3 - Riak

## Provisioning Tips

### Must read tips on initial setup

This is the VM for chapter 3. On first boot it will provision Erlang and Riak for you (from source) and build the Riak developer environment.

To boot the VM image, cd into this folder and type `vagrant up`.

When the VM is ready (which can take 20-30 minutes the first time) you can type `vagrant ssh` to connect to it. 

**Note:** There is a bug in Vagrant v1.0.4 and earlier which sometimes prevents the provisioning process from completing cleanly. If you can see `Done!` in the output then you can press Ctrl+C twice to exit the process, then type `vagrant ssh`.

Once you are connected via SSH you can cd into the `riak-1.2.0` folder, skip the make step in the book and start launching Riak instances e.g. enter `dev/dev1/bin/riak start`

### Chapter 3 - Corrections

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