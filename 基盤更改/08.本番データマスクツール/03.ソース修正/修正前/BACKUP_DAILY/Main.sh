#!/bin/sh

source ~/.bash_profile
#-------------------------------------------------------------------------------------
HOME_PATH=$(cd $(dirname $0);pwd)

NOW=`date '+%Y%m%d'`
TIME=`date '+%H%M%S'`
TIME_COUNT=0
TRG_FILE_FLG=0

TRG_FILE="${HOME_PATH}/TRG/${NOW}_injxhukb030a_i.trg"

if [ ! -d ${HOME_PATH}/TRG ];then
    mkdir -pm 755 ${HOME_PATH}/TRG
fi

if [ ! -d ${HOME_PATH}/log ];then
    mkdir -pm 755 ${HOME_PATH}/log
fi

LOG_FILE=${HOME_PATH}/log/Main_${NOW}.log
#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#�V�F��_START                                                      " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------

TENGUN_KBN=$1
TRG_KBN=$2

if [ "${TENGUN_KBN}" == "" ];
then
	echo "�Ɩ��敪���w�肵�Ă�������!!"		    | tee -a ${LOG_FILE}
	exit 1
fi

while [ "${TIME_COUNT}" != "300" -a "${TRG_KBN}" == "TRG" ]
do 
	TIME=`date '+%H%M%S'`
	if [ -f ${TRG_FILE} ];
	then
		BTB_PROCESS="sh ${HOME_PATH}/exp_YDC_${TENGUN_KBN}.sh"
		${BTB_PROCESS} &
		let TRG_FILE_FLG=1
		let TIME_COUNT=300
	else
		sleep 60
		let TIME_COUNT=TIME_COUNT+1
	fi
done
if [ "${TRG_FILE_FLG}" == "0" -a "${TRG_KBN}" == "TRG" ];
then
		BTB_PROCESS="sh ${HOME_PATH}/exp_YDC_${TENGUN_KBN}.sh"
		${BTB_PROCESS} &
fi

#---- 30���O�̃t�@�C�����폜
BEFOR_WEEK0=`date --date '30 days ago' '+%Y%m%d'`
BEFOR_WEEK1=`date --date '31 days ago' '+%Y%m%d'`
BEFOR_WEEK2=`date --date '32 days ago' '+%Y%m%d'`

echo "30���O�̃t�@�C�����폜�J�n�u`date`�v"    | tee -a ${LOG_FILE}
rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK0}*
rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK1}*
rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK2}*
echo "30���O�̃t�@�C�����폜�����u`date`�v"    | tee -a ${LOG_FILE}

#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#�V�F��_END                                                        " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------
exit 0

