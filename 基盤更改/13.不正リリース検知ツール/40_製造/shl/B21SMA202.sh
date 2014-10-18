#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA202.sh
#�@�@���́@�@�@�@�@:�T�[�o�[���X�V
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20101229 �V�K                         GUT �I�F
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
#***************************************************************
#  �O����
#***************************************************************
#---- �O��̃��O�t�@�C�����폜
rm -f ${LOG_PATH}/B21SMA202_*.log
rm -f ${ERR_LOG_PATH}/B21SMA202_*.err
#---- �O��̈ꎞ�t�@�C�����폜
rm -f ${TMP_PATH}/B21SMA202_*
#---- �J�n���b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh\
 "B21SMA202.sh"\
 "${SVR_KBN}"\
 "1"\
 "I000001"\
 "�T�[�o�[���X�V�J�n"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#***************************************************************
#  �又��
#***************************************************************
#---- �e�[�u���u�T�[�o�[���ꗗ�v�ɂ��A�t�@�C���u�T�[�o�[���ꗗ�v���쐬����B
echo "spool ${TMP_PATH}/B21SMA202_TEMP1.txt" >> ${TMP_PATH}/B21SMA202_TEMP1.sql
echo "select SVR_KBN,SVR_GRP_ID,SVR_ID "     >> ${TMP_PATH}/B21SMA202_TEMP1.sql
echo "from FS_TB006_SVR_JOUHOU; "            >> ${TMP_PATH}/B21SMA202_TEMP1.sql
echo "spool off"                             >> ${TMP_PATH}/B21SMA202_TEMP1.sql
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    set echo off
    set feedback off
    set heading off
    set trimspool on
    set colsep ','
    set linesize 20000
    @${TMP_PATH}/B21SMA202_TEMP1.sql
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA202.sh" \
   "${SVR_KBN}"\
   "2" \
   "E000008" \
   "SELECT�p��SQL���iB21SMA202_TEMP1.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �t�@�C���̋�s���폜
cat ${TMP_PATH}/B21SMA202_TEMP1.txt | awk '{if(NF>0) print}' | perl -pe 's/ *//g' | sort | uniq > ${TMP_PATH}/B21SMA202_TEMP1
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA202.sh" \
   "${SVR_KBN}"\
   "3" \
   "E000006" \
   "awk�����ُ�B" \
   "11"
  exit 9
fi
#---- �X�V�pSQL�t�@�C�����쐬
DB_UPDATE()
{
  cat ${TMP_PATH}/B21SMA202_TEMP1 | grep ''${SVR_KBN}','${SVR_GRP_ID}','${SVR_ID}'' >> /dev/null
  if [ $? == 0 ]
  then
    echo "update FS_TB006_SVR_JOUHOU "                                                                         >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "set OLD_COMPARE_DATE = NEW_COMPARE_DATE, NEW_COMPARE_DATE = '${NEW_COMPARE_DATE}', "                 >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "NEW_COMPARE_FLAG = '1', COMPARE_RESULT = '0' "                                                       >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "where SVR_KBN = '${SVR_KBN}' and SVR_GRP_ID = '${SVR_GRP_ID}' and SVR_ID = '${SVR_ID}'; "            >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "commit;"                                                                                             >> ${TMP_PATH}/B21SMA202_TEMP2.sql
  else
    echo "insert into FS_TB006_SVR_JOUHOU "                                                                    >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "values('${SVR_GRP_ID}','${SVR_ID}','${OS_GRP_ID}',' ','${NEW_COMPARE_DATE}','1','0','${SVR_KBN}');"  >> ${TMP_PATH}/B21SMA202_TEMP2.sql
    echo "commit;"                                                                                             >> ${TMP_PATH}/B21SMA202_TEMP2.sql
  fi
}
for ITEM in `ls ${INFILE_PATH}`
do
#---- �T�[�o�[ID���擾
  SVR_ID=`echo ${ITEM} | awk -F\. '{print $1}' | awk -F\- '{print $2}'`
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA202.sh" \
     "${SVR_KBN}"\
     "4" \
     "E000006" \
     "awk�����ُ�B" \
     "11"
    exit 9
  fi
#---- OS���ނ��擾
  rm -f ${TMP_PATH}/B21SMA202_TEMP2
  cat ${INFILE_PATH}/${ITEM} | dos2unix | awk -F\\t '{print $NF}' | sort | uniq | awk '{if(NF>0) print}' >> ${TMP_PATH}/B21SMA202_TEMP2
  if [ "$?" != 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "B21SMA202.sh" \
     "${SVR_KBN}"\
     "5" \
     "E000006" \
     "awk�����ُ�B" \
     "11"
    exit 9
  fi
  if [ `ls -l ${TMP_PATH}/B21SMA202_TEMP2 | awk '{print $5}'` != 0 ]
  then
    OS_GRP_ID="U"
  else
    OS_GRP_ID="W"
  fi
#---- �ŐV���m�����擾
  NEW_COMPARE_DATE=`date +%Y%m%d`
#---- �T�[�o�[�O���[�vID���擾
  if [ "${SVR_KBN}" == "RX" -o "${SVR_KBN}" == "TX" -o "${SVR_KBN}" == "RA" ]
  then
    SVR_GRP_ID=`echo ${ITEM} | awk -F\- '{print $1}'`
    if [ "$?" != 0 ]
    then
      sh ${SHL_PATH}/B00SCM201.sh \
       "B21SMA202.sh" \
       "${SVR_KBN}"\
       "6" \
       "E000006" \
       "awk�����ُ�B" \
       "11"
      exit 9
    fi
    DB_UPDATE
  else
    cat ${INFILE_PATH}/${ITEM} | awk -F\\t '{print $1}' | sort | uniq | while read RECORD
    do
      SVR_GRP_ID=${RECORD}
      DB_UPDATE
    done
  fi
done
#---- �쐬���ꂽSQL�t�@�C���ɂ��A�e�[�u���u�T�[�o�[���ꗗ�v���X�V����B
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${TMP_PATH}/B21SMA202_TEMP2.sql
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA202.sh" \
   "${SVR_KBN}"\
   "7" \
   "E000008" \
   "UPDATE�p��SQL���iB21SMA202_TEMP2.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#***************************************************************
#  �����I��
#***************************************************************
#---- �I�����b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA202.sh"\
 "${SVR_KBN}"\
 "8"\
 "I000002"\
 "�T�[�o�[���X�V�I��"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
