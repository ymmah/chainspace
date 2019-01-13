#!/bin/bash

set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command


# This is so that you can run the script from where it is but resets the cd to the top level dir.
RUN_DIR=$(git rev-parse --show-toplevel)

cd ${RUN_DIR}

# ls is used here to pick up whatever version of the jar files there is there.
# Warning, assumes there is only 1 version!
NETWORK_DIST_TARGET_DIR=chainspacecore/target/network-dist
NETWORK_DIST_CONFIG=contrib/core-tools/example-networks/localhost-one-shard-two-replicas

contrib/core-tools/generate-node-config.sh generate-nodes ${NETWORK_DIST_CONFIG} ${NETWORK_DIST_TARGET_DIR}

tree ${NETWORK_DIST_TARGET_DIR}
