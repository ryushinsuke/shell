#!/bin/sh
source ~/.bash_profile
################################################################################
# システムＩＤ  ：  KMN_Mask_main
# システム名称  ：  顧問系データマスク処理
# 処理概要      ：  顧問系データマスクメイン処理
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100706 新規 GUT王    新規作成
# 20130327 改修 GUT      仕様変更対応
# 20130920 改修 GUT趙銘　仕様変更対応
################################################################################
#--- 引数1(処理区分)
MASK_KBN=$1

#--- 初期処理
WORK_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${WORK_PATH}/conf"
LOG_PATH="${WORK_PATH}/log"
SHL_PATH="${WORK_PATH}/sh"
TMP_PATH="${WORK_PATH}/tmp"
TMP_BAK_PATH="${WORK_PATH}/tmp_bak"
CONF_FILE="${CONF_PATH}/KMN_Mask_main.conf"
LOG_FILE="${LOG_PATH}/KMN_Mask_main_`date '+%Y%m%d-%H%M%S'`.log"

#--- ENDファイル設定
CURRENT_END="${TMP_PATH}/exp_YDC_CURRENT.END"
KOMON_END="${TMP_PATH}/exp_YDC_KOMON.END"

#------------------------------------------------------------------------
# ステップ-010  # パラメータ数チェック
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN010
if [ $# -ne 1 ];then
  echo "Parameter ERR"                                                | tee -a ${LOG_FILE}
  echo "usage: \$1 処理区分[ 0：CURRENT | 1：通常(週次) ]"            | tee -a ${LOG_FILE}
  exit 1
fi

#------------------------------------------------------------------------
# ステップ-020  # マスク日付取得
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN020
case "${MASK_KBN}" in
"0")
  if [ -f "${CURRENT_END}" ];then
    MASK_DATE=`cat ${CURRENT_END} | grep -E '[0-9]{8,8}\b'|sort|tail -1`
    if [ -z "${MASK_DATE}" ];then
      echo "ファイル(${CURRENT_END})の中に日付取得ERR。(`date`)"      | tee -a ${LOG_FILE}
      exit 1
    fi
  else
    echo "本番データマスクの臨時依頼がないです。(`date`)"             | tee -a ${LOG_FILE}
    exit 1
  fi
  ;;
"1")
  if [ -f "${KOMON_END}" ];then
    MASK_DATE=`cat ${KOMON_END} | grep -E '[0-9]{8,8}\b'|sort|tail -1`
    if [ -z "${MASK_DATE}" ];then
      echo "ファイル(${KOMON_END})の中に日付取得ERR[週次]。(`date`)"  | tee -a ${LOG_FILE}
      exit 1
    fi
  else
    echo "本番データマスクの週次ENDファイル取得失敗。(`date`)"        | tee -a ${LOG_FILE}
    exit 1
  fi
  ;;
esac

#------------------------------------------------------------------------
# ステップ-030  # confファイル存在チェック
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN030
if [ -e "${CONF_FILE}" ];then
  . "${CONF_FILE}"
else
  echo "★CONFファイル(${CONF_FILE})が存在しないので、ERR"            | tee -a ${LOG_FILE}
  exit 1
fi
#基盤更改の修正　START
#---  臨時依頼の会社リストファイル取得チェック
if [ -z ${CURRENT_FILE} ]
then
  echo "臨時依頼の会社リストファイル取得にエラーが発生しました！"     | tee -a ${LOG_FILE}
  exit 1
fi

#---  臨時依頼によって、本番に作成した本番DMPファイルのパス(CURRENT)取得チェック
if [ -z ${HB_DMP_CURRENT_PATH} ]
then
  echo "本番DMPファイルのパス(CURRENT)取得にエラーが発生しました！"   | tee -a ${LOG_FILE}
  exit 1
fi

#本番に作成した本番DMPファイルのパス(週次)取得チェック
if [ -z ${HB_DMP_NORMAL_PATH} ]
then
  echo "本番DMPファイルのパス(週次)取得にエラーが発生しました！"      | tee -a ${LOG_FILE}
  exit 1
fi

#HISTORYファイル定義取得チェック
if [ -z ${HISTORY_CURRENT} ]
then
  echo "HISTORY_CURRENTファイル定義取得にエラーが発生しました！"      | tee -a ${LOG_FILE}
  exit 1
fi

#HISTORYファイル定義取得チェック
if [ -z ${HISTORY_NORMAL} ]
then
  echo "HISTORY_NORMALファイル定義取得にエラーが発生しました！"       | tee -a ${LOG_FILE}
  exit 1
