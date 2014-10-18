#!/bin/sh

NOW=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile
#CMN
exp /@TSTARCMN1  file=$HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.log direct=y
#à≥èkÇ∑ÇÈ
/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.dmp
/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.END

cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
