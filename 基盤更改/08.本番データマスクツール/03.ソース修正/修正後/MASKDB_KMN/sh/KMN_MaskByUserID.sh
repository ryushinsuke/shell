#!/bin/sh
# ========================================================================
# �V�X�e���h�c  �F  KMN_MaskByUserID
# �V�X�e������  �F  �ږ�n�f�[�^�}�X�N�����Еʏ���
# �����T�v      �F  �ږ�n�f�[�^�}�X�N�����Еʏ���
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100629 �V�K GUT      �V�K�쐬
# 20130327 ���C GUT      �d�l�ύX�Ή�
# 20130920 ���C GUT����@�d�l�ύX�Ή�
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# �����J�n.
#------------------------------------------------------------------------
MASKDATE=$1
KAISYACD=$2
MASKHOME="$(cd $(dirname $0);pwd)/.."
SHL_PATH="${MASKHOME}/sh"
. ${MASKHOME}"/conf/KMN_MaskByUserID.conf"
#�c�[���̃��O�t�@�C��
LogFile=${MASKHOME}"/log/KMN_Mask_${KAISYACD}.log"
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

#MASK�f�[�^�x�[�X���[�U���擾�`�F�b�N
if [ -z ${TSYSDBNAME} ]
then
  echo "MASK�f�[�^�x�[�X���[�U���擾�ɃG���[���������܂����I"    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#MASK�f�[�^�x�[�XPASSWORD�擾�`�F�b�N
if [ -z ${TSYSDBPWD} ]
then
  echo "MASK�f�[�^�x�[�XPASSWORD�擾�ɃG���[���������܂����I"    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#MASK�f�[�^�x�[�X�ڑ��q�擾�`�F�b�N
if [ -z ${TRIREKIDB} ]
then
  echo "MASK�f�[�^�x�[�X�ڑ��q�擾�ɃG���[���������܂����I"      | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#����DMP�̃p�X�擾�`�F�b�N
if [ -z ${TASAIN_PATH} ]
then
  echo "����DMP�̃p�X�擾�ɃG���[���������܂����I"               | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#�f�[�^�C���|�[�g���O�p�X�擾�`�F�b�N
if [ -z ${TMASKWKDIR} ]
then
  echo "�f�[�^�C���|�[�g���O�p�X�擾�ɃG���[���������܂����I"    | tee -a $LogFile
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
#STEPNAME=KMNMASK010
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
#STEPNAME=KMNMASK020
if [ -f "${MASKHOME}/tmp/KMN_Masking.lock" ];then 
  echo "���� ���b�N�t�@�C��(KMN_Masking.lock)���݂�����܂��̂ŁA���s�I��!! ����"  | tee -a $LogFile 
  exit 1
else 
  touch "${MASKHOME}/tmp/KMN_Masking.lock" 
  break 
fi 

#------------------------------------------------------------------------
# �X�e�b�v-030  # �e�[�u��MASK_DB_K�쐬
#------------------------------------------------------------------------
#STEPNAME=KMNMASK030
echo "DROP TABLE MASK_DB_K CASCADE CONSTRAINTS PURGE;"        >  ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "/"                                                      >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "CREATE TABLE MASK_DB_K("                                >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "TABLE_NAME       VARCHAR2(30)   ,"                      >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "WHERE_NAIYOU     VARCHAR2(200)  ,"                      >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "UP_CLM_NAME      VARCHAR2(30)   ,"                      >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "SET_JOUHOU       VARCHAR2(300)  ,"                      >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "UPD_USER         VARCHAR2(30)   ,"                      >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo "UPD_YMD          VARCHAR2(08)   "                       >> ${MASKHOME}/tmp/MASK_DB_K.ddl
echo ");"                                                     >> ${MASKHOME}/tmp/MASK_DB_K.ddl
#
sqlplus  ${TRIREKIDB}  << SQL_END_D > /dev/null
         @${MASKHOME}/tmp/MASK_DB_K.ddl
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MASK DB CREATE ERR"                                     | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# �X�e�b�v-040  # �e�[�u��MASK_DB_K�Ƀf�[�^�����[�h
#------------------------------------------------------------------------
#STEPNAME=KMNMASK040
#---- CTL�쐬����
echo "LOAD DATA"                                              >  ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "TRUNCATE"                                               >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "INTO TABLE MASK_DB_K"                                   >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'"   >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "(TABLE_NAME      CHAR(30)  ,"                           >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "WHERE_NAIYOU     CHAR(200)  ,"                          >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "UP_CLM_NAME      CHAR(30)   ,"                          >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "SET_JOUHOU       CHAR(300)  ,"                          >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "UPD_USER         CHAR(30)   ,"                          >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo "UPD_YMD          CHAR(08)   "                           >> ${MASKHOME}/tmp/MASK_DB_K.ctl
echo ")"                                                      >> ${MASKHOME}/tmp/MASK_DB_K.ctl
#---- �f�[�^�t�@�C���̓���
sqlldr ${TRIREKIDB} \
control=${MASKHOME}/tmp/MASK_DB_K.ctl \
log=${MASKHOME}/log/MASK_DB_K_load.log \
data=${MASKHOME}/sql/MASK_DB_KMN.csv  > /dev/null 2>&1
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DATA LOAD ERR"                                          | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#---- �ꎞ�t�@�C�����N���A
rm -f ${MASKHOME}/tmp/MASK_DB_K.ddl
rm -f ${MASKHOME}/tmp/MASK_DB_K.ctl

