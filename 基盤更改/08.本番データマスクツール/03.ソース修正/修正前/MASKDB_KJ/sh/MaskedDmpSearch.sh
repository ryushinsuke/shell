#!/bin/bash
######################################################################
##      �}�X�N���ׂ�DMP�t�@�C���̑��݃`�F�b�N                       ##
######################################################################
#---����
TARGET_PATH=$1  #def:/ext/YDC_DMP/MASKDB
TARGET_KBN=$2   #����(CMN�ƐV����):0 ����(ITK/JTK/NAM):1 ���ߌ�:2
TARGET_DATE=$3  #ALL�E�ʓ��t�w���

#---�����`�F�b�N
if [ $# -ne 3 ];then
   echo 'usage $1 [ 1 ] : PATH(/ext/YDC_DMP/MASKDB)��TARGET�Ƃ���'
   echo '           ��L�ȊO�̏ꍇ�A�ڂ����p�X���w�肵�Ă��������I'
   echo 'usage $2 [ 0 ] : CMN�ƐV���ʂ̃}�X�N�ς݃t�@�C���`�F�b�N'
   echo '         [ 1 ] : ����(ITK/JTK/NAM)�̃}�X�N�ς݃t�@�C���`�F�b�N'
   echo '         [ 2 ] : ���ߌ�̃}�X�N�ς݃t�@�C���`�F�b�N'
   echo 'usage $3 [ ALL ]      : �}�X�N�ς݂̊i�[�p�X�����̑S���̓��t�t�H���_�͑ΏۂƂ���'
   echo '         [ YYYYMMDD ] : �}�X�N�ς݂̊i�[�p�X�����̎w��̓��t�t�H���_�͑ΏۂƂ���'
   exit 1
fi

#---�����ݒ�
WORK_PATH=$(cd $(dirname $0);pwd)/..
PRARM_PATH="${WORK_PATH}/param"
ITK_CODE_FILE="${PRARM_PATH}/ITK_CODE.lst"

######################################################################
##  �w�肵�����t�t�H���_�����̃}�X�N�ς�DMP�`�F�b�N�֐�             ##
######################################################################
DATE_MASKED_CHECK()
{
  DATE_DIR=$1
  #---����(CMN/�V����)�`�F�b�N
  if [ "${TARGET_KBN}" = "0" ];then
     #--CMN
     ls ${DATE_DIR} | grep -w "exp_YDC_CMN_${DATE_DIR}_m.dmp.gz" > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0000	1	exp_YDC_CMN_${DATE_DIR}_m.dmp.gz"
       
     #--ITK_SINKYOTU
     ls ${DATE_DIR}|grep -w "exp_YDC_ITK_SINKYOTU_${DATE_DIR}_m.dmp.gz" > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0003	1	exp_YDC_ITK_SINKYOTU_${DATE_DIR}_m.dmp.gz"
       
     #--JTK_SINKYOTU
     ls ${DATE_DIR}|grep -w "exp_YDC_JTK_SINKYOTU_${DATE_DIR}_m.dmp.gz"  > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0002	1	exp_YDC_JTK_SINKYOTU_${DATE_DIR}_m.dmp.gz"
       
     #--NAM_SINKYOTU
     ls ${DATE_DIR}|grep -w "exp_YDC_NAM_SINKYOTU_${DATE_DIR}_m.dmp.gz"  > /dev/null
     RE_STATUS=$?
     test ${RE_STATUS} -eq 0 \
       || echo "${DATE_DIR}	0001	1	exp_YDC_NAM_SINKYOTU_${DATE_DIR}_m.dmp.gz"
       
  #---����(ITK/JTK/NAM)�`�F�b�N
  elif [ "${TARGET_KBN}" = "1" ];then
    #---����ITK
     test -e ${ITK_CODE_FILE} \
      || (echo "PARAM�t�@�C��(${ITK_CODE_FILE})�����݂��Ȃ��̂ŁAERR " \
      && exit 1)
      
     while read COMPANY_RECORD
     do
        ls ${DATE_DIR}|grep -E "exp_YDC_ITK_${DATE_DIR}_[1-2]{1,1}[0-9]{3,3}_m.dmp.gz"  > /dev/null
        RE_STATUS=$?
        if [ ${RE_STATUS} -ne 0 ];then
          echo "${DATE_DIR}	�}�X�N�ςݒ���DMP�t�@�C�����Ȃ�" 
          NO_FLG="ASAITI_NO"
          break
        fi

        ls ${DATE_DIR} | grep -w "exp_YDC_ITK_${DATE_DIR}_${COMPANY_RECORD}_m.dmp.gz"  > /dev/null
        RE_STATUS=$?
        test ${RE_STATUS} -eq 0 \
         || echo "${DATE_DIR}	${COMPANY_RECORD}	1"
     done<"${ITK_CODE_FILE}"
     if [ "${NO_FLG}" != "ASAITI_NO" ];then
      #---����ITK(�Ɩ�����)
       ls ${DATE_DIR} | grep -w "exp_YDC_ITK_${DATE_DIR}_1000_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1000	1"
       
      #---����JTK
       ls ${DATE_DIR} | grep -w "exp_YDC_JTK_${DATE_DIR}_2001_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2001	1"
      #---����JTK(�Ɩ�����)
       ls ${DATE_DIR} | grep -w "exp_YDC_JTK_${DATE_DIR}_2000_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2000	1"
      
      #---����NAM
       ls ${DATE_DIR} | grep -w "exp_YDC_NAM_${DATE_DIR}_1001_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1001	1"
      #---����NAM(�Ɩ�����)
       ls ${DATE_DIR} | grep -w "exp_YDC_NAM_${DATE_DIR}_1000_m.dmp.gz"  > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	10001	1"
     fi
  
  #---���ߌ�`�F�b�N
  elif [ "${TARGET_KBN}" = "2" ];then
     while read COMPANY_RECORD
     do
        ls ${DATE_DIR} | grep -E "[1-2]{1,1}[0-9]{3,3}_itk_m.exp.gz" > /dev/null
        RE_STATUS=$?
        if [ ${RE_STATUS} -ne 0 ];then
          echo "${DATE_DIR}	�}�X�N�ςݒ��ߌ�DMP�t�@�C�����Ȃ�" 
          NO_FLG="SIMEGO_NO"
          break
        fi

        ls ${DATE_DIR} | grep -w "${COMPANY_RECORD}_itk_m.exp.gz" > /dev/null
        RE_STATUS=$?
        test ${RE_STATUS} -eq 0 \
         || echo "${DATE_DIR}	${COMPANY_RECORD}	2"
        
     done<"${ITK_CODE_FILE}"
     
     if [ "${NO_FLG}" != "SIMEGO_NO" ];then
      #---���ߌ�ITK(�Ɩ�����)
       ls ${DATE_DIR} | grep -w "1000_itk_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1000	2"
      
      #---���ߌ�JTK
       ls ${DATE_DIR} | grep -w "2001_jtk_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2001	2"
      
      #---���ߌ�JTK(�Ɩ�����)
       ls ${DATE_DIR} | grep -w "2000_jtk_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	2000	2"
      
      #---���ߌ�NAM
       ls ${DATE_DIR} | grep -w "1001_nam_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	1001	2"
      
      #---���ߌ�NAM(�Ɩ�����)
       ls ${DATE_DIR} | grep -w "1000_nam_m.exp.gz" > /dev/null
       RE_STATUS=$?
       test ${RE_STATUS} -eq 0 \
        || echo "${DATE_DIR}	10001	2"
     fi
  fi
}

######################################################################
##      Main ����                                                   ##
######################################################################
echo "--------------------------------------------------------------------------"
echo "�����}�X�N���ׂ�DMP�t�@�C���̑��݃`�F�b�N�J�n(`date`)��"
echo "--------------------------------------------------------------------------"
case "${TARGET_PATH}" in
"1")
   TARGET_PATH="/ext/YDC_DMP/MASKDB"
