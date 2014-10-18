#!/bin/sh
source ~/.bash_profile
# ========================================================================
# �V�X�e���h�c  �F  Past_KJ_Mask_JTK
# �V�X�e������  �F  ��n�ߋ����f�[�^�}�X�N���� JTK�AJTK�Ɩ����ʂ̂�
# �����T�v      �F  ��n�ߋ����f�[�^�}�X�N���� JTK�AJTK�Ɩ����ʂ̂�
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100407 �V�K GUT��    �V�K�쐬
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
#--- �����ݒ�
DATA_KBN=$1       # ���ʂƐV����:0  ����Ɩ��ƋƖ�����:1  ���ߌ�Ɩ��ƋƖ�����:2
DATE_FILE=$2      # �ߋ�MASK�u���ʗp:00 ����p�F01 ���ߌ�F02�v  �w����t:XXXXXXXX
DB_FILE=$3        # �ߋ�DATA�p:1   ���[�U�w��:/XXXXX/XXXX/XXXX

#--- ��������
WORK_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${WORK_PATH}/conf"
PARAM_PATH="${WORK_PATH}/param"
SHL_PATH="${WORK_PATH}/sh"
TMP_PATH="${WORK_PATH}/tmp"
END_PATH="${WORK_PATH}/end"
LOG_PATH="${WORK_PATH}/log"

#--- ���O�p�X�͑��݂��Ȃ��ꍇ�A�쐬����
test -e ${LOG_PATH} \
  || mkdir -p "${LOG_PATH}"

#--- ���O�t�@�C���ݒ�
LOG_FILE="${LOG_PATH}/Past_KJ_Mask_${DATA_KBN}.log"

#--- CONF�t�@�C������������
CONF_FILE="${CONF_PATH}/Past_KJ_Mask.conf"
if [ -e "${CONF_FILE}" ] ;then
  . "${CONF_FILE}"
else
  echo "CONF�t�@�C�����Ȃ��̂ŁAERR"                                  | tee -a "${LOG_FILE}"
  exit 1
fi

#--- �����`�F�b�N
if [ $# -ne 3 ] ;then
  echo "Parameter  ERR"                                               | tee -a "${LOG_FILE}"
  echo 'usage $1  [ 0 ] CMN�ƐV����MASK'                              | tee -a "${LOG_FILE}"
  echo '          [ 1 ] ����Ɩ��ƋƖ�����MASK '                      | tee -a "${LOG_FILE}"
  echo '          [ 2 ] ���ߌ�Ɩ��ƋƖ�����MASK'                     | tee -a "${LOG_FILE}"
  echo 'usage $2  [ 0 ] �ߋ����ʓ��tFILE'                             | tee -a "${LOG_FILE}"
  echo '          [ 1 ] �ߋ�������tFILE'                             | tee -a "${LOG_FILE}"
  echo '          [ 2 ] �ߋ����ߌ���tFILE '                          | tee -a "${LOG_FILE}"
  echo 'usage $3  [ 1 ] �ߋ��pWKDB�t�@�C�� '                          | tee -a "${LOG_FILE}"
  echo '            ��L�ȊO�̏ꍇ�AWORK-DB-FILE���w�肵�Ă��������B' | tee -a "${LOG_FILE}"
  exit 1
fi

#--- ITK��Ѓ��X�g�t�@�C���̑��݃`�F�b�N
ITK_FILE="${PARAM_PATH}/${ITK_LIST_NAME}"
test -e "${ITK_FILE}" \
  || (echo "ITK��Ѓ��X�g[${ITK_FILE}]���Ȃ��̂ŁAERR"                | tee -a "${LOG_FILE}" \
  && exit 1)

#--- ITK��Ѓ��X�g�t�@�C���̒��g�`�F�b�N
grep -E '^[^1]' ${ITK_FILE} > /dev/null
RE_STATUS=$?
test ${RE_STATUS} -eq 0 \
  && (echo "ITK��Ѓ��X�g[${ITK_FILE}]�̒��g��ITK��ЈȊO�̉�Ђ�����̂ŁA ERR" | tee -a "${LOG_FILE}" \
  && exit 1)

#--- �ߋ��p�f�t�H���gWORK DB�t�@�C���w��
if [ "${DB_FILE}" = "1" ];then
   DB_FILE="${CONF_PATH}/${PAST_WKDB_FILE}"
fi

#--- WORK-DB-FILE�̑��݃`�F�b�N
if [ -e "${DB_FILE}" ] ;then
  . "${DB_FILE}"
else
  echo "�w�肵��WORK-DB-FILE(${DB_FILE})���Ȃ��̂ŁAERR"              | tee -a "${LOG_FILE}"
  exit 1
fi

#--- �ߋ��f�[�^���t�t�@�C���ݒ�
case ${DATE_FILE} in
"0")
  PAST_DATE_FILE="${PARAM_PATH}/${PAST_KJN_FILE00}"
  ;;
