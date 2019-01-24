#!/usr/bin/env bash

NODE_NAME=$(basename ${PWD})

echo -e "\nStarting Chainspace Node [${NODE_NAME}]...\n"

echo -e "Working Dir: [${PWD}]\n"

BFT_SMART_LIB=lib/bft-smart-1.0.0-DECODE.jar
CHAINSPACE_JAR=chainspace-1.0-SNAPSHOT-jar-with-dependencies.jar
CHECKER_START_PORT=__START_PORT__
MAIN_CLASS=uk.ac.ucl.cs.sec.chainspace.bft.TreeMapServer
CONFIG_FILE=config/node/config.txt
PYTHON_ENV_NAME=__PYTHON_ENV_NAME__



PYTHON_BIN=$(./find_python_bin.sh ${PYTHON_ENV_NAME})

if [[ ${PYTHON_BIN} == "no-python-env-found" ]]; then
    echo "Could not locate a python virtual env called [${PYTHON_ENV_NAME}]. This is essential, please create one!"
    exit 1
fi

LOG_DIR=/var/log/chainspace
mkdir -p ${LOG_DIR}

LOG_FILE=${LOG_DIR}/${NODE_NAME}-system.log

set -x
java -Dchecker.python.bin=${PYTHON_BIN} -Dchecker.start.port=${CHECKER_START_PORT} -cp ${BFT_SMART_LIB}:${CHAINSPACE_JAR} ${MAIN_CLASS} ${CONFIG_FILE} &> ${LOG_FILE} &
set +x
