#!/usr/bin/env bash
set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command

# This script takes input of a chainspace-network config file and the name of the node from that network that you want
# to generate and creates an output folder containing all the relevant files you need for that node.
# You can also pass "client-api" and it will generate a client api


if [[ ${1:-not-set} == "not-set" ]]; then
    echo "No command set, please specify one..."
    CMD=usage
else
    CMD=$1
    shift
fi


ROOT_DIR="."
CHAINSPACE_APP_JAR=`ls ${ROOT_DIR}/lib/chainspace*-with-dependencies.jar`
BFT_JAR=`ls ${ROOT_DIR}/lib/bft-smart*-DECODE.jar`
NODE_DIST_TEMPLATE="${ROOT_DIR}/node-config-template"


CONTRACT_DIR="${ROOT_DIR}/contracts"

function usage {
    echo -e "\nUsage:\n"
    echo "./node-config.sh generate <path to network definition> <path to target dir> <path to python bin>"
    echo -e "\ne.g."
    echo -e "./node-config.sh generate ./example-networks/localhost-one-shard-two-replicas ./nodes .chainspace.env\n"
}

function init-params {
    export NETWORK_CONFIG=$1
    export NETWORK_DIST_TARGET_DIR=$2
    export PYTHON_ENV_NAME=$3
    export NODE_BUILD_DIR="${NETWORK_DIST_TARGET_DIR}/_node_build"
    export CLIENT_API_BUILD_DIR="${NETWORK_DIST_TARGET_DIR}/_client_api"
}

function show-params {
    echo "Network config [${NETWORK_CONFIG}]"
    echo "Target dir [${NETWORK_DIST_TARGET_DIR}]"
    echo "Python bin [${PYTHON_ENV_NAME}]"
}

function remove_files_from_dir {
    DIR=$1
    FILES_TO_REMOVE=$2
    cd ${DIR}
    rm -rf ${FILES_TO_REMOVE}
    cd - >> /dev/null
}

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



function prepare-build-dirs {
    NETWORK_DIST_TARGET_DIR=$1
    NODE_BUILD_DIR="${NETWORK_DIST_TARGET_DIR}/_node_build"
    CLIENT_API_BUILD_DIR="${NETWORK_DIST_TARGET_DIR}/_client_api"

    echo "Cleaning and re-initialising [${NETWORK_DIST_TARGET_DIR}]..."

    rm -rf ${NETWORK_DIST_TARGET_DIR}
    mkdir -p ${NODE_BUILD_DIR}
    mkdir -p ${CLIENT_API_BUILD_DIR}

    cp ${CHAINSPACE_APP_JAR} ${NODE_BUILD_DIR}

    mkdir -p ${NODE_BUILD_DIR}/lib
    cp ${BFT_JAR} ${NODE_BUILD_DIR}/lib
    cp -r ${CONTRACT_DIR} ${NODE_BUILD_DIR}
    cp -r ${NODE_DIST_TEMPLATE}/* ${NODE_BUILD_DIR}


    cp -r ${NODE_BUILD_DIR}/* ${CLIENT_API_BUILD_DIR}

    remove_files_from_dir ${NODE_BUILD_DIR} "start_client_api.sh config/client-api"
    remove_files_from_dir ${CLIENT_API_BUILD_DIR} "config/node start_node.sh contracts"

}

function clean-build-dirs {
    NETWORK_DIST_TARGET_DIR=$1
    NODE_BUILD_DIR="${NETWORK_DIST_TARGET_DIR}/_node_build"
    CLIENT_API_BUILD_DIR="${NETWORK_DIST_TARGET_DIR}/_client_api"

    rm -rf ${NODE_BUILD_DIR}
    rm -rf ${CLIENT_API_BUILD_DIR}

}

function get-value-of {
    REF=$1
    echo ${!REF}
}



function generate-node-dist {

    PYTHON_ENV_NAME=$1
    NODE_ID=$2

    REPLICA_ID=$(get-value-of "${NODE_ID}_REPLICA_ID")

    echo "Generating a node distribution config for node ${NODE_ID} which is replica [${REPLICA_ID}]"


    NODE_DIR=${NETWORK_DIST_TARGET_DIR}/${NODE_ID}


    mkdir -p ${NODE_DIR}
	cp -r ${NODE_BUILD_DIR}/* ${NODE_DIR}/
	replace_template_parameter ${NODE_DIR}/config/node/config.txt __REPLICA_ID__ ${REPLICA_ID}
	replace_template_parameter ${NODE_DIR}/start_node.sh __START_PORT__ 13${REPLICA_ID}10
	replace_template_parameter ${NODE_DIR}/start_node.sh __PYTHON_ENV_NAME__ ${PYTHON_ENV_NAME}

	echo -e ${SHARD_HOST_LIST} >> ${NODE_DIR}/config/shards/S_0/hosts.config
	chmod +x ${NODE_DIR}/start_node.sh
}

# TODO - really this should generate 1 client per node - not sure about client talking to replicas though. Needs testing
function generate-client-api-dist {
    echo "Generating a client-api distribution config"
    CLIENT_API_DIR="${NETWORK_DIST_TARGET_DIR}/client-api"
    mkdir -p ${CLIENT_API_DIR}

    cp -r ${CLIENT_API_BUILD_DIR}/* ${CLIENT_API_DIR}
    echo -e ${SHARD_HOST_LIST} >> ${CLIENT_API_DIR}/config/shards/S_0/hosts.config
}


function generate {
    init-params $@
    show-params

    prepare-build-dirs ${NETWORK_DIST_TARGET_DIR}

    echo "Completed preparations."

    source ${NETWORK_CONFIG}.sh

    generate-client-api-dist ${NETWORK_CONFIG} ${NETWORK_DIST_TARGET_DIR}

    for REPLICA_NODE_ID in ${SHARD_REPLICAS[*]}; do
        generate-node-dist ${PYTHON_ENV_NAME} ${REPLICA_NODE_ID}
    done

    clean-build-dirs ${NETWORK_DIST_TARGET_DIR}

    echo -e "\nCompleted generation of node configurations in [${NETWORK_DIST_TARGET_DIR}]\n"
}




${CMD} $@
