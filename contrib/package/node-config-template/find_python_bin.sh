#!/usr/bin/env bash

set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command

VIRTUAL_ENV_NAME=$1


function check-for-bin {
    PATH=$1
    BIN_FILE=${PATH}/${VIRTUAL_ENV_NAME}

    if [[ -e ${BIN_FILE} ]]; then
        echo ${BIN_FILE}
    else
        echo "not-found"
    fi

}

FOUND=$(check-for-bin ${PWD})

START_DIR=${PWD}

while [[ ${FOUND} == "not-found" ]]; do
    cd ..
    if [[ ${PWD} == "/" ]]; then
        FOUND="no-python-env-found"
    else
        FOUND=$(check-for-bin ${PWD})
    fi
done

echo ${FOUND}/bin/python

cd ${START_DIR}
