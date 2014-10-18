#!/bin/sh
source ~/.bash_profile
# ========================================================================
# システムＩＤ  ：  Past_KJ_Mask_JTK
# システム名称  ：  基準系過去分データマスク処理 JTK、JTK業務共通のみ
# 処理概要      ：  基準系過去分データマスク処理 JTK、JTK業務共通のみ
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100407 新規 GUT王    新規作成
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
#--- 引数設定
DATA_KBN=$1       # 共通と新共通:0  朝一業務と業務共通:1  締め後業務と業務共通:2
DATE_FILE=$2      # 過去MASK「共通用:00 朝一用：01 締め後：02」  指定日付:XXXXXXXX
DB_FILE=$3        # 過去DATA用:1   ユーザ指定:/XXXXX/XXXX/XXXX

#--- 初期処理
WORK_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${WORK_PATH}/conf"
PARAM_PATH="${WORK_PATH}/param"
SHL_PATH="${WORK_PATH}/sh"
TMP_PATH="${WORK_PATH}/tmp"
END_PATH="${WORK_PATH}/end"
LOG_PATH="${WORK_PATH}/log"

#--- ログパスは存在しない場合、作成する
test -e ${LOG_PATH} \
  || mkdir -p "${LOG_PATH}"

#--- ログファイル設定
LOG_FILE="${LOG_PATH}/Past_KJ_Mask_${DATA_KBN}.log"

#--- CONFファイルを引き込み
CONF_FILE="${CONF_PATH}/Past_KJ_Mask.conf"
if [ -e "${CONF_FILE}" ] ;then
  . "${CONF_FILE}"
else
  echo "CONFファイルがないので、ERR"                                  | tee -a "${LOG_FILE}"
  exit 1
fi

#--- 引数チェック
if [ $# -ne 3 ] ;then
  echo "Parameter  ERR"                                               | tee -a "${LOG_FILE}"
  echo 'usage $1  [ 0 ] CMNと新共通MASK'                              | tee -a "${LOG_FILE}"
  echo '          [ 1 ] 朝一業務と業務共通MASK '                      | tee -a "${LOG_FILE}"
  echo '          [ 2 ] 締め後業務と業務共通MASK'                     | tee -a "${LOG_FILE}"
  echo 'usage $2  [ 0 ] 過去共通日付FILE'                             | tee -a "${LOG_FILE}"
  echo '          [ 1 ] 過去朝一日付FILE'                             | tee -a "${LOG_FILE}"
  echo '          [ 2 ] 過去締め後日付FILE '                          | tee -a "${LOG_FILE}"
  echo 'usage $3  [ 1 ] 過去用WKDBファイル '                          | tee -a "${LOG_FILE}"
  echo '            上記以外の場合、WORK-DB-FILEを指定してください。' | tee -a "${LOG_FILE}"
  exit 1
fi

#--- ITK会社リストファイルの存在チェック
ITK_FILE="${PARAM_PATH}/${ITK_LIST_NAME}"
test -e "${ITK_FILE}" \
  || (echo "ITK会社リスト[${ITK_FILE}]がないので、ERR"                | tee -a "${LOG_FILE}" \
  && exit 1)

#--- ITK会社リストファイルの中身チェック
grep -E '^[^1]' ${ITK_FILE} > /dev/null
RE_STATUS=$?
test ${RE_STATUS} -eq 0 \
  && (echo "ITK会社リスト[${ITK_FILE}]の中身がITK会社以外の会社があるので、 ERR" | tee -a "${LOG_FILE}" \
  && exit 1)

#--- 過去用デフォルトWORK DBファイル指定
if [ "${DB_FILE}" = "1" ];then
   DB_FILE="${CONF_PATH}/${PAST_WKDB_FILE}"
fi

#--- WORK-DB-FILEの存在チェック
if [ -e "${DB_FILE}" ] ;then
  . "${DB_FILE}"
else
  echo "指定したWORK-DB-FILE(${DB_FILE})がないので、ERR"              | tee -a "${LOG_FILE}"
  exit 1
fi

#--- 過去データ日付ファイル設定
case ${DATE_FILE} in
"0")
  PAST_DATE_FILE="${PARAM_PATH}/${PAST_KJN_FILE00}"
  ;;
