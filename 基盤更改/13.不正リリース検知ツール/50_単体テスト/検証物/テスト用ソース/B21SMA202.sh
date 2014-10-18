#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA202.sh
#　　名称　　　　　:サーバー情報更新
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20101229 新規                         GUT 姜宇
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
rm -f ${LOG_PATH}/B21SMA202_*.log
rm -f ${ERR_LOG_PATH}/B21SMA202_*.err
#---- 前回の一時ファイルを削除
rm -f ${TMP_PATH}/B21SMA202_*
#---- 開始メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh\
 "B21SMA202.sh"\
 "${SVR_KBN}"\
 "1"\
 "I000001"\
 "サーバー情報更新開始"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#***************************************************************
#  主処理
#***************************************************************
#---- テーブル「サーバー情報一覧」により、ファイル「サーバー情報一覧」を作成する。
echo "spool ${TMP_PATH}/B21SMA202_TEMP1.txt" >> ${TMP_PATH}/B21SMA202_TEMP1.sql
echo "select SVR_KBN,SVR_GRP_ID,SVR_ID "     >> ${TMP_PATH}/B21SMA202_TEMP1.sql
echo "from FS_TB006_SVR_JOUHOU; "            >> ${TMP_PATH}/B21SMA202_TEMP1.sql
echo "spool off"                             >> ${TMP_PATH}/B21SMA202_TEMP1.sql
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    set echo off
    set feedback off
    set heading off
    set trimspool on
    set colsep ','
    set linesize 20000
    @${TMP_PATH}/B21SMA202_TEMP1.sql
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA202.sh" \
   "${SVR_KBN}"\
   "2" \
   "E000008" \
   "SELECT用のSQL文（B21SMA202_TEMP1.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- ファイルの空行を削除
cat ${TMP_PATH}/B21SMA202_TEMP1.txt | awk '{if(NF>0) print}' | perl -pe 's/ *//g' | sort | uniq > ${TMP_PATH}/B21SMA202_TEMP1
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA202.sh" \
   "${SVR_KBN}"\
   "3" \
   "E000006" \
   "awk処理異常。" \
   "11"
  exit 9
fi
#---- 更新用SQLファイルを作成
DB_UPDATE()
{
  cat ${TMP_PATH}/B21SMA202_TEMP1 | grep ''${SVR_KBN}','${SVR_GRP_ID}','${SVR_ID}'' >> /dev/null
  if [ $? == 0 ]
  then
    echo "update FS_TB006_SVR_JOUHOU "                                                                         >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "set OLD_COMPARE_DATE = NEW_COMPARE_DATE, NEW_COMPARE_DATE = '${NEW_COMPARE_DATE}', "                 >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "NEW_COMPARE_FLAG = '1', COMPARE_RESULT = '0' "                                                       >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "where SVR_KBN = '${SVR_KBN}' and SVR_GRP_ID = '${SVR_GRP_ID}' and SVR_ID = '${SVR_ID}'; "            >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "commit;"                                                                                             >> ${TMP_PATH}/B21SMA202_TEMP2.sql
  else
    echo "insert into FS_TB006_SVR_JOUHOU "                                                                    >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "values('${SVR_GRP_ID}','${SVR_ID}','${OS_GRP_ID}',' ','${NEW_COMPARE_DATE}','1','0','${SVR_KBN}');"  >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "commit;"                                                                                             >> ${TMP_PATH}/B21SMA202_TEMP2.sql
  fi
}
for ITEM in `ls ${INFILE_PATH}`
do
#---- サーバーIDを取得
  SVR_ID=`echo ${ITEM} | awk -F\. '{print $1}' | awk -F\- '{print $2}'`
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA202.sh" \
     "${SVR_KBN}"\
     "4" \
     "E000006" \
     "awk処理異常。" \
     "11"
    exit 9
  fi
#---- OS分類を取得
  rm -f ${TMP_PATH}/B21SMA202_TEMP2
  cat ${INFILE_PATH}/${ITEM} | dos2unix | awk -F\\t '{print $NF}' | sort | uniq | awk '{if(NF>0) print}' >> ${TMP_PATH}/B21SMA202_TEMP2
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA202.sh" \
     "${SVR_KBN}"\
     "5" \
     "E000006" \
     "awk処理異常。" \
     "11"
    exit 9
  fi
  if [ `ls -l ${TMP_PATH}/B21SMA202_TEMP2 | awk '{print $5}'` != 0 ]
  then
    OS_GRP_ID="U"
  else
    OS_GRP_ID="W"
  fi
#---- 最新検知日を取得
  NEW_COMPARE_DATE=`date +%Y%m%d`
#---- サーバーグループIDを取得
  if [ "${SVR_KBN}" == "RX" -o "${SVR_KBN}" == "TX" -o "${SVR_KBN}" == "RA" ]
  then
    SVR_GRP_ID=`echo ${ITEM} | awk -F\- '{print $1}'`
    if [ "$?" != 0 ]
    then
      sh ${SHL_PATH}/B00SCM201.sh \
       "B21SMA202.sh" \
       "${SVR_KBN}"\
       "6" \
       "E000006" \
       "awk処理異常。" \
       "11"
      exit 9
    fi
    DB_UPDATE
  else
    cat ${INFILE_PATH}/${ITEM} | awk -F\\t '{print $1}' | sort | uniq | while read RECORD
    do
      SVR_GRP_ID=${RECORD}
      DB_UPDATE
    done
  fi
done
#---- 作成されたSQLファイルにより、テーブル「サーバー情報一覧」を更新する。
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${TMP_PATH}/B21SMA202_TEMP2.sql
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA202.sh" \
   "${SVR_KBN}"\
   "7" \
   "E000008" \
   "UPDATE用のSQL文（B21SMA202_TEMP2.sql）が実行異常。" \
   "11"
  exit 9
fi
#***************************************************************
#  処理終了
#***************************************************************
#---- 終了メッセージ出力
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA202.sh"\
 "${SVR_KBN}"\
 "8"\
 "I000002"\
 "サーバー情報更新終了"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
