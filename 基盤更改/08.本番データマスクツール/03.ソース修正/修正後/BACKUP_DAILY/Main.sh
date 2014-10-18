#!/bin/sh
# =======================================================================
# システムＩＤ  ：  Main
# システム名称  ：  基準系本番データエクスポートメイン処理シェル
# 処理概要      ：  トリガーファイル（${NOW}_injxhukb030a_i.trg）の存在チェックを行い、
#                   存在しない場合、一定時間起動しないように制御を行う。
#                   子シェルの起動を行う。
# 入力引数      ：  ① 業務区分
#                   ② TRG区分
# リターンコード：  ０：正常終了
#                   １：異常終了
# 改訂履歴
# 年月日   区分 担当者    内容
# -------- ---- --------- -----------------------------------------------
#          新規 GUT       新規作成
# 20130917 修正 GUT高志英 基盤更改
# =======================================================================
source ~/.bash_profile
#-------------------------------------------------------------------------------------
HOME_PATH=$(cd $(dirname $0);pwd)

NOW=`date '+%Y%m%d'`
TIME=`date '+%H%M%S'`
TIME_COUNT=0
TRG_FILE_FLG=0

TRG_FILE="${HOME_PATH}/TRG/${NOW}_injxhukb030a_i.trg"

#基盤更改の修正　START
#if [ ! -d ${HOME_PATH}/TRG ];then
#    mkdir -pm 755 ${HOME_PATH}/TRG
#fi
#基盤更改の修正　END

if [ ! -d ${HOME_PATH}/log ];then
    mkdir -pm 755 ${HOME_PATH}/log
fi

LOG_FILE=${HOME_PATH}/log/Main_${NOW}.log
#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#シェル_START                                                      " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------

TENGUN_KBN=$1
TRG_KBN=$2

if [ "${TENGUN_KBN}" == "" ];
then
	echo "業務区分を指定してください!!"		    | tee -a ${LOG_FILE}
	exit 1
fi

while [ "${TIME_COUNT}" != "300" -a "${TRG_KBN}" == "TRG" ]
do 
	TIME=`date '+%H%M%S'`
	if [ -f ${TRG_FILE} ];
	then
		BTB_PROCESS="sh ${HOME_PATH}/exp_YDC_${TENGUN_KBN}.sh"
		${BTB_PROCESS} &
		let TRG_FILE_FLG=1
		let TIME_COUNT=300
	else
		sleep 60
		let TIME_COUNT=TIME_COUNT+1
	fi
done
if [ "${TRG_FILE_FLG}" == "0" -a "${TRG_KBN}" == "TRG" ];
then
		BTB_PROCESS="sh ${HOME_PATH}/exp_YDC_${TENGUN_KBN}.sh"
		${BTB_PROCESS} &
fi

#基盤更改の修正　START
#---- 30日前のファイルを削除
#BEFOR_WEEK0=`date --date '30 days ago' '+%Y%m%d'`
#BEFOR_WEEK1=`date --date '31 days ago' '+%Y%m%d'`
#BEFOR_WEEK2=`date --date '32 days ago' '+%Y%m%d'`

#echo "30日前のファイルを削除開始「`date`」"    | tee -a ${LOG_FILE}
#rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK0}*
#rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK1}*
#rm -f $HOME_PATH/../../YDC_DMP/exp_YDC_*${BEFOR_WEEK2}*
#echo "30日前のファイルを削除完了「`date`」"    | tee -a ${LOG_FILE}
#基盤更改の修正　END

#-------------------------------------------------------------------------------------
echo "#------------------------------------------------------------------" >>${LOG_FILE}
echo "#シェル_END                                                        " >>${LOG_FILE}
echo "#------------------------------------------------------------------" >>${LOG_FILE}
#-------------------------------------------------------------------------------------
exit 0
