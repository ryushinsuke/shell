#!/bin/sh

source ~/.bash_profile
#-------------------------------------------------------------------------------------
HOME_PATH=$(cd $(dirname $0);pwd)
TRG_FILE="/ext/unyoshare/trg/apl/injxhukb030a_i.trg"

NOW=`date '+%Y%m%d'`
TIME=`date '+%H%M%S'`
TIME_COUNT=0

if [ ! -d ${HOME_PATH}/TRG ];then
    mkdir -pm 755 ${HOME_PATH}/TRG
fi

if [ ! -d ${HOME_PATH}/log ];then
    mkdir -pm 755 ${HOME_PATH}/log
fi

LOG_FILE=${HOME_PATH}/log/checkTrg_${NOW}.log
#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#シェル_START                                                      " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------

while [ "${TIME_COUNT}" != "300" ]
do 
	if [ -f ${TRG_FILE} ];
	then
		touch ${HOME_PATH}/TRG/${NOW}_injxhukb030a_i.trg
		let TIME_COUNT=300
	else
		sleep 60
		let TIME_COUNT=TIME_COUNT+1
	fi
done
#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#シェル_END                                                        " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------
exit 0

