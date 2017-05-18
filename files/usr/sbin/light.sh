#!/bin/sh

USAGE="$(basename ${0}) [GB1|GB2] [ON|OFF]"

if [ ${#} -ne 2 ]; then
  echo "Missing arguments"
  echo "${USAGE}"
  exit 1
fi

ID=${1}
CMD=${2}
CMD_STR="sysmon_cli -c relay"

if [ "x${ID}x" == "xGB1x" ]; then
  CMD_STR="${CMD_STR} -o channel=1"
elif [ "x${ID}x" == "xGB2x" ]; then
  CMD_STR="${CMD_STR} -o channel=2"
else
  echo "Unsupported identifier: ${ID}"
  echo "${USAGE}"
  exit 1
fi

if [ "x${CMD}x" == "xONx" ]; then
  CMD_STR="${CMD_STR} -o state=on"
elif [ "x${CMD}x" == "xOFFx" ]; then
  CMD_STR="${CMD_STR} -o state=off"
else
  echo "Unknown command"
  echo "${USAGE}"
  exit 1
fi

STATUS=0
OUTPUT=$(${CMD_STR})

exit ${STATUS}

