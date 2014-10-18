#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA205.sh
#�@�@���́@�@�@�@�@:����s�������[�X�ꗗ�쐬
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110110 �V�K                         GUT ���ʔ�
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
#---- �O��̈ꎞ�t�@�C���A���O�t�@�C�����폜
rm -f ${TMP_PATH}/B21SMA205_*
rm -f ${LOG_PATH}/B21SMA205_*
rm -f ${ERR_LOG_PATH}/B21SMA205_*.err
#---- �J�n���b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA205.sh" \
 "${SVR_KBN}" \
 "1" \
 "I000001" \
 "����s�������[�X�ꗗ�쐬�J�n" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
#---- ����SQL�u����s�������[�X�ꗗ�쐬�pSQL���v�t�@�C�����݃`�F�b�N����
if [ ! -f ${DDL_PATH}/FS_TB005_NEW_FUSEI_INSERT.sql ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA205.sh" \
   "${SVR_KBN}" \
   "2" \
   "E000003" \
   "${DDL_PATH}/FS_TB005_NEW_FUSEI_INSERT.sql" \
   "11"
  exit 9
fi
#***************************************************************
#  �又��
#***************************************************************
#---- �e�[�u����V�K�쐬
sh ${SHL_PATH}/B00SCM202.sh \
  "B21SMA205.sh" \
  "${SVR_KBN}" \
  "FS_TB005_NEW_FUSEI_${SVR_KBN}" \
  ""
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA205.sh" \
   "${SVR_KBN}"\
   "3" \
   "E000011" \
   "�yB00SCM202�z���ԃe�[�u���V�K�쐬�T�u�V�F���ُ�I���B" \
   "11"
  exit 9
fi
#---- ����s�������[�X�ꗗ�̍쐬
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
     whenever oserror exit failure
     whenever sqlerror exit failure
     @${DDL_PATH}/FS_TB005_NEW_FUSEI_INSERT.sql ${SVR_KBN}
     commit;
     exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then 
  sh ${SHL_PATH}/B00SCM201.sh \
   "B21SMA205.sh" \
   "${SVR_KBN}" \
   "4" \
   "E000008" \
   "INSERT�p��SQL���iFS_TB005_NEW_FUSEI_INSERT.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#***************************************************************
#  �㏈��
#***************************************************************
#---- �I�����b�Z�[�W�o��
sh ${SHL_PATH}/B00SCM201.sh \
 "B21SMA205.sh" \
 "${SVR_KBN}" \
 "5" \
 "I000002" \
 "����s�������[�X�ꗗ�쐬�I��" \
 "10"
if [ "$?" != 0 ]
then
  exit 9
fi
exit 0
