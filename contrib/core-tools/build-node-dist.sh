#!/bin/bash

set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command


# This script expects to be run where it is.


# ls is used here to pick up whatever version of the jar files there is there.
# Warning, assumes there is only 1 version!
NETWORK_DIST_TARGET_DIR=../../chainspacecore/target/network-dist
NETWORK_DIST_CONFIG=./example-networks/localhost-one-shard-two-replicas.sh

./generate-node-config.sh prepare-build-dirs ${NETWORK_DIST_TARGET_DIR}

./generate-node-config.sh generate-client-api-dist ${NETWORK_DIST_CONFIG} NODE_0_0 ${NETWORK_DIST_TARGET_DIR}

for i in $(seq 0 1); do
    ./generate-node-config.sh generate-node-dist ${NETWORK_DIST_CONFIG} "NODE_0_${i}" ${NETWORK_DIST_TARGET_DIR} ${i}
done


./generate-node-config.sh clean-build-dirs ${NETWORK_DIST_TARGET_DIR}


tree ${NETWORK_DIST_TARGET_DIR}
