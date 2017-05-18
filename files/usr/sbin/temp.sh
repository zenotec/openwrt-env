#!/bin/sh

USAGE="$(basename ${0}) [AMB|TANK1|TANK2]"
ADDR="192.168.10.20"
LOCK="/var/run/Canakit"

if [ ${#} -ne 1 ]; then
  echo "Missing arguments"
  echo "${USAGE}"
  exit 1
fi

ping -qc 1 ${ADDR} > /dev/null
ret=${?}
if [ ${ret} -ne 0 ]; then
  echo "Host ${ADDR} is MIA"
  exit 1
fi

SENSOR=${1}

if [ "x${SENSOR}x" == "xAMBx" ]; then
  CMD_STR="TEMP4"
elif [ "x${SENSOR}x" == "xTANK1x" ]; then
  CMD_STR="TEMP5"
elif [ "x${SENSOR}x" == "xTANK2x" ]; then
  CMD_STR="TEMP6"
else
  echo "Unknown command"
  echo "${USAGE}"
  exit 1
fi

STATUS=1

if lockfile-create --use-pid --retry 6 ${LOCK}; then
  readarray -t OUTPUT <<< "$(ssh root@${ADDR} "CanaKit --cmd ${CMD_STR}")"
  DATE=$(date "+%D,%T")
  SENSOR=${OUTPUT[0]}
  TEMP=$(echo ${OUTPUT[1]} | awk '{print $2}')
  lockfile-remove ${LOCK}
  if [ "${OUTPUT[0]}" == "${CMD_STR}" ]; then
    echo "${DATE},${SENSOR},${TEMP}"
    STATUS=0
  else
    echo "Bad response"
  fi
else
  echo "Timed out creating lock"
fi

exit ${STATUS}