;;
esac

#---TARGET�p�X���݃`�F�b�N
if [ ! -e "${TARGET_PATH}" ];then
   echo "�w�肵���p�X[${TARGET_PATH}]�����݂��Ȃ��̂ŁAEXIT !"
   exit 1
fi

#---TARGET�p�X�`�F���W
cd "${TARGET_PATH}" \
  || (echo "�p�X[${TARGET_PATH}]�`�F���W ERR" \
  && exit 1)
  
case "${TARGET_KBN}" in
"0"|"1")
  DATA_KBN_PATH="ASAITI"
;;
"2")
  DATA_KBN_PATH="SIMEGO"
;;
*)
  echo "����2�̓��� ERR"
  exit 1
;;
esac

echo "�f�[�^�敪�F${DATA_KBN_PATH}"

#---�敪�p�X�Ƀ`�F���W
cd "${DATA_KBN_PATH}" \
  ||  (echo "�p�X[${TARGET_PATH}/${DATA_KBN_PATH}]�`�F���W ERR" \
  &&  exit 1)

case "${TARGET_DATE}" in
"ALL")
  for DATE_DIR_RECORD in `ls -1|sort`
  do
    DATE_MASKED_CHECK ${DATE_DIR_RECORD}
  done
;;
*)
  DATE_MASKED_CHECK ${TARGET_DATE}
;;
esac

echo "--------------------------------------------------------------------------"
echo "�����}�X�N���ׂ�DMP�t�@�C���̑��݃`�F�b�N�I��(`date`)��"
echo "--------------------------------------------------------------------------"

#---����I��
exit 0
