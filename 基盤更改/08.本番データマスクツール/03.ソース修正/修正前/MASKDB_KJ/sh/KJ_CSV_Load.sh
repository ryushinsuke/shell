#!/bin/sh
source ~/.bash_profile
# ========================================================================
# �V�X�e���h�c  �F  KJ_CSV_Load
# �V�X�e������  �F  ��n�f�[�^�}�X�NCSV���[�h����
# �����T�v      �F  ��n�f�[�^�}�X�NCSV���[�h����
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100407 �V�K GUT      �V�K�쐬
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# �����J�n
#------------------------------------------------------------------------
CSVLOADHOME="$(cd $(dirname $0);pwd)/.."
. ${CSVLOADHOME}"/conf/KJ_CSV_Load.conf"
#------------------------------------------------------------------------
echo "***************************************************"    >>$LOADLogFile
echo "SHL($LOADshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LOADLogFile
echo "***************************************************"    >>$LOADLogFile
#------------------------------------------------------------------------
# �X�e�b�v-010  # �e�[�u��MASK_DB�쐬
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK010
#---- SQL�t�@�C�����쐬
#
echo "DROP TABLE MASK_DB CASCADE CONSTRAINTS PURGE;"          >  ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "/"                                                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "CREATE TABLE MASK_DB("                                  >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "TABLE_NAME       VARCHAR2(30)   ,"                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "WHERE_NAIYOU     VARCHAR2(200)  ,"                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "UP_CLM_NAME      VARCHAR2(30)   ,"                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "SET_JOUHOU       VARCHAR2(300)  ,"                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "UPD_USER         VARCHAR2(30)   ,"                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo "UPD_YMD          VARCHAR2(08)   "                       >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
echo ");"                                                     >> ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
#
sqlplus  ${LOADRIREKIDB}  << SQL_END_D > /dev/null
           @${CSVLOADHOME}/tmp/MASK_DB_U.ddl
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "MASK DB CREATE ERR"                                     | tee -a $LOADLogFile
echo "***************************************************"    >>$LOADLogFile
echo "SHL($LOADshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LOADLogFile
echo "***************************************************"    >>$LOADLogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-012  # �e�[�u��MASK_DB�Ƀf�[�^LOAD
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK012
#---- CTL�쐬����
echo "LOAD DATA"                                              >  ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "TRUNCATE"                                               >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "INTO TABLE MASK_DB"                                     >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'"   >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "(TABLE_NAME      CHAR(30)  ,"                           >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "WHERE_NAIYOU     CHAR(200)  ,"                          >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "UP_CLM_NAME      CHAR(30)   ,"                          >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "SET_JOUHOU       CHAR(300)  ,"                          >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "UPD_USER         CHAR(30)   ,"                          >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "UPD_YMD          CHAR(08)   "                           >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo ")"                                                      >> ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
#---- �f�[�^�t�@�C���̓���
sqlldr ${LOADRIREKIDB} \
       control=${CSVLOADHOME}/tmp/MASK_DB_U.ctl \
       log=${CSVLOADHOME}/log/MASK_DB_U_load.log \
       data=${CSVLOADHOME}/sql/MASK_DB_KJ.csv  > /dev/null 2>&1
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DATA LOAD ERR"                                          | tee -a $LOADLogFile
echo "***************************************************"    >>$LOADLogFile
echo "SHL($LOADshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LOADLogFile
echo "***************************************************"    >>$LOADLogFile
TS_RCODE=1
exit $TS_RCODE
fi
#---- �ꎞ�t�@�C�����N���A
rm -f ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
rm -f ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "***************************************************"    >>$LOADLogFile
echo "SHL($LOADshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LOADLogFile
echo "***************************************************"    >>$LOADLogFile
exit 0