"1")
  PAST_DATE_FILE="${PARAM_PATH}/${PAST_KJN_FILE01}"
  ;;
"2")
  PAST_DATE_FILE="${PARAM_PATH}/${PAST_KJN_FILE02}"
  ;;
*)
  echo 'Parameter Err'                                                | tee -a "${LOG_FILE}"
  echo 'usage $2  [ 0 | 1 | 2 ] の任意を指定してください。'           | tee -a "${LOG_FILE}"
  ;;
esac

#--- 過去データ日付ファイルの存在チェック
if [ ! -e "${PAST_DATE_FILE}" ] ;then
  echo "指定した日付ファイル(${PAST_DATE_FILE})がないので、Err"       | tee -a "${LOG_FILE}"
  exit 1
fi

######################################################################
##   指定したDB接続子により、PROCESSの上限になっているかどうか      ##
######################################################################
PROCESS_MAX_CHECK()
{
  #--- 引数1：DB接続子
  MAX_CHK_DBCONN=$1
  while true
  do
    PROCESS_MAX_CNT=`ps -ef | grep "${SHL_PATH}/${SON_SHELL} ${MAX_CHK_DBCONN}" \
                        | grep -v 'grep' | wc -l`
    if  [ ${PROCESS_MAX_CNT} -lt ${MAX_CALL_COUNT} ] ;then
       break
    else
       echo "マスクシェルのPROCESS個数が上限(${MAX_CALL_COUNT})" \
            "になっているので、SLEEP(`date`)"                         | tee -a ${LOG_FILE}
       sleep 60
    fi
  done
}

######################################################################
##   指定した会社、データ区分、DB接続子により                       ##
##   マスクシェルが起動されたかどうか判断関数                       ##
######################################################################
PROCESS_CHECK()
{
  #--- 引数1：DB接続子
  CHK_WKDB_CONN=$1
  #--- 引数2：会社コード
  CHK_USER_CODE=$2
  #--- 引数3：データ区分
  CHK_DATE_KBN=$3
  while true
  do
    PROCESS_CNT=`ps -ef | grep "${SHL_PATH}/${SON_SHELL} ${CHK_WKDB_CONN}" \
                 | grep "${CHK_USER_CODE} ${CHK_DATE_KBN}" | grep -v 'grep' | wc -l`
    if  [ ${PROCESS_CNT} -lt 1 ] ;then
      break
    else
      echo "DB接続子(${WKDB_CONN})が占用されますので、WAIT.."         | tee -a "${LOG_FILE}"
      sleep 60
    fi
  done
}

######################################################################
##   朝一CMN・新共通のマスク処理関数                                ##
######################################################################
CMN_MASK()
{
  #--- 引数1：マスク日付
  CMN_MASK_DATA=$1
  
  #--- CMN 0000
  PROCESS_CHECK "${ASAITI_WKDB_0000_CONN}" "0000" "1"
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0000_CONN}" "${CMN_MASK_DATA}" "0000" "1" &
  
  #--- SINKYOTU NAM
  PROCESS_CHECK "${ASAITI_WKDB_0001_CONN}" "0001" "1"
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0001_CONN}" "${CMN_MASK_DATA}" "0001" "1" &
  
  #--- SINKYOTU JTK
#基盤更改の修正　START
# PROCESS_CHECK "${ASAITI_WKDB_0001_CONN}" "0002" "1"
  PROCESS_CHECK "${ASAITI_WKDB_0002_CONN}" "0002" "1"
#基盤更改の修正　END
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0002_CONN}" "${CMN_MASK_DATA}" "0002" "1" &
  
  #--- SINKYOTU ITK
  PROCESS_CHECK "${ASAITI_WKDB_0003_CONN}" "0003" "1"
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0003_CONN}" "${CMN_MASK_DATA}" "0003" "1" &
}

