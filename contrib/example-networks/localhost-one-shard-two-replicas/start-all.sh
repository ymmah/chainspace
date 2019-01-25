#!/usr/bin/env bash

set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command


NODE_CONFIG_DIR=${1:-.}

CUR_DIR=${PWD}

# TODO: Make this into a loop!
echo "Starting node [node_0_0]..."
cd ${NODE_CONFIG_DIR}/node_0_0
exec ./start_node.sh &
cd -
echo "Started."



echo "Starting node [node_0_1]..."
cd ${NODE_CONFIG_DIR}/node_0_1
exec ./start_node.sh &
cd -
echo "Started."

sleep 2

echo "Starting client-api ..."
cd ${NODE_CONFIG_DIR}/client-api
./start_client_api.sh
cd -
echo "Started."


