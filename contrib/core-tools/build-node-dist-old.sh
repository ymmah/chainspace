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
DIST=chainspacecore/target/dist
CHAINSPACE_APP_JAR=`ls chainspacecore/target/chainspace*-with-dependencies.jar`
BFT_JAR=`ls chainspacecore/lib/bft-smart*-DECODE.jar`
DIST_TEMPLATE="contrib/core-tools/node-dist-template"
NODE_BUILD_DIR="${DIST}/_node_build"
CONTRACT_DIR="chainspacecore/contracts"

rm -rf ${DIST}
mkdir -p ${NODE_BUILD_DIR}

cp ${CHAINSPACE_APP_JAR} ${NODE_BUILD_DIR}

mkdir -p ${NODE_BUILD_DIR}/lib
cp ${BFT_JAR} ${NODE_BUILD_DIR}/lib
cp -r ${CONTRACT_DIR} ${NODE_BUILD_DIR} #TODO Remove this if its not needed
cp -r ${DIST_TEMPLATE}/* ${NODE_BUILD_DIR}

CLIENT_API="${DIST}/client-api"
mkdir -p ${CLIENT_API}
cp -r ${NODE_BUILD_DIR}/* ${CLIENT_API}/

function remove_files_from_dir {
    DIR=$1
    FILES_TO_REMOVE=$2
    cd ${DIR}
    rm -rf ${FILES_TO_REMOVE}
    cd -
}

remove_files_from_dir ${CLIENT_API} "config/node start_node.sh contracts"
remove_files_from_dir ${NODE_BUILD_DIR} "start_client_api.sh config/client-api"



# -i doesn't work on osx so need to do it a long and boring way
function replace_template_parameter {
    TEMPLATE_FILE=$1
    PARAMETER=$2
    VALUE=$3
    if [[ "Darwin" == $(uname) ]]; then
        sed -e "s/${PARAMETER}/${VALUE}/g" ${TEMPLATE_FILE} >> ${TEMPLATE_FILE}.1
        rm ${TEMPLATE_FILE}
        cp ${TEMPLATE_FILE}.1 ${TEMPLATE_FILE}
        rm ${TEMPLATE_FILE}.1
    else
        sed -e "s/${PARAMETER}/${VALUE}/g" -i ${TEMPLATE_FILE}
    fi
}

function make_node {
	COUNTER=$1
	NODE_DIR=$2
    mkdir -p ${NODE_DIR}
	cp -r ${NODE_BUILD_DIR}/* ${NODE_DIR}/
	replace_template_parameter ${NODE_DIR}/config/node/config.txt __REPLICA_ID__ ${COUNTER}
	replace_template_parameter ${NODE_DIR}/start_node.sh __START_PORT__ 13${COUNTER}10
	chmod +x ${NODE_DIR}/start_node.sh
}

for i in $(seq 0 1); do
	make_node $i $DIST/node_0_$i
done

rm -rf $NODE_BUILD_DIR

tree $DIST
