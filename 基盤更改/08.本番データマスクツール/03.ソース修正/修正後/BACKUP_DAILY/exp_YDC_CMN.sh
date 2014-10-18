#!/bin/sh
# ========================================================================
# �V�F���h�c    �F  exp_YDC_CMN.sh
# �V�F������    �F  ��n�{�ԋ��ʃf�[�^�G�N�X�|�[�g����
# �����T�v      �F  ��n�{�ԋ��ʃf�[�^�G�N�X�|�[�g����
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
#CMN

#��ՍX���̏C���@START
LOG_FILE=${HOME_PATH}/log/exp_YDC_CMN_${NOW}.log

# CONF�t�@�C����ǂݍ���
CONF_PATH=${HOME_PATH}/conf
CONF_FILE="${CONF_PATH}/backup_daily.conf"
if [ -e "${CONF_FILE}" ]
then
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

#�{��DB�ڑ��q(����)�̃`�F�b�N
if [ -z ${CMN_CONN} ]
then
  echo  "�{��DB�ڑ��q(����)�擾�ɃG���[���������܂����I" | tee -a ${LOG_FILE}
  exit 1
fi

#�G�N�X�|�[�g�i�[�ꏊ�̃`�F�b�N
if [ ! -d ${HB_NAS_PATH}/${NOW} ]
then
  mkdir -pm 755 ${HB_NAS_PATH}/${NOW}
fi

#���ʃf�[�^�G�N�X�|�[�g
echo "��n�{�ԋ��ʃf�[�^�G�N�X�|�[�g�����J�n(`date`)" | tee -a ${LOG_FILE}
#exp /@TSTARCMN1  file=$HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.dmp log=$HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.log direct=y
sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${CMN_CONN} ${HB_NAS_PATH}/${NOW}/exp_YDC_CMN_${NOW}.dmp exp_YDC_CMN_${NOW}.log "TABLES=%" > ${HB_NAS_PATH}/${NOW}/exp_YDC_CMN_${NOW}.log 2>&1

#���k����
#/bin/gzip $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.dmp
/bin/gzip ${HB_NAS_PATH}/${NOW}/exp_YDC_CMN_${NOW}.dmp

#END�t�@�C���쐬
#/bin/touch $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.END
/bin/touch ${HB_NAS_PATH}/${NOW}/exp_YDC_CMN_${NOW}.END

#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.dmp.gz /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.log /ext/ikodatatx/pmo/YDC_DMP/ASAITI/
#cp -p $HOME_PATH/../../YDC_DMP/exp_YDC_CMN_$NOW.END /ext/ikodatatx/pmo/YDC_DMP/ASAITI/

#����I��
echo "��n�{�ԋ��ʃf�[�^�G�N�X�|�[�g�����I��(`date`)" | tee -a ${LOG_FILE}
exit 0
#��ՍX���̏C���@END
