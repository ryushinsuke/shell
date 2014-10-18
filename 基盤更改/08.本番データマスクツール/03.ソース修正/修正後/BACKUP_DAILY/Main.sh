#!/bin/sh
# =======================================================================
# �V�X�e���h�c  �F  Main
# �V�X�e������  �F  ��n�{�ԃf�[�^�G�N�X�|�[�g���C�������V�F��
# �����T�v      �F  �g���K�[�t�@�C���i${NOW}_injxhukb030a_i.trg�j�̑��݃`�F�b�N���s���A
#                   ���݂��Ȃ��ꍇ�A��莞�ԋN�����Ȃ��悤�ɐ�����s���B
#                   �q�V�F���̋N�����s���B
# ���͈���      �F  �@ �Ɩ��敪
#                   �A TRG�敪
# ���^�[���R�[�h�F  �O�F����I��
#                   �P�F�ُ�I��
# ��������
# �N����   �敪 �S����    ���e
# -------- ---- --------- -----------------------------------------------
#          �V�K GUT       �V�K�쐬
# 20130917 �C�� GUT���u�p ��ՍX��
# =======================================================================
source ~/.bash_profile
#-------------------------------------------------------------------------------------
HOME_PATH=$(cd $(dirname $0);pwd)

NOW=`date '+%Y%m%d'`
TIME=`date '+%H%M%S'`
TIME_COUNT=0
TRG_FILE_FLG=0

TRG_FILE="${HOME_PATH}/TRG/${NOW}_injxhukb030a_i.trg"

#��ՍX���̏C���@START
#if [ ! -d ${HOME_PATH}/TRG ];then
#    mkdir -pm 755 ${HOME_PATH}/TRG
#fi
#��ՍX���̏C���@END

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

#��ՍX���̏C���@START
#---- 30���O�̃t�@�C�����폜
#BEFOR_WEEK0=`date --date '30 days ago' '+%Y%m%d'`
#BEFOR_WEEK1=`date --date '31 days ago' '+%Y%m%d'`
#BEFOR_WEEK2=`date --date '32 days ago' '+%Y%m%d'`

#echo "30���O�̃t�@�C�����폜�J�n�u`date`�v"    | tee -a ${LOG_FILE}
#rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK0}*
#rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK1}*
#rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK2}*
#echo "30���O�̃t�@�C�����폜�����u`date`�v"    | tee -a ${LOG_FILE}
#��ՍX���̏C���@END

#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#�V�F��_END                                                        " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------
exit 0
