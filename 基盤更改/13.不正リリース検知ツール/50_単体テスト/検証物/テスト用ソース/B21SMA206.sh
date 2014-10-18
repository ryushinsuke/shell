#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA206.sh
#　　名称　　　　　:チェックサムのみ変更分作成
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110112 新規                         GUT 劉双雨
#***************************************************************
#***************************************************************
#  引数チェック
#***************************************************************
#---- 環境変数「SJ_PEX_FRAME」からサーバー区分を取得する
SVR_KBN=`echo ${SJ_PEX_FRAME} | awk -F\_ '{print $3}'`
if [ "${SVR_KBN}" != "RX" -a "${SVR_KBN}" != "TX" -a "${SVR_KBN}" != "RA" -a "${SVR_KBN}" != "KRX" -a "${SVR_KBN}" != "KTX" ]
then
  echo "取得されたサーバー区分[${SVR_KBN}]が不正です。環境変数「SJ_PEX_FRAME」を確認してください。"
  exit 9
fi
#***************************************************************
#  共通環境変数読込み
#***************************************************************
FSKT_PATH=$(cd $(dirname $0)/../..;pwd)
if [ ! -f ${FSKT_PATH}/src/conf/B21TCG201.def ]
then
  echo "共通環境変数一覧(${FSKT_PATH}/src/conf/B21TCG201.def)が見つかりません。"
  exit 9
fi
. ${FSKT_PATH}/src/conf/B21TCG201.def ${SVR_KBN}
#***************************************************************
#  前処理
#***************************************************************
#---- 前回のログファイルを削除
rm -f ${LOG_PATH}/B21SMA206_*.log
#---- 前回のエラーログファイルを削除
rm -f ${ERR_LOG_PATH}/B21SMA201_*.err
#---- 前回の一時ファイルを削除
rm -f ${OUTFILE_PATH}/B21SMA206_*
rm -f ${TMP_PATH}/B21SMA206_*
#---- 開始メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA206.sh" \
 "${SVR_KBN}" \
 "1" \
 "I000001" \
 "チェックサムのみ変更分作成開始" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- 入力SQL「チェックサムのみ変更分作成用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB005_NEW_FUSEI_ADD.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA206.sh" \
   "${SVR_KBN}" \
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB005_NEW_FUSEI_ADD.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  主処理
#***************************************************************
#---- チェックサムのみ変更分の作成
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB005_NEW_FUSEI_ADD.sql ${SVR_KBN}
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA206.sh" \
   "${SVR_KBN}" \
   "3" \
   "E000008" \
   "INSERT用のSQL文（FS_TB005_NEW_FUSEI_ADD.sql）が実行異常。" \
   "11"
  exit 9
fi
#***************************************************************
#  後処理
#***************************************************************
#---- 終了メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA206.sh" \
 "${SVR_KBN}" \
 "4" \
 "I000002" \
 "チェックサムのみ変更分作成終了" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
