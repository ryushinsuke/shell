#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA207.sh
#　　名称　　　　　:不正リリース検知結果作成
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110105 新規                         GUT 姜宇
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
rm -f ${LOG_PATH}/B21SMA207_*.log
rm -f ${ERR_LOG_PATH}/B21SMA207_*.err
#---- 前回の一時ファイルを削除
rm -f ${TMP_PATH}/B21SMA207_*
#---- 開始メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh\
 "B21SMA207.sh"\
 "${SVR_KBN}"\
 "1"\
 "I000001"\
 "不正リリース検知結果作成開始"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- 入力SQL「不正リリースの解消用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB001_FUSEI_RELEASE_UPDATE.sql ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB001_FUSEI_RELEASE_UPDATE.sql" \
   "11"
  exit 9
fi
#---- 入力SQL「不正リリースの追加用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB001_FUSEI_RELEASE_INSERT.sql ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "3" \
   "E000003" \
   "${DDL_PATH}/FS_TB001_FUSEI_RELEASE_INSERT.sql" \
   "11"
  exit 9
fi
#---- 入力SQL「コンペア結果更新用SQL文」ファイル存在チェック処理
if [ ! -f ${DDL_PATH}/FS_TB006_SVR_JOUHOU_UPDATE.sql ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "4" \
   "E000003" \
   "${DDL_PATH}/FS_TB006_SVR_JOUHOU_UPDATE.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  主処理
#***************************************************************
#---- 不正リリースの解消
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB001_FUSEI_RELEASE_UPDATE.sql ${SVR_KBN};
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "5" \
   "E000008" \
   "UPDATE用のSQL文（FS_TB001_FUSEI_RELEASE_UPDATE.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- 不正リリースの追加
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB001_FUSEI_RELEASE_INSERT.sql ${SVR_KBN};
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "6" \
   "E000008" \
   "INSERT用のSQL文（FS_TB001_FUSEI_RELEASE_INSERT.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- コンペア結果更新
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB006_SVR_JOUHOU_UPDATE.sql ${SVR_KBN};
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "7" \
   "E000008" \
   "UPDATE用のSQL文（FS_TB006_SVR_JOUHOU_UPDATE.sql）が実行異常。" \
   "11"
  exit 9
fi
#***************************************************************
#  処理終了
#***************************************************************
#---- 終了メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA207.sh"\
 "${SVR_KBN}"\
 "8"\
 "I000002"\
 "不正リリース検知結果作成終了"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
