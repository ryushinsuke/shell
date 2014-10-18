#!/bin/sh
# ========================================================================
# システムＩＤ  ：
# システム名称  ：
# ジョブID      ：KMN_OutputByUserID
# ジョブ名      ：顧問系データ会社別出力処理
# 処理概要      ：指定された会社のデータをテーブル別出力処理
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20130326 新規 GUT      新規作成
# 20130920 改修 GUT趙銘　仕様変更対応
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# 処理開始.
#------------------------------------------------------------------------
#--- 引数1(処理区分)
MASK_KBN=$1
#--- 引数2(会社コード)
KAISYACD=$2
#--- 引数2(マスク日付)
MASKDATE=$3

MTBASEHOME="$(cd $(dirname $0);pwd)/.."
. ${MTBASEHOME}"/conf/KMN_OutputByUserID.conf"
#ツールのログファイル
LogFile=${MTBASEHOME}"/log/KMN_OutputByUserID_${KAISYACD}.log"
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

#マスクされたの出力顧問系DUMPファイル格納場所取得チェック
if [ -z ${TASAOUT_PATH} ]
then
  echo "顧問系DUMPファイル出力場所取得にエラーが発生しました！"  | tee -a $LogFile
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
#STEPNAME=KMNTBL010
if [ $# -ne 3 ]
then
echo "usage: \$1 処理区分"                                  | tee -a $LogFile
echo "usage: \$2 会社コード"                                  | tee -a $LogFile
echo "usage: \$3 マスク日付"                                  | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
TS_RCODE=1
exit $TS_RCODE
fi

#------------------------------------------------------------------------ 
# ステップ-020  # ロックファイル作成 
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL020
if [ -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock" ];then 
  echo "★★ ロックファイル(KMN_OutputByUserID.lock)存在がありますので、実行終了!! ★★"  | tee -a $LogFile 
  exit 1
else 
  touch "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock" 
  break 
fi
#------------------------------------------------------------------------ 
# ステップ-030  # Export出力ディレクトリ作成
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL030
#基盤更改の修正　START
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
#基盤更改の修正　END
fi
if [ ! -d ${EXP_PATH} ]
then
    mkdir ${EXP_PATH}
fi
#------------------------------------------------------------------------ 
# ステップ-040  # 会社別テーブル一覧ファイル作成
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
echo "対象テーブルリストファイル作成 ERR"                     | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------ 
# ステップ-050  # 出力DUMPファイルをEXPORT処理
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL050
  while read TABLE_NAME_LIST
  do
#基盤更改の修正　START
#  exp ${KDBCONN} file="${EXP_PATH}/${TABLE_NAME_LIST}.exp" log="${EXP_PATH}/${TABLE_NAME_LIST}.log" TABLES=(${TABLE_NAME_LIST}) direct=y
sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${KDBCONN} ${EXP_PATH}/${TABLE_NAME_LIST}.exp ${TABLE_NAME_LIST}.log "TABLES=${TABLE_NAME_LIST}" > ${EXP_PATH}/${TABLE_NAME_LIST}.log 2>&1
#基盤更改の修正　END
   TS_STATUS=$?
   if [ "${TS_STATUS}" != "0" ];then
   echo "DUMPファイル${EXP_PATH}/${TABLE_NAME_LIST}${MASK_KBN}.exp EXPORT ERR" | tee -a $LogFile
   echo "***************************************************"    >>$LogFile
   echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
   echo "***************************************************"    >>$LogFile
   #ERR時、ロックファイル削除
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
   #ERR時、ロックファイル削除
   rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
   rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
   rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
   TS_RCODE=1
   exit $TS_RCODE
   fi
  done < "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"
#------------------------------------------------------------------------ 
# ステップ-060  # 終了処理
#------------------------------------------------------------------------ 
#STEPNAME=KMNTBL060
   rm -f "${MTBASEHOME}/tmp/KMN_OutputByUserID.lock"
   rm -f "${MTBASEHOME}/tmp/get_${KAISYACD}_kmn_${MASK_KBN}_table_list.sql"
   rm -f "${MTBASEHOME}/tmp/${KAISYACD}_kmn_${MASK_KBN}_table.lst"

#--- 正常終了
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile
exit 0
