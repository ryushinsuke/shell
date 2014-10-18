#!/bin/bash
######################################################################
##      マスクすべきDMPファイルの存在チェック                       ##
######################################################################
#---引数
TARGET_PATH=$1  #def:/ext/YDC_DMP/MASKDB
TARGET_KBN=$2   #朝一(CMNと新共通):0 朝一(ITK/JTK/NAM):1 締め後:2
TARGET_DATE=$3  #ALL・個別日付指定可

#---引数チェック
if [ $# -ne 3 ];then
   echo 'usage $1 [ 1 ] : PATH(/ext/YDC_DMP/MASKDB)はTARGETとする'
   echo '           上記以外の場合、詳しいパスを指定してください！'
   echo 'usage $2 [ 0 ] : CMNと新共通のマスク済みファイルチェック'
   echo '         [ 1 ] : 朝一(ITK/JTK/NAM)のマスク済みファイルチェック'
   echo '         [ 2 ] : 締め後のマスク済みファイルチェック'
   echo 'usage $3 [ ALL ]      : マスク済みの格納パス直下の全部の日付フォルダは対象とする'
   echo '         [ YYYYMMDD ] : マスク済みの格納パス直下の指定の日付フォルダは対象とする'
   exit 1
fi

#---初期設定
WORK_PATH=$(cd $(dirname $0);pwd)/..
PRARM_PATH="${WORK_PATH}/param"
ITK_CODE_FILE="${PRARM_PATH}/ITK_CODE.lst"

######################################################################
##  指定した日付フォルダ直下のマスク済みDMPチェック関数             ##
######################################################################
DATE_MASKED_CHECK()
{
  DATE_DIR=$1
  #---朝一(CMN/新共通)チェック
  if [ "${TARGET_KBN}" = "0" ];then
     #--CMN
     ls ${DATE_DIR} | grep -w "exp_YDC_CMN_${DATE_DIR}_m.dmp.gz" > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0000	1	exp_YDC_CMN_${DATE_DIR}_m.dmp.gz"
       
     #--ITK_SINKYOTU
     ls ${DATE_DIR}|grep -w "exp_YDC_ITK_SINKYOTU_${DATE_DIR}_m.dmp.gz" > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0003	1	exp_YDC_ITK_SINKYOTU_${DATE_DIR}_m.dmp.gz"
       
     #--JTK_SINKYOTU
     ls ${DATE_DIR}|grep -w "exp_YDC_JTK_SINKYOTU_${DATE_DIR}_m.dmp.gz"  > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0002	1	exp_YDC_JTK_SINKYOTU_${DATE_DIR}_m.dmp.gz"
       
     #--NAM_SINKYOTU
     ls ${DATE_DIR}|grep -w "exp_YDC_NAM_SINKYOTU_${DATE_DIR}_m.dmp.gz"  > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0001	1	exp_YDC_NAM_SINKYOTU_${DATE_DIR}_m.dmp.gz"
       
  #---朝一(ITK/JTK/NAM)チェック
  elif [ "${TARGET_KBN}" = "1" ];then
    #---朝一ITK
     test -e ${ITK_CODE_FILE} \
      || (echo "PARAMファイル(${ITK_CODE_FILE})が存在しないので、ERR " \
      && exit 1)
      
     while read COMPANY_RECORD
     do
        ls ${DATE_DIR}|grep -E "exp_YDC_ITK_${DATE_DIR}_[1-2]{1,1}[0-9]{3,3}_m.dmp.gz"  > /dev/null
        RE_STATUS=$?
        if [ ${RE_STATUS} -ne 0 ];then
          echo "${DATE_DIR}	マスク済み朝一DMPファイルがなし" 
          NO_FLG="ASAITI_NO"
          break
        fi

        ls ${DATE_DIR} | grep -w "exp_YDC_ITK_${DATE_DIR}_${COMPANY_RECORD}_m.dmp.gz"  > /dev/null
        RE_STATUS=$?
        test ${RE_STATUS} -eq 0 \
         || echo "${DATE_DIR}	${COMPANY_RECORD}	1"
     done<"${ITK_CODE_FILE}"
     if [ "${NO_FLG}" != "ASAITI_NO" ];then
      #---朝一ITK(業務共通)
       ls ${DATE_DIR} | grep -w "exp_YDC_ITK_${DATE_DIR}_1000_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1000	1"
       
      #---朝一JTK
       ls ${DATE_DIR} | grep -w "exp_YDC_JTK_${DATE_DIR}_2001_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2001	1"
      #---朝一JTK(業務共通)
       ls ${DATE_DIR} | grep -w "exp_YDC_JTK_${DATE_DIR}_2000_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2000	1"
      
      #---朝一NAM
       ls ${DATE_DIR} | grep -w "exp_YDC_NAM_${DATE_DIR}_1001_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1001	1"
      #---朝一NAM(業務共通)
       ls ${DATE_DIR} | grep -w "exp_YDC_NAM_${DATE_DIR}_1000_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	10001	1"
     fi
  
  #---締め後チェック
  elif [ "${TARGET_KBN}" = "2" ];then
     while read COMPANY_RECORD
     do
        ls ${DATE_DIR} | grep -E "[1-2]{1,1}[0-9]{3,3}_itk_m.exp.gz" > /dev/null
        RE_STATUS=$?
        if [ ${RE_STATUS} -ne 0 ];then
          echo "${DATE_DIR}	マスク済み締め後DMPファイルがなし" 
          NO_FLG="SIMEGO_NO"
          break
        fi

        ls ${DATE_DIR} | grep -w "${COMPANY_RECORD}_itk_m.exp.gz" > /dev/null
        RE_STATUS=$?
        test ${RE_STATUS} -eq 0 \
         || echo "${DATE_DIR}	${COMPANY_RECORD}	2"
        
     done<"${ITK_CODE_FILE}"
     
     if [ "${NO_FLG}" != "SIMEGO_NO" ];then
      #---締め後ITK(業務共通)
       ls ${DATE_DIR} | grep -w "1000_itk_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1000	2"
      
      #---締め後JTK
       ls ${DATE_DIR} | grep -w "2001_jtk_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2001	2"
      
      #---締め後JTK(業務共通)
       ls ${DATE_DIR} | grep -w "2000_jtk_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2000	2"
      
      #---締め後NAM
       ls ${DATE_DIR} | grep -w "1001_nam_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1001	2"
      
      #---締め後NAM(業務共通)
       ls ${DATE_DIR} | grep -w "1000_nam_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	10001	2"
     fi
  fi
}

######################################################################
##      Main 処理                                                   ##
######################################################################
echo "--------------------------------------------------------------------------"
echo "↓↓マスクすべきDMPファイルの存在チェック開始(`date`)★"
echo "--------------------------------------------------------------------------"
case "${TARGET_PATH}" in
"1")
   TARGET_PATH="/ext/YDC_DMP/MASKDB"
