#!/bin/sh
source ~/.bash_profile
# ========================================================================
# システムＩＤ  ：  KJ_CSV_Load
# システム名称  ：  基準系データマスクCSVロード処理
# 処理概要      ：  基準系データマスクCSVロード処理
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100407 新規 GUT      新規作成
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# 処理開始
#------------------------------------------------------------------------
CSVLOADHOME="$(cd $(dirname $0);pwd)/.."
. ${CSVLOADHOME}"/conf/KJ_CSV_Load.conf"
#------------------------------------------------------------------------
echo "***************************************************"    >>$LOADLogFile
echo "SHL($LOADshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LOADLogFile
echo "***************************************************"    >>$LOADLogFile
#------------------------------------------------------------------------
# ステップ-010  # テーブルMASK_DB作成
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK010
#---- SQLファイルを作成
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
# ステップ-012  # テーブルMASK_DBにデータLOAD
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK012
#---- CTL作成部分
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
#---- データファイルの導入
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
#---- 一時ファイルをクリア
rm -f ${CSVLOADHOME}/tmp/MASK_DB_U.ddl
rm -f ${CSVLOADHOME}/tmp/MASK_DB_U.ctl
echo "***************************************************"    >>$LOADLogFile
echo "SHL($LOADshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LOADLogFile
echo "***************************************************"    >>$LOADLogFile
exit 0

