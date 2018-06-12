#!/bin/sh

cd $(git rev-parse --show-toplevel)

DIST=chainspacecore/target/dist

UBER_JAR=`ls chainspacecore/target/chainspace*-with-dependencies.jar`
BFT_JAR=`ls chainspacecore/lib/bft-smart*-DECODE.jar`
DIST_TEMPLATE="contrib/core-tools/node-dist-template"
CONTRACT_DIR="chainspacecore/contracts"

NODETEMPL="$DIST/nodetempl"

rm -rf $DIST
mkdir -p $NODETEMPL

cp $UBER_JAR $NODETEMPL

mkdir -p $NODETEMPL/lib
cp $BFT_JAR $NODETEMPL/lib
cp -r $CONTRACT_DIR $NODETEMPL
cp -r $DIST_TEMPLATE/* $NODETEMPL

CLIENT_API="$DIST/client-api"
mkdir -p $CLIENT_API
cp -r $NODETEMPL/* $CLIENT_API/

cleanfiles="$CLIENT_API/config/node $NODETEMPL/contracts $CLIENT_API/start_node.sh $NODETEMPL/start_client_api.sh $NODETEMPL/config/client-api"
rm -rf $cleanfiles



make_node() {
	num="$1"
	path="$2"
	mkdir -p $path
	cp -r $NODETEMPL/* $path/
	sed -e "s/REPLICA_ID/$num/g" -i $path/config/node/config.txt
	sed -e "s/__START_PORT__/13010/g" -i $path/start_node.sh
	chmod +x $path/start_node.sh
}

for i in $(seq 0 3); do
	make_node $i $DIST/node_0_$i
done

tree $DIST
