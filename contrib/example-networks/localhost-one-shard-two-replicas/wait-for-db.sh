#!/usr/bin/env bash

DB_FILE="${PWD}/node_0_0/database.sqlite"

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

wait-for-db
