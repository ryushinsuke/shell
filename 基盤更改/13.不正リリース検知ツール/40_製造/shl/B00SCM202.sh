#!/bin/sh
#set -x
#***************************************************************
#　　プロジェクト　:T-STAR不正リリース検知ツール
#　　モジュール名　:B00SCM202.sh
#　　名称　　　　　:中間テーブル新規作成
#　　処理概要　　　:①引数3に指定された中間テーブルを新規作成する。
#　　　　　　　　　:②引数4に指定されたロードファイルを導入する。
#　　ＡＲＧ　　　　:1　シェルID
#　　　　　　　　　:2　サーバー区分
#　　　　　　　　　:3　テーブルID
#　　　　　　　　　:4　ロードファイルID(省略可)
#　　改訂履歴
#　　年月日 　区分　内容                   改訂者
#　　-------- ----　---------------------　---------
#　　20110104 新規                         GUT 姜宇
#***************************************************************
#***************************************************************
#  引数個数チェック
#***************************************************************
if [ $# != 3 -a $# != 4 ]
then
  echo "入力引数が不正である。"
  exit 9
else
  SHL_ID=$1
  TMP_SHL_ID=`echo ${SHL_ID} | awk -F\. '{print $1}'`
  SVR_KBN=$2
  TABLE_ID=$3
  SQLLDR_FILE_ID=$4
fi
#***************************************************************
#  前処理
#***************************************************************
#---- ロードファイル存在チェック
if [ "${SQLLDR_FILE_ID}" != "" ]
then
  if [ ! -f ${OUTFILE_PATH}/${SQLLDR_FILE_ID} ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "${SHL_ID}(B00SCM202.sh)" \
     "${SVR_KBN}"\
     "1" \
     "E000003" \
     "${OUTFILE_PATH}/${SQLLDR_FILE_ID}" \
     "11"
    exit 9
  fi
fi
#---- 前回処理で作成されたファイルの削除
rm -f ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_*
#***************************************************************
#  主処理
#***************************************************************
#---- 引数「テーブルID」により、既存の中間テーブルを削除する。
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    drop table ${TABLE_ID};
    commit;
    purge recyclebin;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "2" \
   "E000008" \
   "DROP用のSQL文（drop table ${TABLE_ID}）が実行異常。" \
   "11"
  exit 9
fi
#---- 引数「テーブルID」が検索条件として、テーブル「テーブル項目一覧」から関連データを洗出す。
echo "spool ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.txt"                              >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
echo "select TBL_ID,TBL_ITEM_ID,TBL_ITEM_DATA_TYPE,TBL_ITEM_NUM,TBL_ITEM_NULL_SEIY,PK_KBN" >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
echo "from KM_TB003_DBITEM where TBL_ID = '${TABLE_ID}' order by TBL_ITEM_NO; "            >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
echo "spool off"                                                                           >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    set echo off
    set feedback off
    set heading off
    set trimspool on
    set colsep ':'
    set linesize 20000
    @${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "3" \
   "E000008" \
   "SELECT用のSQL文（${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql）が実行異常。" \
   "11"
  exit 9
fi
#---- ファイルの空行を削除
cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.txt | awk '{if(NF>0) print}' \
                                                     | perl -pe 's/ //g' > ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT
#---- 関連データが存在しない場合
if [ ! -s ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "5" \
   "E000010" \
   "テーブル「KM_TB003_DBITEM」にテーブルID:${TABLE_ID}のデータが未存在。" \
   "11"
  exit 9
fi
#---- 上記で取得されたデータは「：」を区切りとして、テーブル作成用SQLファイルに出力する。
PRIMARY_KEY=`cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT | \
             awk -F\: '{ if($6!="0") print $2}' | perl -pe 's/\n/,/g' | perl -pe 's/,$/\n/g'`
echo "CREATE TABLE ${TABLE_ID} "                                >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
echo "("                                                        >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
if [ "${PRIMARY_KEY}" != "" ]
then
  cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT \
  | awk -F\: '{ if($5=="Y") print $2" "$3"("$4") DEFAULT # # NOT NULL," ;\
                else print $2" "$3"("$4") DEFAULT # #,"}' \
  | perl -pe s/#/\'/g                                           >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
  echo "PRIMARY KEY(${PRIMARY_KEY})"                            >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
else
  END_FLG=`cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT | tail -1 | awk -F\: '{print $2}'`
  cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT \
  | awk -F\: '{ if($5=="Y") print $2" "$3"("$4") DEFAULT # # NOT NULL" ;\
                else print $2" "$3"("$4") DEFAULT # #"}' \
  | awk '{ if($1=="'${END_FLG}'") print $0 ;else print $0","}'\
  | perl -pe s/#/\'/g                                           >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
fi
echo ");"                                                       >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
#---- テーブル作成用SQLファイルにより、中間テーブルを新規作成する。
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql;
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "6" \
   "E000008" \
   "CREATE用のSQL文（${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql）が実行異常。" \
   "11"
  exit 9
fi
if [ "${SQLLDR_FILE_ID}" != "" ]
then
#---- 上記で取得されたデータにより、ＣＴＬファイルを作成する。
  DB_KEY=`cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT | awk -F\: '{print $2}' | perl -pe 's/\n/,/g' | perl -pe 's/,$/\n/g'`
  echo "LOAD DATA"                                                     >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "TRUNCATE"                                                      >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "PRESERVE BLANKS"                                               >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "INTO TABLE ${TABLE_ID} "                                       >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "FIELDS TERMINATED BY "'","'" OPTIONALLY ENCLOSED BY '\"'"      >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "(${DB_KEY})"                                                   >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
#---- データファイルの導入
  cp ${OUTFILE_PATH}/${SQLLDR_FILE_ID} ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat
  ${SQLLDR_CMD} ${ORA_USR}/${ORA_PWD}@${ORA_SCA} \
       control=${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl \
       log=${LOG_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.log \
       data=${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat > /dev/null 2>&1
  if [ "$?" == 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "${SHL_ID}(B00SCM202.sh)"\
     "${SVR_KBN}"\
     "7"\
     "I000004"\
     "${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat"\
     "10"
  else
    sh ${SHL_PATH}/B00SCM201.sh \
     "${SHL_ID}(B00SCM202.sh)"\
     "${SVR_KBN}"\
     "8"\
     "E000005"\
     "${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat"\
     "11"
    exit 9
  fi
fi

exit 0
