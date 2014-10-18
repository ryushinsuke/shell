#!/bin/sh
# ========================================================================
# ジョブID      ：KMN_NoMaskByUserID
# ジョブ名      ：顧問系データマスクなし会社別処理
# 処理概要      ：顧問系データマスクなし会社別処理
# 入力引数      ： マスク日付
#               ： 会社コード
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20130326 新規 GUT      新規作成
# 20130927 修正 GUT趙銘  基盤更改
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# 処理開始.
#------------------------------------------------------------------------
MASKDATE=$1
KAISYACD=$2
MTBASEHOME="$(cd $(dirname $0);pwd)/.."
SHL_PATH="${MTBASEHOME}/sh"
. ${MTBASEHOME}"/conf/KMN_NoMaskByUserID.conf"
#ツールのログファイル
LogFile=${MTBASEHOME}"/log/KMN_NoMask_${KAISYACD}.log"
#------------------------------------------------------------------------
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$LogFile
echo "***************************************************"    >>$LogFile

#基盤更改の修正　START
#---  シェルID取得の判定
if [ -z ${Kshid} ]
then
  echo "シェルID取得にエラーが発生しました！"                    | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#データベース接続子取得の判定
if [ -z ${KDBCONN} ]
then
  echo "データベース接続子取得にエラーが発生しました！"          | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#インポート顧問系ファイル格納場所取得の判定
if [ -z ${TASAIN_PATH} ]
then
  echo "インポート顧問系ファイル格納場所取得にエラーが発生しました！" | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi

#DUMPファイルインポートログ出力パス取得の判定
if [ -z ${TMASKWKDIR} ]
then
  echo "DUMPファイルインポートログ出力パス取得にエラーが発生しました！" | tee -a $LogFile
  echo "***************************************************"     >>$LogFile
  echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
  echo "***************************************************"     >>$LogFile
  exit 1
fi
#基盤更改の修正　END
#------------------------------------------------------------------------
# ステップ-010  # パラメータ数チェック
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA010
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
#STEPNAME=KMNNOMA020
if [ -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock" ];then 
  echo "★★ ロックファイル(KMN_NoMasking.lock)存在がありますので、実行終了!! ★★"  | tee -a $LogFile 
  exit 1
else 
  touch "${MTBASEHOME}/tmp/KMN_NoMasking.lock" 
  break 
fi
#------------------------------------------------------------------------
# ステップ-030  # IMPORTのログファイル出力パスを作成
#------------------------------------------------------------------------
#STEPNAME=KMNMASK030
if [ ! -e ${TMASKWKDIR} ]
then
    mkdir ${TMASKWKDIR}
fi
#------------------------------------------------------------------------
# ステップ-040  # INPUT DUMPファイル解凍
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA040
if [ ! -f ${TASAIN_PATH}"/"${KAISYACD}"_kmn_2.exp.gz" ]
then
 echo "DUMPファイル${TASAIN_PATH}/${KAISYACD}_kmn_2.exp.gzが存在しません"  | tee -a $LogFile
 echo "***************************************************"    >>$LogFile
 echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
 echo "***************************************************"    >>$LogFile
 #ERR時、ロックファイル削除
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
 #ERR時、ロックファイル削除
 rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
 TS_RCODE=1
 exit $TS_RCODE
 fi
fi
#------------------------------------------------------------------------
# ステップ-050  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA050
sqlplus ${KDBCONN} @${MTBASEHOME}"/sql/drop_all_tables.sql"
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DROP ALL TABLES ERR"                                    | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-060  # DUMPファイルをIMPORT処理
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA060
#基盤更改の修正　START
FROM_SCHEMA=`cat ${MTBASEHOME}/conf/KMN_MASK.lst |grep -v '^#' |grep 'ORACLE,DB'|awk -F, '{print $3}' | awk -F\/ '{print $1}'`
if [ "${FROM_SCHEMA}" == "" ];then
  FROM_SCHEMA="apl"
fi
TO_SCHEMA="`echo ${KDBCONN} | awk -F\/ '{print $1}'`"
#imp ${KDBCONN} file=${TASAIN_PATH}"/"${KAISYACD}"_kmn_2.exp" log=${TMASKWKDIR}"/"${KAISYACD}_${MASKDATE}"_kmn_2.log" TABLES=(%)
sh BCZC0070.sh imp ${Kshid} ${KDBCONN} ${TASAIN_PATH}/${KAISYACD}_kmn_2.exp ${KAISYACD}_${MASKDATE}_kmn_2.log "FULL=Y" REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA} > ${TMASKWKDIR}/${KAISYACD}_${MASKDATE}_kmn_2.log 2>&1
#基盤更改の修正　END
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo "DUMPファイル${TASAIN_PATH}/${KAISYACD}_kmn_2.exp IMPORT ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-070  # 顧問系データ会社別出力処理シェル起動
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA070
  ${SHL_PATH}/KMN_OutputByUserID.sh  \
     "2"  \
     ${KAISYACD}  \
     ${MASKDATE}
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
echo " 顧問系データ会社別出力処理シェル起動 ERR" | tee -a $LogFile
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$LogFile
echo "***************************************************"    >>$LogFile
#ERR時、ロックファイル削除
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-080  # 終了処理
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA080
rm -f "${MTBASEHOME}/tmp/KMN_NoMasking.lock"
#--- 正常終了
echo "***************************************************"    >>$LogFile
echo "SHL($Kshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$LogFile
echo "***************************************************"    >>$LogFile

#--- 正常終了
exit 0