fi

#ワークDBに本番DMPファイルを置くパス取得チェック
if [ -z ${WKDB_DMP_PATH_IN_BASE} ]
then
  echo "本番DMPファイル格納パス(BASE)取得にエラーが発生しました！"    | tee -a ${LOG_FILE}
  exit 1
fi

#ワークDBに本番DMPファイルを置くパス取得チェック
if [ -z ${WKDB_DMP_PATH_IN} ]
then
  echo "本番DMPファイル格納パス取得にエラーが発生しました！"          | tee -a ${LOG_FILE}
  exit 1
fi

#ワークDBにマスク後DMPファイルを置くパス取得チェック
if [ -z ${WKDB_DMP_PATH_OUT_BASE} ]
then
  echo "マスク後DMPファイル格納パス(BASE)取得にエラーが発生しました！" | tee -a ${LOG_FILE}
  exit 1
fi

#ワークDBにマスク後DMPファイルを置くパス取得チェック
if [ -z ${WKDB_DMP_PATH_OUT} ]
then
  echo "マスク後DMPファイル格納パス取得にエラーが発生しました！"      | tee -a ${LOG_FILE}
  exit 1
fi

#公開した顧問マスク済みパス(CURRENT)取得チェック
if [ -z ${KOKAI_KMN_CURRENT_PATH} ]
then
  echo "公開顧問マスク済みパス(CURRENT)取得にエラーが発生しました！"  | tee -a ${LOG_FILE}
  exit 1
fi

#公開した顧問マスク済みパス(週次)取得チェック
if [ -z ${KOKAI_KMN_NORMAL_PATH} ]
then
  echo "公開顧問マスク済みパス(週次)取得にエラーが発生しました！"     | tee -a ${LOG_FILE}
  exit 1
fi
#基盤更改の修正　END

#------------------------------------------------------------------------
# ステップ-040  # historyファイルに、マスク日付存在チェック
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN040
case "${MASK_KBN}" in
"0")
  cat ${HISTORY_CURRENT} | grep -w ${MASK_DATE}
  RE_STATUS=$?
  if [ "${RE_STATUS}" -eq 0 ] ;then
    echo "履歴ファイル(${HISTORY_CURRENT})の中に、"                   | tee -a ${LOG_FILE}
    echo "該当日付が存在していますので、マスクせずに終了する"         | tee -a ${LOG_FILE}
    exit 0
  fi
  ;;
"1")
  cat ${HISTORY_NORMAL} | grep -w ${MASK_DATE}
  RE_STATUS=$?
  if [ "${RE_STATUS}" -eq 0 ] ;then
    echo "履歴ファイル(${HISTORY_NORMAL})の中に、"                    | tee -a ${LOG_FILE}
    echo "該当日付が存在していますので、マスクせずに終了する"         | tee -a ${LOG_FILE}
    exit 0
  fi
  ;;
esac

