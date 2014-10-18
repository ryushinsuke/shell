#!/bin/sh
#*********************************************************************
#�@�@�v���W�F�N�g�@�@:�ږ�n
#�@�@���W���[�����@�@:exp_YDC_DDL.sh
#�@�@���́@�@�@�@�@�@:�ږ�nDDL���쐬
#�@�@��������
#�@�@ �N���� �@�敪�@���e�@�@�@�@�@�@�@�@�@ ������
#�@�@ -------- ----�@---------------------�@---------
#�@�@ 20100820 �V�K�@�@�@�@�@�@�@�@�@�@�@�@�@GUT
#�@�@ 20130924 �C���@��ՍX���@�@�@�@�@�@�@�@GUT���
#*********************************************************************
#
source ~/.bash_profile
#SYS_KJN=`date '+%Y%m%d'`
SYS_KJN=$1
#--- �����`�F�b�N
if [ $# -ne 1 ] ;then
  echo "Parameter ERR!"
  exit 1
fi

WORK_DIR=$(cd $(dirname $0);pwd)
#��ՍX���̏C���@START
#DMP_PATH=/ext/bkwork/pmo/YDC_DMP_KMN
LOG_FILE=${WORK_DIR}/log/exp_YDC_DDL_${SYS_KJN}.log

#--- �ږ�n�o�b�N�A�b�v���ꗗ�t�@�C����Ǎ���
CONF_FILE=${WORK_DIR}/exp_YDC_KMN.conf
if [ -f ${CONF_FILE} ];then
  . ${CONF_FILE}
else
  echo "�ږ�n�o�b�N�A�b�v���ꗗ ${WORK_DIR}/exp_YDC_KMN.conf ��������܂���B" |tee -a ${LOG_FILE}
  exit 1
fi
#--- �ږ�n�}�X�N�e�[�u���ꗗ�t�@�C���̑��݃`�F�b�N
if [ -f "${WORK_DIR}/KMN_MASK.lst" ];then
#��ՍX���̏C���@END
CONN=`cat $WORK_DIR/KMN_MASK.lst |grep -v '^#' \
|grep 'ORACLE,DB'|awk -F, '{print $3}'`
#��ՍX���̏C���@START
else
  echo "�ږ�n�}�X�N�e�[�u���ꗗ ${WORK_DIR}/KMN_MASK.lst ��������܂���B" |tee -a ${LOG_FILE}
  exit 1
fi

#-- �_�v�t�@�C���i�[�ꏊ�擾�`�F�b�N
if [ -z ${DMP_PATH} ]
then
  echo "�_�v�t�@�C���i�[�ꏊ�擾�ɃG���[���������܂����I"                     | tee -a ${LOG_FILE}
  exit 1
fi
#��ՍX���̏C���@END

#---- �f�B���N�g�����݃`�F�b�N
if [ ! -d ${DMP_PATH}/${SYS_KJN} ];then
   mkdir -p ${DMP_PATH}/${SYS_KJN}
fi
#*********************************************************************
#---- ddl���擾
#*********************************************************************
cat ${WORK_DIR}/KMN_CODE.lst   | while read -r KAIYA_CODE
do
#---- ���[�U�f�B���N�g��
get_ddl_id()
{
  sqlplus -s ${CONN} << SQL_END_D > /dev/null
  set echo off;
  set feedback off;
  set heading off;
  set line 2000;
  set long 200000;
  set pages 2000;
  set longchunksize 600;
  set termout off;
  set trimspool on;
  
  EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE)
  EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',FALSE)
 
  spool  ${DMP_PATH}/${SYS_KJN}/$1_kmn_${KAIYA_CODE}.sql
  select 'DROP TABLE $1_${KAIYA_CODE};' from dual;
  select dbms_metadata.get_ddl('TABLE','$1_${KAIYA_CODE}') from dual;
  select dbms_metadata.get_ddl('INDEX',index_name) from user_indexes where table_name = '$1_${KAIYA_CODE}' and uniqueness = 'NONUNIQUE';
  spool off;
exit SQL.SQLCODE
SQL_END_D
sed 's/PARTITION BY .*/;/g' ${DMP_PATH}/${SYS_KJN}/$1_kmn_${KAIYA_CODE}.sql \
|grep -v 'PARTITION' |sed 's/"OPS$APL[0-9]*".//g' | sed 's/ LOCAL/\//g' > ${DMP_PATH}/${SYS_KJN}/$1_${KAIYA_CODE}_kmn.sql
cp -f ${DMP_PATH}/${SYS_KJN}/$1_${KAIYA_CODE}_kmn.sql ${DMP_PATH}/${SYS_KJN}/$1_kmn_${KAIYA_CODE}.sql
rm -rf ${DMP_PATH}/${SYS_KJN}/$1_${KAIYA_CODE}_kmn.sql
}
get_ddl_id TKUSMS01
get_ddl_id TKUSSK01
get_ddl_id TKUSTH01
get_ddl_id TKUSZT01
done
echo "�ږ�nDDL���𐳏�쐬"
exit 0

