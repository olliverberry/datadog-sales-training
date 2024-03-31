#!/bin/bash

MESSAGES=(
    "[INFO] | Requesting starting at path: GET /api/dogs."
    "[DEBUG] | Request finished at path: GET /api/dogs. time: 50ms."
    "[TRACE] | Executing action at Api.Controllers.GetDogs."
    "[INFO] | Requesting starting at path: GET /api/dogs/{id}."
    "[DEBUG] | Request finished at path: GET /api/dogs/{id}. time: 50ms."
    "[TRACE] | Executing action at Api.Controllers.GetDogById."
    "[WARN] | Unable to find dog with id: 1."
    "[INFO] | Requesting starting at path: DELETE /api/dogs/{id}."
    "[DEBUG] | Request finished at path: DELETE /api/dogs/{id}. time: 50ms."
    "[TRACE] | Executing action at Api.Controllers.DeleteDogById."
    "[DEBUG] | Successfully delete dog with id: 1 from the database."
    "[INFO] | Requesting starting at path: POST /api/dogs/{id}."
    "[DEBUG] | Request finished at path: POST /api/dogs/{id}. time: 50ms."
    "[TRACE] | Executing action at Api.Controllers.CreateDog."
    "[ERROR] | Unexpected error occurred while create dog with id: 10. Exception: duplication key exception"
)

while $true;
do
    INDEX=0
    for MESSAGE in "${MESSAGES[@]}"; do
        LOG_MESSAGE="$(date -u +"%Y-%m-%dT%H:%M:%SZ") | $MESSAGE"
        echo $LOG_MESSAGE
        ((INDEX++))
    done
    sleep 1
done