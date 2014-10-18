#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B00SCM201.sh
#�@�@���́@�@�@�@�@:���b�Z�[�W�o��
#�@�@�����T�v�@�@�@:���s���b�Z�[�W���o�͂���B
#�@�@�@�@�@�@�@�@�@ �ꍇ�ɂ���āA�o�͐�̓X�N���[���A���O�t�@�C���A
#�@�@�@�@�@�@�@�@�@ �G���[���O�t�@�C�����قȂ�B
#�@�@�`�q�f�@�@�@�@:1�@�����o�f�l
#�@�@�@�@�@�@�@�@�@:2�@�T�[�o�[�敪
#�@�@�@�@�@�@�@�@�@:3�@�����ӏ�
#�@�@�@�@�@�@�@�@�@:4�@���b�Z�[�WID
#�@�@�@�@�@�@�@�@�@:5�@�⑫���e
#�@�@�@�@�@�@�@�@�@:6�@���O�L���敪
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20101230 �V�K                         GUT �I�F
#***************************************************************
#***************************************************************
#  �������`�F�b�N
#***************************************************************
if [ $# != 6 ]
then
  echo "���͈������s���ł���B"
  exit 9
fi
#***************************************************************
LOG_PROC()
{
     echo "����������������������������������"                         | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "�y<${MsgLel}>${PGM} ${SVR_KBN}:<${TimeStamp}>:<${POS}>�z"   | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${MsgNay}"                                                  | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${HOSUNAY}"                                                 | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
}

LOG_PROC2()
{
     echo "����������������������������������"                         >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "�y<${MsgLel}>${PGM} ${SVR_KBN}:<${TimeStamp}>:<${POS}>�z"   >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${MsgNay}"                                                  >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${HOSUNAY}"                                                 >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
}

#---- �o�͓��e�擾
#---- ����PGM
PGM=$1
PGM_ID=`echo "$1" | awk -F\. '{print $1}'`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- �T�[�o�[�敪
SVR_KBN=$2
#---- �����ӏ�
POS=$3
#---- ���b�Z�[�W���x��
MsgLel=`echo "$4" | cut -c0-1`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- ���b�Z�[�W���e
MsgNay=`grep -w $4 ${CONF_PATH}/B21TCG202.def | awk -F, '{print $2}'`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- �⑫���e
HOSUNAY=$5
#---- ���O�t�@�C���L���敪
LogKun=`echo "$6" | awk '{print substr($1,1,1)}'`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- �G���[���O�t�@�C���L���敪
ELogKun=`echo "$6" | awk '{print substr($1,2,1)}'`
if [ "$?" != 0 ]
then
  exit 9
fi

TimeStamp=`date +%Y%m%d%H%M%S`
TmStamp=`date +%Y%m%d`
#
if [ ${LogKun} -ne 0 ]; then
    LogPath=${LOG_PATH}/${PGM_ID}_${TmStamp}.log
    LOG_PROC ${LogPath}
fi

if [ ${ELogKun} -ne 0 ]; then
    ELogPath=${ERR_LOG_PATH}/${PGM_ID}_${TmStamp}.err
    LOG_PROC2 ${ELogPath}
fi
exit 0
