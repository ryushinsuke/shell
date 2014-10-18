#!/bin/sh
# ========================================================================
# �V�X�e���h�c  �F MaskedData_cpy
# �V�X�e������  �F �}�X�N�ς݃f�[�^�]������
# �����T�v      �F �}�X�N�ς݃f�[�^�]������
# ���͈���      �F �@  �����敪
#                  �A  �������t
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20130923 �V�K GUT���  �V�K�쐬
# ========================================================================

# �����ݒ�
SYORI_KBN=$1     #1:����  2:���ߌ�  3:�ږ�
SYORI_DATE=$2    #def:1(sysdate)  �V�X�e�����t
if [ "${SYORI_DATE}" = "1" ] ;then
  SYORI_DATE=`date '+%Y%m%d'`
fi

# �ϐ�������
HOME_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${HOME_PATH}/conf"
LOG_PATH="${HOME_PATH}/log"

test -d ${LOG_PATH} || mkdir -p ${LOG_PATH}
LOG_FILE=${LOG_PATH}/MaskedData_cpy_${SYORI_DATE}.log

#--- �����`�F�b�N
if [ $# -ne 2 ] ;then
  echo "Parameter  ERR"                                               | tee -a ${LOG_FILE}
  echo 'usage $1  [ 1 ] ����'                                         | tee -a ${LOG_FILE}
  echo '          [ 2 ] ���ߌ�'                                       | tee -a ${LOG_FILE}
  echo '          [ 3 ] �ږ�'                                         | tee -a ${LOG_FILE}
  echo 'usage $2  [ 1 ] �������t'                                     | tee -a ${LOG_FILE}
  echo '          ��L�ȊO�̏ꍇ�A���t���w�肵�Ă��������B'           | tee -a ${LOG_FILE}
  exit 1
fi

#--- ���t�@�C���ǂݍ���
CONF_FILE=${CONF_PATH}/MaskedData_cpy.conf
if [ -f ${CONF_FILE} ];then
  . ${CONF_FILE}
else
  echo "���t�@�C�����Ȃ��̂ŁAERR!"                                 | tee -a ${LOG_FILE}
  exit 1
fi

#-------------------------------------------------------
# �֐��FKJ_ASAITI_CPY  ��n����}�X�N�ς݃f�[�^�]��
#-------------------------------------------------------
KJ_ASAITI_CPY()
{
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn ssh -l ${TYOSA_USER} ${TYOSA_IP}
  expect {
  "*password: " {send "${TYOSA_PWD}\r"; }
  }
  expect " ~]"
  send "mkdir -p ${KJ_DMP_ASAITI_OUT_PATH}/${SYORI_DATE}\r"
  expect " ~]"
  send "exit\r"
  interact
EOF
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn sftp ${TYOSA_USER}@${TYOSA_IP}
  expect "password:"
  send "${TYOSA_PWD}\r"

  expect "sftp>"
  send "mput ${KJ_DMP_ASAITI_IN_PATH}/${SYORI_DATE}/* ${KJ_DMP_ASAITI_OUT_PATH}/${SYORI_DATE}\r"

  expect "sftp>"
  send "exit\r"
  interact
EOF
}

#-------------------------------------------------------
# �֐��FKJ_SIMEGO_CPY  ��n���ߌ�}�X�N�ς݃f�[�^�]��
#-------------------------------------------------------
KJ_SIMEGO_CPY()
{
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn ssh -l ${TYOSA_USER} ${TYOSA_IP}
  expect {
  "*password: " {send "${TYOSA_PWD}\r"; }
  }
  expect " ~]"
  send "mkdir -p ${KJ_DMP_SIMEGO_OUT_PATH}/${SYORI_DATE}\r"
  expect " ~]"
  send "exit\r"
  interact
EOF
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn sftp ${TYOSA_USER}@${TYOSA_IP}
  expect "password:"
  send "${TYOSA_PWD}\r"

  expect "sftp>"
  send "mput ${KJ_DMP_SIMEGO_IN_PATH}/${SYORI_DATE}/* ${KJ_DMP_SIMEGO_OUT_PATH}/${SYORI_DATE}\r"

  expect "sftp>"
  send "exit\r"
  interact
EOF
}

#-------------------------------------------------------
# �֐��FKMN_CPY  �ږ�n�}�X�N�ς݃f�[�^�]��
#-------------------------------------------------------
KMN_CPY()
{
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn ssh -l ${TYOSA_USER} ${TYOSA_IP}
  expect {
  "*password: " {send "${TYOSA_PWD}\r"; }
  }
  expect " ~]"
  send "mkdir -p ${KMN_DMP_OUT_PATH}/${SYORI_DATE}\r"
  expect " ~]"
  send "exit\r"
  interact
EOF
  expect << EOF >> ${LOG_FILE}
  set timeout 50
  spawn sftp ${TYOSA_USER}@${TYOSA_IP}
  expect "password:"
  send "${TYOSA_PWD}\r"

  expect "sftp>"
  send "mput ${KMN_DMP_IN_PATH}/${SYORI_DATE}/* ${KMN_DMP_OUT_PATH}/${SYORI_DATE}\r"

  expect "sftp>"
  send "exit\r"
  interact
EOF
}

########################################################
#     MAIN ����
########################################################
echo "��-----------------------------------------------------------��"| tee -a ${LOG_FILE}
echo "�� �}�X�N�ς݃f�[�^�]�������J�n(`date`)"                        | tee -a ${LOG_FILE}
echo "��-----------------------------------------------------------��"| tee -a ${LOG_FILE}

case ${SYORI_KBN} in
  1)
    KJ_ASAITI_CPY
    ;;
  2)
    KJ_SIMEGO_CPY
    ;;
  3)
    KMN_CPY
    ;;
  *)
    echo "�w�肵�������敪���Ȃ��̂ŁAERR"                            | tee -a ${LOG_FILE}
    exit 1
    ;;
esac
TS_STATUS=$?
if [ "${TS_STATUS}" != "0" ];then
  echo "�}�X�N�ς݃f�[�^�]������ ERR!"                                | tee -a ${LOG_FILE}
  exit 1
fi

#--- ����I��
echo "��-----------------------------------------------------------��"| tee -a ${LOG_FILE}
echo "�� �}�X�N�ς݃f�[�^�]�������I��(`date`)"                        | tee -a ${LOG_FILE}
echo "��-----------------------------------------------------------��"| tee -a ${LOG_FILE}
exit 0
