#!/bin/sh

USAGE="$(basename ${0}) TEMPERATURE (C)"
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

SET_TEMP=${1}

# Tank 1

TANKS="1 2"

for TANK in ${TANKS}; do
  OUTPUT=$(temp.sh TANK${TANK})
  SENSOR=$(echo ${OUTPUT} | awk -F, '{print $3}')
  TEMP=$(echo ${OUTPUT} | awk -F, '{print $4}')
  if [ "x${SENSOR}x" == "xx" ] || [ "x${TEMP}x" == "xx" ]; then
    echo "Failed to read temperature: ${OUTPUT}"
    ${0} ${1}
    exit ${?}
  fi
  CMP=$(echo "${SET_TEMP} >= ${TEMP}" | bc)
  if [ ${CMP} -eq 1 ]; then
    echo "$(date '+%D,%T'),TANK${TANK},ON,${SET_TEMP},${TEMP}"
    heater.sh TANK${TANK} OFF > /dev/null
  else
    echo "$(date '+%D,%T'),TANK${TANK},OFF,${SET_TEMP},${TEMP}"
    heater.sh TANK${TANK} ON > /dev/null
  fi
done

exit 0