######################################################################
##        会社別マスク処理関数                                      ##
######################################################################
USER_MASK()
{
  USER_CODE=$1
  F_MASK_DATE=$2
  HB_DMP_PATH=$3
  WK_PATH_IN=$4
  WK_PATH_OUT=$5
  KOKAI_PATH=$6

#------------------------------------------------------------------------
# ステップ-010  # メッセージ出力
#------------------------------------------------------------------------
#STEPNAME=USERMASK010
  echo "処理会社：${USER_CODE}"                                       | tee -a ${LOG_FILE}

#------------------------------------------------------------------------
# ステップ-020  # マスク対象をワーク入力フォルダにコピー
#------------------------------------------------------------------------
#STEPNAME=USERMASK020
  cp ${HB_DMP_PATH}/${USER_CODE}_kmn_1.exp*  ${WK_PATH_IN}

#------------------------------------------------------------------------
# ステップ-030  # マスク処理
#------------------------------------------------------------------------
#STEPNAME=USERMASK030
  ${SHL_PATH}/KMN_MaskByUserID.sh  \
     ${F_MASK_DATE}  \
     ${USER_CODE}
#基盤更改の修正　START
  MV_M_STATUS=$?
#基盤更改の修正　END

#------------------------------------------------------------------------
# ステップ-040  # マスク済みデータファイルを公開フォルダへ移動
#------------------------------------------------------------------------
#STEPNAME=USERMASK040
#基盤更改の修正　START
#  if [ -d "${WK_PATH_OUT}/${USER_CODE}_1_m" ];then
#    mv -f ${WK_PATH_OUT}/${USER_CODE}_1_m \
#          ${KOKAI_PATH}
#    MV_M_STATUS=$?
#  else
#    echo "★${USER_CODE}のマスク出力DMPが作成しない！"                | tee -a ${LOG_FILE}
#  fi
#基盤更改の修正　END
#------------------------------------------------------------------------
# ステップ-050  # マスクなし対象をワーク入力フォルダにコピー
#                （会社別運用成果データファイル以外）
#------------------------------------------------------------------------
#STEPNAME=USERMASK050
  cp ${HB_DMP_PATH}/${USER_CODE}_kmn_2.exp*  ${WK_PATH_IN}

#------------------------------------------------------------------------
# ステップ-060  # マスクなしデータをテーブル単位にて出力処理
#                （会社別運用成果データファイル以外）
#------------------------------------------------------------------------
#STEPNAME=USERMASK060
  ${SHL_PATH}/KMN_NoMaskByUserID.sh  \
     ${F_MASK_DATE}  \
     ${USER_CODE}
#基盤更改の修正　START
  MV_O_STATUS=$?
#基盤更改の修正　END

#------------------------------------------------------------------------
# ステップ-070  # マスクなしのデータファイルを公開フォルダへ移動
#                （会社別運用成果データファイル以外）
#------------------------------------------------------------------------
  K_PATH="${KOKAI_PATH}/${USER_CODE}_2"
#STEPNAME=USERMASK070
#基盤更改の修正　START
#  if [ -d "${WK_PATH_OUT}/${USER_CODE}_2" ];then
#    mv -f ${WK_PATH_OUT}/${USER_CODE}_2 \
#          ${KOKAI_PATH}
#    MV_O_STATUS=$?
#  else
#基盤更改の修正　END
    if [ ! -e ${K_PATH} ]
    then
        mkdir ${K_PATH}
    fi
#基盤更改の修正　START
#    echo "★${USER_CODE}のマスクなし出力DMPが作成しない！"                | tee -a ${LOG_FILE}
#  fi
#基盤更改の修正　END
#------------------------------------------------------------------------
# ステップ-080  # 会社別運用成果データファイルを公開フォルダへコピー
#------------------------------------------------------------------------
#STEPNAME=USERMASK080
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSMS01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSMS01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSMS01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSMS01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSMS01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSMS01_${USER_CODE}.sql
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSSK01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSSK01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSSK01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSSK01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSSK01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSSK01_${USER_CODE}.sql
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSTH01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSTH01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSTH01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSTH01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSTH01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSTH01_${USER_CODE}.sql
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSZT01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSZT01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSZT01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSZT01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSZT01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSZT01_${USER_CODE}.sql
#------------------------------------------------------------------------
# ステップ-090  # 完了又はエラーメッセージ出力
#------------------------------------------------------------------------
#STEPNAME=USERMASK090
    if    [ ${MV_M_STATUS} -ne 0 ] \
       || [ ${MV_O_STATUS} -ne 0 ] ;then
      echo "★${USER_CODE}の顧問データは公開ERR！"                    | tee -a ${LOG_FILE}
    else
      echo "会社${USER_CODE}のマスク済みデータとDDLが公開されました。"| tee -a ${LOG_FILE}
    fi
}

######################################################################
##        履歴ファイル書き込み関数                                  ##
######################################################################
WRITE_HISTORY()
{
  #--- 引数1：書き込みの日付
  H_MASK_DATE=$1
  #--- 引数2：書き込み先のファイル
  HISTORY_FILE=$2
  echo "履歴ファイル(${HISTORY_FILE})に書き込み開始(`date`)"          | tee -a ${LOG_FILE}
  echo "${MASK_DATE}" >> "${HISTORY_FILE}"
  echo "書き込みの日付：${H_MASK_DATE}"                               | tee -a ${LOG_FILE}
  echo "履歴ファイル(${HISTORY_FILE})に書き込み終了(`date`)"          | tee -a ${LOG_FILE}
}

######################################################################
##                  MAIN 処理                                       ##
######################################################################
#------------------------------------------------------------------------
# ステップ-050  # CURRENT処理 -- 公開用フォルダ作成
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN050
if [ "${MASK_KBN}" = "0" ] && [ -f "${CURRENT_FILE}" ] ;then
  #--- 公開用フォルダ作成
  if [ ! -d "${KOKAI_KMN_CURRENT_PATH}" ] ;then
    mkdir "${KOKAI_KMN_CURRENT_PATH}"
  fi