######################################################################
##   ITKのマスク処理関数                                            ##
######################################################################
ITK_MASK()
{
  #--- 引数1：マスク日付
  ITK_MASK_DATA=$1
  #--- 引数2：WORK-DB接続子
  ITK_WKDB_CONN=$2
  #--- 引数3：DATA区分
  ITK_DATA_KBN=$3
  while read RECORD_USER
  do
    #--- PROCESSの上限になっているかどうかチェック
    PROCESS_MAX_CHECK "${ITK_WKDB_CONN}"
    #--- 指定した会社、データ区分、DB接続子が占用されるかどうかチェック
    PROCESS_CHECK "${ITK_WKDB_CONN}" "${RECORD_USER}" "${ITK_DATA_KBN}"
    sleep 10
    #--- MASKシェル起動
    sh ${SHL_PATH}/${SON_SHELL} ${ITK_WKDB_CONN} ${ITK_MASK_DATA} ${RECORD_USER} ${ITK_DATA_KBN} &
    sleep 20
  done<"${ITK_FILE}"
}

######################################################################
##           MAIN 処理                                              ##
######################################################################
echo "★-----------------------------------------------------------★"| tee -a "${LOG_FILE}"
echo "◆ ↓過去データマスク処理START(`date`)"                         | tee -a "${LOG_FILE}"
echo "★-----------------------------------------------------------★"| tee -a "${LOG_FILE}"

