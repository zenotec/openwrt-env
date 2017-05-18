#!/bin/sh

USAGE="$(basename ${0}) [TANK1|TANK2] TEMPERATURE (C)"

if [ ${#} -ne 2 ]; then
  echo "Missing arguments"
  echo "${USAGE}"
  exit 1
fi

ID=${1}
SET_TEMP=${2}
AMB_TEMP=$(sysmon_cli -c temp -o 4)

CMD_STR="sysmon_cli -c relay"

if [ "x${ID}x" == "xTANK1x" ]; then
  CMD_STR="${CMD_STR} -o channel=3"
  TANK_TEMP=$(sysmon_cli -c temp -o 5)
  CMP=$(echo "${SET_TEMP} >= ${TANK_TEMP}" | bc)
elif [ "x${ID}x" == "xTANK2x" ]; then
  CMD_STR="${CMD_STR} -o channel=4"
  TANK_TEMP=$(sysmon_cli -c temp -o 6)
  CMP=$(echo "${SET_TEMP} >= ${TANK_TEMP}" | bc)
else
  echo "Unsupported identifier: ${ID}"
  echo "${USAGE}"
  exit 1
fi

if [ ${CMP} -eq 1 ]; then
  CMD_STR="${CMD_STR} -o state=on"
  echo "$(date '+%D,%T'), ${AMB_TEMP}, ${ID}, ON, ${SET_TEMP}, ${TANK_TEMP}"
else
  CMD_STR="${CMD_STR} -o state=off"
  echo "$(date '+%D,%T'), ${AMB_TEMP}, ${ID}, OFF, ${SET_TEMP}, ${TANK_TEMP}"
fi


STATUS=0
OUTPUT=$(${CMD_STR})

exit ${STATUS}

