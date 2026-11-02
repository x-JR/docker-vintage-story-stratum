#!/bin/bash
killpid="$(pgrep -n -f "/[S]tratumServer(\\.dll)?")"

if [ -z "${killpid}" ]; then
	exit 1
fi

tail --pid="${killpid}" -f /dev/null
log_pid="$(pgrep -n -f "tail -f ${DATA_DIR}/[m]asterLog.0")"
if [ -n "${log_pid}" ]; then
	kill "${log_pid}"
fi