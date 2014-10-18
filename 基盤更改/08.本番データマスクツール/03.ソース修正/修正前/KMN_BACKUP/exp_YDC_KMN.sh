#!/bin/sh
#set -x
#*********************************************************************
#�@�@�v���W�F�N�g�@�@:�f�[�^�o�b�N�A�b�v
#�@�@���W���[�����@�@:exp_YDC_KMN.sh
#�@�@���́@�@�@�@�@�@:�ږ�n���[�U�ʃo�b�N�A�b�v
#�@�@#���͈��� �@�@�@ :
#�@�@��������
#�@�@ �N���� �@�敪�@���e�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@ ������
#�@�@ -------- ----�@--------------------------------�@---------
#�@�@ 20100706 �V�K�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@GUT
#�@�@ 20131021 �C���@�ۑ����Ԃ̕ύX�i5���с�3���сj�@�@�@GUT���y
#*********************************************************************
source ~/.bash_profile
SYS_KJN=`date '+%Y%m%d'`
HOME_PATH=$(cd $(dirname $0);pwd)
LOG_FILE=$HOME_PATH/log/exp_YDC_KMN_${SYS_KJN}.log
DMP_PATH=/ext/bkwork/pmo/YDC_DMP_KMN
#
echo "**********   �O�����J�n"                                        |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:1  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- ���������f
#if [ $# -ne 1 ];then
#echo "**********   �������s��  "                                    |tee -a $LOG_FILE
#echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
#echo "**********   POS:2  "                                           |tee -a $LOG_FILE
#exit 9
#fi
KIDO_KBN_GET=$1
echo "**********   ���̓t�`�F�b�N "                                   |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:3  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- ��ЃR�[�h�ꗗ
if [ ! -f $HOME_PATH/KMN_CODE.lst ];then
echo "**********   $HOME_PATH/KMN_CODE.lst���݂��Ȃ�"                 |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:4  "                                           |tee -a $LOG_FILE
exit 9
fi
#---- �}�X�N�Ώۈꗗ
if [ ! -f $HOME_PATH/KMN_MASK.lst ];then
echo "**********   $HOME_PATH/KMN_MASK.lst���݂��Ȃ�"                 |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:5  "                                           |tee -a $LOG_FILE
exit 9
fi
ORACLE_CNN=`cat $HOME_PATH/KMN_MASK.lst |grep -v '^#' \
|grep 'ORACLE,DB'|awk -F, '{print $3}'`
#
rm -rf $HOME_PATH/log/*.*
#
echo "**********   �又���J�n "                                       |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:6  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#*********************************************************************
#            �f�[�^�N���A
#*********************************************************************
DIR_CLEAR()
{
echo "**********   �f�[�^�N���A   "                                   |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:7  "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE

#---- �ۑ����Ԃ̕ύX�i5���с�3���сj2013/10/21 START------------------
#---- �ږ�n5���ёO�N���A
#---- �y�j���N��
#BEFOR_WEEK=`date --date '35 days ago' '+%Y%m%d'`
#---- ���j���N��
#AFTER_WEEK=`date --date '34 days ago' '+%Y%m%d'`
#cd $DMP_PATH
#if [ -e "${DMP_PATH}/${BEFOR_WEEK}" ]; then
#echo "**********   $DMP_PATH/$BEFOR_WEEK �폜"                        |tee -a $LOG_FILE
#echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
#echo "**********   POS:8  "                                           |tee -a $LOG_FILE
#echo ""                                                               |tee -a $LOG_FILE
#rm -rf $BEFOR_WEEK
#fi
#if [ -e "${DMP_PATH}/${AFTER_WEEK}" ]; then
#echo "**********   $DMP_PATH/$BEFOR_WEEK �폜 "                       |tee -a $LOG_FILE
#echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
#echo "**********   POS:9  "                                           |tee -a $LOG_FILE
#echo ""                                                               |tee -a $LOG_FILE
#rm -rf $AFTER_WEEK
#fi

COUNT=0
cd ${DMP_PATH}
ls -drl 20?????? | awk '{print $9}' > $HOME_PATH/log/filelist.txt
while read del_record
do
  if [ -f ${DMP_PATH}/${del_record}/SUCCESS.END ]; then
    let COUNT=COUNT+1
    if [ ${COUNT} -gt 3 ]; then
      echo "**********   $DMP_PATH/${del_record} �폜"                |tee -a $LOG_FILE
      rm -rf ${del_record}
    fi
  else
    if [ ${COUNT} -ge 3 ]; then
      echo "**********   $DMP_PATH/${del_record} �폜"                |tee -a $LOG_FILE
      rm -rf ${del_record}
    fi
  fi
done <"$HOME_PATH/log/filelist.txt"

rm -f "$HOME_PATH/log/filelist.txt"
#---- �ۑ����Ԃ̕ύX�i5���с�3���сj2013/10/21 END -------------------
}
#*********************************************************************
#            ��ЃR�[�h���(���)�t�@�C���o��
#*********************************************************************
MAIN_SYORI()
{
echo "**********   ��ЃR�[�h�֘A����  "                              |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:10 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#
cat ${CODE_FILE}  | while read -r KAIYA_CODE
do
  #---- ��ƑΏۃ`�F�b�N
  CODE_NF=`echo ${KAIYA_CODE}|tr -d "\r\n\n"`
  if [ `cat ${HOME_PATH}/KMN_CODE_EX.lst | grep "${KAIYA_CODE}" | wc -l` == "0"  -a \
     "${CODE_NF}" != "" ]; then
        #��Њ֘A����
        LOG_KBN="���"
        M_NM_KBN=`echo "%"${KAIYA_CODE}|tr -d "\r\n\n"`
        #---- ��Ѓ}�X�N
        KAIYA_MASK_SYORI
        #---- ��Ѓ}�X�N�ΏۊO
        KAIYA_SYORI_OTHER
  fi
done
}
#*********************************************************************
#            ��ЃR�[�h�}�X�N �G�N�X�|�[�g����
#*********************************************************************
KAIYA_MASK_SYORI()
{
GREP_KEY="MASK,KAIYA"
GREP_CODE=`echo "_"${KAIYA_CODE}|tr -d "\r\n\n"`
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_1"|tr -d "\r\n\n"`
#---- ��Ѓ}�X�N�֘A���X�g�o��
KINO_LIST
#
#---- ��Ѓ}�X�N�f�[�^�􂢏o��
KAIYA_M_TBL=${MASK_TBLM}
KAIYA_N_TBL=${MASK_TBLN}
M_TB_KBN=${KAIYA_M_TBL}
EXP_TBS=${M_TB_KBN}
EXP_DATA
}
#*********************************************************************
#            ��ЃR�[�h�}�X�N�ΏۊO �G�N�X�|�[�g����
#*********************************************************************
KAIYA_SYORI_OTHER()
{
#---- �u��T�C�Y�v
GREP_KEY="BIG,KAIYA"
GREP_CODE=`echo "_"${KAIYA_CODE}|tr -d "\r\n\n"`
#---- ��Ѓ}�X�N�ΏۊO�u��T�C�Y�v�֘A���X�g�o��
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_2"|tr -d "\r\n\n"`
KINO_LIST
#
for B_TBL in `cat $HOME_PATH/log/${MASK_KBN}.txt`
do
  B_NM=`echo "${B_TBL}"|tr -d "\r\n\n"|awk -F_ '{print $1}'|sed -e 's/,$//g'|tr -d "'"`
  EXP_TBS=`echo "${B_TBL}"|tr -d "\r\n\n"|sed -e 's/,$//g'|tr -d "'"`
  MASK_KBN=`echo ${KAIYA_CODE}"_kmn_"${B_NM}|tr -d "\r\n\n"`
  EXP_DATA
done
rm -rf $HOME_PATH/log/${MASK_KBN}.txt
#---- ��Ѓ}�X�N�ΏۊO
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_2"|tr -d "\r\n\n"`
KAIYA_N_TBLB=${MASK_TBLN}
M_TB_KBN=${KAIYA_N_TBL}","${KAIYA_N_TBLB}
DB_WHERE=" where table_name like '${M_NM_KBN}' \
           and table_name NOT IN (${M_TB_KBN})"
MAST_N_LIST_GET
EXP_TBS=${NO_MASK_LIST}
EXP_DATA
}
#*********************************************************************
#            ���ʃ}�X�N   �G�N�X�|�[�g����
#*********************************************************************
KYOTU_MASK_SYORI()
{
KAIYA_CODE="1000"
LOG_KBN="����(�Ɩ�����)"
GREP_KEY="MASK,KYOTU"
GREP_CODE=""
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_1"|tr -d "\r\n\n"`
KINO_LIST
#---- ���ʃ}�X�N�Ώ�
KYOT_M_TBL=${MASK_TBLM}
KYOT_N_TBL=${MASK_TBLN}
M_TB_KBN=${KYOT_M_TBL}
EXP_TBS=${M_TB_KBN}
EXP_DATA
}
#*********************************************************************
#            ���ʃ}�X�N�ΏۊO   �G�N�X�|�[�g����
#*********************************************************************
KYOTU_SYORI_OTHER()
{
#---- ���ʃ}�X�N�ΏۊO
M_TB_KBN=${KYOT_N_TBL}
DB_WHERE=" where (substr(table_name,length(table_name)-4,1) <> '_') \
           and table_name NOT IN (${M_TB_KBN})"
MASK_KBN=`echo ${KAIYA_CODE}"_kmn_2"|tr -d "\r\n\n"`
MAST_N_LIST_GET
EXP_TBS="${NO_MASK_LIST}"
EXP_DATA
}
#*********************************************************************
#            ���X�g�ꗗ�o��
#*********************************************************************
#---- ���X�g�Ώے��o
KINO_LIST()
{
echo "**********   ���X�g�ꗗ�o�͏���  "                              |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:11 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- ���X�g�t�@�C���쐬
MASK_TBLN=""
MASK_TBLY=""
for TBL_CODE in `grep "${GREP_KEY}" ${HOME_PATH}/KMN_MASK.lst |grep -v '^#'|awk -F, '{print $3}'`
do
  echo "'"${TBL_CODE}${GREP_CODE}"'," >> $HOME_PATH/log/${MASK_KBN}.txt
done
#
MASK_TBLN=`cat $HOME_PATH/log/${MASK_KBN}.txt |tr -d "\r\n\n"|sed -e 's/,$//g'`
MASK_TBLM=`echo ${MASK_TBLN}|tr -d "'"`
}

#*********************************************************************
#            �}�X�N�ΏۊO�ꗗ�o��
#*********************************************************************
MAST_N_LIST_GET()
{
echo "**********   �}�X�N�ΏۊO�ꗗ�o�͏��� "                         |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:12 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#
echo "SPOOL $HOME_PATH/log/${MASK_KBN}.lst"          >> $HOME_PATH/log/${MASK_KBN}.sql
echo "select table_name||','  from user_all_tables " >> $HOME_PATH/log/${MASK_KBN}.sql
echo " ${DB_WHERE} order by 1;"                      >> $HOME_PATH/log/${MASK_KBN}.sql
echo "SPOOL OFF"                                     >> $HOME_PATH/log/${MASK_KBN}.sql
#
sqlplus -S  ${ORACLE_CNN}   << SQL_END_D > /dev/null
         set echo off
         set feedback off
         set heading off
         set trimspool on
         @$HOME_PATH/log/${MASK_KBN}.sql
quit
SQL_END_D
VALUE="$?"
if [ "$VALUE" != 0 ];then
echo "**********   SQL������ُ� "                                    |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:13 "                                           |tee -a $LOG_FILE
exit 9
fi
#
if [ ! -s $HOME_PATH/log/${MASK_KBN}.lst ];then
echo "**********   $HOME_PATH/log/${MASK_KBN}.lst ���݂��܂���"       |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:14 "                                           |tee -a $LOG_FILE
exit 9
else
NO_MASK_LIST=`cat $HOME_PATH/log/${MASK_KBN}.lst | tr -d "\r\n\n" \
|awk '{$0=gensub(/,$/,"","g");print}'`
fi
}
#*********************************************************************
#           ���̂�   �G�N�X�|�[�g����
#*********************************************************************
EXP_DATA()
{
echo "**********"  ${LOG_KBN}"�G�N�X�|�[�g�J�n    "                   |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:15 "                                           |tee -a $LOG_FILE
echo ""                                                               |tee -a $LOG_FILE
#---- �_���v�t�@�C���쐬
if [ "${EXP_TBS}" == "" ];then
echo "**********   �G�N�X�|�[�g�ΏۂȂ�"                              |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:16 "                                           |tee -a $LOG_FILE
exit 9
fi
#
exp ${ORACLE_CNN} tables=(${EXP_TBS}) file=${DB_FILE}/${MASK_KBN}.exp \
log=${DB_FILE}/${MASK_KBN}.log direct=y
#if [ "$?" != 0 ];then
#exit 9
#else
#DD_ORA_CHECK=`grep 'EXP-' ${DB_FILE}/${MASK_KBN}.log|wc -l`
#   if [ ${DD_ORA_CHECK} != 0 ]; then
#      grep 'EXP-' ${DB_FILE}/${MASK_KBN}.log|tee -a $LOG_FILE
#      rm -rf ${DB_FILE}/*.*
#      exit 9
#   fi
#fi
gzip -f ${DB_FILE}/${MASK_KBN}.exp
echo "${EXP_TBS}" |awk '{$0=gensub(/,/,"\r\n","g");print}' \
>> ${DB_FILE}/${MASK_KBN}.lst
}

#*********************************************************************
#            ��ЃR�[�h���t�@�C���o��
#*********************************************************************
#if [ "${KIDO_KBN_GET}" == "Y" ];then
#---- �����莞�N���u��Ёv
if [ "${KIDO_KBN_GET}" != "" ];then
SYS_KJN=${KIDO_KBN_GET}
DB_FILE=${DMP_PATH}"/CURRENT"
CODE_PATH=${DB_FILE}"/PARAM"
CODE_FILE=${CODE_PATH}"/"${SYS_KJN}
#---- �f�B���N�g�����݃`�F�b�N
if [ ! -d  ${CODE_PATH} ];then
  mkdir -p ${CODE_PATH}
fi
#---- ���̓`�F�b�N
if [ ! -f ${CODE_FILE} ];then
echo "**********    ${CODE_FILE}�͑��݂��Ȃ�"                     |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                              |tee -a $LOG_FILE
echo "**********   POS:17 "                                       |tee -a $LOG_FILE
exit 9
fi
#rm -rf ${DB_FILE}/*.*
rm -f $DB_FILE/exp_YDC_CURRENT.END
MAIN_SYORI
KYOTU_MASK_SYORI
KYOTU_SYORI_OTHER
echo "${SYS_KJN}" >$DB_FILE/exp_YDC_CURRENT.END
else
    #---- �y�j���莞�N��
    #---- �f�B���N�g�����݃`�F�b�N
    if [ ! -d ${DMP_PATH}/${SYS_KJN} ];then
       mkdir -p ${DMP_PATH}/${SYS_KJN}
    fi
    #---- �o�̓N���A
    rm -rf ${DMP_PATH}"/"${SYS_KJN}/*.lst
    rm -f $DMP_PATH/exp_YDC_KOMON.END
    DB_FILE=${DMP_PATH}"/"${SYS_KJN}
    CODE_FILE=${HOME_PATH}"/KMN_CODE.lst"
#    DIR_CLEAR
    MAIN_SYORI
    KYOTU_MASK_SYORI
    KYOTU_SYORI_OTHER

    #---- �S�̓��ʃe�[�u����DDL���쐬
    sh ${HOME_PATH}/exp_YDC_DDL.sh "${SYS_KJN}"

    echo ""  |tee -a $LOG_FILE
    echo "`ll $DMP_PATH/${SYS_KJN}`"  |tee -a $LOG_FILE
    cd $DMP_PATH
    ls -dtr 20?????? > exp_YDC_KOMON.END
    touch ${SYS_KJN}/SUCCESS.END
    DIR_CLEAR
fi
#*********************************************************************
#            ���ԃt�@�C���N���A
#*********************************************************************
rm -rf ${HOME_PATH}/*.txt
rm -rf ${HOME_PATH}/*.sql
#*********************************************************************
#            ����I��
#*********************************************************************
echo "**********����I��"                                             |tee -a $LOG_FILE
echo "**********    "$0" �i`date`�j"                                  |tee -a $LOG_FILE
echo "**********   POS:18 "                                           |tee -a $LOG_FILE
exit 0
