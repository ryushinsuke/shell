#!/bin/sh
# ========================================================================
# �V�X�e���h�c  �F  OUT_Mask
# �V�X�e������  �F  OUT�n�f�[�^�}�X�N����
# �����T�v      �F  OUT�n�f�[�^�}�X�N����
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100127 �V�K GUT      �V�K�쐬
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# �����J�n
#------------------------------------------------------------------------
KAISYACD=$1
MASKHOME="$(cd $(dirname $0);pwd)/.."
. ${MASKHOME}"/sh/OUT_Mask.conf"
#�c�[���̃��O�t�@�C��
LogFile=${MASKHOME}"/log/OUT_Mask_${KAISYACD}.log"
#------------------------------------------------------------------------
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LogFile
echo "***************************************************"    >>$LogFile
#------------------------------------------------------------------------
# �X�e�b�v-010  # �p�����[�^���`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=OUTMASK010
if [ $# -ne 1 ];
then
echo "usage: $1 KAISYA_CODE"                                  | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-010-1  # ������Ў��s�`�F�b�N
#------------------------------------------------------------------------
job_process_user_cnt=`ps -ef|grep -w "${shid}.sh"|grep -w "${KAISYACD}"|grep -v 'grep'|wc -l`
if [ "${job_process_user_cnt}" != "2" ];then
  echo "�Y����Ђ̃f�[�^�̓}�X�N���c�A�I���I"                 | tee -a $LogFile
  exit 1
fi
#------------------------------------------------------------------------
# �X�e�b�v-010-2  # ���b�N�t�@�C���쐬
#------------------------------------------------------------------------
while [ 1 ]
  do
  if [ -f "${MASKHOME}/tmp/OUT_Masking.lock" ];then
    echo "���s�҂��c�A5����Ď��s���āA�҂��Ă��������I"     | tee -a $LogFile
    sleep 300
  else
    touch "${MASKHOME}/tmp/OUT_Masking.lock"
    break
  fi
done
#------------------------------------------------------------------------
# �X�e�b�v-011  # ���[�NDB�Ə��DB�\�z
#------------------------------------------------------------------------
#STEPNAME=OUTMASK011
#���[�NDB�\�z
sqlplus ${SYSDBCONN} @${MASKHOME}"/sql/create_tmp_user.sql" ${WKDBNAME} ${WKDBPWD}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "CREATE TMP USER ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-012  # ���[�NDB�N���A
#------------------------------------------------------------------------
#STEPNAME=OUTMASK012
sqlplus ${WKDBCONN} @${MASKHOME}"/sql/drop_all_tables.sql"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DROP ALL TABLES ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-013  # ���DB�\�z
#------------------------------------------------------------------------
#STEPNAME=OUTMASK013
sqlplus ${SYSDBCONN} @${MASKHOME}"/sql/create_tmp_user.sql" ${JHDBNAME} ${JHDBPWD}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "CREATE ��� USER ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-014  # �e�[�u��MASK_DB_O�쐬
#------------------------------------------------------------------------
#STEPNAME=OUTMASK014
#---- SQL�t�@�C�����쐬
#
echo "DROP TABLE MASK_DB_O CASCADE CONSTRAINTS PURGE;"        >  ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "/"                                                      >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "CREATE TABLE MASK_DB_O("                                >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "TABLE_NAME       VARCHAR2(30)   ,"                      >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "WHERE_NAIYOU     VARCHAR2(200)  ,"                      >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "UP_CLM_NAME      VARCHAR2(30)   ,"                      >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "SET_JOUHOU       VARCHAR2(300)  ,"                      >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "UPD_USER         VARCHAR2(30)   ,"                      >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo "UPD_YMD          VARCHAR2(08)   "                       >> ${MASKHOME}/tmp/MASK_DB_O.ddl
echo ");"                                                     >> ${MASKHOME}/tmp/MASK_DB_O.ddl
#
sqlplus  ${JHDBCONN}  << SQL_END_D > /dev/null
           @${MASKHOME}/tmp/MASK_DB_O.ddl
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MASK DB CREATE ERR"                                     | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-015  # ���DB�f�[�^LOAD
#------------------------------------------------------------------------
#STEPNAME=OUTMASK015
#---- CTL�쐬����
echo "LOAD DATA"                                              >  ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "TRUNCATE"                                               >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "INTO TABLE MASK_DB_O"                                   >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'"   >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "(TABLE_NAME      CHAR(30)  ,"                           >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "WHERE_NAIYOU     CHAR(200)  ,"                          >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "UP_CLM_NAME      CHAR(30)   ,"                          >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "SET_JOUHOU       CHAR(300)  ,"                          >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "UPD_USER         CHAR(30)   ,"                          >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo "UPD_YMD          CHAR(08)   "                           >> ${MASKHOME}/tmp/MASK_DB_O.ctl
echo ")"                                                      >> ${MASKHOME}/tmp/MASK_DB_O.ctl
#---- �f�[�^�t�@�C���̓���
sqlldr ${JHDBCONN} \
control=${MASKHOME}/tmp/MASK_DB_O.ctl \
log=${MASKHOME}/log/MASK_DB_OUT_load.log \
data=${MASKHOME}/sql/MASK_DB_OUT.csv  > /dev/null 2>&1
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DATA LOAD ERR"                                          | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#---- �ꎞ�t�@�C�����N���A
rm -f ${MASKHOME}/tmp/MASK_DB_O.ddl
rm -f ${MASKHOME}/tmp/MASK_DB_O.ctl
#------------------------------------------------------------------------
# �X�e�b�v-020  # �Ώۃe�[�u��DUMP�t�@�C���쐬
#------------------------------------------------------------------------
#STEPNAME=OUTMASK020
#�Ώۃe�[�u�����X�g�擾
echo "spool ${MASKHOME}/tmp/${KAISYACD}_table_list.txt"       > ${MASKHOME}/tmp/get_${KAISYACD}_table_list.sql
echo "SELECT TABLE_NAME FROM USER_TABLES@DBMASK_OUT_LINK \
WHERE (TABLE_NAME LIKE '%/_${KAISYACD}' ESCAPE '/' \
AND SUBSTR(TABLE_NAME,1,LENGTH(TABLE_NAME)-5) \
IN (SELECT DISTINCT TABLE_NAME FROM ${JHDBNAME}.MASK_DB_O)) \
OR TABLE_NAME IN (SELECT DISTINCT TABLE_NAME FROM ${JHDBNAME}.MASK_DB_O) \
OR (TABLE_NAME LIKE '%/_K_' ESCAPE '/' \
AND SUBSTR(TABLE_NAME,1,LENGTH(TABLE_NAME)-3) \
IN (SELECT DISTINCT TABLE_NAME FROM ${JHDBNAME}.MASK_DB_O));" >> ${MASKHOME}/tmp/get_${KAISYACD}_table_list.sql
echo "spool off"                                              >> ${MASKHOME}/tmp/get_${KAISYACD}_table_list.sql
sqlplus ${CMNDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/get_${KAISYACD}_table_list.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MOVE�p�Ώۃe�[�u�����X�g�擾 ERR"                       | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#�Ώۃe�[�u��DUMP�p���X�g�t�@�C���쐬
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
echo "" > "${MASKHOME}/tmp/${KAISYACD}_create_temp_table.sql"
TMP_FLG=1
for TABLE_NAME in `cat ${MASKHOME}/tmp/${KAISYACD}_table_list.txt`
do
if [ ${TABLE_NAME} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TABLE_NAME}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
else
echo ",${TABLE_NAME}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
fi
TMP_FLG=`expr ${TMP_FLG} + 1`
fi
echo "create table ${TABLE_NAME} as select * from ${TABLE_NAME}@DBMASK_OUT_LINK where 1=2;" >> "${MASKHOME}/tmp/${KAISYACD}_create_temp_table.sql"
done
echo ")"                                                      >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
rm -f ${MASKHOME}/tmp/get_${KAISYACD}_table_list.sql
rm -f ${MASKHOME}/tmp/${KAISYACD}_table_list.txt
if [ ${TMP_FLG} != 1 ]
then
#MOVE�pDUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MOVE�pDUMP�t�@�C��EXPORT ERR"                           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
sqlplus ${WKDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/${KAISYACD}_create_temp_table.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�}�X�N�Ώۃe�[�u��WKDB�ɍ쐬 ERR"                 | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#MOVE�pDUMP�t�@�C����IMPORT����
imp ${WKDBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.dmp ignore=y log=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MOVE�pDUMP�t�@�C��IMPORT ERR"                           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
rm -f ${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.dmp
rm -f ${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.log
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
fi
#------------------------------------------------------------------------
# �X�e�b�v-021  # �}�X�N����
#------------------------------------------------------------------------
#STEPNAME=OUTMASK021
sqlplus ${WKDBCONN} @${MASKHOME}"/sql/OUT_Mask.sql" ${JHDBNAME}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "           MASK ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
##���ʂƋƖ��f�[�^�������Ɩ��f�[�^�쐬�J�n##
if [ "${KAISYACD}" != "0000" ];then
#------------------------------------------------------------------------
# �X�e�b�v-022  # �Y����Ѓ}�X�N�Ώۃe�[�u�����X�g�擾
#------------------------------------------------------------------------
#STEPNAME=OUTMASK022
COUNT_FLG=1
echo "spool ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt"        >  "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "SELECT TABLE_NAME FROM USER_TABLES \
WHERE TABLE_NAME LIKE '%/_${KAISYACD}' ESCAPE '/' ;"          >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "spool off"                                              >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
sqlplus ${WKDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "��Еʃ}�X�N�Ώۃe�[�u�����X�g�擾 ERR"                 | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-023  # �Y����Ѓ}�X�N�Ώۃe�[�u��DUMP�t�@�C���쐬
#------------------------------------------------------------------------
#STEPNAME=OUTMASK023
#�Y����Ѓ}�X�N�Ώۃe�[�u��DUMP�p���X�g�t�@�C���쐬
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
if [ ${TBNAME_KS_CD} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##�񋟗p���X�g�t�@�C���쐬
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##�񋟗p���X�g�t�@�C���쐬
echo "${TBNAME_KS_CD}"                                        >> ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
fi
TMP_FLG=`expr ${TMP_FLG} + 1`
fi
done
echo ")"                                                      >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
rm -f "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
rm -f ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt
if [ ${TMP_FLG} != 1 ]
then
#�o��DUMP�t�@�C����EXPORT����
exp ${WKDBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "��Еʃ}�X�N�Ώ�DUMP�t�@�C��EXPORT ERR"                 | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp
echo "�t�@�C��(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)���k�I��" | tee -a $LogFile
######################################################################
##   EXP�pparam�t�@�C���R�s�[                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
######################################################################
COUNT_FLG=`expr ${COUNT_FLG} + 1`
fi
#------------------------------------------------------------------------
# �X�e�b�v-024  # �Y����Ѓ}�X�N�ΏۊO�e�[�u�����X�g�擾
#------------------------------------------------------------------------
#STEPNAME=OUTMASK024
echo "spool ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt"        >  "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "SELECT TABLE_NAME FROM USER_TABLES@DBMASK_OUT_LINK \
WHERE TABLE_NAME LIKE '%/_${KAISYACD}' ESCAPE '/' AND \
SUBSTR(TABLE_NAME,1,INSTR(TABLE_NAME,'_${KAISYACD}')-1) NOT IN (SELECT \
DISTINCT TABLE_NAME FROM ${JHDBNAME}.MASK_DB_O);"             >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "spool off"                                              >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
sqlplus ${CMNDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "��Еʃ}�X�N�ΏۊO�e�[�u�����X�g�擾 ERR"               | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #�}�X�N�Ώ�EXP��A���b�N�t�@�C���폜
#------------------------------------------------------------------------
# �X�e�b�v-025  # �Y����Ѓ}�X�N�ΏۊO�e�[�u��DUMP�t�@�C���쐬
#------------------------------------------------------------------------
#STEPNAME=OUTMASK025
#�Y����Ѓ}�X�N�ΏۊO�e�[�u��DUMP�p���X�g�t�@�C���쐬
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
case  ${TBNAME_KS_CD} in
"")
TMP_FLG=${TMP_FLG}
;;
TOR3KJ10_${KAISYACD})
#�o��DUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp log=${OUT_PATH}/exp_OUT_TOR3KJ10_${KAISYACD}_m.log TABLES=TOR3KJ10_${KAISYACD} direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�e�[�u���uTOR3KJ10_${KAISYACD}�vDUMP�t�@�C��EXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp
echo "�t�@�C��(exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp)���k�I��" | tee -a $LogFile
;;
TOR3KJ20_${KAISYACD})
#�o��DUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp log=${OUT_PATH}/exp_OUT_TOR3KJ20_${KAISYACD}_m.log TABLES=TOR3KJ20_${KAISYACD} direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�e�[�u���uTOR3KJ20_${KAISYACD}�vDUMP�t�@�C��EXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp
echo "�t�@�C��(exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp)���k�I��" | tee -a $LogFile
;;
TOR2KJ10_${KAISYACD})
#�o��DUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp log=${OUT_PATH}/exp_OUT_TOR2KJ10_${KAISYACD}_m.log TABLES=TOR2KJ10_${KAISYACD} direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�e�[�u���uTOR2KJ10_${KAISYACD}�vDUMP�t�@�C��EXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp
echo "�t�@�C��(exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp)���k�I��" | tee -a $LogFile
;;
*)
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
else
if [ ${TMP_FLG} == 200 ]
then
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
echo ")"                                                      >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
echo "${TBNAME_KS_CD}"                                        >> ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
#�o��DUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�uexp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp�vEXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp
echo "�t�@�C��(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)���k�I��" | tee -a $LogFile
######################################################################
##   EXP�pparam�t�@�C���R�s�[                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
######################################################################
COUNT_FLG=`expr ${COUNT_FLG} + 1`
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=0
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
echo "${TBNAME_KS_CD}"                                        >> ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
fi
fi
TMP_FLG=`expr ${TMP_FLG} + 1`
;;
esac
done
rm -f "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
rm -f ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt
if [ ! ${TMP_FLG} == 1 ]
then
echo ")"                                                      >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
#�o��DUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�uexp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp�vEXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp
echo "�t�@�C��(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)���k�I��" | tee -a $LogFile
######################################################################
##   EXP�pparam�t�@�C���R�s�[                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
######################################################################
COUNT_FLG=`expr ${COUNT_FLG} + 1`
fi
##���ʂƋƖ��f�[�^���������ʃf�[�^�쐬�J�n##
else
#
#�Ɩ�DB�̋��ʃe�[�u���Ή�
#------------------------------------------------------------------------
# �X�e�b�v-026  # �Ɩ�DB�̋��ʃ}�X�N�Ώۃe�[�u�����X�g�擾
#------------------------------------------------------------------------
#STEPNAME=OUTMASK026
echo "spool ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt"        >  "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "SELECT TABLE_NAME FROM USER_TABLES \
WHERE TABLE_NAME NOT LIKE '%/_${KAISYACD}' ESCAPE '/';"       >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "spool off"                                              >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
sqlplus ${WKDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�Ɩ�DB�̋��ʃ}�X�N�Ώۃe�[�u�����X�g�擾 ERR"           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-027  # �Ɩ�DB�̋��ʃ}�X�N�Ώۃe�[�u��DUMP�t�@�C���쐬
#------------------------------------------------------------------------
#STEPNAME=OUTMASK027
#�Ɩ�DB�̋��ʃ}�X�N�Ώۃe�[�u��DUMP�p���X�g�t�@�C���쐬
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
if [ ${TBNAME_KS_CD} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##�񋟗p���X�g�t�@�C���쐬 
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_0000_data_1_m.lst
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##�񋟗p���X�g�t�@�C���쐬 
echo "${TBNAME_KS_CD}"                                        >> ${OUT_PATH}/exp_OUT_0000_data_1_m.lst
fi
TMP_FLG=`expr ${TMP_FLG} + 1`
fi
done
rm -f "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
rm -f ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt
if [ ! ${TMP_FLG} == 1 ]
then
echo ")"                                                      >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
#�o��DUMP�t�@�C����EXPORT����
exp ${WKDBCONN}  file=${OUT_PATH}/exp_OUT_0000_data_1_m.dmp log=${OUT_PATH}/exp_OUT_0000_data_1_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMP�t�@�C���uexp_OUT_0000_data_1_m.dmp�vEXPORT ERR"    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR���A���b�N�t�@�C���폜
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_0000_data_1_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_0000_data_1_m.dmp
echo "�t�@�C��(exp_OUT_0000_data_1_m.dmp)���k�I��" | tee -a $LogFile
######################################################################
##   EXP�pparam�t�@�C���R�s�[                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_0000_data_1_m.lst
######################################################################
fi
#------------------------------------------------------------------------
# �X�e�b�v-028  # �Ɩ�DB�̋��ʃ}�X�N�ΏۊO�e�[�u�����X�g�擾
#------------------------------------------------------------------------
#STEPNAME=OUTMASK028
echo "spool ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt"        >  "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "SELECT TABLE_NAME FROM USER_TABLES@DBMASK_OUT_LINK \
WHERE (TABLE_NAME NOT LIKE '%/_%' ESCAPE '/' \
AND TABLE_NAME NOT IN (SELECT DISTINCT TABLE_NAME \
FROM ${JHDBNAME}.MASK_DB_O)) OR \
(TABLE_NAME LIKE '%/_%' ESCAPE '/' AND \
TABLE_NAME NOT LIKE '%/_____' ESCAPE '/' \
AND SUBSTR(TABLE_NAME,1,INSTR(TABLE_NAME,'_')-1) NOT IN \
(SELECT DISTINCT TABLE_NAME FROM ${JHDBNAME}.MASK_DB_O));"    >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
echo "spool off"                                              >> "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
sqlplus ${CMNDBCONN} << SQL_END_D > /dev/null
     set echo off
     set feedback off
     set heading off
     set trimspool on
     set linesize 30
     set term off
     @${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql
exit SQL.SQLCODE
SQL_END_D
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "�Ɩ�DB�̋��ʃ}�X�N�ΏۊO�e�[�u�����X�g�擾 ERR"         | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #�}�X�N�Ώ�EXP��A���b�N�t�@�C���폜
#------------------------------------------------------------------------
# �X�e�b�v-029  # �Y����Ѓ}�X�N�ΏۊO�e�[�u��DUMP�t�@�C���쐬
#------------------------------------------------------------------------
#STEPNAME=OUTMASK029
#�Y����Ѓ}�X�N�ΏۊO�e�[�u��DUMP�p���X�g�t�@�C���쐬
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
if [ ${TBNAME_KS_CD} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##�񋟗p���X�g�t�@�C���쐬
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_0000_data_2_m.lst
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##�񋟗p���X�g�t�@�C���쐬
echo "${TBNAME_KS_CD}"                                        >> ${OUT_PATH}/exp_OUT_0000_data_2_m.lst
fi
TMP_FLG=`expr ${TMP_FLG} + 1`
fi
done
rm -f "${MASKHOME}/tmp/get_${KAISYACD}_tbname.sql"
rm -f ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt
if [ ! ${TMP_FLG} == 1 ]
then
echo ")"                                                      >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
#�o��DUMP�t�@�C����EXPORT����
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_0000_data_2_m.dmp log=${OUT_PATH}/exp_OUT_0000_data_2_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMP�t�@�C���uexp_OUT_0000_data_2_m.dmp�vEXPORT ERR"    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ���k����(20100518)
#------------------------------------------------------------------------
echo "�t�@�C��(exp_OUT_0000_data_2_m.dmp)���k�J�n" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_0000_data_2_m.dmp
echo "�t�@�C��(exp_OUT_0000_data_2_m.dmp)���k�I��" | tee -a $LogFile
######################################################################
##   EXP�pparam�t�@�C���R�s�[                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_0000_data_2_m.lst
######################################################################
fi
fi
##------------------------------------------------------------------------
# �X�e�b�v-040  # ���튮��
#------------------------------------------------------------------------
#STEPNAME=OUTMASK040
#rm -f ${MASKHOME}/tmp/mask_dump_name_out.lst
#rm -f ${MASKHOME}/tmp/get_kaisya_cd.sql
#rm -f ${MASKHOME}/tmp/KAISYA_CD.txt
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile
exit 0
