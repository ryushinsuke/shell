#!/bin/sh
# ========================================================================
# システムＩＤ  ：
# システム名称  ：
# ジョブID      ：KMN_NoMaskByUserID
# ジョブ名      ：顧問系データマスクなし会社別処理
# 処理概要      ：顧問系データマスクなし会社別処理
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20130326 新規 GUT      新規作成
#
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
#------------------------------------------------------------------------
# ステップ-010  # パラメータ数チェック
#------------------------------------------------------------------------
#STEPNAME=KMNNOMA010
if [ $# -ne 2 ];
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
imp ${KDBCONN} file=${TASAIN_PATH}"/"${KAISYACD}"_kmn_2.exp" log=${TMASKWKDIR}"/"${KAISYACD}_${MASKDATE}"_kmn_2.log" TABLES=(%)
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
