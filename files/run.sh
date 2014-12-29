#! /usr/bin/env bash
set -o errexit -o pipefail

## CrashPlan root path
CRASHPLAN_PATH="/usr/local/crashplan"

## Set file paths
PID_FILE="${CRASHPLAN_PATH}/CrashPlanEngine.pid"
SERVICE_FILE="${CRASHPLAN_PATH}/conf/my.service.xml"

## Get serviceHost line info
SERVICE_HOST="$(grep -n '<serviceHost>127.0.0.1</serviceHost>' ${SERVICE_FILE})"

## Expose service port
if [[ ! -z "${SERVICE_HOST}" ]]; then

    LINE="$(echo ${SERVICE_HOST} | awk -F : '{print $1}')"

    echo "Exposing service port to host"
    sed -i "${LINE}s/127.0.0.1/0.0.0.0/g" ${SERVICE_FILE}

fi

## Kill crashplan
function killCrashplan(){
    kill $(cat ${PID_FILE}); exit 0
}

## Set trap
trap 'killCrashplan' SIGINT SIGTERM

## Launch daemon
${CRASHPLAN_PATH}/bin/CrashPlanEngine start; sleep 2

## Loop while the pidfile and the process exist
while [[ -f ${PID_FILE} ]] && kill -0 $(cat ${PID_FILE}); do
    sleep 1
done

## Exit
exit 1
