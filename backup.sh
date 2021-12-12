#!/bin/bash

ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`

source ${DIRECTORY}/config

uuid=`uuid`
stamp=`date +%s`-`date +"%Y%m%d-%H%M%S-I"`
do_full=""
do_quet=0

while getopts "fq" opt; do
    case $opt in
	f) do_full=1;;
	q) do_quet=1;;
# -f -full
# -q -quet (no verbose output)
	esac
done


if [ -n "${do_full}" ]
then
    if [ "${do_quet}" == 0 ]
    then
        echo "Full backup started"
    fi

    stamp=`date +%s`-`date +"%Y%m%d-%H%M%S-F"`
    rm -f ${prefix}/incremental/*
fi

if [ ! -d "${prefix}/incremental" ]; then
    # Создать папку, только если ее не было
    mkdir ${prefix}/incremental
fi

if [ ! -d "${prefix}/compressed" ]; then
    # Создать папку, только если ее не было
    mkdir ${prefix}/compressed
fi

mkdir ${prefix}/${stamp}

# SQL DB Backup
for sql_item in ${sql_list}
do
    if [ "${do_quet}" == 0 ]
    then
	echo -n "Collecting database ${sql_item//:/ }...."
    fi

    #${sqldump_prefix} ${sql_item//:/ } | gzip > ${prefix}/${stamp}/${sql_item//:/.}.sql.gz

    if [[ -f "${prefix}/incremental/${sql_item//:/.}.sql" ]]
    then
	xsuffix=".diff"
	${sqldump_prefix} ${sql_item//:/ } | diff ${prefix}/incremental/${sql_item//:/.}.sql - > ${prefix}/${stamp}/${sql_item//:/.}.sql.diff
    else
	${sqldump_prefix} ${sql_item//:/ } | cat > ${prefix}/${stamp}/${sql_item//:/.}.sql
	cp ${prefix}/${stamp}/${sql_item//:/.}.sql ${prefix}/incremental/
    fi
    if [ "${do_quet}" == 0 ]
    then
        echo "OK"
    fi
done

#Archiving SQL for DIFF

#Files Full Backup
for file_item in ${files_list}
do
    xfolder=`echo ${file_item} | awk -F : '{ print $1 }'`
    if [[ -n "`echo ${file_item} | awk -F : '{ print $2 }'`" ]]
    then
	xsubfolders=`echo ${file_item} | sed -e 's/^[^:]*://'`
    else
        xsubfolders="*"
    fi

    if [ "${do_quet}" == 0 ]
    then
        echo -n "Collecting folder ${xfolder}...."
    fi
    if [[ -f "${prefix}/incremental/${xfolder////_}.snar" ]]
    then
	cp ${prefix}/incremental/${xfolder////_}.snar ${prefix}/incremental/${xfolder////_}.snar.diff
	xsuffix=".diff"
    else
	xsuffix=""
    fi

    cd ${xfolder} && tar -c --listed-incremental=${prefix}/incremental/${xfolder////_}.snar${xsuffix} -f ${prefix}/${stamp}/${xfolder////_}${xsuffix}.tar ${xsubfolders//:/ }
    rm -f ${prefix}/incremental/${xfolder////_}.snar.diff
    if [ "${do_quet}" == 0 ]
    then
	echo "OK"
    fi
done

# Compressing
cd ${prefix}/${stamp} && tar -czf ${prefix}/compressed/${stamp}.tgz *
rm -f $prefix/$stamp/*
rmdir $prefix/$stamp

# Sending data
if [ -n "${sshhost}" ]
then
	for xfile_item in `ls ${prefix}/compressed`
	do
	    scp -B -i ${sshkey} ${prefix}/compressed/${xfile_item} ${sshuser}@${sshhost}:${sshpath} > /dev/null
	    if [ "$?" == 0 ]
	    then
		rm -f ${prefix}/compressed/${xfile_item}
	    fi
	done
fi

