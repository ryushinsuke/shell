#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA201.sh
#　　名称　　　　　:本番配布要モジュール一覧作成
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110105 新規                         GUT 劉双雨
#***************************************************************
#***************************************************************
#  サーバー区分の設定
#***************************************************************
SVR_KBN=CMN
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
rm -f ${LOG_PATH}/B21SMA201_*.log
#---- 前回のORACLEログを削除
rm -f ${FSKT_PATH}/log/RX/SQL.log
rm -f ${FSKT_PATH}/log/TX/SQL.log
rm -f ${FSKT_PATH}/log/RA/SQL.log
rm -f ${FSKT_PATH}/log/KRX/SQL.log
rm -f ${FSKT_PATH}/log/KTX/SQL.log
rm -f ${FSKT_PATH}/log/CMN/SQL.log
#---- 前回のエラーログファイルを削除
rm -f ${ERR_LOG_PATH}/B21SMA201_*.err
#---- 前回の一時ファイルを削除
rm -f ${OUTFILE_PATH}/B21SMA201_*
rm -f ${TMP_PATH}/B21SMA201_*
#---- 開始メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA201.sh" \
 "${SVR_KBN}" \
 "1" \
 "I000001" \
 "本番配布要モジュール一覧作成開始" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- 入力SQL「最新検知フラグ初期化用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB006_SVR_JOUHOU_INIT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB006_SVR_JOUHOU_INIT.sql" \
   "11"
  exit 9
fi
#---- 入力SQL「本番配布要モジュール一覧作成用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_ELIB_DATA_SELECT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "3" \
   "E000003" \
   "${DDL_PATH}/FS_ELIB_DATA_SELECT.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  主処理
#***************************************************************
#---- 本番配布要モジュール一覧データを取得
${MYSQL_CMD} -h ${MYSQL_IP} -u ${MYSQL_USR} -p${MYSQL_PWD} -D ${MYSQL_SCA} < ${DDL_PATH}/FS_ELIB_DATA_SELECT.sql \
    > ${TMP_PATH}/B21SMA201_TEMP 2>&1
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}"\
   "4" \
   "E000009" \
   "SELECT用のSQL文（FS_ELIB_DATA_SELECT.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- 「本番配布要モジュール一覧」ファイルをフォーマット
sed 's/\t/","/g' ${TMP_PATH}/B21SMA201_TEMP | sed -n '2,$p' | awk '{print "\""$0"\""}' > ${OUTFILE_PATH}/B21SMA201_OUTFILE
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}"\
   "5" \
   "E000006" \
   "awk処理異常。" \
   "11"
  exit 9
fi
#---- 本番配布要モジュール一覧をＤＢに導入
sh ${SHL_PATH}/B00SCM202.sh \
 "B21SMA201.sh" \
 "${SVR_KBN}" \
 "FS_TB002_MODULE_ELIB" \
 "B21SMA201_OUTFILE"
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "6" \
   "E000011" \
   "【B00SCM202】中間テーブル新規作成サブシェル異常終了。" \
   "11"
  exit 9
fi
#---- 「本番配布要モジュール一覧」テーブルの重複データを削除
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB002_MODULE_ELIB_DELETE.sql;
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}"\
   "11" \
   "E000008" \
   "DELETE用のSQL文（FS_TB002_MODULE_ELIB_DELETE.sql）が実行異常。" \
   "11"
  exit 9
fi
#----「サーバー情報一覧」テーブルの「最新検知フラグ」項目を初期化
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB006_SVR_JOUHOU_INIT.sql
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "7" \
   "E000008" \
   "UPDATE用のSQL文（FS_TB006_SVR_JOUHOU_INIT.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- 前回のリストファイルをバックアップフォルダーにコピー
cp -rp ${FSKT_PATH}/infile/* ${FSKT_PATH}/infile_old/
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "8" \
   "E000006" \
   "cp処理異常。" \
   "11"
  exit 9
fi
#---- 前回のリストファイルの削除
rm -f ${FSKT_PATH}/infile/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/infile/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/infile/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/infile/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/infile/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm処理異常(リストファイル)。" \
   "11"
  exit 9
fi
#---- 前回のログファイルの削除
rm -f ${FSKT_PATH}/log/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/log/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/log/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/log/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/log/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm処理異常(ログファイル)。" \
   "11"
  exit 9
fi
#---- 前回のエラーログファイルの削除
rm -f ${FSKT_PATH}/log_err/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/log_err/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/log_err/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/log_err/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/log_err/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm処理異常(エラーログファイル)。" \
   "11"
  exit 9
fi
#---- 前回の出力ファイルの削除
rm -f ${FSKT_PATH}/outfile/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/outfile/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/outfile/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/outfile/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/outfile/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm処理異常(出力ファイル)。" \
   "11"
  exit 9
fi
#---- 前回の一時ファイルの削除
rm -f ${FSKT_PATH}/tmp/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/tmp/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/tmp/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/tmp/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/tmp/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm処理異常(一時ファイル)。" \
   "11"
  exit 9
fi
#***************************************************************
#  後処理
#***************************************************************
#---- 終了メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA201.sh" \
 "${SVR_KBN}" \
 "9" \
 "I000002" \
 "本番配布要モジュール一覧作成終了" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
