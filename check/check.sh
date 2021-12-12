#!/bin/bash

ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

source ${DIRECTORY}/config
currStamp=`date +%s`

for backup_dir in `ls -d ${prefix}/backup-*`
do
    echo Directory ${backup_dir}:
    lastFull=`cd ${backup_dir}/ && ls -t *-[F].t* 2>/dev/null | head -n 1`
    lastDaily=`cd ${backup_dir}/ && ls -t *-[DI].t* 2>/dev/null | head -n 1`
    echo LF: ${lastFull:-WARN == FULL NOT FOUND}
    echo LD: ${lastDaily:-WARN == DAILY NOT FOUND}
    if [[ -n ${lastFull} ]]
    then
	lastFullStamp=`echo ${lastFull} | awk -F '-' '{ print $1 }'`
	lastFullDelta=`expr ${currStamp} - ${lastFullStamp}`
	if [ "${fullSecMax}" -gt "${lastFullDelta}" ]
	then
	    echo "OK - Full delta ${lastFullDelta} OK"
	else
	    echo "FAIL == LAST FULL EXPIRED"
	fi

    fi

    if [[ -n ${lastDaily} ]]
    then
	lastDailyStamp=`echo ${lastDaily} | awk -F '-' '{ print $1 }'`
	lastDailyDelta=`expr ${currStamp} - ${lastDailyStamp}`
	if [ "${dailySecMax}" -gt "${lastDailyDelta}" ]
	then
	    echo "OK - Daily delta ${lastDailyDelta} OK"
	else
	    echo "FAIL == LAST DAILY EXPIRED"
	fi
    fi

done

