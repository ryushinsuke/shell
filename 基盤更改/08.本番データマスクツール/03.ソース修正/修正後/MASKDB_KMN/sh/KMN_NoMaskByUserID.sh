#!/bin/sh
# ========================================================================
# �W���uID      �FKMN_NoMaskByUserID
# �W���u��      �F�ږ�n�f�[�^�}�X�N�Ȃ���Еʏ���
# �����T�v      �F�ږ�n�f�[�^�}�X�N�Ȃ���Еʏ���
# ���͈���      �F �}�X�N���t
#               �F ��ЃR�[�h
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20130326 �V�K GUT      �V�K�쐬
# 20130927 �C�� GUT���  ��ՍX��
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# �����J�n.
#------------------------------------------------------------------------
MASKDATE=$1
KAISYACD=$2
MTBASEHOME="$(cd $(dirname $0);pwd)/.."
SHL_PATH="${MTBASEHOME}/sh"
. ${MTBASEHOME}"/conf/KMN_NoMaskByUserID.conf"
#�c�[���̃��O�t�@�C��
LogFile=${MTBASEHOME}"/log/KMN_NoMask_${KAISYACD}.log"
#------------------------------------------------------------------------
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LogFile
echo "***************************************************"    >>$LogFile

#��ՍX���̏C���@START
#---  �V�F��ID�擾�̔���
if [ -z ${Kshid} ]
then
  echo "�V�F��ID�擾�ɃG���[���������܂����I"                    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#�f�[�^�x�[�X�ڑ��q�擾�̔���
if [ -z ${KDBCONN} ]
then
  echo "�f�[�^�x�[�X�ڑ��q�擾�ɃG���[���������܂����I"          | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#�C���|�[�g�ږ�n�t�@�C���i�[�ꏊ�擾�̔���
if [ -z ${TASAIN_PATH} ]
then
  echo "�C���|�[�g�ږ�n�t�@�C���i�[�ꏊ�擾�ɃG���[���������܂����I" | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#DUMP�t�@�C���C���|�[�g���O�o�̓p�X�擾�̔���
if [ -z ${TMASKWKDIR} ]
then
  echo "DUMP�t�@�C���C���|�[�g���O�o�̓p�X�擾�ɃG���[���������܂����I" | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi
#��ՍX���̏C���@END
#------------------------------------------------------------------------
# �X�e�b�v-010  # �p�����[�^���`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA010
if [ $# -ne 2 ]
then
echo "usage: \$1 �}�X�N���t"                                  | tee -a $LogFile
echo "usage: \$2 ��ЃR�[�h"                                  | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------ 
# �X�e�b�v-020  # ���b�N�t�@�C���쐬 
#------------------------------------------------------------------------ 
#STEPNAME=KMNNOMA020
if [ -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock" ];then 
  echo "���� ���b�N�t�@�C��(KMN_NoMasking.lock)���݂�����܂��̂ŁA���s�I��!! ����"  | tee -a $LogFile 
  exit 1
else 
  touch "${MTBASEHOME}/tmp/KMN_NoMasking.lock" 
  break 
fi
#------------------------------------------------------------------------
# �X�e�b�v-030  # IMPORT�̃��O�t�@�C���o�̓p�X���쐬
#------------------------------------------------------------------------
#STEPNAME=KMNMASK030
if [ ! -e ${TMASKWKDIR} ]
then
    mkdir ${TMASKWKDIR}
fi
#------------------------------------------------------------------------
# �X�e�b�v-040  # INPUT DUMP�t�@�C����
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA040
if [ ! -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_2.exp.gz" ]
then
 echo "DUMP�t�@�C��${TASAIN_PATH}/${KAISYACD}_kmn_2.exp.gz�����݂��܂���"  | tee -a $LogFile
 echo "***************************************************"    >>$LogFile
 echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
 echo "***************************************************"    >>$LogFile
 #ERR���A���b�N�t�@�C���폜
 rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
 TS_RCODE=1
 exit $TS_RCODE
else
 gunzip -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_2.exp.gz"
 TS_STATUS=$?
 if [ "${TS_STATUS}" != "0" ];then
 echo "gunzip -f ${TASAIN_PATH}/${KAISYACD}_kmn_2.exp ERR"        | tee -a $LogFile
 echo "***************************************************"    >>$LogFile
 echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
 echo "***************************************************"    >>$LogFile
 #ERR���A���b�N�t�@�C���폜
 rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
 TS_RCODE=1
 exit $TS_RCODE
 fi
fi
#------------------------------------------------------------------------
# �X�e�b�v-050  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA050
sqlplus ${KDBCONN} @${MTBASEHOME}"/sql/drop_all_tables.sql"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DROP ALL TABLES ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-060  # DUMP�t�@�C����IMPORT����
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA060
#��ՍX���̏C���@START
FROM_SCHEMA=`cat ${MTBASEHOME}/conf/KMN_MASK.lst |grep -v '^#' |grep 'ORACLE,DB'|awk -F, '{print $3}' | awk -F\/ '{print $1}'`
if [ "${FROM_SCHEMA}" == "" ];then
  FROM_SCHEMA="apl"
fi
TO_SCHEMA="`echo ${KDBCONN} | awk -F\/ '{print $1}'`"
#imp ${KDBCONN} file=${TASAIN_PATH}"/"${KAISYACD}"_kmn_2.exp" log=${TMASKWKDIR}"/"${KAISYACD}_${MASKDATE}"_kmn_2.log" TABLES=(%)
sh BCZC0070.sh imp ${Kshid} ${KDBCONN} ${TASAIN_PATH}/${KAISYACD}_kmn_2.exp ${KAISYACD}_${MASKDATE}_kmn_2.log "FULL=Y" REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA} > ${TMASKWKDIR}/${KAISYACD}_${MASKDATE}_kmn_2.log 2>&1
#��ՍX���̏C���@END
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMP�t�@�C��${TASAIN_PATH}/${KAISYACD}_kmn_2.exp IMPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-070  # �ږ�n�f�[�^��Еʏo�͏����V�F���N��
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA070
  ${SHL_PATH}/KMN_OutputByUserID.sh  \
     "2"  \
     ${KAISYACD}  \
     ${MASKDATE}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo " �ږ�n�f�[�^��Еʏo�͏����V�F���N�� ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-080  # �I������
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA080
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
#--- ����I��
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile

#--- ����I��
exit 0
