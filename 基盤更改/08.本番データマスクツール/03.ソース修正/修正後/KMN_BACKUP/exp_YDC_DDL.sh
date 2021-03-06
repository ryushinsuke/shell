#!/bin/sh
#*********************************************************************
#　　プロジェクト　　:顧問系
#　　モジュール名　　:exp_YDC_DDL.sh
#　　名称　　　　　　:顧問系DDL文作成
#　　改訂履歴
#　　 年月日 　区分　内容　　　　　　　　　 改訂者
#　　 -------- ----　---------------------　---------
#　　 20100820 新規　　　　　　　　　　　　　GUT
#　　 20130924 修正　基盤更改　　　　　　　　GUT趙銘
#*********************************************************************
#
source ~/.bash_profile
#SYS_KJN=`date '+%Y%m%d'`
SYS_KJN=$1
#--- 引数チェック
if [ $# -ne 1 ] ;then
  echo "Parameter ERR!"
  exit 1
fi

WORK_DIR=$(cd $(dirname $0);pwd)
#基盤更改の修正　START
#DMP_PATH=/ext/bkwork/pmo/YDC_DMP_KMN
LOG_FILE=${WORK_DIR}/log/exp_YDC_DDL_${SYS_KJN}.log

#--- 顧問系バックアップ情報一覧ファイルを読込む
CONF_FILE=${WORK_DIR}/exp_YDC_KMN.conf
if [ -f ${CONF_FILE} ];then
  . ${CONF_FILE}
else
  echo "顧問系バックアップ情報一覧 ${WORK_DIR}/exp_YDC_KMN.conf が見つかりません。" |tee -a ${LOG_FILE}
  exit 1
fi
#--- 顧問系マスクテーブル一覧ファイルの存在チェック
if [ -f "${WORK_DIR}/KMN_MASK.lst" ];then
#基盤更改の修正　END
CONN=`cat $WORK_DIR/KMN_MASK.lst |grep -v '^#' \
|grep 'ORACLE,DB'|awk -F, '{print $3}'`
#基盤更改の修正　START
else
  echo "顧問系マスクテーブル一覧 ${WORK_DIR}/KMN_MASK.lst が見つかりません。" |tee -a ${LOG_FILE}
  exit 1
fi

#-- ダプファイル格納場所取得チェック
if [ -z ${DMP_PATH} ]
then
  echo "ダプファイル格納場所取得にエラーが発生しました！"                     | tee -a ${LOG_FILE}
  exit 1
fi
#基盤更改の修正　END

#---- ディレクトリ存在チェック
if [ ! -d ${DMP_PATH}/${SYS_KJN} ];then
   mkdir -p ${DMP_PATH}/${SYS_KJN}
fi
#*********************************************************************
#---- ddl文取得
#*********************************************************************
cat ${WORK_DIR}/KMN_CODE.lst   | while read -r KAIYA_CODE
do
#---- ユーザディレクトリ
get_ddl_id()
{
  sqlplus -s ${CONN} << SQL_END_D > /dev/null
  set echo off;
  set feedback off;
  set heading off;
  set line 2000;
  set long 200000;
  set pages 2000;
  set longchunksize 600;
  set termout off;
  set trimspool on;
  
  EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE)
  EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',FALSE)
 
  spool  ${DMP_PATH}/${SYS_KJN}/$1_kmn_${KAIYA_CODE}.sql
  select 'DROP TABLE $1_${KAIYA_CODE};' from dual;
  select dbms_metadata.get_ddl('TABLE','$1_${KAIYA_CODE}') from dual;
  select dbms_metadata.get_ddl('INDEX',index_name) from user_indexes where table_name = '$1_${KAIYA_CODE}' and uniqueness = 'NONUNIQUE';
  spool off;
exit SQL.SQLCODE
SQL_END_D
sed 's/PARTITION BY .*/;/g' ${DMP_PATH}/${SYS_KJN}/$1_kmn_${KAIYA_CODE}.sql \
|grep -v 'PARTITION' |sed 's/"OPS$APL[0-9]*".//g' | sed 's/ LOCAL/\//g' > ${DMP_PATH}/${SYS_KJN}/$1_${KAIYA_CODE}_kmn.sql
cp -f ${DMP_PATH}/${SYS_KJN}/$1_${KAIYA_CODE}_kmn.sql ${DMP_PATH}/${SYS_KJN}/$1_kmn_${KAIYA_CODE}.sql
rm -rf ${DMP_PATH}/${SYS_KJN}/$1_${KAIYA_CODE}_kmn.sql
}
get_ddl_id TKUSMS01
get_ddl_id TKUSSK01
get_ddl_id TKUSTH01
get_ddl_id TKUSZT01
done
echo "顧問系DDL文を正常作成"
exit 0