cat ${PAST_DATE_FILE} | while read DATE_RECORD
do
  #--- データ区分によりマスク
  case "${DATA_KBN}" in
  "0")
    CMN_MASK "${DATE_RECORD}"
    #--- ENDファイルが存在する場合
    if [ -f "${END_PATH}/Past_KJ_Mask.0.END" ];then
       echo "★共通と新共通データ★処理まで..過去日付：${DATE_RECORD}"| tee -a "${LOG_FILE}"
       break
    fi
    ;;
  "1")
    #ITK_MASK "${DATE_RECORD}" "${ASAITI_WKDB_CONN}" "1"
  
    #--- NAM
    #------ PROCESSの上限になっているかどうかチェック
    #PROCESS_MAX_CHECK "${ASAITI_WKDB_CONN}"
    #------ NAM会社、データ区分、DB接続子が占用されるかどうかチェック
    #PROCESS_CHECK "${ASAITI_WKDB_CONN}" "1001" "1"
    #--- MASKシェル起動
    #sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_CONN}" "${DATE_RECORD}" "1001" "1" &
  
    #--- NAM 業務共通
    #------ NAM会社、データ区分、DB接続子が占用されるかどうかチェック
    #PROCESS_CHECK "${ASAITI_WKDB_10001_CONN}" "10001" "1"
    #--- MASKシェル起動
    #sh ${SHL_PATH}/${SON_SHELL} ${ASAITI_WKDB_10001_CONN} ${DATE_RECORD} "10001" "1" &
  
    #--- JTK
    #------ PROCESSの上限になっているかどうかチェック
    PROCESS_MAX_CHECK "${ASAITI_WKDB_CONN}"
    #------ JTK会社、データ区分、DB接続子が占用されるかどうかチェック
    PROCESS_CHECK "${ASAITI_WKDB_CONN}" "2001" "1"
    #--- MASKシェル起動
    sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_CONN}" "${DATE_RECORD}" "2001" "1" &
  
    #--- JTK 業務共通
    #------ JTK会社、データ区分、DB接続子が占用されるかどうかチェック
    PROCESS_CHECK "${ASAITI_WKDB_2000_CONN}" "2000" "1"
    #--- MASKシェル起動
    sh ${SHL_PATH}/${SON_SHELL} ${ASAITI_WKDB_2000_CONN} ${DATE_RECORD} "2000" "1" &
    
    #--- ITK 業務共通
    #------ ITK会社、データ区分、DB接続子が占用されるかどうかチェック
    #PROCESS_CHECK "${ASAITI_WKDB_1000_CONN}" "1000" "1"
    #--- MASKシェル起動
    #sh ${SHL_PATH}/${SON_SHELL} ${ASAITI_WKDB_1000_CONN} ${DATE_RECORD} "1000" "1" &
    
    #--- ENDファイルが存在する場合
    if [ -f "${END_PATH}/Past_KJ_Mask.1.END" ];then
       echo "★朝一業務データ★処理まで..過去日付：${DATE_RECORD}"    | tee -a "${LOG_FILE}"
       break
    fi
    ;;
  "2")
    #ITK_MASK "${DATE_RECORD}" "${SIMEGO_WKDB_CONN}" "2"
  
    #--- NAM
    #------ PROCESSの上限になっているかどうかチェック
    #PROCESS_MAX_CHECK "${SIMEGO_WKDB_CONN}"
    #------ NAM会社、データ区分、DB接続子が占用されるかどうかチェック
    #PROCESS_CHECK "${SIMEGO_WKDB_CONN}" "1001" "2"
    #--- MASKシェル起動
    #sh ${SHL_PATH}/${SON_SHELL} "${SIMEGO_WKDB_CONN}" "${DATE_RECORD}" "1001" "2" &
  
    #--- NAM 業務共通
    #------ NAM会社、データ区分、DB接続子が占用されるかどうかチェック
    #PROCESS_CHECK "${SIMEGO_WKDB_10001_CONN}" "10001" "2"
    #--- MASKシェル起動
    #sh ${SHL_PATH}/${SON_SHELL} ${SIMEGO_WKDB_10001_CONN} ${DATE_RECORD} "10001" "2" &
  
    #--- JTK
    #------ PROCESSの上限になっているかどうかチェック
    PROCESS_MAX_CHECK "${SIMEGO_WKDB_CONN}"
    #------ JTK会社、データ区分、DB接続子が占用されるかどうかチェック
    PROCESS_CHECK "${SIMEGO_WKDB_CONN}" "2001" "2"
    #--- MASKシェル起動
    sh ${SHL_PATH}/${SON_SHELL} "${SIMEGO_WKDB_CONN}" "${DATE_RECORD}" "2001" "2" &
  
    #--- JTK 業務共通
    #------ JTK会社、データ区分、DB接続子が占用されるかどうかチェック
    PROCESS_CHECK "${SIMEGO_WKDB_2000_CONN}" "2000" "2"
    #--- MASKシェル起動
    sh ${SHL_PATH}/${SON_SHELL} ${SIMEGO_WKDB_2000_CONN} ${DATE_RECORD} "2000" "2" &
    
    #--- ITK 業務共通
    #------ ITK会社、データ区分、DB接続子が占用されるかどうかチェック
    #PROCESS_CHECK "${SIMEGO_WKDB_1000_CONN}" "1000" "2"
    #--- MASKシェル起動
    #sh ${SHL_PATH}/${SON_SHELL} ${SIMEGO_WKDB_1000_CONN} ${DATE_RECORD} "1000" "2" &

    #--- ENDファイルが存在する場合
    if [ -f "${END_PATH}/Past_KJ_Mask.2.END" ];then
       echo "★締め後業務データ★処理まで..過去日付：${DATE_RECORD}"  | tee -a "${LOG_FILE}"
       break
    fi
    ;;
  *)
    echo "指定したデータ区分がないので、ERR"                          | tee -a "${LOG_FILE}"
    exit 1
    ;;
  esac
done

#--- 正常終了
echo "★-----------------------------------------------------------★"| tee -a "${LOG_FILE}"
echo "◆ ↑過去データマスク処理 END (`date`)"                         | tee -a "${LOG_FILE}"
echo "★-----------------------------------------------------------★"| tee -a "${LOG_FILE}"
exit 0
