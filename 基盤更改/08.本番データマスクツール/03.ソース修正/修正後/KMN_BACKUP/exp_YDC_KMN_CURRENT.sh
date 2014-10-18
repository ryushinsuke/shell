#!/bin/sh
#set -x
#*********************************************************************
#�@�@�v���W�F�N�g�@�@:�f�[�^�o�b�N�A�b�v
#�@�@���W���[�����@�@:exp_YDC_KMN_CURRENT.sh
#�@�@���́@�@�@�@�@�@:�ږ�n���[�U�ʃo�b�N�A�b�v(�����N��)
#�@�@���͈��� �@�@�@ :�Ȃ�
#�@�@��������
#�@�@ �N���� �@�敪�@���e�@�@�@�@�@�@�@�@�@ ������
#�@�@ -------- ----�@---------------------�@---------
#�@�@ 20100706 �V�K�@�@�@�@�@�@�@�@�@�@�@�@�@GUT
#�@�@ 20130924 �C���@��ՍX���@�@�@�@�@�@�@�@GUT���
#*********************************************************************
source ~/.bash_profile

SYS_KJN=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)
#HOME_FILE=`cd $HOME_PATH/../../`
HOME_FILE=$HOME_PATH
LOG_FILE=$HOME_PATH/log/exp_YDC_KMN_CURRENT_${SYS_KJN}.log
#��ՍX���̏C���@START
#DMP_PATH=/ext/bkwork/pmo/YDC_DMP_KMN/CURRENT/PARAM

#--- �ږ�n�o�b�N�A�b�v���ꗗ�t�@�C����Ǎ���
CONF_FILE=${HOME_PATH}/exp_YDC_KMN.conf
if [ -f ${CONF_FILE} ];then
  . ${CONF_FILE}
else
  echo "�ږ�n�o�b�N�A�b�v���ꗗ ${HOME_PATH}/exp_YDC_KMN.conf ��������܂���B" |tee -a  ${LOG_FILE}
  exit 1
fi
DMP_PATH=${DMP_PATH}/CURRENT/PARAM
#��ՍX���̏C���@END
echo "**********   �O�����J�n"                                        |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:1          "                                   |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- �f�B���N�g�����݃`�F�b�N
if [ ! -d ${DMP_PATH} ];then
   mkdir -p ${DMP_PATH}
fi
rm -rf $HOME_PATH/log/codefile.lst
#---- ���t�t�@�C����􂢏o��
find ${DMP_PATH}/ -name "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" \
     -type f >$HOME_PATH/log/codefile.lst
#---- �G�N�X�|�[�g�������R�[��
CAL_SHELL()
{
#��ՍX���̏C���@START
#echo "**********   �N�X�|�[�g�������R�[��"                            |tee -a $LOG_FILE
echo "**********   �G�N�X�|�[�g�������R�[��"                          |tee -a $LOG_FILE
#��ՍX���̏C���@END
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:2         "                                    |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
sh ${HOME_PATH}/exp_YDC_KMN.sh ${KJN_FILE}
echo "**********   �t�@�C��${KJN_FILE}�𕽓��ɃG�N�X�|�[�g���܂���"   |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j "                                 |tee -a $LOG_FILE
echo "**********   POS:3        "                                     |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
}
#---- �G�N�X�|�[�g�Ώۂ�􂢏o��
for DD_PATH in  `cat $HOME_PATH/log/codefile.lst `
do
  KJN_FILE=`echo ${DD_PATH} |awk -F\/ '{print $NF}'`
  #---- ���t���݃`�F�b�N
  date -d "$KJN_FILE" "+%Y%m%d" 2>/dev/null | grep -q "$KJN_FILE"
  if [ "$?" == 0 ];then
     if [ "${KJN_FILE}" -eq "${SYS_KJN}" ];then
        #FILE_PATH=`pwd``echo "${DD_PATH}"|cut -c2-$p`
        dos2unix -q ${DD_PATH}
        #---- ���g�`�F�b�N
        if [ -s ${DD_PATH} ];then
           CODE_EG=`cat ${DD_PATH} | grep '[^0-9]'`
           CODE_UP=`cat ${DD_PATH} | egrep '[0-9]{5,}'`
           CODE_DW=`cat ${DD_PATH} |egrep '[0-9]{1,3}'|egrep -v '[0-9]{4}'`
           #---- 4�����`�F�b�N
           if [ "${CODE_EG}" == "" -a "${CODE_UP}" == "" -a "${CODE_DW}" == "" ];then
              CAL_SHELL
           fi
        fi
     fi
  fi
done
#*********************************************************************
#            ����I��
#*********************************************************************
echo "**********    ����I��              "                           |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:4            "                                 |tee -a $LOG_FILE
exit 0

