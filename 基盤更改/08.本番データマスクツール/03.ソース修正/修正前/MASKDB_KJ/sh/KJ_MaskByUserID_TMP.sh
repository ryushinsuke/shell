#!/bin/bash
source ~/.bash_profile
# ========================================================================
# システムＩＤ  ：  KJ_MaskByUserID_TMP
# システム名称  ：  TMPマスク起動シェル
# 処理概要      ：  TMPマスク起動シェル
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100414 新規 GUT      新規作成
# ========================================================================
#---引数設定
MASK_DATE=$1
USER_ID=$2
SYORI_KBN=$3

#---初期設定
WORK_HOME="$(cd $(dirname $0);pwd)/.."
PARAM_PATH="${WORK_HOME}/param"
TMP_PATH="${WORK_HOME}/tmp"
SHL_PATH="${WORK_HOME}/sh"
LOG_PATH="${WORK_HOME}/log/KJ_MaskByUserID_TMP"

#---PATHが存在しない場合、作成する
test -e "${LOG_PATH}" \
  || mkdir -p "${LOG_PATH}"
  
#---ログファイル定義
LOG_FILE="${LOG_PATH}/KJ_MaskByUserID_TMP_${MASK_DATE}_${USER_ID}.log"

PBUMASK_DATE="${MASK_DATE}"        #下記のCONFファイル用
#---CONFファイルを引き込む
CONF_FILE="${WORK_HOME}/conf/Past_KJ_MaskByUserID.conf"
if [ -e "${CONF_FILE}" ];then
  . "${CONF_FILE}"
else
  echo "必要なCONFファイル(${CONF_FILE})がないため、ERR "             | tee -a ${LOG_FILE}
  exit 1
fi

#---引数チェック
if [ $# -ne 3 ] ;then
  echo "Parameter    ERR"                                             | tee -a ${LOG_FILE}
  echo 'usage: $1 マスク日付指定'                                     | tee -a ${LOG_FILE}
  echo 'usage: $2 ユーザーID指定'                                     | tee -a ${LOG_FILE}
  echo 'usage: $3 処理区分指定[1：朝一  2：締め後]'                   | tee -a ${LOG_FILE}
  exit 1
fi

#--- DB接続用ファイルの存在チェック
CONN_FILE="${PARAM_PATH}/tmp_conn.lst"
if [ ! -f "${CONN_FILE}" ] ;then
  echo "DB接続用のファイル(${CONN_FILE})がないため、ERR"              | tee -a ${LOG_FILE}
  exit 1
fi

#--- DB接続子取得
CONN_ROW=0
DB_CONN="0000"
while read CONN_RECORD
do
  CONN_ROW=`expr ${CONN_ROW} + 1`
  LOCK_FILE="${TMP_PATH}/conn_${CONN_ROW}.lock"
  if [ ! -e "${LOCK_FILE}" ] ;then
     DB_CONN="${CONN_RECORD}"
     break
  fi
done<"${CONN_FILE}"

#--- DB接続子取得後チェック
if [ "${DB_CONN}" = "0000" ];then
  echo "DB接続用のファイル(${CONN_FILE})の中に、" \
       "すべてのDB接続子が占用されていますので、EXIT"                | tee -a ${LOG_FILE}
  exit 1
fi
######################################################################
##    MAIN 処理                                                     ##
######################################################################
echo "◆----------------------------------------------------------◆"| tee -a ${LOG_FILE}
echo "★  TMPマスク処理開始 (`date`)                                "| tee -a ${LOG_FILE}
echo "◆----------------------------------------------------------◆"| tee -a ${LOG_FILE}
MASK_SHELL="${SHL_PATH}/Past_KJ_MaskByUserID.sh"
if [ -e "${MASK_SHELL}" ] ;then
  touch "${LOCK_FILE}"
  echo "${DB_CONN} ${MASK_DATE} ${USER_ID} ${SYORI_KBN}"             | tee -a ${LOG_FILE}
  ${MASK_SHELL} ${DB_CONN} ${MASK_DATE} ${USER_ID} ${SYORI_KBN}      | tee -a ${LOG_FILE}
  rm -f "${LOCK_FILE}"
else
  echo "マスクシェル(${MASK_SHELL})がないため、ERR"                  | tee -a ${LOG_FILE}
  exit 1
fi

#--- 正常終了
echo "DATE：${MASK_DATE} USER：${USER_ID} KBN：${SYORI_KBN}         "| tee -a ${LOG_FILE}
echo "◆----------------------------------------------------------◆"| tee -a ${LOG_FILE}
echo "★  TMPマスク処理終了 (`date`)                                "| tee -a ${LOG_FILE}
echo "◆----------------------------------------------------------◆"| tee -a ${LOG_FILE}
exit 0
