#!/bin/sh

NOW=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile

#YDCのテーブルをエックスポートする
exp /@TSTARNAM1 tables=(TB%,FN%) file=$HOME_PATH/../../YDC_DMP/exp_YDC_NAM_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_NAM_${NOW}.log direct=y
#圧縮する
/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_NAM_$NOW.dmp
/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_NAM_$NOW.END

cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_NAM_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_NAM_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_NAM_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/

