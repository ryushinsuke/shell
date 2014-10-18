#!/bin/sh
# ========================================================================
# �V�F���h�c    �F  exp_YDC_JTK_SINKYOTU.sh
# �V�F������    �F  ��n�{�ԐV���ʎ���f�[�^�G�N�X�|�[�g����
# �����T�v      �F  ��n�{�ԐV���ʎ���f�[�^�G�N�X�|�[�g����
# ���͈���      �F  �Ȃ�
# ���^�[���R�[�h�F  0�F����I��
#                   1�F�ُ�I��
# ��������
# �N����   �敪 �S����    ���e
# -------- ---- --------- --------------------------------------
#          �V�K GUT       �V�K�쐬
# 20130912 �C�� GUT���u�p ��ՍX��
# ========================================================================

NOW=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)

source ~/.bash_profile

#��ՍX���̏C���@START
LOG_FILE=${HOME_PATH}/log/exp_YDC_JTK_SINKYOTU_${NOW}.log

# CONF�t�@�C����ǂݍ���
CONF_PATH=${HOME_PATH}/conf
CONF_FILE="${CONF_PATH}/backup_daily.conf"
if [ -e "${CONF_FILE}" ] ;then
  . "${CONF_FILE}"
else
  echo "CONF�t�@�C���ubackup_daily.conf�v�����݂��Ă��Ȃ��B" | tee -a ${LOG_FILE}
  exit 1
fi

#�{��NAS�_���v�t�@�C���o�b�N�A�b�vPATH�̃`�F�b�N
if [ -z ${HB_NAS_PATH} ]
then 
  echo  "�{��NAS�_���v�t�@�C���o�b�N�A�b�vPATH�擾�ɃG���[���������܂����I" | tee -a ${LOG_FILE}
  exit 1
fi

#�{��DB�ڑ��q(�V���ʎ��)�̃`�F�b�N
if [ -z ${JTK_SINKYOTU_CONN} ]
then
  echo  "�{��DB�ڑ��q(�V���ʎ��)�擾�ɃG���[���������܂����I" | tee -a ${LOG_FILE}
  exit 1
fi

#�G�N�X�|�[�g�i�[�ꏊ�̃`�F�b�N
if [ ! -d ${HB_NAS_PATH}/${NOW} ]
then
  mkdir -pm 755 ${HB_NAS_PATH}/${NOW}
fi

#�V���ʎ���f�[�^�G�N�X�|�[�g
#�y�h�s�j�z��YDC�̃e�[�u�����G�b�N�X�|�[�g����
echo "��n�{�ԐV���ʎ���f�[�^�G�N�X�|�[�g�����J�n(`date`)" | tee -a ${LOG_FILE}
#exp /@TSTARJTK1  parfile=$HOME_PATH/JTK_SINKYOTU_TBL.prm file=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.log direct=y
#exp /@TSTARJTK1 tables=(TK%,TO%,WT%) file=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_${NOW}.log direct=y
sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${JTK_SINKYOTU_CONN} ${HB_NAS_PATH}/${NOW}/exp_YDC_JTK_SINKYOTU_${NOW}.dmp exp_YDC_JTK_SINKYOTU_${NOW}.log "TABLES=TK%,TO%,WT%" > ${HB_NAS_PATH}/${NOW}/exp_YDC_JTK_SINKYOTU_${NOW}.log 2>&1

#���k����
#/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.dmp
/bin/gzip ${HB_NAS_PATH}/${NOW}/exp_YDC_JTK_SINKYOTU_${NOW}.dmp

#END�t�@�C���쐬
#/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.END
/bin/touch ${HB_NAS_PATH}/${NOW}/exp_YDC_JTK_SINKYOTU_${NOW}.END

#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_JTK_SINKYOTU_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/

#����I��
echo "��n�{�ԐV���ʎ���f�[�^�G�N�X�|�[�g�����I��(`date`)" | tee -a ${LOG_FILE}
exit 0
#��ՍX���̏C���@END
