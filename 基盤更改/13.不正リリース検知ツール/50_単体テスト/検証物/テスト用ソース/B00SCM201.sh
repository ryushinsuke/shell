#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B00SCM201.sh
#　　名称　　　　　:メッセージ出力
#　　処理概要　　　:実行メッセージを出力する。
#　　　　　　　　　 場合によって、出力先はスクリーン、ログファイル、
#　　　　　　　　　 エラーログファイルより異なる。
#　　ＡＲＧ　　　　:1　発生ＰＧＭ
#　　　　　　　　　:2　サーバー区分
#　　　　　　　　　:3　発生箇所
#　　　　　　　　　:4　メッセージID
#　　　　　　　　　:5　補足内容
#　　　　　　　　　:6　ログ記入区分
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20101230 新規                         GUT 姜宇
#***************************************************************
#***************************************************************
#  引数個数チェック
#***************************************************************
if [ $# != 6 ]
then
  echo "入力引数が不正である。"
  exit 9
fi
#***************************************************************
LOG_PROC()
{
     echo "★★★★★★★★★★★★★★★★★"                         | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "【<${MsgLel}>${PGM} ${SVR_KBN}:<${TimeStamp}>:<${POS}>】"   | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${MsgNay}"                                                  | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${HOSUNAY}"                                                 | tee -a $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
}

LOG_PROC2()
{
     echo "★★★★★★★★★★★★★★★★★"                         >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "【<${MsgLel}>${PGM} ${SVR_KBN}:<${TimeStamp}>:<${POS}>】"   >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${MsgNay}"                                                  >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
     echo "${HOSUNAY}"                                                 >> $1
     if [ "$?" != 0 ]
     then
       exit 9
     fi
}

#---- 出力内容取得
#---- 発生PGM
PGM=$1
PGM_ID=`echo "$1" | awk -F\. '{print $1}'`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- サーバー区分
SVR_KBN=$2
#---- 発生箇所
POS=$3
#---- メッセージレベル
MsgLel=`echo "$4" | cut -c0-1`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- メッセージ内容
MsgNay=`grep -w $4 ${CONF_PATH}/B21TCG202.def | awk -F, '{print $2}'`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- 補足内容
HOSUNAY=$5
#---- ログファイル記入区分
LogKun=`echo "$6" | awk '{print substr($1,1,1)}'`
if [ "$?" != 0 ]
then
  exit 9
fi
#---- エラーログファイル記入区分
ELogKun=`echo "$6" | awk '{print substr($1,2,1)}'`
if [ "$?" != 0 ]
then
  exit 9
fi

TimeStamp=`date +%Y%m%d%H%M%S`
TmStamp=`date +%Y%m%d`
#
if [ ${LogKun} -ne 0 ]; then
    LogPath=${LOG_PATH}/${PGM_ID}_${TmStamp}.log
    LOG_PROC ${LogPath}
fi

if [ ${ELogKun} -ne 0 ]; then
    ELogPath=${ERR_LOG_PATH}/${PGM_ID}_${TmStamp}.err
    LOG_PROC2 ${ELogPath}
fi
exit 0