"1")
  PAST_DATE_FILE="${PARAM_PATH}/${PAST_KJN_FILE01}"
  ;;
"2")
  PAST_DATE_FILE="${PARAM_PATH}/${PAST_KJN_FILE02}"
  ;;
*)
  echo 'Parameter Err'                                                | tee -a "${LOG_FILE}"
  echo 'usage $2  [ 0 | 1 | 2 ] �̔C�ӂ��w�肵�Ă��������B'           | tee -a "${LOG_FILE}"
  ;;
esac

#--- �ߋ��f�[�^���t�t�@�C���̑��݃`�F�b�N
if [ ! -e "${PAST_DATE_FILE}" ] ;then
  echo "�w�肵�����t�t�@�C��(${PAST_DATE_FILE})���Ȃ��̂ŁAErr"       | tee -a "${LOG_FILE}"
  exit 1
fi

######################################################################
##   �w�肵��DB�ڑ��q�ɂ��APROCESS�̏���ɂȂ��Ă��邩�ǂ���      ##
######################################################################
PROCESS_MAX_CHECK()
{
  #--- ����1�FDB�ڑ��q
  MAX_CHK_DBCONN=$1
  while true
  do
    PROCESS_MAX_CNT=`ps -ef | grep "${SHL_PATH}/${SON_SHELL} ${MAX_CHK_DBCONN}" \
                        | grep -v 'grep' | wc -l`
    if  [ ${PROCESS_MAX_CNT} -lt ${MAX_CALL_COUNT} ] ;then
       break
    else
       echo "�}�X�N�V�F����PROCESS�������(${MAX_CALL_COUNT})" \
            "�ɂȂ��Ă���̂ŁASLEEP(`date`)"                         | tee -a ${LOG_FILE}
       sleep 60
    fi
  done
}

######################################################################
##   �w�肵����ЁA�f�[�^�敪�ADB�ڑ��q�ɂ��                       ##
##   �}�X�N�V�F�����N�����ꂽ���ǂ������f�֐�                       ##
######################################################################
PROCESS_CHECK()
{
  #--- ����1�FDB�ڑ��q
  CHK_WKDB_CONN=$1
  #--- ����2�F��ЃR�[�h
  CHK_USER_CODE=$2
  #--- ����3�F�f�[�^�敪
  CHK_DATE_KBN=$3
  while true
  do
    PROCESS_CNT=`ps -ef | grep "${SHL_PATH}/${SON_SHELL} ${CHK_WKDB_CONN}" \
                 | grep "${CHK_USER_CODE} ${CHK_DATE_KBN}" | grep -v 'grep' | wc -l`
    if  [ ${PROCESS_CNT} -lt 1 ] ;then
      break
    else
      echo "DB�ڑ��q(${WKDB_CONN})����p����܂��̂ŁAWAIT.."         | tee -a "${LOG_FILE}"
      sleep 60
    fi
  done
}

######################################################################
##   ����CMN�E�V���ʂ̃}�X�N�����֐�                                ##
######################################################################
CMN_MASK()
{
  #--- ����1�F�}�X�N���t
  CMN_MASK_DATA=$1
  
  #--- CMN 0000
  PROCESS_CHECK "${ASAITI_WKDB_0000_CONN}" "0000" "1"
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0000_CONN}" "${CMN_MASK_DATA}" "0000" "1" &
  
  #--- SINKYOTU NAM
  PROCESS_CHECK "${ASAITI_WKDB_0001_CONN}" "0001" "1"
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0001_CONN}" "${CMN_MASK_DATA}" "0001" "1" &
  
  #--- SINKYOTU JTK
