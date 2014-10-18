#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA201.sh
#�@�@���́@�@�@�@�@:�{�Ԕz�z�v���W���[���ꗗ�쐬
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110105 �V�K                         GUT ���o�J
#***************************************************************
#***************************************************************
#  �T�[�o�[�敪�̐ݒ�
#***************************************************************
SVR_KBN=CMN
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
rm -f ${LOG_PATH}/B21SMA201_*.log
#---- �O���ORACLE���O���폜
rm -f ${FSKT_PATH}/log/RX/SQL.log
rm -f ${FSKT_PATH}/log/TX/SQL.log
rm -f ${FSKT_PATH}/log/RA/SQL.log
rm -f ${FSKT_PATH}/log/KRX/SQL.log
rm -f ${FSKT_PATH}/log/KTX/SQL.log
rm -f ${FSKT_PATH}/log/CMN/SQL.log
#---- �O��̃G���[���O�t�@�C�����폜
rm -f ${ERR_LOG_PATH}/B21SMA201_*.err
#---- �O��̈ꎞ�t�@�C�����폜
rm -f ${OUTFILE_PATH}/B21SMA201_*
rm -f ${TMP_PATH}/B21SMA201_*
#---- �J�n���b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA201.sh" \
 "${SVR_KBN}" \
 "1" \
 "I000001" \
 "�{�Ԕz�z�v���W���[���ꗗ�쐬�J�n" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- ����SQL�u�ŐV���m�t���O�������pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB006_SVR_JOUHOU_INIT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB006_SVR_JOUHOU_INIT.sql" \
   "11"
  exit 9
fi
#---- ����SQL�u�{�Ԕz�z�v���W���[���ꗗ�쐬�pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_ELIB_DATA_SELECT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "3" \
   "E000003" \
   "${DDL_PATH}/FS_ELIB_DATA_SELECT.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  �又��
#***************************************************************
#---- �{�Ԕz�z�v���W���[���ꗗ�f�[�^���擾
${MYSQL_CMD} -h ${MYSQL_IP} -u ${MYSQL_USR} -p${MYSQL_PWD} -D ${MYSQL_SCA} < ${DDL_PATH}/FS_ELIB_DATA_SELECT.sql \
    > ${TMP_PATH}/B21SMA201_TEMP 2>&1
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}"\
   "4" \
   "E000009" \
   "SELECT�p��SQL���iFS_ELIB_DATA_SELECT.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �u�{�Ԕz�z�v���W���[���ꗗ�v�t�@�C�����t�H�[�}�b�g
sed 's/\t/","/g' ${TMP_PATH}/B21SMA201_TEMP | sed -n '2,$p' | awk '{print "\""$0"\""}' > ${OUTFILE_PATH}/B21SMA201_OUTFILE
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}"\
   "5" \
   "E000006" \
   "awk�����ُ�B" \
   "11"
  exit 9
fi
#---- �{�Ԕz�z�v���W���[���ꗗ���c�a�ɓ���
sh ${SHL_PATH}/B00SCM202.sh \
 "B21SMA201.sh" \
 "${SVR_KBN}" \
 "FS_TB002_MODULE_ELIB" \
 "B21SMA201_OUTFILE"
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "6" \
   "E000011" \
   "�yB00SCM202�z���ԃe�[�u���V�K�쐬�T�u�V�F���ُ�I���B" \
   "11"
  exit 9
fi
#---- �u�{�Ԕz�z�v���W���[���ꗗ�v�e�[�u���̏d���f�[�^���폜
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB002_MODULE_ELIB_DELETE.sql;
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}"\
   "11" \
   "E000008" \
   "DELETE�p��SQL���iFS_TB002_MODULE_ELIB_DELETE.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#----�u�T�[�o�[���ꗗ�v�e�[�u���́u�ŐV���m�t���O�v���ڂ�������
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB006_SVR_JOUHOU_INIT.sql
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "7" \
   "E000008" \
   "UPDATE�p��SQL���iFS_TB006_SVR_JOUHOU_INIT.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �O��̃��X�g�t�@�C�����o�b�N�A�b�v�t�H���_�[�ɃR�s�[
cp -rp ${FSKT_PATH}/infile/* ${FSKT_PATH}/infile_old/
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "8" \
   "E000006" \
   "cp�����ُ�B" \
   "11"
  exit 9
fi
#---- �O��̃��X�g�t�@�C���̍폜
rm -f ${FSKT_PATH}/infile/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/infile/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/infile/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/infile/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/infile/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm�����ُ�(���X�g�t�@�C��)�B" \
   "11"
  exit 9
fi
#---- �O��̃��O�t�@�C���̍폜
rm -f ${FSKT_PATH}/log/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/log/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/log/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/log/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/log/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm�����ُ�(���O�t�@�C��)�B" \
   "11"
  exit 9
fi
#---- �O��̃G���[���O�t�@�C���̍폜
rm -f ${FSKT_PATH}/log_err/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/log_err/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/log_err/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/log_err/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/log_err/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm�����ُ�(�G���[���O�t�@�C��)�B" \
   "11"
  exit 9
fi
#---- �O��̏o�̓t�@�C���̍폜
rm -f ${FSKT_PATH}/outfile/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/outfile/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/outfile/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/outfile/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/outfile/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm�����ُ�(�o�̓t�@�C��)�B" \
   "11"
  exit 9
fi
#---- �O��̈ꎞ�t�@�C���̍폜
rm -f ${FSKT_PATH}/tmp/RX/*
ERR_NO1=$?
rm -f ${FSKT_PATH}/tmp/TX/*
ERR_NO2=$?
rm -f ${FSKT_PATH}/tmp/RA/*
ERR_NO3=$?
rm -f ${FSKT_PATH}/tmp/KRX/*
ERR_NO4=$?
rm -f ${FSKT_PATH}/tmp/KTX/*
ERR_NO5=$?
if [ ${ERR_NO1} != 0 -o ${ERR_NO2} != 0 -o ${ERR_NO3} != 0 -o ${ERR_NO4} != 0 -o ${ERR_NO5} != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA201.sh" \
   "${SVR_KBN}" \
   "10" \
   "E000006" \
   "rm�����ُ�(�ꎞ�t�@�C��)�B" \
   "11"
  exit 9
fi
#***************************************************************
#  �㏈��
#***************************************************************
#---- �I�����b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA201.sh" \
 "${SVR_KBN}" \
 "9" \
 "I000002" \
 "�{�Ԕz�z�v���W���[���ꗗ�쐬�I��" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