;;
esac

#---TARGETパス存在チェック
if [ ! -e "${TARGET_PATH}" ];then
   echo "指定したパス[${TARGET_PATH}]が存在しないので、EXIT !"
   exit 1
fi

#---TARGETパスチェンジ
cd "${TARGET_PATH}" \
  || (echo "パス[${TARGET_PATH}]チェンジ ERR" \
  && exit 1)
  
case "${TARGET_KBN}" in
"0"|"1")
  DATA_KBN_PATH="ASAITI"
;;
"2")
  DATA_KBN_PATH="SIMEGO"
;;
*)
  echo "引数2の入力 ERR"
  exit 1
;;
esac

echo "データ区分：${DATA_KBN_PATH}"

#---区分パスにチェンジ
cd "${DATA_KBN_PATH}" \
  ||  (echo "パス[${TARGET_PATH}/${DATA_KBN_PATH}]チェンジ ERR" \
  &&  exit 1)

case "${TARGET_DATE}" in
"ALL")
  for DATE_DIR_RECORD in `ls -1|sort`
  do
    DATE_MASKED_CHECK ${DATE_DIR_RECORD}
  done
;;
*)
  DATE_MASKED_CHECK ${TARGET_DATE}
;;
esac

echo "--------------------------------------------------------------------------"
echo "↑↑マスクすべきDMPファイルの存在チェック終了(`date`)★"
echo "--------------------------------------------------------------------------"

#---正常終了
exit 0