#��ՍX���̏C���@START
# PROCESS_CHECK "${ASAITI_WKDB_0001_CONN}" "0002" "1"
  PROCESS_CHECK "${ASAITI_WKDB_0002_CONN}" "0002" "1"
#��ՍX���̏C���@END
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0002_CONN}" "${CMN_MASK_DATA}" "0002" "1" &
  
  #--- SINKYOTU ITK
  PROCESS_CHECK "${ASAITI_WKDB_0003_CONN}" "0003" "1"
  sleep 10
  sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_0003_CONN}" "${CMN_MASK_DATA}" "0003" "1" &
}

######################################################################
##   ITK�̃}�X�N�����֐�                                            ##
######################################################################
ITK_MASK()
{
  #--- ����1�F�}�X�N���t
  ITK_MASK_DATA=$1
  #--- ����2�FWORK-DB�ڑ��q
  ITK_WKDB_CONN=$2
  #--- ����3�FDATA�敪
  ITK_DATA_KBN=$3
  while read RECORD_USER
  do
    #--- PROCESS�̏���ɂȂ��Ă��邩�ǂ����`�F�b�N
    PROCESS_MAX_CHECK "${ITK_WKDB_CONN}"
    #--- �w�肵����ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    PROCESS_CHECK "${ITK_WKDB_CONN}" "${RECORD_USER}" "${ITK_DATA_KBN}"
    sleep 10
    #--- MASK�V�F���N��
    sh ${SHL_PATH}/${SON_SHELL} ${ITK_WKDB_CONN} ${ITK_MASK_DATA} ${RECORD_USER} ${ITK_DATA_KBN} &
    sleep 20
  done<"${ITK_FILE}"
}

######################################################################
##           MAIN ����                                              ##
######################################################################
echo "��-----------------------------------------------------------��"| tee -a "${LOG_FILE}"
echo "�� ���ߋ��f�[�^�}�X�N����START(`date`)"                         | tee -a "${LOG_FILE}"
echo "��-----------------------------------------------------------��"| tee -a "${LOG_FILE}"

