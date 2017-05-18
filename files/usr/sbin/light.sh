#!/bin/sh

USAGE="$(basename ${0}) [GB1|GB2|TANK1|TANK2] [ON|OFF]"
ADDR="192.168.10.20"
LOCK="/var/run/Canakit"

if [ ${#} -ne 2 ]; then
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

ID=${1}
CMD=${2}

if [ "x${ID}x" == "xGB1x" ]; then
  SWITCH="R"
  CHNL=1
elif [ "x${ID}x" == "xGB2x" ]; then
  SWITCH="R"
  CHNL=2
elif [ "x${ID}x" == "xTANK1x" ]; then
  SWITCH="G"
  CHNL=2
elif [ "x${ID}x" == "xTANK2x" ]; then
  SWITCH="G"
  CHNL=3
else
  echo "Unsupported identifier: ${ID}"
  echo "${USAGE}"
  exit 1
fi

if [ "x${CMD}x" == "xONx" ]; then
  CMD_STR="${SWITCH}${CMD}${CHNL}"
elif [ "x${CMD}x" == "xOFFx" ]; then
  CMD_STR="${SWITCH}${CMD}${CHNL}"
else
  echo "Unknown command"
  echo "${USAGE}"
  exit 1
fi

STATUS=1

if lockfile-create --use-pid --retry 5 ${LOCK}; then
  OUTPUT=$(ssh root@${ADDR} "CanaKit --addr lo --cmd ${CMD_STR}")
  if [ "${OUTPUT}" == "${CMD_STR}" ]; then
    STATUS=0
  fi
  lockfile-remove ${LOCK}
fi

exit ${STATUS}

