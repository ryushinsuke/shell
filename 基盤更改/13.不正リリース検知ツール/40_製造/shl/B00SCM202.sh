#!/bin/sh
#set -x
#***************************************************************
#�@�@�v���W�F�N�g�@:T-STAR�s�������[�X���m�c�[��
#�@�@���W���[�����@:B00SCM202.sh
#�@�@���́@�@�@�@�@:���ԃe�[�u���V�K�쐬
#�@�@�����T�v�@�@�@:�@����3�Ɏw�肳�ꂽ���ԃe�[�u����V�K�쐬����B
#�@�@�@�@�@�@�@�@�@:�A����4�Ɏw�肳�ꂽ���[�h�t�@�C���𓱓�����B
#�@�@�`�q�f�@�@�@�@:1�@�V�F��ID
#�@�@�@�@�@�@�@�@�@:2�@�T�[�o�[�敪
#�@�@�@�@�@�@�@�@�@:3�@�e�[�u��ID
#�@�@�@�@�@�@�@�@�@:4�@���[�h�t�@�C��ID(�ȗ���)
#�@�@��������
#�@�@�N���� �@�敪�@���e                   ������
#�@�@-------- ----�@---------------------�@---------
#�@�@20110104 �V�K                         GUT �I�F
#***************************************************************
#***************************************************************
#  �������`�F�b�N
#***************************************************************
if [ $# != 3 -a $# != 4 ]
then
  echo "���͈������s���ł���B"
  exit 9
else
  SHL_ID=$1
  TMP_SHL_ID=`echo ${SHL_ID} | awk -F\. '{print $1}'`
  SVR_KBN=$2
  TABLE_ID=$3
  SQLLDR_FILE_ID=$4
fi
#***************************************************************
#  �O����
#***************************************************************
#---- ���[�h�t�@�C�����݃`�F�b�N
if [ "${SQLLDR_FILE_ID}" != "" ]
then
  if [ ! -f ${OUTFILE_PATH}/${SQLLDR_FILE_ID} ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "${SHL_ID}(B00SCM202.sh)" \
     "${SVR_KBN}"\
     "1" \
     "E000003" \
     "${OUTFILE_PATH}/${SQLLDR_FILE_ID}" \
     "11"
    exit 9
  fi
fi
#---- �O�񏈗��ō쐬���ꂽ�t�@�C���̍폜
rm -f ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_*
#***************************************************************
#  �又��
#***************************************************************
#---- �����u�e�[�u��ID�v�ɂ��A�����̒��ԃe�[�u�����폜����B
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    drop table ${TABLE_ID};
    commit;
    purge recyclebin;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "2" \
   "E000008" \
   "DROP�p��SQL���idrop table ${TABLE_ID}�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �����u�e�[�u��ID�v�����������Ƃ��āA�e�[�u���u�e�[�u�����ڈꗗ�v����֘A�f�[�^���o���B
echo "spool ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.txt"                              >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
echo "select TBL_ID,TBL_ITEM_ID,TBL_ITEM_DATA_TYPE,TBL_ITEM_NUM,TBL_ITEM_NULL_SEIY,PK_KBN" >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
echo "from KM_TB003_DBITEM where TBL_ID = '${TABLE_ID}' order by TBL_ITEM_NO; "            >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
echo "spool off"                                                                           >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    set echo off
    set feedback off
    set heading off
    set trimspool on
    set colsep ':'
    set linesize 20000
    @${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "3" \
   "E000008" \
   "SELECT�p��SQL���i${TMP_SHL_ID}_${TABLE_ID}_SELECT.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
#---- �t�@�C���̋�s���폜
cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT.txt | awk '{if(NF>0) print}' \
                                                     | perl -pe 's/ //g' > ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT
#---- �֘A�f�[�^�����݂��Ȃ��ꍇ
if [ ! -s ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "5" \
   "E000010" \
   "�e�[�u���uKM_TB003_DBITEM�v�Ƀe�[�u��ID:${TABLE_ID}�̃f�[�^�������݁B" \
   "11"
  exit 9
fi
#---- ��L�Ŏ擾���ꂽ�f�[�^�́u�F�v����؂�Ƃ��āA�e�[�u���쐬�pSQL�t�@�C���ɏo�͂���B
PRIMARY_KEY=`cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT | \
             awk -F\: '{ if($6!="0") print $2}' | perl -pe 's/\n/,/g' | perl -pe 's/,$/\n/g'`
echo "CREATE TABLE ${TABLE_ID} "                                >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
echo "("                                                        >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
if [ "${PRIMARY_KEY}" != "" ]
then
  cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT \
  | awk -F\: '{ if($5=="Y") print $2" "$3"("$4") DEFAULT # # NOT NULL," ;\
                else print $2" "$3"("$4") DEFAULT # #,"}' \
  | perl -pe s/#/\'/g                                           >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
  echo "PRIMARY KEY(${PRIMARY_KEY})"                            >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
else
  END_FLG=`cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT | tail -1 | awk -F\: '{print $2}'`
  cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT \
  | awk -F\: '{ if($5=="Y") print $2" "$3"("$4") DEFAULT # # NOT NULL" ;\
                else print $2" "$3"("$4") DEFAULT # #"}' \
  | awk '{ if($1=="'${END_FLG}'") print $0 ;else print $0","}'\
  | perl -pe s/#/\'/g                                           >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
fi
echo ");"                                                       >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql
#---- �e�[�u���쐬�pSQL�t�@�C���ɂ��A���ԃe�[�u����V�K�쐬����B
${SQLPLUS_CMD} ${ORA_USR}"/"${ORA_PWD}"@"${ORA_SCA} << SQL_END_D >> ${SQL_LOG} 2>&1
    whenever oserror exit failure
    whenever sqlerror exit failure
    @${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql;
    commit;
    exit SQL.SQLCODE
SQL_END_D
if [ "$?" != 0 ]
then
  sh ${SHL_PATH}/B00SCM201.sh \
   "${SHL_ID}(B00SCM202.sh)" \
   "${SVR_KBN}"\
   "6" \
   "E000008" \
   "CREATE�p��SQL���i${TMP_SHL_ID}_${TABLE_ID}_CREATE.sql�j�����s�ُ�B" \
   "11"
  exit 9
fi
if [ "${SQLLDR_FILE_ID}" != "" ]
then
#---- ��L�Ŏ擾���ꂽ�f�[�^�ɂ��A�b�s�k�t�@�C�����쐬����B
  DB_KEY=`cat ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SELECT | awk -F\: '{print $2}' | perl -pe 's/\n/,/g' | perl -pe 's/,$/\n/g'`
  echo "LOAD DATA"                                                     >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "TRUNCATE"                                                      >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "PRESERVE BLANKS"                                               >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "INTO TABLE ${TABLE_ID} "                                       >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "FIELDS TERMINATED BY "'","'" OPTIONALLY ENCLOSED BY '\"'"      >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
  echo "(${DB_KEY})"                                                   >> ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl
#---- �f�[�^�t�@�C���̓���
  cp ${OUTFILE_PATH}/${SQLLDR_FILE_ID} ${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat
  ${SQLLDR_CMD} ${ORA_USR}/${ORA_PWD}@${ORA_SCA} \
       control=${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.ctl \
       log=${LOG_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.log \
       data=${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat > /dev/null 2>&1
  if [ "$?" == 0 ]
  then
    sh ${SHL_PATH}/B00SCM201.sh \
     "${SHL_ID}(B00SCM202.sh)"\
     "${SVR_KBN}"\
     "7"\
     "I000004"\
     "${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat"\
     "10"
  else
    sh ${SHL_PATH}/B00SCM201.sh \
     "${SHL_ID}(B00SCM202.sh)"\
     "${SVR_KBN}"\
     "8"\
     "E000005"\
     "${TMP_PATH}/${TMP_SHL_ID}_${TABLE_ID}_SQLLDR.dat"\
     "11"
    exit 9
  fi
fi

exit 0
