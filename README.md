# Chainspace

Chainspace is a distributed ledger platform for high-integrity and transparent processing of transactions within a decentralized system.

## Developer Installation

The bulk of the code is to be found in `chainspacecore`. To run a network of chainspace nodes, you need to first compile and package this module.


### Build
```
cd chainspacecore
mvn -Dversion=1.0-SNAPSHOT package assembly:single
```

This should produce an "uber jar" in the folder `chainspacecore/target`

### Run

There are two parts to chainspace, the client and the network.

The network is a set of nodes that are communicating with each other based on the BFT SMaRt library.

The client is a http server which connects to the network and allows you to submit transactions.
```
./contrib/core-tools/easystart.mac.sh
```

This will show you all running chainspace processes:

```
ps aux | grep -v grep | grep chainspace | awk '{print $2 $11}'
ps aux | grep -v grep | grep chainspace | awk '{print $2 " " $11 " " $12 " " $13}'
```

If you need to kill everything:

```
ps aux | grep -v grep | grep chainspace | awk '{print $2}' | xargs kill
```

### Building with Docker 

First, build the container from the Dockerfile
```
docker build -t chainspace . 
```

Then run chainspace with the following command
```
docker run -ti -p 5000:5000 --name chainspace chainspace
```

### With zenroom

If you are going to use contracts that use zenroom you should install it on your computer, here is a small tutorial to install it.

```
git clone git@github.com:DECODEproject/zenroom.git
cd zenroom

## Download the dependencies
git submodule init
git submodule update

## you should have cmake installed
make osx

sudo cp src/zenroom.command /usr/local/bin/zenroom
```

Also, by convention all zenroom contracts are stored into /opt/contracts, at the moment only the elgamal contract is need, so doing the next steps is enough.

```
sudo mkdir /opt/contracts

sudo cp -r examples/elgamal/ /opt/contracts/
```

You can try that everything is working by starting chainspace and execute the zenroom system tests:

```
source .chainspace.env/bin/activate

cd contrib/core-tools/system-test;
python test_zenroom_petition.py
```



## Developer Setup [IntelliJ Ultimate]

There are intellij modules in this folder for each of the submodules. Create a new empty project in intellij. A dialog will prompt you for the project structure, ignore this and wait for the project to load. You will see the .iml module files in the explorer and you can right click and import them to the project from there.

You will need to set the project sdk to be a JDK 1.8 and also a python virtualenv which you can create and link to each python module.

The modules are:

- chainspaceapi [python]
- chainspacecontract [python]
- chainspacemeasurement [python]
- chainspacecore [java]

You will need to add petlib manually to your python virtualenv from a shell... Intellij will have created your virtual env somewhere of your choosing indicated here as  (`$PATH_TO_VIRTUAL_ENV$`)...

```
source $PATH_TO_VIRTUAL_ENV$/bin/activate
pip install petlib
```
