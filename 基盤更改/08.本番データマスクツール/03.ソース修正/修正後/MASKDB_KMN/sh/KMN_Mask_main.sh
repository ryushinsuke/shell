#!/bin/sh
source ~/.bash_profile
################################################################################
# �V�X�e���h�c  �F  KMN_Mask_main
# �V�X�e������  �F  �ږ�n�f�[�^�}�X�N����
# �����T�v      �F  �ږ�n�f�[�^�}�X�N���C������
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100706 �V�K GUT��    �V�K�쐬
# 20130327 ���C GUT      �d�l�ύX�Ή�
# 20130920 ���C GUT����@�d�l�ύX�Ή�
################################################################################
#--- ����1(�����敪)
MASK_KBN=$1

#--- ��������
WORK_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${WORK_PATH}/conf"
LOG_PATH="${WORK_PATH}/log"
SHL_PATH="${WORK_PATH}/sh"
TMP_PATH="${WORK_PATH}/tmp"
TMP_BAK_PATH="${WORK_PATH}/tmp_bak"
CONF_FILE="${CONF_PATH}/KMN_Mask_main.conf"
LOG_FILE="${LOG_PATH}/KMN_Mask_main_`date '+%Y%m%d-%H%M%S'`.log"

#--- END�t�@�C���ݒ�
CURRENT_END="${TMP_PATH}/exp_YDC_CURRENT.END"
KOMON_END="${TMP_PATH}/exp_YDC_KOMON.END"

#------------------------------------------------------------------------
# �X�e�b�v-010  # �p�����[�^���`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN010
if [ $# -ne 1 ];then
  echo "Parameter ERR"                                                | tee -a ${LOG_FILE}
  echo "usage: \$1 �����敪[ 0�FCURRENT | 1�F�ʏ�(�T��) ]"            | tee -a ${LOG_FILE}
  exit 1
fi

#------------------------------------------------------------------------
# �X�e�b�v-020  # �}�X�N���t�擾
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN020
case "${MASK_KBN}" in
"0")
  if [ -f "${CURRENT_END}" ];then
    MASK_DATE=`cat ${CURRENT_END} | grep -E '[0-9]{8,8}\b'|sort|tail -1`
    if [ -z "${MASK_DATE}" ];then
      echo "�t�@�C��(${CURRENT_END})�̒��ɓ��t�擾ERR�B(`date`)"      | tee -a ${LOG_FILE}
      exit 1
    fi
  else
    echo "�{�ԃf�[�^�}�X�N�̗Վ��˗����Ȃ��ł��B(`date`)"             | tee -a ${LOG_FILE}
    exit 1
  fi
  ;;
"1")
  if [ -f "${KOMON_END}" ];then
    MASK_DATE=`cat ${KOMON_END} | grep -E '[0-9]{8,8}\b'|sort|tail -1`
    if [ -z "${MASK_DATE}" ];then
      echo "�t�@�C��(${KOMON_END})�̒��ɓ��t�擾ERR[�T��]�B(`date`)"  | tee -a ${LOG_FILE}
      exit 1
    fi
  else
    echo "�{�ԃf�[�^�}�X�N�̏T��END�t�@�C���擾���s�B(`date`)"        | tee -a ${LOG_FILE}
    exit 1
  fi
  ;;
esac

#------------------------------------------------------------------------
# �X�e�b�v-030  # conf�t�@�C�����݃`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN030
if [ -e "${CONF_FILE}" ];then
  . "${CONF_FILE}"
else
  echo "��CONF�t�@�C��(${CONF_FILE})�����݂��Ȃ��̂ŁAERR"            | tee -a ${LOG_FILE}
  exit 1
fi
#��ՍX���̏C���@START
#---  �Վ��˗��̉�Ѓ��X�g�t�@�C���擾�`�F�b�N
if [ -z ${CURRENT_FILE} ]
then
  echo "�Վ��˗��̉�Ѓ��X�g�t�@�C���擾�ɃG���[���������܂����I"     | tee -a ${LOG_FILE}
  exit 1
fi

#---  �Վ��˗��ɂ���āA�{�Ԃɍ쐬�����{��DMP�t�@�C���̃p�X(CURRENT)�擾�`�F�b�N
if [ -z ${HB_DMP_CURRENT_PATH} ]
then
  echo "�{��DMP�t�@�C���̃p�X(CURRENT)�擾�ɃG���[���������܂����I"   | tee -a ${LOG_FILE}
  exit 1
