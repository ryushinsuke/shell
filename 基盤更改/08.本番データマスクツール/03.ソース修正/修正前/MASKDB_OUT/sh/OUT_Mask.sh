#!/bin/sh
# ========================================================================
# システムＩＤ  ：  OUT_Mask
# システム名称  ：  OUT系データマスク処理
# 処理概要      ：  OUT系データマスク処理
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100127 新規 GUT      新規作成
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# 処理開始
#------------------------------------------------------------------------
KAISYACD=$1
MASKHOME="$(cd $(dirname $0);pwd)/.."
. ${MASKHOME}"/sh/OUT_Mask.conf"
#ツールのログファイル
LogFile=${MASKHOME}"/log/OUT_Mask_${KAISYACD}.log"
#------------------------------------------------------------------------
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LogFile
echo "***************************************************"    >>$LogFile
#------------------------------------------------------------------------
# ステップ-010  # パラメータ数チェック
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
# ステップ-010-1  # 同じ会社実行チェック
#------------------------------------------------------------------------
job_process_user_cnt=`ps -ef|grep -w "${shid}.sh"|grep -w "${KAISYACD}"|grep -v 'grep'|wc -l`
if [ "${job_process_user_cnt}" != "2" ];then
  echo "該当会社のデータはマスク中…、終了！"                 | tee -a $LogFile
  exit 1
fi
#------------------------------------------------------------------------
# ステップ-010-2  # ロックファイル作成
#------------------------------------------------------------------------
while [ 1 ]
  do
  if [ -f "${MASKHOME}/tmp/OUT_Masking.lock" ];then
    echo "実行待ち…、5分後再実行して、待ってください！"     | tee -a $LogFile
    sleep 300
  else
    touch "${MASKHOME}/tmp/OUT_Masking.lock"
    break
  fi
