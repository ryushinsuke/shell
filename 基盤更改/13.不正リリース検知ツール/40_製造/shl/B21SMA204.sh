#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA204.sh
#�@�@���́@�@�@�@�@:�z�z�σ��W���[���ꗗ�쐬
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110111 �V�K                         GUT �I�F
#***************************************************************
#***************************************************************
#  �����`�F�b�N
#***************************************************************
#---- ���ϐ��uSJ_PEX_FRAME�v����T�[�o�[�敪���擾����
SVR_KBN=`echo ${SJ_PEX_FRAME} | awk -F\_ '{print $3}'`
if [ "${SVR_KBN}" != "RX" -a "${SVR_KBN}" != "TX" -a "${SVR_KBN}" != "RA" -a "${SVR_KBN}" != "KRX" -a "${SVR_KBN}" != "KTX" ]
then
  echo "�擾���ꂽ�T�[�o�[�敪[${SVR_KBN}]���s���ł��B���ϐ��uSJ_PEX_FRAME�v���m�F���Ă��������B"
  exit 9
fi
if [ "$1" != "NEW" -a "$1" != "OLD" ]
then
  echo "���͈���$1���s���ł��B�����́uNEW�AOLD�v����͂��Ă��������B"
  exit 9
else
  SHORI_KBN=$1
fi
#***************************************************************
#  ���ʊ��ϐ��Ǎ���
#***************************************************************
FSKT_PATH=$(cd $(dirname $0)/../..;pwd)
if [ ! -f ${FSKT_PATH}/src/conf/B21TCG201.def ]
then
  echo "���ʊ��ϐ��ꗗ(${FSKT_PATH}/src/conf/B21TCG201.def)��������܂���B"
  exit 9
fi
. ${FSKT_PATH}/src/conf/B21TCG201.def ${SVR_KBN}
#---- ����$2�ɂ��A�����p�X�ƃe�[�u��ID��ݒ�
if [ "${SHORI_KBN}" == "NEW" ]
then
  SHORI_PATH=${INFILE_PATH}
  TABLE_ID="FS_TB003_MODULE_${SVR_KBN}"
else
  SHORI_PATH=${INFILE_OLD_PATH}
  TABLE_ID="FS_TB007_OLD_MODULE_${SVR_KBN}"
fi
#***************************************************************
#  �O����
#***************************************************************
#---- �O��̃��O�t�@�C�����폜
rm -f ${LOG_PATH}/B21SMA204_${SHORI_KBN}_*.log
rm -f ${ERR_LOG_PATH}/B21SMA204_${SHORI_KBN}_*.err
#---- �O��̈ꎞ�t�@�C�����폜
rm -f ${TMP_PATH}/B21SMA204_${SHORI_KBN}_*
rm -f ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_*
#---- �J�n���b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh\
 "B21SMA204_${SHORI_KBN}.sh"\
 "${SVR_KBN}"\
 "1"\
 "I000001"\
 "�z�z�σ��W���[���ꗗ�쐬�J�n"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- ����SQL�u�����ΏۊO�f�[�^�폜�pSQL���v�t�@�C�����݃`�F�b�N����
if [ "${SHORI_KBN}" == "NEW" ]
then
  if [ ! -f ${DDL_PATH}/FS_TB003-TB004_DELETE.sql ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "2" \
     "E000003" \
     "${DDL_PATH}/FS_TB003-TB004_DELETE.sql" \
     "11"
    exit 9
  fi
fi
#***************************************************************
#  �又��
#***************************************************************
#---- YDC/ODC�z�z�σ��W���[���ꗗ���쐬����
for ITEM in `ls ${SHORI_PATH}`
do
#---- �T�[�o�[ID���擾
  SVR_ID=`echo ${ITEM} | awk -F\. '{print $1}' | awk -F\- '{print $2}'`
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "3" \
     "E000006" \
     "awk�����ُ�B" \
     "11"
    exit 9
  fi
#---- ���[�h�t�@�C�����쐬�u�T�[�o�[�O���[�vID�A�T�[�o�[ID�A�{��GW�z�z��p�X�A�t�@�C��ID�A�^�C���X�^���v�A�T�C�Y�A�`�F�b�N�T���v
  cat ${SHORI_PATH}/${ITEM} | dos2unix | awk -F\\t '{ if($6=="") print "\""$1"\",\"'${SVR_ID}'\",\""$2"\",\""$3"\",\""$4"\",\""$5"\",\" \"" ;\
                                          else print "\""$1"\",\"'${SVR_ID}'\",\""$2"\",\""$3"\",\""$4"\",\""$5"\",\""$6"\""}' \
                               >> ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_OUTFILE
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "4" \
     "E000006" \
     "awk�����ُ�B" \
     "11"
    exit 9
  fi
done
if [ ! -s ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_OUTFILE ]
then
  touch ${OUTFILE_PATH}/B21SMA204_${SHORI_KBN}_OUTFILE
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "8" \
     "E000006" \
     "touch�����ُ�B" \
     "11"
    exit 9
  fi
fi
#---- �uB00SCM202.sh�v���R�[�����āA�e�[�u�����쐬���āA���z�z�σ��W���[���ꗗ�𓱓�����B
sh ${SHL_PATH}/B00SCM202.sh\
 "B21SMA204_${SHORI_KBN}.sh"\
 "${SVR_KBN}"\
 "${TABLE_ID}"\
 "B21SMA204_${SHORI_KBN}_OUTFILE"
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA204_${SHORI_KBN}.sh" \
   "${SVR_KBN}"\
   "5" \
   "E000011" \
   "�yB00SCM202�z���ԃe�[�u���V�K�쐬�T�u�V�F���ُ�I���B" \
   "11"
  exit 9
fi
if [ "${SHORI_KBN}" == "NEW" ]
then
#---- �����ΏۊO�f�[�^���폜����
  ${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
      whenever oserror exit failure
      whenever sqlerror exit failure
      @${DDL_PATH}/FS_TB003-TB004_DELETE.sql ${TABLE_ID} ${SVR_KBN} "HONBAN";
      commit;
      exit SQL.SQLCODE
SQL_END_D
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA204_${SHORI_KBN}.sh" \
     "${SVR_KBN}"\
     "6" \
     "E000008" \
     "DELETE�p��SQL���iFS_TB003-TB004_DELETE.sql�j�����s�ُ�B" \
     "11"
    exit 9
  fi
fi
#***************************************************************
#  �����I��
#***************************************************************
#---- �I�����b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA204_${SHORI_KBN}.sh"\
 "${SVR_KBN}"\
 "7"\
 "I000002"\
 "�z�z�σ��W���[���ꗗ�쐬�I��"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
