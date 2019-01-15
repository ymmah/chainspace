#!/usr/bin/env bash

set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command

ROOT_DIR=$(git rev-parse --show-toplevel)
cd ${ROOT_DIR}

TARGET_DIR="${ROOT_DIR}/target/dist"
LIB_DIR="${TARGET_DIR}/lib"
CONTRACT_DIR="${TARGET_DIR}/contracts"

echo "Going to build a chainspace distribution in ${TARGET_DIR} ... "

mkdir -p ${TARGET_DIR} ${LIB_DIR} ${CONTRACT_DIR}


CHAINSPACE_APP_JAR=`ls ${ROOT_DIR}/chainspacecore/target/chainspace*-with-dependencies.jar`
BFT_JAR=`ls ${ROOT_DIR}/chainspacecore/lib/bft-smart*-DECODE.jar`
NODE_DIST_TEMPLATE="${ROOT_DIR}/contrib/core-tools/node-dist-template"

CONTRACT_SRC_DIR="${ROOT_DIR}/chainspacecore/contracts"

echo -e "Copying files accross..."
cp ${CHAINSPACE_APP_JAR} ${LIB_DIR}
cp ${BFT_JAR} ${LIB_DIR}
cp ${CONTRACT_SRC_DIR}/* ${CONTRACT_DIR}

cd ${TARGET_DIR}
tree
cd -



