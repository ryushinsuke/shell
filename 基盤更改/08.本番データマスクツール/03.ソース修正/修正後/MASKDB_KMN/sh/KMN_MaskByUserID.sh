#!/bin/sh
# ========================================================================
# システムＩＤ  ：  KMN_MaskByUserID
# システム名称  ：  顧問系データマスクあり会社別処理
# 処理概要      ：  顧問系データマスクあり会社別処理
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100629 新規 GUT      新規作成
# 20130327 改修 GUT      仕様変更対応
# 20130920 改修 GUT趙銘　仕様変更対応
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# 処理開始.
#------------------------------------------------------------------------
MASKDATE=$1
KAISYACD=$2
MASKHOME="$(cd $(dirname $0);pwd)/.."
SHL_PATH="${MASKHOME}/sh"
. ${MASKHOME}"/conf/KMN_MaskByUserID.conf"
#ツールのログファイル
LogFile=${MASKHOME}"/log/KMN_Mask_${KAISYACD}.log"
#基盤更改の修正　START
#---  シェールID取得チェック
if [ -z ${Kshid} ]
then
  echo "シェールID取得にエラーが発生しました！"                  | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#データベースSYSユーザ接続子取得チェック
if [ -z ${KDBCONN} ]
then
  echo "データベースSYSユーザ接続子取得にエラーが発生しました！" | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#MASKデータベースユーザ名取得チェック
if [ -z ${TSYSDBNAME} ]
then
  echo "MASKデータベースユーザ名取得にエラーが発生しました！"    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#MASKデータベースPASSWORD取得チェック
if [ -z ${TSYSDBPWD} ]
then
  echo "MASKデータベースPASSWORD取得にエラーが発生しました！"    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#MASKデータベース接続子取得チェック
if [ -z ${TRIREKIDB} ]
then
  echo "MASKデータベース接続子取得にエラーが発生しました！"      | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#入力DMPのパス取得チェック
if [ -z ${TASAIN_PATH} ]
then
  echo "入力DMPのパス取得にエラーが発生しました！"               | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#データインポートログパス取得チェック
if [ -z ${TMASKWKDIR} ]
then
  echo "データインポートログパス取得にエラーが発生しました！"    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi
#基盤更改の修正　END
#------------------------------------------------------------------------
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LogFile
echo "***************************************************"    >>$LogFile

#------------------------------------------------------------------------
# ステップ-010  # パラメータ数チェック
#------------------------------------------------------------------------
#STEPNAME=KMNMASK010
if [ $# -ne 2 ]
then
echo "usage: \$1 マスク日付"                                  | tee -a $LogFile
echo "usage: \$2 会社コード"                                  | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------ 
# ステップ-020  # ロックファイル作成 
#------------------------------------------------------------------------ 
#STEPNAME=KMNMASK020
if [ -f "${MASKHOME}/tmp/KMN_Masking.lock" ];then 
  echo "★★ ロックファイル(KMN_Masking.lock)存在がありますので、実行終了!! ★★"  | tee -a $LogFile 
  exit 1
else 
  touch "${MASKHOME}/tmp/KMN_Masking.lock" 
  break 
fi 

#------------------------------------------------------------------------
# ステップ-030  # テーブルMASK_DB_K作成
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
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# ステップ-040  # テーブルMASK_DB_Kにデータをロード
#------------------------------------------------------------------------
#STEPNAME=KMNMASK040
#---- CTL作成部分
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
#---- データファイルの導入
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
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#---- 一時ファイルをクリア
rm -f ${MASKHOME}/tmp/MASK_DB_K.ddl
rm -f ${MASKHOME}/tmp/MASK_DB_K.ctl

#------------------------------------------------------------------------
# ステップ-050  # IMPORTのログファイル出力パスを作成
#------------------------------------------------------------------------
#STEPNAME=KMNMASK050
if [ ! -e ${TMASKWKDIR} ]
then
    mkdir ${TMASKWKDIR}
fi

#------------------------------------------------------------------------
# ステップ-060  # INPUT DUMPファイル解凍
#------------------------------------------------------------------------
#STEPNAME=KMNMASK060
if [ ! -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_1.exp.gz" ]
  then
  echo "DUMPファイル${TASAIN_PATH}/${KAISYACD}_kmn_1.exp.gzが存在しません"  | tee -a $LogFile
  echo "***************************************************"    >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"    >>$LogFile
  #ERR時、ロックファイル削除
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
  #ERR時、ロックファイル削除
  rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
  TS_RCODE=1
  exit $TS_RCODE
  fi
fi
#------------------------------------------------------------------------
# ステップ-070  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=KMNMASK070
sqlplus ${KDBCONN} @${MASKHOME}"/sql/drop_all_tables.sql"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DROP ALL TABLES ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# ステップ-080  # DUMPファイルをIMPORT処理
#------------------------------------------------------------------------
#STEPNAME=KMNMASK080
#基盤更改の修正　START
FROM_SCHEMA=`cat ${MASKHOME}/conf/KMN_MASK.lst |grep -v '^#' |grep 'ORACLE,DB'|awk -F, '{print $3}' | awk -F\/ '{print $1}'`
if [ "${FROM_SCHEMA}" == "" ];then
  FROM_SCHEMA="apl"
fi
TO_SCHEMA="`echo ${KDBCONN} | awk -F\/ '{print $1}'`"
#imp ${KDBCONN} file=${TASAIN_PATH}"/"${KAISYACD}"_kmn_1.exp" log=${TMASKWKDIR}"/"${KAISYACD}_${MASKDATE}"_kmn_1.log" TABLES=(%)
sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${KDBCONN} ${TASAIN_PATH}/${KAISYACD}_kmn_1.exp ${KAISYACD}_${MASKDATE}_kmn_1.log "FULL=Y" REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA} > ${TMASKWKDIR}/${KAISYACD}_${MASKDATE}_kmn_1.log 2>&1
#基盤更改の修正　END
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMPファイル${TASAIN_PATH}/${KAISYACD}_kmn_1.exp IMPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# ステップ-090  # 対象テーブルリストファイル作成
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
echo "対象テーブルファイル作成 ERR"                           | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
rm -f "${MASKHOME}/tmp/get_table_list.sql"
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# ステップ-100  # マスク処理
#------------------------------------------------------------------------
#STEPNAME=KMNMASK100
sqlplus ${KDBCONN} @${MASKHOME}"/sql/KMN_MASK.sql" ${TSYSDBNAME}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "           MASK ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------
# ステップ-110  # 顧問系データ会社別出力処理シェル起動
#------------------------------------------------------------------------
#STEPNAME=KMNMASK110
  ${SHL_PATH}/KMN_OutputByUserID.sh  \
     "1"  \
     ${KAISYACD}  \
     ${MASKDATE}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo " 顧問系データ会社別出力処理シェル起動 ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#マスク対象EXP後、ロックファイル削除
rm -f "${MASKHOME}/tmp/KMN_Masking.lock"

#------------------------------------------------------------------------
# ステップ-120  # 入力DUMPファイルを削除
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
# ステップ-130  # 終了処理
#------------------------------------------------------------------------
#STEPNAME=KMNMASK120
rm -f "${MASKHOME}/tmp/${KAISYACD}_parfile.lst"
rm -f "${MASKHOME}/tmp/get_table_list.sql"
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile
exit 0
