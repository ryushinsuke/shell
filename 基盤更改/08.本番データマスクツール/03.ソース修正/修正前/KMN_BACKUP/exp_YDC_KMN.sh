#!/bin/sh
#set -x
#*********************************************************************
#　　プロジェクト　　:データバックアップ
#　　モジュール名　　:exp_YDC_KMN.sh
#　　名称　　　　　　:顧問系ユーザ別バックアップ
#　　#入力引数 　　　 :
#　　改訂履歴
#　　 年月日 　区分　内容　　　　　　　　　　　　　　　 改訂者
#　　 -------- ----　--------------------------------　---------
#　　 20100706 新規　　　　　　　　　　　　　　　　　　　GUT
#　　 20131021 修正　保存期間の変更（5世帯⇒3世帯）　　　GUT高楽
#*********************************************************************
source ~/.bash_profile
SYS_KJN=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)
LOG_FILE=$HOME_PATH/log/exp_YDC_KMN_${SYS_KJN}.log
DMP_PATH=/ext/bkwork/pmo/YDC_DMP_KMN
#
echo "**********   前処理開始"                                        |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:1  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- 引数個数判断
#if [ $# -ne 1 ];then
#echo "**********   引数個数不正  "                                    |tee -a $LOG_FILE
#echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
#echo "**********   POS:2  "                                           |tee -a $LOG_FILE
#exit 9
#fi
KIDO_KBN_GET=$1
echo "**********   入力フチェック "                                   |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:3  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- 会社コード一覧
if [ ! -f $HOME_PATH/KMN_CODE.lst ];then
echo "**********   $HOME_PATH/KMN_CODE.lst存在しない"                 |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:4  "                                           |tee -a $LOG_FILE
exit 9
fi
#---- マスク対象一覧
if [ ! -f $HOME_PATH/KMN_MASK.lst ];then
echo "**********   $HOME_PATH/KMN_MASK.lst存在しない"                 |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:5  "                                           |tee -a $LOG_FILE
exit 9
fi
ORACLE_CNN=`cat $HOME_PATH/KMN_MASK.lst |grep -v '^#' \
|grep 'ORACLE,DB'|awk -F, '{print $3}'`
#
rm -rf $HOME_PATH/log/*.*
#
echo "**********   主処理開始 "                                       |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:6  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#*********************************************************************
#            データクリア
#*********************************************************************
DIR_CLEAR()
{
echo "**********   データクリア   "                                   |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:7  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE

#---- 保存期間の変更（5世帯⇒3世帯）2013/10/21 START------------------
#---- 顧問系5世帯前クリア
#---- 土曜日起動
#BEFOR_WEEK=`date --date '35 days ago' '+%Y%m%d'`
#---- 日曜日起動
#AFTER_WEEK=`date --date '34 days ago' '+%Y%m%d'`
#cd $DMP_PATH
#if [ -e "${DMP_PATH}/${BEFOR_WEEK}" ]; then
#echo "**********   $DMP_PATH/$BEFOR_WEEK 削除"                        |tee -a $LOG_FILE
#echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
#echo "**********   POS:8  "                                           |tee -a $LOG_FILE
#echo ""                                                               |tee -a $LOG_FILE
#rm -rf $BEFOR_WEEK
#fi
#if [ -e "${DMP_PATH}/${AFTER_WEEK}" ]; then
#echo "**********   $DMP_PATH/$BEFOR_WEEK 削除 "                       |tee -a $LOG_FILE
#echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
#echo "**********   POS:9  "                                           |tee -a $LOG_FILE
#echo ""                                                               |tee -a $LOG_FILE
#rm -rf $AFTER_WEEK
#fi

COUNT=0
cd ${DMP_PATH}
ls -drl 20?????? | awk '{print $9}' > $HOME_PATH/log/filelist.txt
while read del_record
do
  if [ -f ${DMP_PATH}/${del_record}/SUCCESS.END ]; then
    let COUNT=COUNT+1
    if [ ${COUNT} -gt 3 ]; then
      echo "**********   $DMP_PATH/${del_record} 削除"                |tee -a $LOG_FILE
      rm -rf ${del_record}
    fi
  else
    if [ ${COUNT} -ge 3 ]; then
      echo "**********   $DMP_PATH/${del_record} 削除"                |tee -a $LOG_FILE
      rm -rf ${del_record}
    fi
  fi
done <"$HOME_PATH/log/filelist.txt"

rm -f "$HOME_PATH/log/filelist.txt"
#---- 保存期間の変更（5世帯⇒3世帯）2013/10/21 END -------------------
}
#*********************************************************************
#            会社コードより(会社)ファイル出力
#*********************************************************************
MAIN_SYORI()
{
echo "**********   会社コード関連処理  "                              |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:10 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#
cat ${CODE_FILE}  | while read -r KAIYA_CODE
do
  #---- 作業対象チェック
  CODE_NF=`echo ${KAIYA_CODE}|tr -d "\r\n\n"`
  if [ `cat ${HOME_PATH}/KMN_CODE_EX.lst | grep "${KAIYA_CODE}" | wc -l` == "0"  -a \
     "${CODE_NF}" != "" ]; then
        #会社関連処理
        LOG_KBN="会社"
        M_NM_KBN=`echo "%"${KAIYA_CODE}|tr -d "\r\n\n"`
        #---- 会社マスク
        KAIYA_MASK_SYORI
        #---- 会社マスク対象外
        KAIYA_SYORI_OTHER
  fi
done
}
#*********************************************************************
#            会社コードマスク エクスポート処理
#*********************************************************************
KAIYA_MASK_SYORI()
{
GREP_KEY="MASK,KAIYA"
GREP_CODE=`echo "_"${KAIYA_CODE}|tr -d "\r\n\n"`
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_1"|tr -d "\r\n\n"`
#---- 会社マスク関連リスト出力
KINO_LIST
#
#---- 会社マスクデータ洗い出す
KAIYA_M_TBL=${MASK_TBLM}
KAIYA_N_TBL=${MASK_TBLN}
M_TB_KBN=${KAIYA_M_TBL}
EXP_TBS=${M_TB_KBN}
EXP_DATA
}
#*********************************************************************
#            会社コードマスク対象外 エクスポート処理
#*********************************************************************
KAIYA_SYORI_OTHER()
{
#---- 「大サイズ」
GREP_KEY="BIG,KAIYA"
GREP_CODE=`echo "_"${KAIYA_CODE}|tr -d "\r\n\n"`
#---- 会社マスク対象外「大サイズ」関連リスト出力
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_2"|tr -d "\r\n\n"`
KINO_LIST
#
for B_TBL in `cat $HOME_PATH/log/${MASK_KBN}.txt`
do
  B_NM=`echo "${B_TBL}"|tr -d "\r\n\n"|awk -F_ '{print $1}'|sed -e 's/,$//g'|tr -d "'"`
  EXP_TBS=`echo "${B_TBL}"|tr -d "\r\n\n"|sed -e 's/,$//g'|tr -d "'"`
  MASK_KBN=`echo ${KAIYA_CODE}"_kmn_"${B_NM}|tr -d "\r\n\n"`
  EXP_DATA
done
rm -rf $HOME_PATH/log/${MASK_KBN}.txt
#---- 会社マスク対象外
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_2"|tr -d "\r\n\n"`
KAIYA_N_TBLB=${MASK_TBLN}
M_TB_KBN=${KAIYA_N_TBL}","${KAIYA_N_TBLB}
DB_WHERE=" where table_name like '${M_NM_KBN}' \
           and table_name NOT IN (${M_TB_KBN})"
MAST_N_LIST_GET
EXP_TBS=${NO_MASK_LIST}
EXP_DATA
}
#*********************************************************************
#            共通マスク   エクスポート処理
#*********************************************************************
KYOTU_MASK_SYORI()
{
KAIYA_CODE="1000"
LOG_KBN="共通(業務共通)"
GREP_KEY="MASK,KYOTU"
GREP_CODE=""
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_1"|tr -d "\r\n\n"`
KINO_LIST
#---- 共通マスク対象
KYOT_M_TBL=${MASK_TBLM}
KYOT_N_TBL=${MASK_TBLN}
M_TB_KBN=${KYOT_M_TBL}
EXP_TBS=${M_TB_KBN}
EXP_DATA
}
#*********************************************************************
#            共通マスク対象外   エクスポート処理
#*********************************************************************
KYOTU_SYORI_OTHER()
{
#---- 共通マスク対象外
M_TB_KBN=${KYOT_N_TBL}
DB_WHERE=" where (substr(table_name,length(table_name)-4,1) <> '_') \
           and table_name NOT IN (${M_TB_KBN})"
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_2"|tr -d "\r\n\n"`
MAST_N_LIST_GET
EXP_TBS="${NO_MASK_LIST}"
EXP_DATA
}
#*********************************************************************
#            リスト一覧出力
#*********************************************************************
#---- リスト対象抽出
KINO_LIST()
{
echo "**********   リスト一覧出力処理  "                              |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:11 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- リストファイル作成
MASK_TBLN=""
MASK_TBLY=""
for TBL_CODE in `grep "${GREP_KEY}" ${HOME_PATH}/KMN_MASK.lst |grep -v '^#'|awk -F, '{print $3}'`
do
  echo "'"${TBL_CODE}${GREP_CODE}"'," >> $HOME_PATH/log/${MASK_KBN}.txt
done
#
MASK_TBLN=`cat $HOME_PATH/log/${MASK_KBN}.txt |tr -d "\r\n\n"|sed -e 's/,$//g'`
MASK_TBLM=`echo ${MASK_TBLN}|tr -d "'"`
}

#*********************************************************************
#            マスク対象外一覧出力
#*********************************************************************
MAST_N_LIST_GET()
{
echo "**********   マスク対象外一覧出力処理 "                         |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:12 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#
echo "SPOOL $HOME_PATH/log/${MASK_KBN}.lst"          >> $HOME_PATH/log/${MASK_KBN}.sql
echo "select table_name||','  from user_all_tables " >> $HOME_PATH/log/${MASK_KBN}.sql
echo " ${DB_WHERE} order by 1;"                      >> $HOME_PATH/log/${MASK_KBN}.sql
echo "SPOOL OFF"                                     >> $HOME_PATH/log/${MASK_KBN}.sql
#
sqlplus -S  ${ORACLE_CNN}   << SQL_END_D > /dev/null
         set echo off
         set feedback off
         set heading off
         set trimspool on
         @$HOME_PATH/log/${MASK_KBN}.sql
quit
SQL_END_D
VALUE="$?"
if [ "$VALUE" != 0 ];then
echo "**********   SQL文操作異常 "                                    |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:13 "                                           |tee -a $LOG_FILE
exit 9
fi
#
if [ ! -s $HOME_PATH/log/${MASK_KBN}.lst ];then
echo "**********   $HOME_PATH/log/${MASK_KBN}.lst 存在しません"       |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:14 "                                           |tee -a $LOG_FILE
exit 9
else
NO_MASK_LIST=`cat $HOME_PATH/log/${MASK_KBN}.lst | tr -d "\r\n\n" \
|awk '{$0=gensub(/,$/,"","g");print}'`
fi
}
#*********************************************************************
#           そのた   エクスポート処理
#*********************************************************************
EXP_DATA()
{
echo "**********"  ${LOG_KBN}"エクスポート開始    "                   |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:15 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- ダンプファイル作成
if [ "${EXP_TBS}" == "" ];then
echo "**********   エクスポート対象なし"                              |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:16 "                                           |tee -a $LOG_FILE
exit 9
fi
#
exp ${ORACLE_CNN} tables=(${EXP_TBS}) file=${DB_FILE}/${MASK_KBN}.exp \
log=${DB_FILE}/${MASK_KBN}.log direct=y
#if [ "$?" != 0 ];then
#exit 9
#else
#DD_ORA_CHECK=`grep 'EXP-' ${DB_FILE}/${MASK_KBN}.log|wc -l`
#   if [ ${DD_ORA_CHECK} != 0 ]; then
#      grep 'EXP-' ${DB_FILE}/${MASK_KBN}.log|tee -a $LOG_FILE
#      rm -rf ${DB_FILE}/*.*
#      exit 9
#   fi
#fi
gzip -f ${DB_FILE}/${MASK_KBN}.exp
echo "${EXP_TBS}" |awk '{$0=gensub(/,/,"\r\n","g");print}' \
>> ${DB_FILE}/${MASK_KBN}.lst
}

#*********************************************************************
#            会社コードよりファイル出力
#*********************************************************************
#if [ "${KIDO_KBN_GET}" == "Y" ];then
#---- 平日定時起動「会社」
if [ "${KIDO_KBN_GET}" != "" ];then
SYS_KJN=${KIDO_KBN_GET}
DB_FILE=${DMP_PATH}"/CURRENT"
CODE_PATH=${DB_FILE}"/PARAM"
CODE_FILE=${CODE_PATH}"/"${SYS_KJN}
#---- ディレクトリ存在チェック
if [ ! -d  ${CODE_PATH} ];then
  mkdir -p ${CODE_PATH}
fi
#---- 入力チェック
if [ ! -f ${CODE_FILE} ];then
echo "**********    ${CODE_FILE}は存在しない"                     |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                              |tee -a $LOG_FILE
echo "**********   POS:17 "                                       |tee -a $LOG_FILE
exit 9
fi
#rm -rf ${DB_FILE}/*.*
rm -f $DB_FILE/exp_YDC_CURRENT.END
MAIN_SYORI
KYOTU_MASK_SYORI
KYOTU_SYORI_OTHER
echo "${SYS_KJN}" >$DB_FILE/exp_YDC_CURRENT.END
else
    #---- 土曜日定時起動
    #---- ディレクトリ存在チェック
    if [ ! -d ${DMP_PATH}/${SYS_KJN} ];then
       mkdir -p ${DMP_PATH}/${SYS_KJN}
    fi
    #---- 出力クリア
    rm -rf ${DMP_PATH}"/"${SYS_KJN}/*.lst
    rm -f $DMP_PATH/exp_YDC_KOMON.END
    DB_FILE=${DMP_PATH}"/"${SYS_KJN}
    CODE_FILE=${HOME_PATH}"/KMN_CODE.lst"
#    DIR_CLEAR
    MAIN_SYORI
    KYOTU_MASK_SYORI
    KYOTU_SYORI_OTHER

    #---- ４つの特別テーブルのDDLを作成
    sh ${HOME_PATH}/exp_YDC_DDL.sh "${SYS_KJN}"

    echo ""  |tee -a $LOG_FILE
    echo "`ll $DMP_PATH/${SYS_KJN}`"  |tee -a $LOG_FILE
    cd $DMP_PATH
    ls -dtr 20?????? > exp_YDC_KOMON.END
    touch ${SYS_KJN}/SUCCESS.END
    DIR_CLEAR
fi
#*********************************************************************
#            中間ファイルクリア
#*********************************************************************
rm -rf ${HOME_PATH}/*.txt
rm -rf ${HOME_PATH}/*.sql
#*********************************************************************
#            正常終了
#*********************************************************************
echo "**********正常終了"                                             |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:18 "                                           |tee -a $LOG_FILE
exit 0
