*Please note: this is prototype code which serves as a validation of the ideas expressed in the [Chainspace S-BAC](https://arxiv.org/abs/1708.03778) peer-reviewed academic paper accepted by [NDSS 2018](https://www.youtube.com/watch?v=bYwIxPWyuD4&list=PLgLMkKEt7E3i1cvelsFwTJ2i2RwasarNd). We are currently building out our production codebase in Go, and the Go codebase will be used going forward. We will replace this Java code with the Go code when it's feature-equivalent. Existing contract code will continue to function.*


# Chainspace

Chainspace is a distributed ledger platform for high-integrity and transparent processing of transactions within a decentralized system.

More detailed documentation can be found in the `docs` folder of this repo. 

Chainspace is a decentralised application. This means that to use it you must instantiate a network of `nodes` and then communicate with those.

## Run a network locally using Docker

You will need Docker installed. It is possible to run everything directly on your machine but the setup is more involved. See [here](docs/local-dev-setup.md) for more details.

Published on dockerhub @ [https://hub.docker.com/r/decodeproject/chainspace-java](https://hub.docker.com/r/decodeproject/chainspace-java).


This image just contains the binaries ready for chainspace, but to run a network you need to configure and run some nodes. 

We have also provided a Dockerfile for that, and so you can run it like this:

````
cd contrib/example-networks/localhost-one-shard-two-replicas
make build-docker
make run-docker
````

And you should have a dockerised version of 2 nodes running! This setup has two nodes and an api server, which should be available on [http://localhost:5000/api/1.0/](http://localhost:5000/api/1.0/).

You will see when you run the above command that it is running the client api in the foreground so you can see transactions going through.

If you want to look at the logs you can exec into the docker image:

````
docker ps
docker exec -t -i <container-id> /bin/bash
````

Then 

````
less /var/log/chainspace/node_0_0-system.log
````

or
````
less /var/log/chainspace/node_0_1-system.log
````

Those are the two nodes.

Finally you can confirm that everything is working by running the following command from a new terminal window:

````
make system-test
````

Hopefully you will see something like this:

````
RESULT OF ALL CONTRACT CALLS: True
````

Be aware that these tests are stateful so if you try to run them again they will fail because you are creating duplicate objects.

To reset everything you can stop the docker container and re-run it and it should reset the data.


