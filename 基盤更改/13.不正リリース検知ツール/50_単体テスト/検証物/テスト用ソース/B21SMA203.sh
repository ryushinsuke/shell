#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA203.sh
#　　名称　　　　　:配布要モジュール一覧作成
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110107 新規                         GUT 劉双雨
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
rm -f ${LOG_PATH}/B21SMA203_*.log
#---- 前回のエラーログファイルを削除
rm -f ${ERR_LOG_PATH}/B21SMA203_*.err
#---- 前回の一時ファイルを削除
rm -f ${OUTFILE_PATH}/B21SMA203_*
rm -f ${TMP_PATH}/B21SMA203_*
#---- 開始メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA203.sh" \
 "${SVR_KBN}" \
 "1" \
 "I000001" \
 "配布要モジュール一覧作成開始" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- 入力SQL「本番配布要モジュール一覧データ展開用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB004_MODULE_ELIB_INSERT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB004_MODULE_ELIB_INSERT.sql" \
   "11"
  exit 9
fi
#---- 入力SQL「処理対象外データ削除用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB003-TB004_DELETE.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "3" \
   "E000003" \
   "${DDL_PATH}/FS_TB003-TB004_DELETE.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  主処理
#***************************************************************
#---- テーブルを新規作成
sh ${SHL_PATH}/B00SCM202.sh \
  "B21SMA203.sh" \
  "${SVR_KBN}" \
  "FS_TB004_MODULE_ELIB_${SVR_KBN}" \
  ""
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}"\
   "4" \
   "E000011" \
   "【B00SCM202】中間テーブル新規作成サブシェル異常終了。" \
   "11"
  exit 9
fi
#---- 「本番配布要モジュール一覧」のデータを展開
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB004_MODULE_ELIB_INSERT.sql ${SVR_KBN}
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "5" \
   "E000008" \
   "INSERT用のSQL文（FS_TB004_MODULE_ELIB_INSERT.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- 「本番配布要モジュール一覧」対象外のデータを削除
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB003-TB004_DELETE.sql FS_TB004_MODULE_ELIB_${SVR_KBN} ${SVR_KBN} "eLIBSYS"
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "6" \
   "E000008" \
   "DELETE用のSQL文（FS_TB003-TB004_DELETE.sql）が実行異常。" \
   "11"
  exit 9
fi
#***************************************************************
#  後処理
#***************************************************************
#---- 終了メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA203.sh" \
 "${SVR_KBN}" \
 "7" \
 "I000002" \
 "配布要モジュール一覧作成終了" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