fi

#�{�Ԃɍ쐬�����{��DMP�t�@�C���̃p�X(�T��)�擾�`�F�b�N
if [ -z ${HB_DMP_NORMAL_PATH} ]
then
  echo "�{��DMP�t�@�C���̃p�X(�T��)�擾�ɃG���[���������܂����I"      | tee -a ${LOG_FILE}
  exit 1
fi

#HISTORY�t�@�C����`�擾�`�F�b�N
if [ -z ${HISTORY_CURRENT} ]
then
  echo "HISTORY_CURRENT�t�@�C����`�擾�ɃG���[���������܂����I"      | tee -a ${LOG_FILE}
  exit 1
fi

#HISTORY�t�@�C����`�擾�`�F�b�N
if [ -z ${HISTORY_NORMAL} ]
then
  echo "HISTORY_NORMAL�t�@�C����`�擾�ɃG���[���������܂����I"       | tee -a ${LOG_FILE}
  exit 1
fi

#���[�NDB�ɖ{��DMP�t�@�C����u���p�X�擾�`�F�b�N
if [ -z ${WKDB_DMP_PATH_IN_BASE} ]
then
  echo "�{��DMP�t�@�C���i�[�p�X(BASE)�擾�ɃG���[���������܂����I"    | tee -a ${LOG_FILE}
  exit 1
fi

#���[�NDB�ɖ{��DMP�t�@�C����u���p�X�擾�`�F�b�N
if [ -z ${WKDB_DMP_PATH_IN} ]
then
  echo "�{��DMP�t�@�C���i�[�p�X�擾�ɃG���[���������܂����I"          | tee -a ${LOG_FILE}
  exit 1
fi

#���[�NDB�Ƀ}�X�N��DMP�t�@�C����u���p�X�擾�`�F�b�N
if [ -z ${WKDB_DMP_PATH_OUT_BASE} ]
then
  echo "�}�X�N��DMP�t�@�C���i�[�p�X(BASE)�擾�ɃG���[���������܂����I" | tee -a ${LOG_FILE}
  exit 1
fi

#���[�NDB�Ƀ}�X�N��DMP�t�@�C����u���p�X�擾�`�F�b�N
if [ -z ${WKDB_DMP_PATH_OUT} ]
then
  echo "�}�X�N��DMP�t�@�C���i�[�p�X�擾�ɃG���[���������܂����I"      | tee -a ${LOG_FILE}
  exit 1
fi

#���J�����ږ�}�X�N�ς݃p�X(CURRENT)�擾�`�F�b�N
if [ -z ${KOKAI_KMN_CURRENT_PATH} ]
then
  echo "���J�ږ�}�X�N�ς݃p�X(CURRENT)�擾�ɃG���[���������܂����I"  | tee -a ${LOG_FILE}
  exit 1
fi

#���J�����ږ�}�X�N�ς݃p�X(�T��)�擾�`�F�b�N
if [ -z ${KOKAI_KMN_NORMAL_PATH} ]
then
  echo "���J�ږ�}�X�N�ς݃p�X(�T��)�擾�ɃG���[���������܂����I"     | tee -a ${LOG_FILE}
  exit 1
fi
#��ՍX���̏C���@END

#------------------------------------------------------------------------
# �X�e�b�v-040  # history�t�@�C���ɁA�}�X�N���t���݃`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN040
case "${MASK_KBN}" in
"0")
  cat ${HISTORY_CURRENT} | grep -w ${MASK_DATE}
  RE_STATUS=$?
  if [ "${RE_STATUS}" -eq 0 ] ;then
    echo "�����t�@�C��(${HISTORY_CURRENT})�̒��ɁA"                   | tee -a ${LOG_FILE}
    echo "�Y�����t�����݂��Ă��܂��̂ŁA�}�X�N�����ɏI������"         | tee -a ${LOG_FILE}
    exit 0
  fi
  ;;
