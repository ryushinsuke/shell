#!/bin/sh

NOW=`date '+%Y%m%d_%H%M'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile

#YDC�̃e�[�u�����G�b�N�X�|�[�g����
exp /@TSTARITK1  parfile=$HOME_PATH/BACKUP_DAILY/ITK_TBL.prm file=$HOME_PATH/../../YDC_DMP/exp_YDC_ITK_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_ITK_${NOW}.log direct=y
#���k����
/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_ITK_$NOW.dmp