cat ${PAST_DATE_FILE} | while read DATE_RECORD
do
  #--- �f�[�^�敪�ɂ��}�X�N
  case "${DATA_KBN}" in
  "0")
    CMN_MASK "${DATE_RECORD}"
    #--- END�t�@�C�������݂���ꍇ
    if [ -f "${END_PATH}/Past_KJ_Mask.0.END" ];then
       echo "�����ʂƐV���ʃf�[�^�������܂�..�ߋ����t�F${DATE_RECORD}"| tee -a "${LOG_FILE}"
       break
    fi
    ;;
  "1")
    #ITK_MASK "${DATE_RECORD}" "${ASAITI_WKDB_CONN}" "1"
  
    #--- NAM
    #------ PROCESS�̏���ɂȂ��Ă��邩�ǂ����`�F�b�N
    #PROCESS_MAX_CHECK "${ASAITI_WKDB_CONN}"
    #------ NAM��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    #PROCESS_CHECK "${ASAITI_WKDB_CONN}" "1001" "1"
    #--- MASK�V�F���N��
    #sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_CONN}" "${DATE_RECORD}" "1001" "1" &
  
    #--- NAM �Ɩ�����
    #------ NAM��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    #PROCESS_CHECK "${ASAITI_WKDB_10001_CONN}" "10001" "1"
    #--- MASK�V�F���N��
    #sh ${SHL_PATH}/${SON_SHELL} ${ASAITI_WKDB_10001_CONN} ${DATE_RECORD} "10001" "1" &
  
    #--- JTK
    #------ PROCESS�̏���ɂȂ��Ă��邩�ǂ����`�F�b�N
    PROCESS_MAX_CHECK "${ASAITI_WKDB_CONN}"
    #------ JTK��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    PROCESS_CHECK "${ASAITI_WKDB_CONN}" "2001" "1"
    #--- MASK�V�F���N��
    sh ${SHL_PATH}/${SON_SHELL} "${ASAITI_WKDB_CONN}" "${DATE_RECORD}" "2001" "1" &
  
    #--- JTK �Ɩ�����
    #------ JTK��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    PROCESS_CHECK "${ASAITI_WKDB_2000_CONN}" "2000" "1"
    #--- MASK�V�F���N��
    sh ${SHL_PATH}/${SON_SHELL} ${ASAITI_WKDB_2000_CONN} ${DATE_RECORD} "2000" "1" &
    
    #--- ITK �Ɩ�����
    #------ ITK��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    #PROCESS_CHECK "${ASAITI_WKDB_1000_CONN}" "1000" "1"
    #--- MASK�V�F���N��
    #sh ${SHL_PATH}/${SON_SHELL} ${ASAITI_WKDB_1000_CONN} ${DATE_RECORD} "1000" "1" &
    
    #--- END�t�@�C�������݂���ꍇ
    if [ -f "${END_PATH}/Past_KJ_Mask.1.END" ];then
       echo "������Ɩ��f�[�^�������܂�..�ߋ����t�F${DATE_RECORD}"    | tee -a "${LOG_FILE}"
       break
    fi
    ;;
  "2")
    #ITK_MASK "${DATE_RECORD}" "${SIMEGO_WKDB_CONN}" "2"
  
    #--- NAM
    #------ PROCESS�̏���ɂȂ��Ă��邩�ǂ����`�F�b�N
    #PROCESS_MAX_CHECK "${SIMEGO_WKDB_CONN}"
    #------ NAM��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    #PROCESS_CHECK "${SIMEGO_WKDB_CONN}" "1001" "2"
    #--- MASK�V�F���N��
    #sh ${SHL_PATH}/${SON_SHELL} "${SIMEGO_WKDB_CONN}" "${DATE_RECORD}" "1001" "2" &
  
    #--- NAM �Ɩ�����
    #------ NAM��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    #PROCESS_CHECK "${SIMEGO_WKDB_10001_CONN}" "10001" "2"
    #--- MASK�V�F���N��
    #sh ${SHL_PATH}/${SON_SHELL} ${SIMEGO_WKDB_10001_CONN} ${DATE_RECORD} "10001" "2" &
  
    #--- JTK
    #------ PROCESS�̏���ɂȂ��Ă��邩�ǂ����`�F�b�N
    PROCESS_MAX_CHECK "${SIMEGO_WKDB_CONN}"
    #------ JTK��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    PROCESS_CHECK "${SIMEGO_WKDB_CONN}" "2001" "2"
    #--- MASK�V�F���N��
    sh ${SHL_PATH}/${SON_SHELL} "${SIMEGO_WKDB_CONN}" "${DATE_RECORD}" "2001" "2" &
  
    #--- JTK �Ɩ�����
    #------ JTK��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    PROCESS_CHECK "${SIMEGO_WKDB_2000_CONN}" "2000" "2"
    #--- MASK�V�F���N��
    sh ${SHL_PATH}/${SON_SHELL} ${SIMEGO_WKDB_2000_CONN} ${DATE_RECORD} "2000" "2" &
    
    #--- ITK �Ɩ�����
    #------ ITK��ЁA�f�[�^�敪�ADB�ڑ��q����p����邩�ǂ����`�F�b�N
    #PROCESS_CHECK "${SIMEGO_WKDB_1000_CONN}" "1000" "2"
    #--- MASK�V�F���N��
    #sh ${SHL_PATH}/${SON_SHELL} ${SIMEGO_WKDB_1000_CONN} ${DATE_RECORD} "1000" "2" &

    #--- END�t�@�C�������݂���ꍇ
    if [ -f "${END_PATH}/Past_KJ_Mask.2.END" ];then
       echo "�����ߌ�Ɩ��f�[�^�������܂�..�ߋ����t�F${DATE_RECORD}"  | tee -a "${LOG_FILE}"
       break
    fi
    ;;
  *)
    echo "�w�肵���f�[�^�敪���Ȃ��̂ŁAERR"                          | tee -a "${LOG_FILE}"
    exit 1
    ;;
  esac
done

#--- ����I��
echo "��-----------------------------------------------------------��"| tee -a "${LOG_FILE}"
echo "�� ���ߋ��f�[�^�}�X�N���� END (`date`)"                         | tee -a "${LOG_FILE}"
echo "��-----------------------------------------------------------��"| tee -a "${LOG_FILE}"
exit 0