"1")
  cat ${HISTORY_NORMAL} | grep -w ${MASK_DATE}
  RE_STATUS=$?
  if [ "${RE_STATUS}" -eq 0 ] ;then
    echo "�����t�@�C��(${HISTORY_NORMAL})�̒��ɁA"                    | tee -a ${LOG_FILE}
    echo "�Y�����t�����݂��Ă��܂��̂ŁA�}�X�N�����ɏI������"         | tee -a ${LOG_FILE}
    exit 0
  fi
  ;;
esac

######################################################################
##        ��Еʃ}�X�N�����֐�                                      ##
######################################################################
USER_MASK()
{
  USER_CODE=$1
  F_MASK_DATE=$2
  HB_DMP_PATH=$3
  WK_PATH_IN=$4
  WK_PATH_OUT=$5
  KOKAI_PATH=$6

#------------------------------------------------------------------------
# �X�e�b�v-010  # ���b�Z�[�W�o��
#------------------------------------------------------------------------
#STEPNAME=USERMASK010
  echo "������ЁF${USER_CODE}"                                       | tee -a ${LOG_FILE}

#------------------------------------------------------------------------
# �X�e�b�v-020  # �}�X�N�Ώۂ����[�N���̓t�H���_�ɃR�s�[
#------------------------------------------------------------------------
#STEPNAME=USERMASK020
  cp ${HB_DMP_PATH}/${USER_CODE}_kmn_1.exp*  ${WK_PATH_IN}

#------------------------------------------------------------------------
# �X�e�b�v-030  # �}�X�N����
#------------------------------------------------------------------------
#STEPNAME=USERMASK030
  ${SHL_PATH}/KMN_MaskByUserID.sh  \
     ${F_MASK_DATE}  \
     ${USER_CODE}
#��ՍX���̏C���@START
  MV_M_STATUS=$?
#��ՍX���̏C���@END

#------------------------------------------------------------------------
# �X�e�b�v-040  # �}�X�N�ς݃f�[�^�t�@�C�������J�t�H���_�ֈړ�
#------------------------------------------------------------------------
#STEPNAME=USERMASK040
#��ՍX���̏C���@START
#  if [ -d "${WK_PATH_OUT}/${USER_CODE}_1_m" ];then
#    mv -f ${WK_PATH_OUT}/${USER_CODE}_1_m \
#          ${KOKAI_PATH}
#    MV_M_STATUS=$?
#  else
#    echo "��${USER_CODE}�̃}�X�N�o��DMP���쐬���Ȃ��I"                | tee -a ${LOG_FILE}
#  fi
#��ՍX���̏C���@END
#------------------------------------------------------------------------
# �X�e�b�v-050  # �}�X�N�Ȃ��Ώۂ����[�N���̓t�H���_�ɃR�s�[
#                �i��Еʉ^�p���ʃf�[�^�t�@�C���ȊO�j
#------------------------------------------------------------------------
#STEPNAME=USERMASK050
  cp ${HB_DMP_PATH}/${USER_CODE}_kmn_2.exp*  ${WK_PATH_IN}

#------------------------------------------------------------------------
# �X�e�b�v-060  # �}�X�N�Ȃ��f�[�^���e�[�u���P�ʂɂďo�͏���
#                �i��Еʉ^�p���ʃf�[�^�t�@�C���ȊO�j
#------------------------------------------------------------------------
#STEPNAME=USERMASK060
  ${SHL_PATH}/KMN_NoMaskByUserID.sh  \
     ${F_MASK_DATE}  \
     ${USER_CODE}
#��ՍX���̏C���@START
  MV_O_STATUS=$?
#��ՍX���̏C���@END

#------------------------------------------------------------------------
# �X�e�b�v-070  # �}�X�N�Ȃ��̃f�[�^�t�@�C�������J�t�H���_�ֈړ�
#                �i��Еʉ^�p���ʃf�[�^�t�@�C���ȊO�j
#------------------------------------------------------------------------
  K_PATH="${KOKAI_PATH}/${USER_CODE}_2"
#STEPNAME=USERMASK070
#��ՍX���̏C���@START
#  if [ -d "${WK_PATH_OUT}/${USER_CODE}_2" ];then
#    mv -f ${WK_PATH_OUT}/${USER_CODE}_2 \
#          ${KOKAI_PATH}
#    MV_O_STATUS=$?
#  else
#��ՍX���̏C���@END
    if [ ! -e ${K_PATH} ]
    then
        mkdir ${K_PATH}
    fi
#��ՍX���̏C���@START
#    echo "��${USER_CODE}�̃}�X�N�Ȃ��o��DMP���쐬���Ȃ��I"                | tee -a ${LOG_FILE}
#  fi
#��ՍX���̏C���@END
#------------------------------------------------------------------------
# �X�e�b�v-080  # ��Еʉ^�p���ʃf�[�^�t�@�C�������J�t�H���_�փR�s�[
#------------------------------------------------------------------------
#STEPNAME=USERMASK080
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSMS01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSMS01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSMS01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSMS01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSMS01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSMS01_${USER_CODE}.sql
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSSK01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSSK01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSSK01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSSK01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSSK01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSSK01_${USER_CODE}.sql
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSTH01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSTH01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSTH01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSTH01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSTH01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSTH01_${USER_CODE}.sql
#
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSZT01.exp.gz \
    | xargs -i cp {} ${K_PATH}/TKUSZT01_${USER_CODE}.exp.gz
  ls  ${HB_DMP_PATH}/${USER_CODE}_kmn_TKUSZT01.log    \
    | xargs -i cp {} ${K_PATH}/TKUSZT01_${USER_CODE}.log
  ls  ${HB_DMP_PATH}/TKUSZT01_kmn_${USER_CODE}.sql    \
    | xargs -i cp {} ${K_PATH}/TKUSZT01_${USER_CODE}.sql
#------------------------------------------------------------------------
# �X�e�b�v-090  # �������̓G���[���b�Z�[�W�o��
#------------------------------------------------------------------------
#STEPNAME=USERMASK090
    if    [ ${MV_M_STATUS} -ne 0 ] \
       || [ ${MV_O_STATUS} -ne 0 ] ;then
      echo "��${USER_CODE}�̌ږ�f�[�^�͌��JERR�I"                    | tee -a ${LOG_FILE}
    else
      echo "���${USER_CODE}�̃}�X�N�ς݃f�[�^��DDL�����J����܂����B"| tee -a ${LOG_FILE}
    fi
}

