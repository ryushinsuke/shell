#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B21SMA200.sh
#　　名称　　　　　:リストファイル転送
#
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110106 新規                         GUT 姜宇
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
#  環境変数を設定
#***************************************************************
#---- ツール配布ディレクトリを設定
FSKT_PATH=$(cd $(dirname $0)/..;pwd)
#---- eLIBSYSサーバーのトリガーファイル格納パス
#ELIBSYS_TORIGA_PATH=/home/chroot/release/check
ELIBSYS_TORIGA_PATH=/home/apl/test_gut/chroot/release/check
#---- eLIBSYSサーバーのリストファイル格納パス
#ELIBSYS_LIST_PATH=/home/chroot/release/check/${SVR_KBN}
ELIBSYS_LIST_PATH=/home/apl/test_gut/chroot/release/check/${SVR_KBN}
#---- eLIBSYS周辺サーバーのリストファイル格納パス
#INFILE_PATH=/home/senelib/DevmanagerV2/fsrelskenti/infile/${SVR_KBN}
INFILE_PATH=/home/apl/test_gut/senelib/DevmanagerV2/fsrelskenti/infile/${SVR_KBN}
#---- ログファイル格納パスを設定
LOG_PATH=${FSKT_PATH}/log/${SVR_KBN}
#---- 一時ファイル格納パスを設定
TMP_PATH=${FSKT_PATH}/tmp/${SVR_KBN}
#---- EXPECTコマンド
#EXPECT_CMD=/usr/bin/expect
EXPECT_CMD=expect
#---- 処理時間を取得
TIMESTAMP=`date +%Y%m%d%H%M%S`
#---- 処理日を取得
SHORI_DATE=`date +%Y%m%d`
#---- FTP接続IPアドレス
#FTP_IP=192.178.64.56
FTP_IP=172.107.61.13
#---- FTP接続ユーザー
#FTP_USER=senelib
FTP_USER=apl
#---- FTP接続パスワード
#FTP_PASS=senelib
FTP_PASS=aplapl
#***************************************************************
#  前処理
#***************************************************************
#---- 前回のログファイルを削除
rm -f ${LOG_PATH}/B21SMA200_*.log
#---- 前回の一時ファイルを削除
rm -f ${TMP_PATH}/B21SMA200_*
#---- 開始メッセージ出力
echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "【<I>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<1>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "ステップ開始。"                                               >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "リストファイル転送開始。"                                     >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
#***************************************************************
#  主処理
#***************************************************************
#---- リストファイル転送
${EXPECT_CMD} << EOF >> ${LOG_PATH}/B21SMA200_FTP.log 2>&1
set timeout 600
set TERM xterm

spawn sftp ${FTP_USER}@${FTP_IP}

expect "password:"
send "${FTP_PASS}\r"

expect "sftp>"
send "put ${ELIBSYS_LIST_PATH}/* ${INFILE_PATH}\r"

expect "sftp>"
send "cd ${INFILE_PATH}\r"

expect "sftp>"
send "ls -l\r"

expect "sftp>"
send "exit\r"

interact

EOF
if [ "$?" != 0 ]
then
  echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<2>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIXコマンドエラー。"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "expect処理異常。"                                             >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#---- ftp処理ログファイルを利用して、ファイル転送結果をチェック
TMP_NUM=`cat ${LOG_PATH}/B21SMA200_FTP.log | sed -n '/sftp> ls -l/='`
let START_NUM=${TMP_NUM}+1
TMP_NUM=`cat ${LOG_PATH}/B21SMA200_FTP.log | sed -n '/sftp> exit/='`
let END_NUM=${TMP_NUM}-1
if [ "${START_NUM}" -le "${END_NUM}" ]
then
#---- ftp処理ログファイルを利用して、ファイルIDとファイルサイズ一覧を取得して、ファイル一覧①を作成
  sed -n ''${START_NUM}','${END_NUM}'p' ${LOG_PATH}/B21SMA200_FTP.log | sed 's/\r//g' \
      | awk '{print $9","$5}' | sort >> ${TMP_PATH}/B21SMA200_TEMP1
  if [ "$?" != 0 ]
  then
    echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<3>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    echo "UNIXコマンドエラー。"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    echo "awk処理異常。"                                                >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    exit 9
  fi
else
  echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★"                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<4>】"                                          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "ファイル転送エラー。"                                                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "eLIBSYSサーバーの/home/chroot/release/check/${SVR_KBN}に、リストファイルが存在していません。" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#--- eLIBSYSサーバーのリストファイル格納パスにより、ファイルIDとファイルサイズ一覧を取得して、ファイル一覧②を作成
ls -l ${ELIBSYS_LIST_PATH} | sed -n '2,$p' | awk '{print $9","$5}' | sort >> ${TMP_PATH}/B21SMA200_TEMP2
if [ "$?" != 0 ]
then
  echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<5>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIXコマンドエラー。"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "awk処理異常。"                                                >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#---- 上記取得のファイル一覧①とファイル一覧②をコンペア、コンペア結果ファイルをチェック
diff ${TMP_PATH}/B21SMA200_TEMP1 ${TMP_PATH}/B21SMA200_TEMP2 >> /dev/null
if [ "$?" != 0 ]
then
  echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<6>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "ファイル転送エラー。"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "リストファイル転送処理異常。"                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#---- トリガーファイルとリストファイルの削除
case ${SVR_KBN} in
  RX) DEL_FILE=rx-releasefileinfo.ENDFILE
    ;;
  TX) DEL_FILE=tx-releasefileinfo.ENDFILE
    ;;
  RA) DEL_FILE=ra-releasefileinfo.ENDFILE
    ;;
 KRX) DEL_FILE=rx-keep-releasefileinfo.ENDFILE
    ;;
 KTX) DEL_FILE=tx-keep-releasefileinfo.ENDFILE
    ;;
esac
rm -f ${ELIBSYS_TORIGA_PATH}/${DEL_FILE}
if [ $? != 0 ]
then
  echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<7>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIXコマンドエラー。"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "rm処理異常。"                                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
rm -f ${ELIBSYS_LIST_PATH}/*
if [ $? != 0 ]
then
  echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "【<E>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<8>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIXコマンドエラー。"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "rm処理異常。"                                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#***************************************************************
#  処理終了
#***************************************************************
#---- 終了メッセージ出力
echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "【<I>B21SMA200.sh ${SVR_KBN}：<${TIMESTAMP}>：<9>】"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "ステップ終了。"                                               >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "リストファイル転送終了。"                                     >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi

exit 0
