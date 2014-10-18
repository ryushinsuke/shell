#!/bin/sh
# ========================================================================
# �V�X�e���h�c  �F
# �V�X�e������  �F
# �W���uID      �FKMN_OutputByUserID
# �W���u��      �F�ږ�n�f�[�^��Еʏo�͏���
# �����T�v      �F�w�肳�ꂽ��Ђ̃f�[�^���e�[�u���ʏo�͏���
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20130326 �V�K GUT      �V�K�쐬
# 20130920 ���C GUT����@�d�l�ύX�Ή�
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# �����J�n.
#------------------------------------------------------------------------
#--- ����1(�����敪)
MASK_KBN=$1
#--- ����2(��ЃR�[�h)
KAISYACD=$2
#--- ����2(�}�X�N���t)
MASKDATE=$3

MTBASEHOME="$(cd $(dirname $0);pwd)/.."
. ${MTBASEHOME}"/conf/KMN_OutputByUserID.conf"
#�c�[���̃��O�t�@�C��
LogFile=${MTBASEHOME}"/log/KMN_OutputByUserID_${KAISYACD}.log"
#��ՍX���̏C���@START
#---  �V�F�[��ID�擾�`�F�b�N
if [ -z ${Kshid} ]
then
  echo "�V�F�[��ID�擾�ɃG���[���������܂����I"                  | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#�f�[�^�x�[�XSYS���[�U�ڑ��q�擾�`�F�b�N
if [ -z ${KDBCONN} ]
then
  echo "�f�[�^�x�[�XSYS���[�U�ڑ��q�擾�ɃG���[���������܂����I" | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#�}�X�N���ꂽ�̏o�͌ږ�nDUMP�t�@�C���i�[�ꏊ�擾�`�F�b�N
if [ -z ${TASAOUT_PATH} ]
then
  echo "�ږ�nDUMP�t�@�C���o�͏ꏊ�擾�ɃG���[���������܂����I"  | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi
#��ՍX���̏C���@END
#------------------------------------------------------------------------
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LogFile
echo "***************************************************"    >>$LogFile
#------------------------------------------------------------------------
# �X�e�b�v-010  # �p�����[�^���`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=KMNTBL010
if [ $# -ne 3 ]
then
echo "usage: \$1 �����敪"                                  | tee -a $LogFile
echo "usage: \$2 ��ЃR�[�h"                                  | tee -a $LogFile
echo "usage: \$3 �}�X�N���t"                                  | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------ 
# �X�e�b�v-020  # ���b�N�t�@�C���쐬 
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL020
if [ -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock" ];then 
  echo "���� ���b�N�t�@�C��(KMN_OutputByUserID.lock)���݂�����܂��̂ŁA���s�I��!! ����"  | tee -a $LogFile 
  exit 1
else 
  touch "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock" 
  break 
fi
#------------------------------------------------------------------------ 
# �X�e�b�v-030  # Export�o�̓f�B���N�g���쐬
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL030
#��ՍX���̏C���@START
#if [ "1" = ${MASK_KBN} ];then
#  EXP_PATH="${TASAOUT_PATH}/${KAISYACD}_${MASK_KBN}_m"
#else
#  EXP_PATH="${TASAOUT_PATH}/${KAISYACD}_${MASK_KBN}"
#fi
if [ `date -d ${MASKDATE} '+%u'` -eq ${SAT_OF_WEEK} ] \
  || [ `date -d ${MASKDATE} '+%u'` -eq ${SUN_OF_WEEK} ];then
  EXP_PATH=${TASAOUT_PATH}/${MASKDATE}
else
#  EXP_PATH="${TASAOUT_PATH}/${KAISYACD}_${MASK_KBN}"
  EXP_PATH=${TASAOUT_PATH}/CURRENT
#��ՍX���̏C���@END
fi
if [ ! -d ${EXP_PATH} ]
then
    mkdir ${EXP_PATH}
fi
#------------------------------------------------------------------------ 
# �X�e�b�v-040  # ��Еʃe�[�u���ꗗ�t�@�C���쐬
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL040
echo "spool ${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst "  > ${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql
echo "SELECT TABLE_NAME FROM USER_TABLES ;" >> ${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql
echo "spool off"                                               >> ${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql
sqlplus ${KDBCONN} << SQL_END_D > /dev/null
     set pagesize 0
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�Ώۃe�[�u�����X�g�t�@�C���쐬 ERR"                     | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------ 
# �X�e�b�v-050  # �o��DUMP�t�@�C����EXPORT����
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL050
  while read TABLE_NAME_LIST
  do
#��ՍX���̏C���@START
#  exp ${KDBCONN} file="${EXP_PATH}/${TABLE_NAME_LIST}.exp" log="${EXP_PATH}/${TABLE_NAME_LIST}.log" TABLES=(${TABLE_NAME_LIST}) direct=y
sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${KDBCONN} ${EXP_PATH}/${TABLE_NAME_LIST}.exp ${TABLE_NAME_LIST}.log "TABLES=${TABLE_NAME_LIST}" > ${EXP_PATH}/${TABLE_NAME_LIST}.log 2>&1
#��ՍX���̏C���@END
   TS_STATUS=$?
   if [ "${TS_STATUS}" != "0" ];then
   echo "DUMP�t�@�C��${EXP_PATH}/${TABLE_NAME_LIST}${MASK_KBN}.exp EXPORT ERR" | tee -a $LogFile
   echo "***************************************************"    >>$LogFile
   echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
   echo "***************************************************"    >>$LogFile
   #ERR���A���b�N�t�@�C���폜
   rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
   rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
   rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
   TS_RCODE=1
   exit $TS_RCODE
   fi
   gzip -f "${EXP_PATH}/${TABLE_NAME_LIST}.exp"
   TS_STATUS=$?
   if [ "${TS_STATUS}" != "0" ];then
   echo "gzip -f ${EXP_PATH}/${TABLE_NAME_LIST}.exp ERR"      | tee -a $LogFile
   echo "***************************************************"    >>$LogFile
   echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
   echo "***************************************************"    >>$LogFile
   #ERR���A���b�N�t�@�C���폜
   rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
   rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
   rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
   TS_RCODE=1
   exit $TS_RCODE
   fi
  done < "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
#------------------------------------------------------------------------ 
# �X�e�b�v-060  # �I������
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL060
   rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
   rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
   rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"

#--- ����I��
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile
exit 0
