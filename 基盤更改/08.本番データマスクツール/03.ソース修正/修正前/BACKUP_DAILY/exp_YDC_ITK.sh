#!/bin/sh

NOW=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile

#YDCのテーブルをエックスポートする
exp /@TSTARITK1 tables=(TB%,FN%) file=$HOME_PATH/../../YDC_DMP/exp_YDC_ITK_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_ITK_${NOW}.log direct=y
#圧縮する
/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.dmp
/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.END

cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/

