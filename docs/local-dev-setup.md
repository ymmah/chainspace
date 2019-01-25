# Local dev setup raw (no docker)

This is somewhat more involved but is very useful if you need a faster dev cycle like if you are trying to fix bugs

### Pre-requisites

- Python, pip, virtualenv
- Java JDK
- Maven

If you want to run CS direct on your box without docker, you will need to own the directory `/var/log/chainspace` - on OSX you dont automatically have permission to write to var/log

You will also need to configure a virtual python environment:

````
virtualenv .chainspace.env
. .chainspace.env/bin/activate
pip install -U setuptools
pip install petlib 
pip install -e chainspaceapi
pip install -e chainspacecontract
````

### Run a simple network

To get started with chainspace on your dev machine, we have provided some scripts that will compile and package the code and run up a simple network with two nodes.

We also provide some example smart contracts in python which you can examine. You can execute these.

To verify that you have a working version follow these steps

````
make test-dist
````

This should compile everything and create you an example config, to be found in `target/chainspace-nodes`, try

````
tree target/chainspace-nodes
````

You will see several directories that are self contained (i.e. they include all nescessary jar files and configs) to run 2 nodes and one client api.

The client-api is a HTTP/JSON server that can communicate to the nodes using the internal CS protocol.

To run everyhing just do

````
make start-dist
````

You need to give it some time to start up, maybe a couple of seconds. The client api will be running in the foreground, the two nodes in the background.

You can see what they are doing like this:
````
tail -f /var/log/chainspace/node_0_0-system.log
```` 

And you can check everything is working by

````
make system-test
````
