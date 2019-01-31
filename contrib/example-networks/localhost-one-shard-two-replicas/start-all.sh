#!/usr/bin/env bash

#set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command


NODE_CONFIG_DIR=${1:-.}

CUR_DIR=${PWD}

DB_FILE="${CUR_DIR}/node_0_0/database.sqlite"

function wait-for-db {
  ATTEMPTS=0
  echo -e "\nWaiting for database to appear @ ${DB_FILE} ...\n"
  while :
  do
    echo "Looking for ${DB_FILE} [${ATTEMPTS}] ..."

    if [[ -e ${DB_FILE} ]]; then
      echo "Db available."
      break;
    fi

    ((ATTEMPTS++))
    if [[ ${ATTEMPTS} == 15 ]]; then
      echo "${DB_FILE} is still not available after 15 retries"
      echo "Exiting"
      exit 1
    fi
    sleep 2
  done

}
# TODO: Make this into a loop!
echo "Starting node [node_0_0]..."
cd ${NODE_CONFIG_DIR}/node_0_0
./start_node.sh &
cd -
echo "Started node_0_0."



echo "Starting node [node_0_1]..."
cd ${NODE_CONFIG_DIR}/node_0_1
./start_node.sh &
cd -
echo "Started node_0_1."


wait-for-db



echo "Starting client-api ..."
cd ${NODE_CONFIG_DIR}/client-api
./start_client_api.sh
cd -
echo "Started client-api."