#------------------------------------------------------------------------
# �X�e�b�v-050  # IMPORT�̃��O�t�@�C���o�̓p�X���쐬
#------------------------------------------------------------------------
#STEPNAME=KMNMASK050
if [ ! -e ${TMASKWKDIR} ]
then
    mkdir ${TMASKWKDIR}
fi

#------------------------------------------------------------------------
# �X�e�b�v-060  # INPUT DUMP�t�@�C����
#------------------------------------------------------------------------
#STEPNAME=KMNMASK060
if [ ! -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_1.exp.gz" ]
  then
  echo "DUMP�t�@�C��${TASAIN_PATH}/${KAISYACD}_kmn_1.exp.gz�����݂��܂���"  | tee -a $LogFile
  echo "***************************************************"    >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"    >>$LogFile
  #ERR���A���b�N�t�@�C���폜
  rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
  TS_RCODE=1
  exit $TS_RCODE
else
  gunzip -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_1.exp.gz"
  TS_STATUS=$?
  if [ "${TS_STATUS}" != "0" ];then
  echo "gunzip -f ${TASAIN_PATH}/${KAISYACD}_kmn_1.exp ERR"        | tee -a $LogFile
  echo "***************************************************"    >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"    >>$LogFile
  #ERR���A���b�N�t�@�C���폜
  rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
  TS_RCODE=1
  exit $TS_RCODE
  fi
fi
#------------------------------------------------------------------------
# �X�e�b�v-070  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=KMNMASK070
sqlplus ${KDBCONN} @${MASKHOME}"/sql/drop_all_tables.sql"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DROP ALL TABLES ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# �X�e�b�v-080  # DUMP�t�@�C����IMPORT����
#------------------------------------------------------------------------
#STEPNAME=KMNMASK080
#��ՍX���̏C���@START
FROM_SCHEMA=`cat ${MASKHOME}/conf/KMN_MASK.lst |grep -v '^#' |grep 'ORACLE,DB'|awk -F, '{print $3}' | awk -F\/ '{print $1}'`
if [ "${FROM_SCHEMA}" == "" ];then
  FROM_SCHEMA="apl"
fi
TO_SCHEMA="`echo ${KDBCONN} | awk -F\/ '{print $1}'`"
#imp ${KDBCONN} file=${TASAIN_PATH}"/"${KAISYACD}"_kmn_1.exp" log=${TMASKWKDIR}"/"${KAISYACD}_${MASKDATE}"_kmn_1.log" TABLES=(%)
sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${KDBCONN} ${TASAIN_PATH}/${KAISYACD}_kmn_1.exp ${KAISYACD}_${MASKDATE}_kmn_1.log "FULL=Y" REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA} > ${TMASKWKDIR}/${KAISYACD}_${MASKDATE}_kmn_1.log 2>&1
#��ՍX���̏C���@END
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMP�t�@�C��${TASAIN_PATH}/${KAISYACD}_kmn_1.exp IMPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# �X�e�b�v-090  # �Ώۃe�[�u�����X�g�t�@�C���쐬
#------------------------------------------------------------------------
#STEPNAME=KMNMASK090
echo "spool ${MASKHOME}/tmp/${KAISYACD}_parfile.lst "                    > ${MASKHOME}/tmp/get_table_list.sql
echo "SELECT TABLE_NAME FROM USER_TABLES \
WHERE (TABLE_NAME LIKE '%/_${KAISYACD}' ESCAPE '/' \
AND SUBSTR(TABLE_NAME,1,LENGTH(TABLE_NAME)-5) \
IN (SELECT DISTINCT TABLE_NAME FROM ${TSYSDBNAME}.MASK_DB_K)) \
OR TABLE_NAME IN (SELECT DISTINCT TABLE_NAME FROM ${TSYSDBNAME}.MASK_DB_K) ;" >> ${MASKHOME}/tmp/get_table_list.sql
echo "spool off"                                               >> ${MASKHOME}/tmp/get_table_list.sql
sqlplus ${KDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/get_table_list.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�Ώۃe�[�u���t�@�C���쐬 ERR"                           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
rm -f "${MASKHOME}/tmp/get_table_list.sql"
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# �X�e�b�v-100  # �}�X�N����
#------------------------------------------------------------------------
#STEPNAME=KMNMASK100
sqlplus ${KDBCONN} @${MASKHOME}"/sql/KMN_MASK.sql" ${TSYSDBNAME}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "           MASK ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# �X�e�b�v-110  # �ږ�n�f�[�^��Еʏo�͏����V�F���N��
#------------------------------------------------------------------------
#STEPNAME=KMNMASK110
  ${SHL_PATH}/KMN_OutputByUserID.sh  \
     "1"  \
     ${KAISYACD}  \
     ${MASKDATE}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo " �ږ�n�f�[�^��Еʏo�͏����V�F���N�� ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR���A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#�}�X�N�Ώ�EXP��A���b�N�t�@�C���폜
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"

#------------------------------------------------------------------------
# �X�e�b�v-120  # ����DUMP�t�@�C�����폜
#------------------------------------------------------------------------
#STEPNAME=KMNMASK120
rm -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_1.exp"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "rm ${TASAIN_PATH}/${KAISYACD}_kmn_1.exp ERR"               | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# �X�e�b�v-130  # �I������
#------------------------------------------------------------------------
#STEPNAME=KMNMASK120
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
rm -f "${MASKHOME}/tmp/get_table_list.sql"
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile
exit 0
