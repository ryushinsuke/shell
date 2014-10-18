#!/bin/sh
# ========================================================================
# システムＩＤ  ： MaskedData_cpy
# システム名称  ： マスク済みデータ転送処理
# 処理概要      ： マスク済みデータ転送処理
# 入力引数      ： ①  処理区分
#                  ②  処理日付
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20130923 新規 GUT趙銘  新規作成
# ========================================================================

# 引数設定
SYORI_KBN=$1     #1:朝一  2:締め後  3:顧問
SYORI_DATE=$2    #def:1(sysdate)  システム日付
if [ "${SYORI_DATE}" = "1" ] ;then
  SYORI_DATE=`date '+%Y%m%d'`
fi

# 変数初期化
HOME_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${HOME_PATH}/conf"
LOG_PATH="${HOME_PATH}/log"

test -d ${LOG_PATH} || mkdir -p ${LOG_PATH}
LOG_FILE=${LOG_PATH}/MaskedData_cpy_${SYORI_DATE}.log

#--- 引数チェック
if [ $# -ne 2 ] ;then
  echo "Parameter  ERR"                                               | tee -a ${LOG_FILE}
  echo 'usage $1  [ 1 ] 朝一'                                         | tee -a ${LOG_FILE}
  echo '          [ 2 ] 締め後'                                       | tee -a ${LOG_FILE}
  echo '          [ 3 ] 顧問'                                         | tee -a ${LOG_FILE}
  echo 'usage $2  [ 1 ] 当日日付'                                     | tee -a ${LOG_FILE}
  echo '          上記以外の場合、日付を指定してください。'           | tee -a ${LOG_FILE}
  exit 1
fi

#--- 環境ファイル読み込み
CONF_FILE=${CONF_PATH}/MaskedData_cpy.conf
if [ -f ${CONF_FILE} ];then
  . ${CONF_FILE}
else
  echo "環境ファイルがないので、ERR!"                                 | tee -a ${LOG_FILE}
  exit 1
fi

#-------------------------------------------------------
# 関数：KJ_ASAITI_CPY  基準系朝一マスク済みデータ転送
#-------------------------------------------------------
KJ_ASAITI_CPY()
{
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn ssh -l ${TYOSA_USER} ${TYOSA_IP}
  expect {
  "*password: " {send "${TYOSA_PWD}\r"; }
  }
  expect " ~]"
  send "mkdir -p ${KJ_DMP_ASAITI_OUT_PATH}/${SYORI_DATE}\r"
  expect " ~]"
  send "exit\r"
  interact
EOF
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn sftp ${TYOSA_USER}@${TYOSA_IP}
  expect "password:"
  send "${TYOSA_PWD}\r"

  expect "sftp>"
  send "mput ${KJ_DMP_ASAITI_IN_PATH}/${SYORI_DATE}/* ${KJ_DMP_ASAITI_OUT_PATH}/${SYORI_DATE}\r"

  expect "sftp>"
  send "exit\r"
  interact
EOF
}

#-------------------------------------------------------
# 関数：KJ_SIMEGO_CPY  基準系締め後マスク済みデータ転送
#-------------------------------------------------------
KJ_SIMEGO_CPY()
{
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn ssh -l ${TYOSA_USER} ${TYOSA_IP}
  expect {
  "*password: " {send "${TYOSA_PWD}\r"; }
  }
  expect " ~]"
  send "mkdir -p ${KJ_DMP_SIMEGO_OUT_PATH}/${SYORI_DATE}\r"
  expect " ~]"
  send "exit\r"
  interact
EOF
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn sftp ${TYOSA_USER}@${TYOSA_IP}
  expect "password:"
  send "${TYOSA_PWD}\r"

  expect "sftp>"
  send "mput ${KJ_DMP_SIMEGO_IN_PATH}/${SYORI_DATE}/* ${KJ_DMP_SIMEGO_OUT_PATH}/${SYORI_DATE}\r"

  expect "sftp>"
  send "exit\r"
  interact
EOF
}

#-------------------------------------------------------
# 関数：KMN_CPY  顧問系マスク済みデータ転送
#-------------------------------------------------------
KMN_CPY()
{
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn ssh -l ${TYOSA_USER} ${TYOSA_IP}
  expect {
  "*password: " {send "${TYOSA_PWD}\r"; }
  }
  expect " ~]"
  send "mkdir -p ${KMN_DMP_OUT_PATH}/${SYORI_DATE}\r"
  expect " ~]"
  send "exit\r"
  interact
EOF
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn sftp ${TYOSA_USER}@${TYOSA_IP}
  expect "password:"
  send "${TYOSA_PWD}\r"

  expect "sftp>"
  send "mput ${KMN_DMP_IN_PATH}/${SYORI_DATE}/* ${KMN_DMP_OUT_PATH}/${SYORI_DATE}\r"

  expect "sftp>"
  send "exit\r"
  interact
EOF
}

########################################################
#     MAIN 処理
########################################################
echo "★-----------------------------------------------------------★"| tee -a ${LOG_FILE}
echo "◆ マスク済みデータ転送処理開始(`date`)"                        | tee -a ${LOG_FILE}
echo "★-----------------------------------------------------------★"| tee -a ${LOG_FILE}

case ${SYORI_KBN} in
  1)
    KJ_ASAITI_CPY
    ;;
  2)
    KJ_SIMEGO_CPY
    ;;
  3)
    KMN_CPY
    ;;
  *)
    echo "指定した処理区分がないので、ERR"                            | tee -a ${LOG_FILE}
    exit 1
    ;;
esac
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
  echo "マスク済みデータ転送処理 ERR!"                                | tee -a ${LOG_FILE}
  exit 1
fi

#--- 正常終了
echo "★-----------------------------------------------------------★"| tee -a ${LOG_FILE}
echo "◆ マスク済みデータ転送処理終了(`date`)"                        | tee -a ${LOG_FILE}
echo "★-----------------------------------------------------------★"| tee -a ${LOG_FILE}
exit 0
