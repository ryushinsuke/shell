#!/bin/sh
#set -x
#*********************************************************************
#　　プロジェクト　　:データバックアップ
#　　モジュール名　　:exp_YDC_KMN_CURRENT.sh
#　　名称　　　　　　:顧問系ユーザ別バックアップ(平日起動)
#　　入力引数 　　　 :なし
#　　改訂履歴
#　　 年月日 　区分　内容　　　　　　　　　 改訂者
#　　 -------- ----　---------------------　---------
#　　 20100706 新規　　　　　　　　　　　　　GUT
#　　 20130924 修正　基盤更改　　　　　　　　GUT趙銘
#*********************************************************************
source ~/.bash_profile

SYS_KJN=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)
#HOME_FILE=`cd $HOME_PATH/../../`
HOME_FILE=$HOME_PATH
LOG_FILE=$HOME_PATH/log/exp_YDC_KMN_CURRENT_${SYS_KJN}.log
#基盤更改の修正　START
#DMP_PATH=/ext/bkwork/pmo/YDC_DMP_KMN/CURRENT/PARAM

#--- 顧問系バックアップ情報一覧ファイルを読込む
CONF_FILE=${HOME_PATH}/exp_YDC_KMN.conf
if [ -f ${CONF_FILE} ];then
  . ${CONF_FILE}
else
  echo "顧問系バックアップ情報一覧 ${HOME_PATH}/exp_YDC_KMN.conf が見つかりません。" |tee -a  ${LOG_FILE}
  exit 1
fi
DMP_PATH=${DMP_PATH}/CURRENT/PARAM
#基盤更改の修正　END
echo "**********   前処理開始"                                        |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:1          "                                   |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- ディレクトリ存在チェック
if [ ! -d ${DMP_PATH} ];then
   mkdir -p ${DMP_PATH}
fi
rm -rf $HOME_PATH/log/codefile.lst
#---- 日付ファイルを洗い出す
find ${DMP_PATH}/ -name "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" \
     -type f >$HOME_PATH/log/codefile.lst
#---- エクスポート処理をコール
CAL_SHELL()
{
#基盤更改の修正　START
#echo "**********   クスポート処理をコール"                            |tee -a $LOG_FILE
echo "**********   エクスポート処理をコール"                          |tee -a $LOG_FILE
#基盤更改の修正　END
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:2         "                                    |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
sh ${HOME_PATH}/exp_YDC_KMN.sh ${KJN_FILE}
echo "**********   ファイル${KJN_FILE}を平日にエクスポートしました"   |tee -a $LOG_FILE
echo "**********    "$0" （`date`） "                                 |tee -a $LOG_FILE
echo "**********   POS:3        "                                     |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
}
#---- エクスポート対象を洗い出す
for DD_PATH in  `cat $HOME_PATH/log/codefile.lst `
do
  KJN_FILE=`echo ${DD_PATH} |awk -F\/ '{print $NF}'`
  #---- 日付存在チェック
  date -d "$KJN_FILE" "+%Y%m%d" 2>/dev/null | grep -q "$KJN_FILE"
  if [ "$?" == 0 ];then
     if [ "${KJN_FILE}" -eq "${SYS_KJN}" ];then
        #FILE_PATH=`pwd``echo "${DD_PATH}"|cut -c2-$p`
        dos2unix -q ${DD_PATH}
        #---- 中身チェック
        if [ -s ${DD_PATH} ];then
           CODE_EG=`cat ${DD_PATH} | grep '[^0-9]'`
           CODE_UP=`cat ${DD_PATH} | egrep '[0-9]{5,}'`
           CODE_DW=`cat ${DD_PATH} |egrep '[0-9]{1,3}'|egrep -v '[0-9]{4}'`
           #---- 4桁数チェック
           if [ "${CODE_EG}" == "" -a "${CODE_UP}" == "" -a "${CODE_DW}" == "" ];then
              CAL_SHELL
           fi
        fi
     fi
  fi
done
#*********************************************************************
#            正常終了
#*********************************************************************
echo "**********    正常終了              "                           |tee -a $LOG_FILE
echo "**********    "$0" （`date`）"                                  |tee -a $LOG_FILE
echo "**********   POS:4            "                                 |tee -a $LOG_FILE
exit 0

