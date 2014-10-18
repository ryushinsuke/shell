#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA207.sh
#�@�@���́@�@�@�@�@:�s�������[�X���m���ʍ쐬
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110105 �V�K                         GUT �I�F
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
rm -f ${LOG_PATH}/B21SMA207_*.log
rm -f ${ERR_LOG_PATH}/B21SMA207_*.err
#---- �O��̈ꎞ�t�@�C�����폜
rm -f ${TMP_PATH}/B21SMA207_*
#---- �J�n���b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh\
 "B21SMA207.sh"\
 "${SVR_KBN}"\
 "1"\
 "I000001"\
 "�s�������[�X���m���ʍ쐬�J�n"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- ����SQL�u�s�������[�X�̉����pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB001_FUSEI_RELEASE_UPDATE.sql ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB001_FUSEI_RELEASE_UPDATE.sql" \
   "11"
  exit 9
fi
#---- ����SQL�u�s�������[�X�̒ǉ��pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB001_FUSEI_RELEASE_INSERT.sql ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "3" \
   "E000003" \
   "${DDL_PATH}/FS_TB001_FUSEI_RELEASE_INSERT.sql" \
   "11"
  exit 9
fi
#---- ����SQL�u�R���y�A���ʍX�V�pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB006_SVR_JOUHOU_UPDATE.sql ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "4" \
   "E000003" \
   "${DDL_PATH}/FS_TB006_SVR_JOUHOU_UPDATE.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  �又��
#***************************************************************
#---- �s�������[�X�̉���
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB001_FUSEI_RELEASE_UPDATE.sql ${SVR_KBN};
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "5" \
   "E000008" \
   "UPDATE�p��SQL���iFS_TB001_FUSEI_RELEASE_UPDATE.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �s�������[�X�̒ǉ�
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB001_FUSEI_RELEASE_INSERT.sql ${SVR_KBN};
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "6" \
   "E000008" \
   "INSERT�p��SQL���iFS_TB001_FUSEI_RELEASE_INSERT.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �R���y�A���ʍX�V
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${DDL_PATH}/FS_TB006_SVR_JOUHOU_UPDATE.sql ${SVR_KBN};
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA207.sh" \
   "${SVR_KBN}"\
   "7" \
   "E000008" \
   "UPDATE�p��SQL���iFS_TB006_SVR_JOUHOU_UPDATE.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#***************************************************************
#  �����I��
#***************************************************************
#---- �I�����b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA207.sh"\
 "${SVR_KBN}"\
 "8"\
 "I000002"\
 "�s�������[�X���m���ʍ쐬�I��"\
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
