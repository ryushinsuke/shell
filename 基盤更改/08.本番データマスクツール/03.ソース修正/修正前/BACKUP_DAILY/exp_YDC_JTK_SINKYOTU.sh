#!/bin/sh

NOW=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile

#�y�h�s�j�z��YDC�̃e�[�u�����G�b�N�X�|�[�g����
#exp /@TSTARJTK1  parfile=$HOME_PATH/JTK_SINKYOTU_TBL.prm file=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.log direct=y
exp /@TSTARJTK1 tables=(TK%,TO%,WT%) file=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.log direct=y
#���k����
/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.dmp
/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.END

cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/

