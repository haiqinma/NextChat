#!/usr/bin/env bash

set -u
set -o pipefail

script_dir=$(cd "$(dirname "$0")" || exit;pwd)
service_dir=$(cd "${script_dir}"/.. || exit 1; pwd)
service_name=$(basename "$service_dir")

LOGFILE_PATH="/opt/logs"
LOGFILE_NAME="24-upgrade-${service_name}.log"
LOGFILE="$LOGFILE_PATH/$LOGFILE_NAME"
if [[ ! -d  "$LOGFILE_PATH" ]]
then
    mkdir -p "$LOGFILE_PATH"
fi

touch "$LOGFILE"

filesize=$(stat -c "%s" "$LOGFILE" )
if [[ "$filesize" -ge 1048576 ]]
then
    echo -e "clear old logs at $(date) to avoid log file too big" > "$LOGFILE"
fi

PORT=${NEXTCHAT_PORT:-3000}
HOSTNAME=${NEXTCHAT_HOSTNAME:-0.0.0.0}
RUNTIME_LOG="/opt/logs/24-runtime-${service_name}.log"

index=1
echo -e "\nstep $index -- upgrade ${service_name} begin. [$(date)]" | tee -a "$LOGFILE"

echo -e "step $index -- check runtime files" | tee -a "$LOGFILE"
if [[ ! -f "${service_dir}/server.js" ]]; then
    echo -e "ERROR! server.js is missing in ${service_dir}" | tee -a "$LOGFILE"
    exit 4
fi

index=$((index+1))
echo -e "\nstep $index -- stop old process on port ${PORT}" | tee -a "$LOGFILE"
if command -v lsof >/dev/null 2>&1; then
    PID=$(lsof -ti tcp:${PORT} || true)
    if [ -n "$PID" ]; then
        echo -e "killing process on port ${PORT}: ${PID}" | tee -a "$LOGFILE"
        kill -9 ${PID}
        while ps -p ${PID} > /dev/null 2>&1; do sleep 1; done
    else
        echo -e "no process found on port ${PORT}" | tee -a "$LOGFILE"
    fi
else
    echo -e "lsof not found, skip port check" | tee -a "$LOGFILE"
fi

index=$((index+1))
echo -e "\nstep $index -- start ${service_name} service" | tee -a "$LOGFILE"
pushd "$service_dir" > /dev/null
nohup env NODE_ENV=production HOSTNAME="$HOSTNAME" PORT="$PORT" node server.js > "$RUNTIME_LOG" 2>&1 &
popd > /dev/null

sleep 2
index=$((index+1))
echo -e "\nstep $index -- ${service_name} started on port ${PORT}" | tee -a "$LOGFILE"

echo -e "\nThis is the end of upgrade ${service_name}. ====$(date)====" | tee -a "$LOGFILE"
