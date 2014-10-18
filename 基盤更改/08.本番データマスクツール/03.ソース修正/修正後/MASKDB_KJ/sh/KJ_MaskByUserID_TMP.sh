#!/bin/bash
source ~/.bash_profile
# ========================================================================
# �V�X�e���h�c  �F  KJ_MaskByUserID_TMP
# �V�X�e������  �F  TMP�}�X�N�N���V�F��
# �����T�v      �F  TMP�}�X�N�N���V�F��
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100414 �V�K GUT      �V�K�쐬
# ========================================================================
#---�����ݒ�
MASK_DATE=$1
USER_ID=$2
SYORI_KBN=$3

#---�����ݒ�
WORK_HOME="$(cd $(dirname $0);pwd)/.."
PARAM_PATH="${WORK_HOME}/param"
TMP_PATH="${WORK_HOME}/tmp"
SHL_PATH="${WORK_HOME}/sh"
LOG_PATH="${WORK_HOME}/log/KJ_MaskByUserID_TMP"

#---PATH�����݂��Ȃ��ꍇ�A�쐬����
test -e "${LOG_PATH}" \
  || mkdir -p "${LOG_PATH}"
  
#---���O�t�@�C����`
LOG_FILE="${LOG_PATH}/KJ_MaskByUserID_TMP_${MASK_DATE}_${USER_ID}.log"

PBUMASK_DATE="${MASK_DATE}"        #���L��CONF�t�@�C���p
#---CONF�t�@�C������������
CONF_FILE="${WORK_HOME}/conf/Past_KJ_MaskByUserID.conf"
if [ -e "${CONF_FILE}" ];then
  . "${CONF_FILE}"
else
  echo "�K�v��CONF�t�@�C��(${CONF_FILE})���Ȃ����߁AERR "             | tee -a ${LOG_FILE}
  exit 1
fi

#---�����`�F�b�N
if [ $# -ne 3 ] ;then
  echo "Parameter    ERR"                                             | tee -a ${LOG_FILE}
  echo 'usage: $1 �}�X�N���t�w��'                                     | tee -a ${LOG_FILE}
  echo 'usage: $2 ���[�U�[ID�w��'                                     | tee -a ${LOG_FILE}
  echo 'usage: $3 �����敪�w��[1�F����  2�F���ߌ�]'                   | tee -a ${LOG_FILE}
  exit 1
fi

#--- DB�ڑ��p�t�@�C���̑��݃`�F�b�N
CONN_FILE="${PARAM_PATH}/tmp_conn.lst"
if [ ! -f "${CONN_FILE}" ] ;then
  echo "DB�ڑ��p�̃t�@�C��(${CONN_FILE})���Ȃ����߁AERR"              | tee -a ${LOG_FILE}
  exit 1
fi

#--- DB�ڑ��q�擾
CONN_ROW=0
DB_CONN="0000"
while read CONN_RECORD
do
  CONN_ROW=`expr ${CONN_ROW} + 1`
  LOCK_FILE="${TMP_PATH}/conn_${CONN_ROW}.lock"
  if [ ! -e "${LOCK_FILE}" ] ;then
     DB_CONN="${CONN_RECORD}"
     break
  fi
done<"${CONN_FILE}"

#--- DB�ڑ��q�擾��`�F�b�N
if [ "${DB_CONN}" = "0000" ];then
  echo "DB�ڑ��p�̃t�@�C��(${CONN_FILE})�̒��ɁA" \
       "���ׂĂ�DB�ڑ��q����p����Ă��܂��̂ŁAEXIT"                | tee -a ${LOG_FILE}
  exit 1
fi
######################################################################
##    MAIN ����                                                     ##
######################################################################
echo "��----------------------------------------------------------��"| tee -a ${LOG_FILE}
echo "��  TMP�}�X�N�����J�n (`date`)                                "| tee -a ${LOG_FILE}
echo "��----------------------------------------------------------��"| tee -a ${LOG_FILE}
MASK_SHELL="${SHL_PATH}/Past_KJ_MaskByUserID.sh"
if [ -e "${MASK_SHELL}" ] ;then
  touch "${LOCK_FILE}"
  echo "${DB_CONN} ${MASK_DATE} ${USER_ID} ${SYORI_KBN}"             | tee -a ${LOG_FILE}
  ${MASK_SHELL} ${DB_CONN} ${MASK_DATE} ${USER_ID} ${SYORI_KBN}      | tee -a ${LOG_FILE}
  rm -f "${LOCK_FILE}"
else
  echo "�}�X�N�V�F��(${MASK_SHELL})���Ȃ����߁AERR"                  | tee -a ${LOG_FILE}
  exit 1
fi

#--- ����I��
echo "DATE�F${MASK_DATE} USER�F${USER_ID} KBN�F${SYORI_KBN}         "| tee -a ${LOG_FILE}
echo "��----------------------------------------------------------��"| tee -a ${LOG_FILE}
echo "��  TMP�}�X�N�����I�� (`date`)                                "| tee -a ${LOG_FILE}
echo "��----------------------------------------------------------��"| tee -a ${LOG_FILE}
exit 0
