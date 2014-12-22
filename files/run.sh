#! /usr/bin/env bash
set -o errexit -o pipefail

## Set pidfile path
PID_FILE="/usr/local/crashplan/CrashPlanEngine.pid"

## Proxy signals
function killCrashplan(){
    kill $(cat ${PID_FILE}); exit 0
}

## Set trap
trap "kill_app" SIGINT SIGTERM

## Launch daemon
/usr/local/crashplan/bin/CrashPlanEngine start; sleep 2

## Loop while the pidfile and the process exist
while [[ -f ${PID_FILE} ]] && kill -0 $(cat ${PID_FILE}); do
    sleep 1
done

## Exit
exit 1
