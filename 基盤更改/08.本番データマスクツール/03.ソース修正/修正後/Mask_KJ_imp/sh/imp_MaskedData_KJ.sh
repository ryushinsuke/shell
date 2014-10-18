#!/bin/sh
source ~/.bash_profile
# ========================================================================
# システムＩＤ  ： imp_MaskedData_KJ.sh
# システム名称  ： 基準系マスク済みデータインポート処理
# 処理概要      ： 基準系マスク済みデータインポート処理
# 入力引数      ： なし
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20130913 新規 GUT趙銘  新規作成
# ========================================================================

#変数初期化
HOME_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${HOME_PATH}/conf"
LOG_PATH="${HOME_PATH}/log"
PARAM_PATH="${HOME_PATH}/param"
TEMP_PATH="${HOME_PATH}/temp"
SQL_PATH="${HOME_PATH}/sql"
SHELL_NAME=`basename $0`

NOW=`date '+%Y%m%d'`

if [ ! -d ${LOG_PATH} ]
then
  mkdir -p ${LOG_PATH}
fi
LOG_FILE="${LOG_PATH}/imp_MaskedData_KJ_${NOW}"

if [ ! -d ${TEMP_PATH} ]
then
  mkdir -p ${TEMP_PATH}
fi
LOCK_FILE="${TEMP_PATH}/imp_MaskedData_KJ.lock"

if [ ! -f ${LOCK_FILE} ]
then
  touch ${LOCK_FILE}
else
  echo "★★ ロックファイル(imp_MaskedData_KJ.lock)存在がありますので、実行終了!! ★★"                | tee -a ${LOG_FILE}
  exit 1
fi

#環境ファイルを読込む
CONF_FILE="${CONF_PATH}/imp_MaskedData_KJ.conf"
if [ -f ${CONF_FILE} ]
then
  . ${CONF_FILE}
else
  #CONFファイルが存在していない場合、ロックファイル削除
  echo "環境ファイルがないので、ERR!"                                                                  | tee -a ${LOG_FILE}
  rm -f "${LOCK_FILE}"
  exit 1
fi

#マスク済みデータ格納場所存在チェック
if [ -z ${MASK_DUMP_PATH} ]
then
  echo "マスク済みデータ格納場所取得にエラーが発生しました！"                                          | tee -a ${LOG_FILE}
  exit 1
fi

#作業用格納場所存在チェック
if [ -z ${MASK_DUMP_TMP_PATH} ]
then
  echo "作業用格納場所取得にエラーが発生しました！"                                                    | tee -a ${LOG_FILE}
  exit 1
fi

#DB接続子(CMN)取得チェック
if [ -z ${CMN_CONN} ]
then
  echo "DB接続子(CMN)取得にエラーが発生しました！"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(CMN)取得チェック
