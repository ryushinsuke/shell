#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B21SMA200.sh
#�@�@���́@�@�@�@�@:���X�g�t�@�C���]��
#
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110106 �V�K                         GUT �I�F
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
#  ���ϐ���ݒ�
#***************************************************************
#---- �c�[���z�z�f�B���N�g����ݒ�
FSKT_PATH=$(cd $(dirname $0)/..;pwd)
#---- eLIBSYS�T�[�o�[�̃g���K�[�t�@�C���i�[�p�X
#ELIBSYS_TORIGA_PATH=/home/chroot/release/check
ELIBSYS_TORIGA_PATH=/home/apl/test_gut/chroot/release/check
#---- eLIBSYS�T�[�o�[�̃��X�g�t�@�C���i�[�p�X
#ELIBSYS_LIST_PATH=/home/chroot/release/check/${SVR_KBN}
ELIBSYS_LIST_PATH=/home/apl/test_gut/chroot/release/check/${SVR_KBN}
#---- eLIBSYS���ӃT�[�o�[�̃��X�g�t�@�C���i�[�p�X
#INFILE_PATH=/home/senelib/DevmanagerV2/fsrelskenti/infile/${SVR_KBN}
INFILE_PATH=/home/apl/test_gut/senelib/DevmanagerV2/fsrelskenti/infile/${SVR_KBN}
#---- ���O�t�@�C���i�[�p�X��ݒ�
LOG_PATH=${FSKT_PATH}/log/${SVR_KBN}
#---- �ꎞ�t�@�C���i�[�p�X��ݒ�
TMP_PATH=${FSKT_PATH}/tmp/${SVR_KBN}
#---- EXPECT�R�}���h
#EXPECT_CMD=/usr/bin/expect
EXPECT_CMD=expect
#---- �������Ԃ��擾
TIMESTAMP=`date +%Y%m%d%H%M%S`
#---- ���������擾
SHORI_DATE=`date +%Y%m%d`
#---- FTP�ڑ�IP�A�h���X
#FTP_IP=192.178.64.56
FTP_IP=172.107.61.13
#---- FTP�ڑ����[�U�[
#FTP_USER=senelib
FTP_USER=apl
#---- FTP�ڑ��p�X���[�h
#FTP_PASS=senelib
FTP_PASS=aplapl
#***************************************************************
#  �O����
#***************************************************************
#---- �O��̃��O�t�@�C�����폜
rm -f ${LOG_PATH}/B21SMA200_*.log
#---- �O��̈ꎞ�t�@�C�����폜
rm -f ${TMP_PATH}/B21SMA200_*
#---- �J�n���b�Z�[�W�o��
echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "�y<I>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<1>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "�X�e�b�v�J�n�B"                                               >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "���X�g�t�@�C���]���J�n�B"                                     >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
#***************************************************************
#  �又��
#***************************************************************
#---- ���X�g�t�@�C���]��
${EXPECT_CMD} << EOF >> ${LOG_PATH}/B21SMA200_FTP.log 2>&1
set timeout 600
set TERM xterm

spawn sftp ${FTP_USER}@${FTP_IP}

expect "password:"
send "${FTP_PASS}\r"

expect "sftp>"
send "put ${ELIBSYS_LIST_PATH}/* ${INFILE_PATH}\r"

expect "sftp>"
send "cd ${INFILE_PATH}\r"

expect "sftp>"
send "ls -l\r"

expect "sftp>"
send "exit\r"

interact

