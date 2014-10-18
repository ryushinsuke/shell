#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA204.sh
#　　名称　　　　　:配布済モジュール一覧作成
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110111 新規                         GUT 姜宇
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
if [ "$1" != "NEW" -a "$1" != "OLD" ]
then
  echo "入力引数$1が不正です。引数は「NEW、OLD」を入力してください。"
  exit 9
else
  SHORI_KBN=$1
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
#---- 引数$2により、処理パスとテーブルIDを設定
if [ "${SHORI_KBN}" == "NEW" ]
then
  SHORI_PATH=${INFILE_PATH}
  TABLE_ID="FS_TB003_MODULE_${SVR_KBN}"
else
  SHORI_PATH=${INFILE_OLD_PATH}
  TABLE_ID="FS_TB007_OLD_MODULE_${SVR_KBN}"
fi
#***************************************************************
#  前処理
#***************************************************************
#---- 前回のログファイルを削除
rm -f ${LOG_PATH}/B21SMA204_${SHORI_KBN}_*.log
rm -f ${ERR_LOG_PATH}/B21SMA204_${SHORI_KBN}_*.err
#---- 前回の一時ファイルを削除
rm -f ${TMP_PATH}/B21SMA204_${SHORI_KBN}_*
rm -f ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_*
#---- 開始メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh\
 "B21SMA204_${SHORI_KBN}.sh"\
 "${SVR_KBN}"\
 "1"\
 "I000001"\
 "配布済モジュール一覧作成開始"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- 入力SQL「処理対象外データ削除用SQL文」ファイル存在チェック処理
if [ "${SHORI_KBN}" == "NEW" ]
then
  if [ ! -f ${DDL_PATH}/FS_TB003-TB004_DELETE.sql ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "2" \
     "E000003" \
     "${DDL_PATH}/FS_TB003-TB004_DELETE.sql" \
     "11"
    exit 9
  fi
fi
#***************************************************************
#  主処理
#***************************************************************
#---- YDC/ODC配布済モジュール一覧を作成する
for ITEM in `ls ${SHORI_PATH}`
do
#---- サーバーIDを取得
  SVR_ID=`echo ${ITEM} | awk -F\. '{print $1}' | awk -F\- '{print $2}'`
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "3" \
     "E000006" \
     "awk処理異常。" \
     "11"
    exit 9
  fi
#---- ロードファイルを作成「サーバーグループID、サーバーID、本番GW配布先パス、ファイルID、タイムスタンプ、サイズ、チェックサム」
  cat ${SHORI_PATH}/${ITEM} | dos2unix | awk -F\\t '{ if($6=="") print "\""$1"\",\"'${SVR_ID}'\",\""$2"\",\""$3"\",\""$4"\",\""$5"\",\" \"" ;\
                                          else print "\""$1"\",\"'${SVR_ID}'\",\""$2"\",\""$3"\",\""$4"\",\""$5"\",\""$6"\""}' \
                               >> ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_OUTFILE
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "4" \
     "E000006" \
     "awk処理異常。" \
     "11"
    exit 9
  fi
done
if [ ! -s ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_OUTFILE ]
then
  touch ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_OUTFILE
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "8" \
     "E000006" \
     "touch処理異常。" \
     "11"
    exit 9
  fi
fi
#---- 「B00SCM202.sh」をコールして、テーブルを作成して、且つ配布済モジュール一覧を導入する。
sh ${SHL_PATH}/B00SCM202.sh\
 "B21SMA204_${SHORI_KBN}.sh"\
 "${SVR_KBN}"\
 "${TABLE_ID}"\
 "B21SMA204_${SHORI_KBN}_OUTFILE"
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA204_${SHORI_KBN}.sh" \
   "${SVR_KBN}"\
   "5" \
   "E000011" \
   "【B00SCM202】中間テーブル新規作成サブシェル異常終了。" \
   "11"
  exit 9
fi
if [ "${SHORI_KBN}" == "NEW" ]
then
#---- 処理対象外データを削除する
  ${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
      whenever oserror exit failure
      whenever sqlerror exit failure
      @${DDL_PATH}/FS_TB003-TB004_DELETE.sql ${TABLE_ID} ${SVR_KBN} "HONBAN";
      commit;
      exit SQL.SQLCODE
SQL_END_D
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "6" \
     "E000008" \
     "DELETE用のSQL文（FS_TB003-TB004_DELETE.sql）が実行異常。" \
     "11"
    exit 9
  fi
fi
#***************************************************************
#  処理終了
#***************************************************************
#---- 終了メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA204_${SHORI_KBN}.sh"\
 "${SVR_KBN}"\
 "7"\
 "I000002"\
 "配布済モジュール一覧作成終了"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