if [ -z ${CMN_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(CMN)取得にエラーが発生しました！"                                                   | tee -a ${LOG_FILE}
  exit 1
fi

#DB接続子(NAM)取得チェック
if [ -z ${NAM_CONN} ]
then
  echo "DB接続子(NAM)取得にエラーが発生しました！"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(NAM新共通)取得チェック
if [ -z ${NAM_SINKYOTU_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(NAM新共通)取得にエラーが発生しました！"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(NAM業務共通)取得チェック
if [ -z ${NAM_KYOTU_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(NAM業務共通)取得にエラーが発生しました！"                                           | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(NAM会社別)取得チェック
if [ -z ${NAM_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(NAM会社別)取得にエラーが発生しました！"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#DB接続子(ITK)取得チェック
if [ -z ${ITK_CONN} ]
then
  echo "DB接続子(ITK)取得にエラーが発生しました！"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(ITK新共通)取得チェック
if [ -z ${ITK_SINKYOTU_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(ITK新共通)取得にエラーが発生しました！"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(ITK業務共通)取得チェック
if [ -z ${ITK_KYOTU_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(ITK業務共通)取得にエラーが発生しました！"                                           | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(ITK会社別)取得チェック
if [ -z ${ITK_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(ITK会社別)取得にエラーが発生しました！"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#DB接続子(JTK)取得チェック
if [ -z ${JTK_CONN} ]
then
  echo "DB接続子(JTK)取得にエラーが発生しました！"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(JTK新共通)取得チェック
if [ -z ${JTK_SINKYOTU_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(JTK新共通)取得にエラーが発生しました！"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(JTK業務共通)取得チェック
if [ -z ${JTK_KYOTU_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(JTK業務共通)取得にエラーが発生しました！"                                           | tee -a ${LOG_FILE}
  exit 1
fi

#元SCHEMA名(JTK会社別)取得チェック
if [ -z ${JTK_SOUR_SCHEMA} ]
then
  echo "元SCHEMA名(JTK会社別)取得にエラーが発生しました！"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#作業用格納場所存在チェック
if [ ! -d ${MASK_DUMP_TMP_PATH} ]
then
  mkdir -p ${MASK_DUMP_TMP_PATH}
fi

#インポート用ログファイルの格納場所存在チェック
if [ ! -d ${LOG_PATH}/ASAITI_IMP ]
then
  mkdir -p ${LOG_PATH}/ASAITI_IMP
fi

#######################################################
#    関数:UNZIP_ANY_DMP　　解凍DMPファイル
#######################################################
UNZIP_ANY_DMP()
{
  DUMP_NAME_TMP=$1

  ls ${MASK_DUMP_PATH} | grep "${DUMP_NAME_TMP}.dmp.gz" > /dev/null
  TS_STATUS=$?
  #圧縮ダプファイルの存在チェック
  if [ ${TS_STATUS} -ne 0 ]
  then
    #圧縮ダプファイルが存在していない場合、ロックファイル削除
    echo "パス「${MASK_DUMP_PATH}」に圧縮ダプファイル「${DUMP_NAME_TMP}.dmp.gz」が存在しないので、ERR" | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi

  cp ${MASK_DUMP_PATH}/${DUMP_NAME_TMP}.dmp.gz  ${MASK_DUMP_TMP_PATH}
  chmod 777 ${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp.gz
  gunzip -f "${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp.gz"
  TS_STATUS=$?
  if [ ${TS_STATUS} -ne 0 ]
  then
    #解凍DMPファイルのチェック
    echo "圧縮ダプファイル「${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp.gz」が解凍失敗ですので、ERR"    | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi

  #解凍後のダプファイルの存在チェック
  if [ ! -f "${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp" ]
  then
    #解凍後のダプファイルが存在していない場合、ロックファイル削除
    echo "ダプファイル(${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp)がないため、ERR"                     | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi
}

#######################################################
#    関数:DROP_ANY_TABLES　　テーブル削除「ITK会社別以外」
#######################################################
DROP_ANY_TABLES()
{
  TENGUN_KBN=$1
  DB_CONN=$2

  case "${TENGUN_KBN}" in
  "CMN")
     echo "テーブル削除 開始 （`date`）"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_CMN.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP CMN TABLES ERR"                                                                      | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     echo "テーブル削除 完了 （`date`）"                                                               | tee -a ${LOG_FILE}
  ;;
  "NAM")
     #NAM新共通の場合
     echo "テーブル削除 開始 （`date`）"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_NAM.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP NAM_SINKYOTU TABLES ERR"                                                             | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #NAM業務共通の場合
     NAM_GYOUMUCMN_DROP="${SQL_PATH}/drop_NAM_GYOUMUCMN.sql"
     echo "spool ${LOG_PATH}/drop_NAM_GYOUMUCMN.log"                                                  >  ${NAM_GYOUMUCMN_DROP}
     echo "set echo on"                                                                               >> ${NAM_GYOUMUCMN_DROP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "TBWF|TBWI|TBWM|TBWS|TBWT|_1\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${NAM_GYOUMUCMN_DROP}
     done
     echo "spool off"                                                                                 >> ${NAM_GYOUMUCMN_DROP}
     echo "exit"                                                                                      >> ${NAM_GYOUMUCMN_DROP}
     sqlplus ${DB_CONN} @${NAM_GYOUMUCMN_DROP}
     TS_STATUS=$?
     rm -f ${NAM_GYOUMUCMN_DROP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP NAM_GYOUMUCMN TABLES ERR"                                                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #NAM会社別の場合
     NAM_KAISYABETU_DORP="${SQL_PATH}/drop_NAM_KAISYABETU.sql"
     echo "spool ${LOG_PATH}/drop_NAM_KAISYABETU.log"                                                 >  ${NAM_KAISYABETU_DORP}
     echo "set echo on"                                                                               >> ${NAM_KAISYABETU_DORP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "_1001\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${NAM_KAISYABETU_DORP}
     done
     echo "spool off"                                                                                 >> ${NAM_KAISYABETU_DORP}
     echo "exit"                                                                                      >> ${NAM_KAISYABETU_DORP}
     sqlplus ${DB_CONN} @${NAM_KAISYABETU_DORP}
     TS_STATUS=$?
     rm -f ${NAM_KAISYABETU_DORP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP NAM_KAISYABETU TABLES ERR"                                                           | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     echo "テーブル削除 完了 （`date`）"                                                               | tee -a ${LOG_FILE}
   ;;
   "JTK")
     #JTK新共通の場合
     echo "テーブル削除 開始 （`date`）"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_JTK.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP JTK_SINKYOTU TABLES ERR"                                                             | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #JTK業務共通の場合
     JTK_GYOUMUCMN_DROP="${SQL_PATH}/drop_JTK_GYOUMUCMN.sql"
     echo "spool ${LOG_PATH}/drop_JTK_GYOUMUCMN.log"                                                  >  ${JTK_GYOUMUCMN_DROP}
     echo "set echo on"                                                                               >> ${JTK_GYOUMUCMN_DROP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "TBWF|TBWI|TBWM|TBWS|TBWT|_2\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${JTK_GYOUMUCMN_DROP}
     done
     echo "spool off"                                                                                 >> ${JTK_GYOUMUCMN_DROP}
     echo "exit"                                                                                      >> ${JTK_GYOUMUCMN_DROP}
     sqlplus ${DB_CONN} @${JTK_GYOUMUCMN_DROP}
     TS_STATUS=$?
     rm -f ${JTK_GYOUMUCMN_DROP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP JTK_GYOUMUCMN TABLES ERR"                                                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #JTK会社別の場合
     JTK_KAISYABETU_DORP="${SQL_PATH}/drop_JTK_KAISYABETU.sql"
     echo "spool ${LOG_PATH}/drop_JTK_KAISYABETU.log"                                                 >  ${JTK_KAISYABETU_DORP}
     echo "set echo on"                                                                               >> ${JTK_KAISYABETU_DORP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "_2001\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${JTK_KAISYABETU_DORP}
     done
     echo "spool off"                                                                                 >> ${JTK_KAISYABETU_DORP}
     echo "exit"                                                                                      >> ${JTK_KAISYABETU_DORP}
     sqlplus ${DB_CONN} @${JTK_KAISYABETU_DORP}
     TS_STATUS=$?
     rm -f ${JTK_KAISYABETU_DORP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP JTK_KAISYABETU TABLES ERR"                                                           | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     echo "テーブル削除 完了 （`date`）"                                                               | tee -a ${LOG_FILE}
   ;;
   "ITK")
     #ITK新共通の場合
     echo "テーブル削除 開始 （`date`）"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_ITK.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP ITK_SINKYOTU TABLES ERR"                                                             | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #ITK業務共通の場合
     ITK_GYOUMUCMN_DROP="${SQL_PATH}/drop_ITK_GYOUMUCMN.sql"
     echo "spool ${LOG_PATH}/drop_ITK_GYOUMUCMN.log"                                                  >  ${ITK_GYOUMUCMN_DROP}
     echo "set echo on"                                                                               >> ${ITK_GYOUMUCMN_DROP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "TBWF|TBWI|TBWM|TBWS|TBWT|_1\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${ITK_GYOUMUCMN_DROP}
     done
     echo "spool off"                                                                                 >> ${ITK_GYOUMUCMN_DROP}
     echo "exit"                                                                                      >> ${ITK_GYOUMUCMN_DROP}
     sqlplus ${DB_CONN} @${ITK_GYOUMUCMN_DROP}
     TS_STATUS=$?
     rm -f ${ITK_GYOUMUCMN_DROP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROPエラーの場合、ロックファイル削除
       echo "DROP ITK_GYOUMUCMN TABLES ERR"                                                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
   ;;
  esac
}

#######################################################
#    関数:DROP_ITK_TABLES    テーブル削除「ITK会社別」
#######################################################
DROP_ITK_TABLES()
{
  KAISYACD=$1
  DB_CONN=$2

  ITK_KAISYABETU_DORP="${SQL_PATH}/drop_ITK_${KAISYACD}.sql"
  echo "spool ${LOG_PATH}/drop_ITK_${KAISYACD}.log"                                                   >  ${ITK_KAISYABETU_DORP}
  echo "set echo on"                                                                                  >> ${ITK_KAISYABETU_DORP}
  cat "${PARAM_PATH}/TBL.lst" | grep "_${KAISYACD}" | while read TBLNAME
  do
    echo "drop table ${TBLNAME} cascade constraints purge;"                                           >> ${ITK_KAISYABETU_DORP}
  done
  echo "spool off"                                                                                    >> ${ITK_KAISYABETU_DORP}
  echo "exit"                                                                                         >> ${ITK_KAISYABETU_DORP}
  sqlplus ${DB_CONN} @${ITK_KAISYABETU_DORP}
  TS_STATUS=$?
  rm -f ${ITK_KAISYABETU_DORP}
  if [ ${TS_STATUS} -ne 0 ]
  then
    #DROPエラーの場合、ロックファイル削除
    echo "DROP ITK_KAISYABETU TABLES ERR"                                                              | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                               | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi
  echo "テーブル削除 完了 （`date`）"                                                                  | tee -a ${LOG_FILE}
}

#######################################################
#   関数:IMPORT_TO_DB　マスク済みデータインポート処理
#######################################################
IMPORT_TO_DB()
{
  DB_CONN=$1
  IMPORT_LOG=$2".log"
  IMPORT_DUMP_NAME=$2".dmp"
  FROM_SCHEMA=$3

  TO_SCHEMA=`echo ${DB_CONN} | awk -F\/ '{print $1}'`
  sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${DB_CONN} ${MASK_DUMP_TMP_PATH}/${IMPORT_DUMP_NAME} ${IMPORT_LOG} "TABLES=${FROM_SCHEMA}.%" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" > ${LOG_PATH}/ASAITI_IMP/${IMPORT_LOG} 2>&1
  TS_STATUS=$?
  if [ ${TS_STATUS} -ne 0 ]
  then
    #IMPORTエラーの場合、ロックファイル削除
    echo "マスク済みデータ「${IMPORT_DUMP_NAME}」IMPORT ERR"                                           | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                               | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi
}

#######################################################
#    MAIN 処理
#######################################################
echo "★-----------------------------------------------------------★"                                 | tee -a ${LOG_FILE}
echo "◆ 基準系マスク済みデータインポート処理開始(`date`)"                                             | tee -a ${LOG_FILE}
echo "★-----------------------------------------------------------★"                                 | tee -a ${LOG_FILE}

##################### CMNの場合 #######################
DUMP_FNAME="exp_YDC_CMN_${NOW}_m"
#IMPORT前に、調査DBテーブルを削除する
DROP_ANY_TABLES "CMN" ${CMN_CONN}
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#ダプファイルのIMPORT
IMPORT_TO_DB ${CMN_CONN} ${DUMP_FNAME} ${CMN_SOUR_SCHEMA}

##################### NAMの場合 #######################
#NAM新共通の場合
DUMP_FNAME="exp_YDC_NAM_SINKYOTU_${NOW}_m"
#IMPORT前に、調査DBテーブルを削除する
DROP_ANY_TABLES "NAM" ${NAM_CONN}
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM新共通ダプファイルのIMPORT
IMPORT_TO_DB ${NAM_CONN} ${DUMP_FNAME} ${NAM_SINKYOTU_SOUR_SCHEMA}

#NAM業務共通の場合
DUMP_FNAME="exp_YDC_NAM_${NOW}_1000_m"
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM業務共通ダプファイルのIMPORT
IMPORT_TO_DB ${NAM_CONN} ${DUMP_FNAME} ${NAM_KYOTU_SOUR_SCHEMA}

#NAM会社別の場合
DUMP_FNAME="exp_YDC_NAM_${NOW}_1001_m"
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM業務共通ダプファイルのIMPORT
IMPORT_TO_DB ${NAM_CONN} ${DUMP_FNAME} ${NAM_SOUR_SCHEMA}

##################### JTKの場合 #######################
#JTK新共通の場合
DUMP_FNAME="exp_YDC_JTK_SINKYOTU_${NOW}_m"
#IMPORT前に、調査DBテーブルを削除する
DROP_ANY_TABLES "JTK" ${JTK_CONN}
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM新共通ダプファイルのIMPORT
IMPORT_TO_DB ${JTK_CONN} ${DUMP_FNAME} ${JTK_SINKYOTU_SOUR_SCHEMA}

#JTK業務共通の場合
DUMP_FNAME="exp_YDC_JTK_${NOW}_2000_m"
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM業務共通ダプファイルのIMPORT
IMPORT_TO_DB ${JTK_CONN} ${DUMP_FNAME} ${JTK_KYOTU_SOUR_SCHEMA}

#JTK会社別の場合
DUMP_FNAME="exp_YDC_JTK_${NOW}_2001_m"
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#JTK業務共通ダプファイルのIMPORT
IMPORT_TO_DB ${JTK_CONN} ${DUMP_FNAME} ${JTK_SOUR_SCHEMA}

##################### ITKの場合 #######################
#ITK新共通の場合
DUMP_FNAME="exp_YDC_ITK_SINKYOTU_${NOW}_m"
#IMPORT前に、調査DBテーブルを削除する
DROP_ANY_TABLES "ITK" ${ITK_CONN}
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM新共通ダプファイルのIMPORT
IMPORT_TO_DB ${ITK_CONN} ${DUMP_FNAME} ${ITK_SINKYOTU_SOUR_SCHEMA}

#ITK業務共通の場合
DUMP_FNAME="exp_YDC_ITK_${NOW}_1000_m"
#解凍ダプファイル
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM業務共通ダプファイルのIMPORT
IMPORT_TO_DB ${ITK_CONN} ${DUMP_FNAME} ${ITK_KYOTU_SOUR_SCHEMA}

#ITK会社別の場合
while read KAISYACD
do
  DUMP_FNAME="exp_YDC_ITK_${NOW}_${KAISYACD}_m"
  #IMPORT前に、調査DBテーブルを削除する
  DROP_ITK_TABLES ${KAISYACD} ${ITK_CONN}
  #解凍ダプファイル
  UNZIP_ANY_DMP ${DUMP_FNAME}
  #NAM業務共通ダプファイルのIMPORT
  IMPORT_TO_DB ${ITK_CONN} ${DUMP_FNAME} ${ITK_SOUR_SCHEMA}
done < ${PARAM_PATH}/ITK_CODE.lst

#正常終了
rm -f "${LOCK_FILE}"
echo "★-----------------------------------------------------------★"                                 | tee -a ${LOG_FILE}
echo "◆ 基準系マスク済みデータインポート処理 正常終了(`date`)"                                        | tee -a ${LOG_FILE}
echo "★-----------------------------------------------------------★"                                 | tee -a ${LOG_FILE}
exit 0
