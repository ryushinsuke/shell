#!/bin/sh
source ~/.bash_profile

################
##  引数設定  ##
################
TARGET_DATE=$1

#################################################################
## PATH(/share/YDC_DMP) 直下の指定日付フォルダ(def:三日前)削除 ##
#################################################################
WORK_PATH=$(cd $(dirname $0);pwd)
TARGET_PATH="/share/YDC_DMP"
if [ $# -eq 0 ];then
  TARGET_DATE=`date -d '3 days ago' '+%Y%m%d'`
fi
test -z "${TARGET_DATE}" && (echo "削除したい日付フォルダを指定してください！" && exit 1)
LOG_FILE="${WORK_PATH}/../log/TmpFolderDel.log"
test -e "${WORK_PATH}/../log" || mkdir -p "${WORK_PATH}/../log"

#パスチェンジ
cd ${TARGET_PATH} 2>/dev/null || (echo "PATH(${TARGET_PATH})チェンジ ERROR." && exit 1)

############################################################
##     Main Shell                                         ##
############################################################
echo "PATH(${TARGET_PATH})下のDATE(${TARGET_DATE})のFolder削除開始(`date`)" | tee -a ${LOG_FILE}
for rm_target_path in `find  -name "${TARGET_DATE}" -type d`
do
  cd ${TARGET_PATH} && rm -r ${rm_target_path}
  echo "日付PATH(${rm_target_path})を削除しました。"                        | tee -a ${LOG_FILE}
done
echo "PATH(${TARGET_PATH})下のDATE(${TARGET_DATE})のFolder削除終了(`date`)" | tee -a ${LOG_FILE}

#正常終了
exit 0
