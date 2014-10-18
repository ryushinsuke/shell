#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA203.sh
#�@�@���́@�@�@�@�@:�z�z�v���W���[���ꗗ�쐬
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110107 �V�K                         GUT ���o�J
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
rm -f ${LOG_PATH}/B21SMA203_*.log
#---- �O��̃G���[���O�t�@�C�����폜
rm -f ${ERR_LOG_PATH}/B21SMA203_*.err
#---- �O��̈ꎞ�t�@�C�����폜
rm -f ${OUTFILE_PATH}/B21SMA203_*
rm -f ${TMP_PATH}/B21SMA203_*
#---- �J�n���b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA203.sh" \
 "${SVR_KBN}" \
 "1" \
 "I000001" \
 "�z�z�v���W���[���ꗗ�쐬�J�n" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- ����SQL�u�{�Ԕz�z�v���W���[���ꗗ�f�[�^�W�J�pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB004_MODULE_ELIB_INSERT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB004_MODULE_ELIB_INSERT.sql" \
   "11"
  exit 9
fi
#---- ����SQL�u�����ΏۊO�f�[�^�폜�pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB003-TB004_DELETE.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "3" \
   "E000003" \
   "${DDL_PATH}/FS_TB003-TB004_DELETE.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  �又��
#***************************************************************
#---- �e�[�u����V�K�쐬
sh ${SHL_PATH}/B00SCM202.sh \
  "B21SMA203.sh" \
  "${SVR_KBN}" \
  "FS_TB004_MODULE_ELIB_${SVR_KBN}" \
  ""
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}"\
   "4" \
   "E000011" \
   "�yB00SCM202�z���ԃe�[�u���V�K�쐬�T�u�V�F���ُ�I���B" \
   "11"
  exit 9
fi
#---- �u�{�Ԕz�z�v���W���[���ꗗ�v�̃f�[�^��W�J
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB004_MODULE_ELIB_INSERT.sql ${SVR_KBN}
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "5" \
   "E000008" \
   "INSERT�p��SQL���iFS_TB004_MODULE_ELIB_INSERT.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �u�{�Ԕz�z�v���W���[���ꗗ�v�ΏۊO�̃f�[�^���폜
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB003-TB004_DELETE.sql FS_TB004_MODULE_ELIB_${SVR_KBN} ${SVR_KBN} "eLIBSYS"
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA203.sh" \
   "${SVR_KBN}" \
   "6" \
   "E000008" \
   "DELETE�p��SQL���iFS_TB003-TB004_DELETE.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#***************************************************************
#  �㏈��
#***************************************************************
#---- �I�����b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA203.sh" \
 "${SVR_KBN}" \
 "7" \
 "I000002" \
 "�z�z�v���W���[���ꗗ�쐬�I��" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