#------------------------------------------------------------------------
# ステップ-051  # CURRENT処理 -- 会社別処理
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN051
  echo "顧問系${MASK_DATE}本番データマスクCURRENT処理開始_(`date`)"   | tee -a ${LOG_FILE}
  while read RECORD_CURRENT
  do
    #--- マスク関数コール
    USER_MASK                   \
      ${RECORD_CURRENT}         \
      ${MASK_DATE}              \
      ${HB_DMP_CURRENT_PATH}    \
      ${WKDB_DMP_PATH_IN}       \
      ${WKDB_DMP_PATH_OUT}      \
      ${KOKAI_KMN_CURRENT_PATH}
  done < "${CURRENT_FILE}"

#------------------------------------------------------------------------
# ステップ-052  # CURRENT処理 -- 業務共通処理
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN052  
USER_MASK                     \
    "1000"                      \
    ${MASK_DATE}                \
    ${HB_DMP_CURRENT_PATH}      \
    ${WKDB_DMP_PATH_IN}         \
    ${WKDB_DMP_PATH_OUT}        \
    ${KOKAI_KMN_CURRENT_PATH}
  
  echo "顧問系${MASK_DATE}本番データマスクCURRENT処理終了_(`date`)"   | tee -a ${LOG_FILE}
  
#------------------------------------------------------------------------
# ステップ-053  # CURRENT処理 -- 履歴ファイル書き込み
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN053  
  WRITE_HISTORY                 \
    ${MASK_DATE}                \
    ${HISTORY_CURRENT}

#------------------------------------------------------------------------
# ステップ-054  # CURRENT処理 -- 臨時依頼のENDファイル移動
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN054  
  mv -f ${CURRENT_END} ${TMP_BAK_PATH}
  mv -f ${CURRENT_FILE} ${TMP_BAK_PATH}
fi

if [ "${MASK_KBN}" = "1" ] ;then
#------------------------------------------------------------------------
# ステップ-060  # 週次処理 -- 公開用フォルダ作成
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN060
  if   [ `date -d ${MASK_DATE} '+%u'` -eq ${SAT_OF_WEEK} ] \
    || [ `date -d ${MASK_DATE} '+%u'` -eq ${SUN_OF_WEEK} ];then
    #--- 公開用フォルダ作成
    if [ ! -d "${KOKAI_KMN_NORMAL_PATH}" ];then
      mkdir "${KOKAI_KMN_NORMAL_PATH}"
    fi
#------------------------------------------------------------------------
# ステップ-061  # 週次処理 -- 共通と会社別処理
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN061
    echo "顧問系${MASK_DATE}本番データマスク週次処理開始_(`date`)"      | tee -a ${LOG_FILE}
    for RECORD_KAISYACD in `ls -1 ${HB_DMP_NORMAL_PATH} | grep '_kmn_1.exp' | awk -F'_' '{print $1}'`
    do
      #--- マスク関数コール
      echo "${RECORD_KAISYACD}"
      USER_MASK                   \
        ${RECORD_KAISYACD}        \
        ${MASK_DATE}              \
        ${HB_DMP_NORMAL_PATH}     \
        ${WKDB_DMP_PATH_IN}       \
        ${WKDB_DMP_PATH_OUT}      \
        ${KOKAI_KMN_NORMAL_PATH}
    done
    echo "顧問系${MASK_DATE}本番データマスク週次処理終了_(`date`)"      | tee -a ${LOG_FILE}
    
#------------------------------------------------------------------------
# ステップ-062  # 週次処理 -- 履歴ファイル書き込み
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN062  
    WRITE_HISTORY                 \
      ${MASK_DATE}                \
      ${HISTORY_NORMAL}

#------------------------------------------------------------------------
# ステップ-063  # 週次処理 -- ENDファイル移動
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN063  
    mv -f ${KOMON_END} ${TMP_BAK_PATH}
  fi
fi

#------------------------------------------------------------------------
# ステップ-070  # ワーク臨時フォルダを削除
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN070  
echo "◆ 臨時フォルダ削除開始(`date`)"                                | tee -a ${LOG_FILE}
echo "〓削除フォルダ：${WKDB_DMP_PATH_IN_BASE} 直下の ${MASK_DATE}"   | tee -a ${LOG_FILE}
cd ${WKDB_DMP_PATH_IN_BASE} && rm -r ${MASK_DATE}
echo "〓削除フォルダ：${WKDB_DMP_PATH_OUT_BASE} 直下の ${MASK_DATE}"  | tee -a ${LOG_FILE}
cd ${WKDB_DMP_PATH_OUT_BASE} && rm -r ${MASK_DATE}
echo "◆ 臨時フォルダ削除終了(`date`)"                                | tee -a ${LOG_FILE}

#--- 正常終了
exit 0
