#!/bin/bash

INDEX=0
LOG_LEVELS=("INFO" "DEBUG" "TRACE" "WARN" "ERROR")
MESSAGES=(
    "Requesting starting at path: /api/dogs."
    "Request finished at path: /api/dogs. time: 50ms."
    "Executing action at Api.Controllers.GetDogs."
    "Unable to find dog with id: 1."
    "Unable to save dog with id: 1 to database. Exception: duplicate key exception."
)

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | [${LOG_LEVELS[INDEX]}] | starting log generator." >> logs.txt
while $true;
do
    LOG_MESSAGE="$(date -u +"%Y-%m-%dT%H:%M:%SZ") | [${LOG_LEVELS[INDEX]}] | ${MESSAGES[INDEX]}"
    echo $LOG_MESSAGE
    ((INDEX++))

    if [ "$INDEX" -eq 5 ]; then
        INDEX=0
    fi
    sleep 1
done