######################################################################
##        �����t�@�C���������݊֐�                                  ##
######################################################################
WRITE_HISTORY()
{
  #--- ����1�F�������݂̓��t
  H_MASK_DATE=$1
  #--- ����2�F�������ݐ�̃t�@�C��
  HISTORY_FILE=$2
  echo "�����t�@�C��(${HISTORY_FILE})�ɏ������݊J�n(`date`)"          | tee -a ${LOG_FILE}
  echo "${MASK_DATE}" >> "${HISTORY_FILE}"
  echo "�������݂̓��t�F${H_MASK_DATE}"                               | tee -a ${LOG_FILE}
  echo "�����t�@�C��(${HISTORY_FILE})�ɏ������ݏI��(`date`)"          | tee -a ${LOG_FILE}
}

######################################################################
##                  MAIN ����                                       ##
######################################################################
#------------------------------------------------------------------------
# �X�e�b�v-050  # CURRENT���� -- ���J�p�t�H���_�쐬
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN050
if [ "${MASK_KBN}" = "0" ] && [ -f "${CURRENT_FILE}" ] ;then
  #--- ���J�p�t�H���_�쐬
  if [ ! -d "${KOKAI_KMN_CURRENT_PATH}" ] ;then
    mkdir "${KOKAI_KMN_CURRENT_PATH}"
  fi

#------------------------------------------------------------------------
# �X�e�b�v-051  # CURRENT���� -- ��Еʏ���
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN051
  echo "�ږ�n${MASK_DATE}�{�ԃf�[�^�}�X�NCURRENT�����J�n_(`date`)"   | tee -a ${LOG_FILE}
  while read RECORD_CURRENT
  do
    #--- �}�X�N�֐��R�[��
    USER_MASK                   \
      ${RECORD_CURRENT}         \
      ${MASK_DATE}              \
      ${HB_DMP_CURRENT_PATH}    \
      ${WKDB_DMP_PATH_IN}       \
      ${WKDB_DMP_PATH_OUT}      \
      ${KOKAI_KMN_CURRENT_PATH}
  done < "${CURRENT_FILE}"

