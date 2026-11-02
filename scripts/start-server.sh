#!/bin/bash
echo "---Checking Stratum---"
STRATUM_JSON="$(wget -qO- https://api.github.com/repos/trevorftp/Stratum/releases/latest)"
STRATUM_V="$(echo "${STRATUM_JSON}" | jq -r '.tag_name')"
STRATUM_DL_URL="$(echo "${STRATUM_JSON}" | jq -r '.assets[] | select(.name | contains("linux-x64")) | .browser_download_url')"
CUR_STRATUM_V="$(find ${DATA_DIR} -maxdepth 1 -name "stratum-installed-*" | sed 's/.*stratum-installed-//')"
if [ -z "${STRATUM_V}" ] || [ "${STRATUM_V}" = "null" ]; then
  echo "---Can't get latest Stratum version, continuing without update---"
elif [ -z "${CUR_STRATUM_V}" ] || [ "${CUR_STRATUM_V}" != "${STRATUM_V}" ]; then
  echo "---Downloading Stratum ${STRATUM_V}---"
  rm -f ${DATA_DIR}/stratum-installed-*
  if wget -q --show-progress --progress=bar:force:noscroll -O /tmp/stratum.zip "${STRATUM_DL_URL}" ; then
    echo "---Extracting Stratum ${STRATUM_V}---"
    unzip -o /tmp/stratum.zip -d ${DATA_DIR}/
    rm -f /tmp/stratum.zip
    touch ${DATA_DIR}/stratum-installed-${STRATUM_V}
    echo "---Stratum ${STRATUM_V} installed---"
  else
    echo "---Can't download Stratum, putting server into sleep mode!---"
    sleep infinity
  fi
else
  echo "---Stratum version up-to-date: ${STRATUM_V}---"
fi

echo "---Preparing Server---"
permission_probe="$(find "${DATA_DIR}" -mindepth 1 -type f -print -quit)"
if chmod "${DATA_PERM}" -- "${DATA_DIR}" 2>/dev/null && \
   { [ -z "${permission_probe}" ] || chmod "${DATA_PERM}" -- "${permission_probe}" 2>/dev/null; }; then
  chmod -R "${DATA_PERM}" "${DATA_DIR}"
else
  echo "---The data filesystem does not allow chmod; preserving existing permissions---"
fi
echo "---Checking for old logs---"
find ${DATA_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2&>/dev/null

echo "---Starting Server---"
cd ${DATA_DIR}
if [ -f "${DATA_DIR}/StratumServer" ]; then
  echo "---Launching Stratum (StratumServer)---"
  screen -S VintageStory -L -Logfile ${DATA_DIR}/masterLog.0 -d -m ${DATA_DIR}/StratumServer --dataPath ${DATA_DIR}/data ${GAME_PARAMS}
  sleep 2
  screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
  echo "---Stratum server started, tailing log---"
  tail -f ${DATA_DIR}/masterLog.0
else
  echo "---Can't find StratumServer executable, putting container into sleep mode!---"
  sleep infinity
fi