EOF
if [ "$?" != 0 ]
then
  echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<2>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIX�R�}���h�G���[�B"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "expect�����ُ�B"                                             >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#---- ftp�������O�t�@�C���𗘗p���āA�t�@�C���]�����ʂ��`�F�b�N
TMP_NUM=`cat ${LOG_PATH}/B21SMA200_FTP.log | sed -n '/sftp> ls -l/='`
let START_NUM=${TMP_NUM}+1
TMP_NUM=`cat ${LOG_PATH}/B21SMA200_FTP.log | sed -n '/sftp> exit/='`
let END_NUM=${TMP_NUM}-1
if [ "${START_NUM}" -le "${END_NUM}" ]
then
#---- ftp�������O�t�@�C���𗘗p���āA�t�@�C��ID�ƃt�@�C���T�C�Y�ꗗ���擾���āA�t�@�C���ꗗ�@���쐬
  sed -n ''${START_NUM}','${END_NUM}'p' ${LOG_PATH}/B21SMA200_FTP.log | sed 's/\r//g' \
      | awk '{print $9","$5}' | sort >> ${TMP_PATH}/B21SMA200_TEMP1
  if [ "$?" != 0 ]
  then
    echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<3>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    echo "UNIX�R�}���h�G���[�B"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    echo "awk�����ُ�B"                                                >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
    exit 9
  fi
else
  echo "������������������������������������������������������������"                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<4>�z"                                          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�t�@�C���]���G���[�B"                                                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "eLIBSYS�T�[�o�[��/home/chroot/release/check/${SVR_KBN}�ɁA���X�g�t�@�C�������݂��Ă��܂���B" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#--- eLIBSYS�T�[�o�[�̃��X�g�t�@�C���i�[�p�X�ɂ��A�t�@�C��ID�ƃt�@�C���T�C�Y�ꗗ���擾���āA�t�@�C���ꗗ�A���쐬
ls -l ${ELIBSYS_LIST_PATH} | sed -n '2,$p' | awk '{print $9","$5}' | sort >> ${TMP_PATH}/B21SMA200_TEMP2
if [ "$?" != 0 ]
then
  echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<5>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIX�R�}���h�G���[�B"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "awk�����ُ�B"                                                >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#---- ��L�擾�̃t�@�C���ꗗ�@�ƃt�@�C���ꗗ�A���R���y�A�A�R���y�A���ʃt�@�C�����`�F�b�N
diff ${TMP_PATH}/B21SMA200_TEMP1 ${TMP_PATH}/B21SMA200_TEMP2 >> /dev/null
if [ "$?" != 0 ]
then
  echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<6>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�t�@�C���]���G���[�B"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "���X�g�t�@�C���]�������ُ�B"                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#---- �g���K�[�t�@�C���ƃ��X�g�t�@�C���̍폜
case ${SVR_KBN} in
  RX) DEL_FILE=rx-releasefileinfo.ENDFILE
    ;;
  TX) DEL_FILE=tx-releasefileinfo.ENDFILE
    ;;
  RA) DEL_FILE=ra-releasefileinfo.ENDFILE
    ;;
 KRX) DEL_FILE=rx-keep-releasefileinfo.ENDFILE
    ;;
 KTX) DEL_FILE=tx-keep-releasefileinfo.ENDFILE
    ;;
esac
rm -f ${ELIBSYS_TORIGA_PATH}/${DEL_FILE}
if [ $? != 0 ]
then
  echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<7>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIX�R�}���h�G���[�B"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "rm�����ُ�B"                                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
rm -f ${ELIBSYS_LIST_PATH}/*
if [ $? != 0 ]
then
  echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "�y<E>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<8>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "UNIX�R�}���h�G���[�B"                                         >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  echo "rm�����ُ�B"                                                 >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
  exit 9
fi
#***************************************************************
#  �����I��
#***************************************************************
#---- �I�����b�Z�[�W�o��
echo "������������������������������������������������������������" >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "�y<I>B21SMA200.sh ${SVR_KBN}�F<${TIMESTAMP}>�F<9>�z"          >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "�X�e�b�v�I���B"                                               >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi
echo "���X�g�t�@�C���]���I���B"                                     >> ${LOG_PATH}/B21SMA200_${SHORI_DATE}.log
if [ "$?" != 0 ]
then
  exit 9
fi

exit 0