#------------------------------------------------------------------------
# �X�e�b�v-052  # CURRENT���� -- �Ɩ����ʏ���
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN052  
USER_MASK                     \
    "1000"                      \
    ${MASK_DATE}                \
    ${HB_DMP_CURRENT_PATH}      \
    ${WKDB_DMP_PATH_IN}         \
    ${WKDB_DMP_PATH_OUT}        \
    ${KOKAI_KMN_CURRENT_PATH}
  
  echo "�ږ�n${MASK_DATE}�{�ԃf�[�^�}�X�NCURRENT�����I��_(`date`)"   | tee -a ${LOG_FILE}
  
#------------------------------------------------------------------------
# �X�e�b�v-053  # CURRENT���� -- �����t�@�C����������
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN053  
  WRITE_HISTORY                 \
    ${MASK_DATE}                \
    ${HISTORY_CURRENT}

#------------------------------------------------------------------------
# �X�e�b�v-054  # CURRENT���� -- �Վ��˗���END�t�@�C���ړ�
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN054  
  mv -f ${CURRENT_END} ${TMP_BAK_PATH}
  mv -f ${CURRENT_FILE} ${TMP_BAK_PATH}
fi

if [ "${MASK_KBN}" = "1" ] ;then
#------------------------------------------------------------------------
# �X�e�b�v-060  # �T������ -- ���J�p�t�H���_�쐬
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN060
  if   [ `date -d ${MASK_DATE} '+%u'` -eq ${SAT_OF_WEEK} ] \
    || [ `date -d ${MASK_DATE} '+%u'` -eq ${SUN_OF_WEEK} ];then
    #--- ���J�p�t�H���_�쐬
    if [ ! -d "${KOKAI_KMN_NORMAL_PATH}" ];then
      mkdir "${KOKAI_KMN_NORMAL_PATH}"
    fi
#------------------------------------------------------------------------
# �X�e�b�v-061  # �T������ -- ���ʂƉ�Еʏ���
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN061
    echo "�ږ�n${MASK_DATE}�{�ԃf�[�^�}�X�N�T�������J�n_(`date`)"      | tee -a ${LOG_FILE}
    for RECORD_KAISYACD in `ls -1 ${HB_DMP_NORMAL_PATH} | grep '_kmn_1.exp' | awk -F'_' '{print $1}'`
    do
      #--- �}�X�N�֐��R�[��
      echo "${RECORD_KAISYACD}"
      USER_MASK                   \
        ${RECORD_KAISYACD}        \
        ${MASK_DATE}              \
        ${HB_DMP_NORMAL_PATH}     \
        ${WKDB_DMP_PATH_IN}       \
        ${WKDB_DMP_PATH_OUT}      \
        ${KOKAI_KMN_NORMAL_PATH}
    done
    echo "�ږ�n${MASK_DATE}�{�ԃf�[�^�}�X�N�T�������I��_(`date`)"      | tee -a ${LOG_FILE}
    
#------------------------------------------------------------------------
# �X�e�b�v-062  # �T������ -- �����t�@�C����������
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN062  
    WRITE_HISTORY                 \
      ${MASK_DATE}                \
      ${HISTORY_NORMAL}

#------------------------------------------------------------------------
# �X�e�b�v-063  # �T������ -- END�t�@�C���ړ�
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN063  
    mv -f ${KOMON_END} ${TMP_BAK_PATH}
  fi
fi

#------------------------------------------------------------------------
# �X�e�b�v-070  # ���[�N�Վ��t�H���_���폜
#------------------------------------------------------------------------
#STEPNAME=KMNMASKMAIN070  
echo "�� �Վ��t�H���_�폜�J�n(`date`)"                                | tee -a ${LOG_FILE}
echo "���폜�t�H���_�F${WKDB_DMP_PATH_IN_BASE} ������ ${MASK_DATE}"   | tee -a ${LOG_FILE}
cd ${WKDB_DMP_PATH_IN_BASE} && rm -r ${MASK_DATE}
echo "���폜�t�H���_�F${WKDB_DMP_PATH_OUT_BASE} ������ ${MASK_DATE}"  | tee -a ${LOG_FILE}
cd ${WKDB_DMP_PATH_OUT_BASE} && rm -r ${MASK_DATE}
echo "�� �Վ��t�H���_�폜�I��(`date`)"                                | tee -a ${LOG_FILE}

#--- ����I��
exit 0