done
#------------------------------------------------------------------------
# ステップ-011  # ワークDBと情報DB構築
#------------------------------------------------------------------------
#STEPNAME=OUTMASK011
#ワークDB構築
sqlplus ${SYSDBCONN} @${MASKHOME}"/sql/create_tmp_user.sql" ${WKDBNAME} ${WKDBPWD}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "CREATE TMP USER ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-012  # ワークDBクリア
#------------------------------------------------------------------------
#STEPNAME=OUTMASK012
sqlplus ${WKDBCONN} @${MASKHOME}"/sql/drop_all_tables.sql"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DROP ALL TABLES ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-013  # 情報DB構築
#------------------------------------------------------------------------
#STEPNAME=OUTMASK013
sqlplus ${SYSDBCONN} @${MASKHOME}"/sql/create_tmp_user.sql" ${JHDBNAME} ${JHDBPWD}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "CREATE 情報 USER ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-014  # テーブルMASK_DB_O作成
#------------------------------------------------------------------------
#STEPNAME=OUTMASK014
#---- SQLファイルを作成
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
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-015  # 情報DBデータLOAD
#------------------------------------------------------------------------
#STEPNAME=OUTMASK015
#---- CTL作成部分
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
#---- データファイルの導入
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
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#---- 一時ファイルをクリア
rm -f ${MASKHOME}/tmp/MASK_DB_O.ddl
rm -f ${MASKHOME}/tmp/MASK_DB_O.ctl
#------------------------------------------------------------------------
# ステップ-020  # 対象テーブルDUMPファイル作成
#------------------------------------------------------------------------
#STEPNAME=OUTMASK020
#対象テーブルリスト取得
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
echo "MOVE用対象テーブルリスト取得 ERR"                       | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#対象テーブルDUMP用リストファイル作成
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
#MOVE用DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MOVE用DUMPファイルEXPORT ERR"                           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
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
echo "マスク対象テーブルWKDBに作成 ERR"                 | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#MOVE用DUMPファイルをIMPORT処理
imp ${WKDBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.dmp ignore=y log=${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "MOVE用DUMPファイルIMPORT ERR"                           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
rm -f ${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.dmp
rm -f ${OUT_PATH}/exp_OUT_${KAISYACD}_MOVE_MASK.log
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
fi
#------------------------------------------------------------------------
# ステップ-021  # マスク処理
#------------------------------------------------------------------------
#STEPNAME=OUTMASK021
sqlplus ${WKDBCONN} @${MASKHOME}"/sql/OUT_Mask.sql" ${JHDBNAME}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "           MASK ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
##共通と業務データ分離→業務データ作成開始##
if [ "${KAISYACD}" != "0000" ];then
#------------------------------------------------------------------------
# ステップ-022  # 該当会社マスク対象テーブルリスト取得
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
echo "会社別マスク対象テーブルリスト取得 ERR"                 | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-023  # 該当会社マスク対象テーブルDUMPファイル作成
#------------------------------------------------------------------------
#STEPNAME=OUTMASK023
#該当会社マスク対象テーブルDUMP用リストファイル作成
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
if [ ${TBNAME_KS_CD} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##提供用リストファイル作成
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##提供用リストファイル作成
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
#出力DUMPファイルをEXPORT処理
exp ${WKDBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "会社別マスク対象DUMPファイルEXPORT ERR"                 | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp
echo "ファイル(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)圧縮終了" | tee -a $LogFile
######################################################################
##   EXP用paramファイルコピー                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
######################################################################
COUNT_FLG=`expr ${COUNT_FLG} + 1`
fi
#------------------------------------------------------------------------
# ステップ-024  # 該当会社マスク対象外テーブルリスト取得
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
echo "会社別マスク対象外テーブルリスト取得 ERR"               | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #マスク対象EXP後、ロックファイル削除
#------------------------------------------------------------------------
# ステップ-025  # 該当会社マスク対象外テーブルDUMPファイル作成
#------------------------------------------------------------------------
#STEPNAME=OUTMASK025
#該当会社マスク対象外テーブルDUMP用リストファイル作成
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
case  ${TBNAME_KS_CD} in
"")
TMP_FLG=${TMP_FLG}
;;
TOR3KJ10_${KAISYACD})
#出力DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp log=${OUT_PATH}/exp_OUT_TOR3KJ10_${KAISYACD}_m.log TABLES=TOR3KJ10_${KAISYACD} direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "テーブル「TOR3KJ10_${KAISYACD}」DUMPファイルEXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp
echo "ファイル(exp_OUT_TOR3KJ10_${KAISYACD}_m.dmp)圧縮終了" | tee -a $LogFile
;;
TOR3KJ20_${KAISYACD})
#出力DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp log=${OUT_PATH}/exp_OUT_TOR3KJ20_${KAISYACD}_m.log TABLES=TOR3KJ20_${KAISYACD} direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "テーブル「TOR3KJ20_${KAISYACD}」DUMPファイルEXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp
echo "ファイル(exp_OUT_TOR3KJ20_${KAISYACD}_m.dmp)圧縮終了" | tee -a $LogFile
;;
TOR2KJ10_${KAISYACD})
#出力DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp log=${OUT_PATH}/exp_OUT_TOR2KJ10_${KAISYACD}_m.log TABLES=TOR2KJ10_${KAISYACD} direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "テーブル「TOR2KJ10_${KAISYACD}」DUMPファイルEXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp
echo "ファイル(exp_OUT_TOR2KJ10_${KAISYACD}_m.dmp)圧縮終了" | tee -a $LogFile
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
#出力DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "「exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp」EXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp
echo "ファイル(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)圧縮終了" | tee -a $LogFile
######################################################################
##   EXP用paramファイルコピー                                       ##
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
#出力DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp log=${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "「exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp」EXPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp
echo "ファイル(exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.dmp)圧縮終了" | tee -a $LogFile
######################################################################
##   EXP用paramファイルコピー                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_${KAISYACD}_data_${COUNT_FLG}_m.lst
######################################################################
COUNT_FLG=`expr ${COUNT_FLG} + 1`
fi
##共通と業務データ分離→共通データ作成開始##
else
#
#業務DBの共通テーブル対応
#------------------------------------------------------------------------
# ステップ-026  # 業務DBの共通マスク対象テーブルリスト取得
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
echo "業務DBの共通マスク対象テーブルリスト取得 ERR"           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-027  # 業務DBの共通マスク対象テーブルDUMPファイル作成
#------------------------------------------------------------------------
#STEPNAME=OUTMASK027
#業務DBの共通マスク対象テーブルDUMP用リストファイル作成
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
if [ ${TBNAME_KS_CD} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##提供用リストファイル作成 
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_0000_data_1_m.lst
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##提供用リストファイル作成 
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
#出力DUMPファイルをEXPORT処理
exp ${WKDBCONN}  file=${OUT_PATH}/exp_OUT_0000_data_1_m.dmp log=${OUT_PATH}/exp_OUT_0000_data_1_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMPファイル「exp_OUT_0000_data_1_m.dmp」EXPORT ERR"    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #ERR時、ロックファイル削除
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_0000_data_1_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_0000_data_1_m.dmp
echo "ファイル(exp_OUT_0000_data_1_m.dmp)圧縮終了" | tee -a $LogFile
######################################################################
##   EXP用paramファイルコピー                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_0000_data_1_m.lst
######################################################################
fi
#------------------------------------------------------------------------
# ステップ-028  # 業務DBの共通マスク対象外テーブルリスト取得
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
echo "業務DBの共通マスク対象外テーブルリスト取得 ERR"         | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
rm -f "${MASKHOME}/tmp/OUT_Masking.lock"                  #マスク対象EXP後、ロックファイル削除
#------------------------------------------------------------------------
# ステップ-029  # 該当会社マスク対象外テーブルDUMPファイル作成
#------------------------------------------------------------------------
#STEPNAME=OUTMASK029
#該当会社マスク対象外テーブルDUMP用リストファイル作成
echo "TABLES=("                                               >  "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TMP_FLG=1
for TBNAME_KS_CD in `cat ${MASKHOME}/tmp/TBNAME_${KAISYACD}_CD.txt`
do
if [ ${TBNAME_KS_CD} != "" ]
then
if [ ${TMP_FLG} == 1 ]
then
echo "${TBNAME_KS_CD}"                                        >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##提供用リストファイル作成
echo "${TBNAME_KS_CD}"                                        > ${OUT_PATH}/exp_OUT_0000_data_2_m.lst
else
echo ",${TBNAME_KS_CD}"                                       >> "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
##提供用リストファイル作成
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
#出力DUMPファイルをEXPORT処理
exp ${DBCONN}  file=${OUT_PATH}/exp_OUT_0000_data_2_m.dmp log=${OUT_PATH}/exp_OUT_0000_data_2_m.log parfile="${MASKHOME}/tmp/${KAISYACD}_parfile.lst" direct=y
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMPファイル「exp_OUT_0000_data_2_m.dmp」EXPORT ERR"    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($shid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# 圧縮処理(20100518)
#------------------------------------------------------------------------
echo "ファイル(exp_OUT_0000_data_2_m.dmp)圧縮開始" | tee -a $LogFile
gzip -f ${OUT_PATH}/exp_OUT_0000_data_2_m.dmp
echo "ファイル(exp_OUT_0000_data_2_m.dmp)圧縮終了" | tee -a $LogFile
######################################################################
##   EXP用paramファイルコピー                                       ##
######################################################################
cp "${MASKHOME}/tmp/${KAISYACD}_parfile.lst" ${MASKHOME}/param/exp_OUT_0000_data_2_m.lst
######################################################################
fi
fi
##------------------------------------------------------------------------
# ステップ-040  # 正常完了
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
