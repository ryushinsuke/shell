#!/bin/sh
# ========================================================================
# シェルＩＤ    ：  exp_YDC_ITK.sh
# シェル名称    ：  基準系本番委託データエクスポート処理
# 処理概要      ：  基準系本番委託データエクスポート処理
# 入力引数      ：  なし
# リターンコード：  0：正常終了
#                   1：異常終了
# 改訂履歴
# 年月日   区分 担当者    内容
# -------- ---- --------- --------------------------------------
#          新規 GUT       新規作成
# 20130912 修正 GUT高志英 基盤更改
# ========================================================================

NOW=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile

#基盤更改の修正　START
LOG_FILE=${HOME_PATH}/log/exp_YDC_ITK_${NOW}.log

# CONFファイルを読み込む
CONF_PATH=${HOME_PATH}/conf
CONF_FILE="${CONF_PATH}/backup_daily.conf"
if [ -e "${CONF_FILE}" ] ;then
  . "${CONF_FILE}"
else
  echo "CONFファイル「backup_daily.conf」が存在していない。" | tee -a ${LOG_FILE}
  exit 1
fi

#本番NASダンプファイルバックアップPATHのチェック
if [ -z ${HB_NAS_PATH} ]
then 
  echo  "本番NASダンプファイルバックアップPATH取得にエラーが発生しました！" | tee -a ${LOG_FILE}
  exit 1
fi

#本番DB接続子(委託)のチェック
if [ -z ${ITK_CONN} ]
then
  echo  "本番DB接続子(委託)取得にエラーが発生しました！" | tee -a ${LOG_FILE}
  exit 1
fi

#エクスポート格納場所のチェック
if [ ! -d ${HB_NAS_PATH}/${NOW} ]
then
  mkdir -pm 755 ${HB_NAS_PATH}/${NOW}
fi

#委託データエクスポート
#YDCのテーブルをエックスポートする
echo "基準系本番委託データエクスポート処理開始(`date`)" | tee -a ${LOG_FILE}
#exp /@TSTARITK1 tables=(TB%,FN%) file=$HOME_PATH/../../YDC_DMP/exp_YDC_ITK_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_ITK_${NOW}.log direct=y
sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${ITK_CONN} ${HB_NAS_PATH}/${NOW}/exp_YDC_ITK_${NOW}.dmp exp_YDC_ITK_${NOW}.log "TABLES=TB%,FN%" > ${HB_NAS_PATH}/${NOW}/exp_YDC_ITK_${NOW}.log 2>&1

#圧縮する
#/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.dmp
/bin/gzip ${HB_NAS_PATH}/${NOW}/exp_YDC_ITK_${NOW}.dmp

#ENDファイル作成
#/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.END
/bin/touch ${HB_NAS_PATH}/${NOW}/exp_YDC_ITK_${NOW}.END

#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/

#正常終了
echo "基準系本番委託データエクスポート処理終了(`date`)" | tee -a ${LOG_FILE}
exit 0
#基盤更改の修正　END
