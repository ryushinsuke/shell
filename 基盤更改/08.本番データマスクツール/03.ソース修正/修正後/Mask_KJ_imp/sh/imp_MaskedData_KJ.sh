#!/bin/sh
source ~/.bash_profile
# ========================================================================
# �V�X�e���h�c  �F imp_MaskedData_KJ.sh
# �V�X�e������  �F ��n�}�X�N�ς݃f�[�^�C���|�[�g����
# �����T�v      �F ��n�}�X�N�ς݃f�[�^�C���|�[�g����
# ���͈���      �F �Ȃ�
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20130913 �V�K GUT���  �V�K�쐬
# ========================================================================

#�ϐ�������
HOME_PATH="$(cd $(dirname $0);pwd)/.."
CONF_PATH="${HOME_PATH}/conf"
LOG_PATH="${HOME_PATH}/log"
PARAM_PATH="${HOME_PATH}/param"
TEMP_PATH="${HOME_PATH}/temp"
SQL_PATH="${HOME_PATH}/sql"
SHELL_NAME=`basename $0`

NOW=`date '+%Y%m%d'`

if [ ! -d ${LOG_PATH} ]
then
  mkdir -p ${LOG_PATH}
fi
LOG_FILE="${LOG_PATH}/imp_MaskedData_KJ_${NOW}"

if [ ! -d ${TEMP_PATH} ]
then
  mkdir -p ${TEMP_PATH}
fi
LOCK_FILE="${TEMP_PATH}/imp_MaskedData_KJ.lock"

if [ ! -f ${LOCK_FILE} ]
then
  touch ${LOCK_FILE}
else
  echo "���� ���b�N�t�@�C��(imp_MaskedData_KJ.lock)���݂�����܂��̂ŁA���s�I��!! ����"                | tee -a ${LOG_FILE}
  exit 1
fi

#���t�@�C����Ǎ���
CONF_FILE="${CONF_PATH}/imp_MaskedData_KJ.conf"
if [ -f ${CONF_FILE} ]
then
  . ${CONF_FILE}
else
  #CONF�t�@�C�������݂��Ă��Ȃ��ꍇ�A���b�N�t�@�C���폜
  echo "���t�@�C�����Ȃ��̂ŁAERR!"                                                                  | tee -a ${LOG_FILE}
  rm -f "${LOCK_FILE}"
  exit 1
fi

#�}�X�N�ς݃f�[�^�i�[�ꏊ���݃`�F�b�N
if [ -z ${MASK_DUMP_PATH} ]
then
  echo "�}�X�N�ς݃f�[�^�i�[�ꏊ�擾�ɃG���[���������܂����I"                                          | tee -a ${LOG_FILE}
  exit 1
fi

#��Ɨp�i�[�ꏊ���݃`�F�b�N
if [ -z ${MASK_DUMP_TMP_PATH} ]
then
  echo "��Ɨp�i�[�ꏊ�擾�ɃG���[���������܂����I"                                                    | tee -a ${LOG_FILE}
  exit 1
fi

#DB�ڑ��q(CMN)�擾�`�F�b�N
if [ -z ${CMN_CONN} ]
then
  echo "DB�ڑ��q(CMN)�擾�ɃG���[���������܂����I"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(CMN)�擾�`�F�b�N
if [ -z ${CMN_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(CMN)�擾�ɃG���[���������܂����I"                                                   | tee -a ${LOG_FILE}
  exit 1
fi

#DB�ڑ��q(NAM)�擾�`�F�b�N
if [ -z ${NAM_CONN} ]
then
  echo "DB�ڑ��q(NAM)�擾�ɃG���[���������܂����I"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(NAM�V����)�擾�`�F�b�N
if [ -z ${NAM_SINKYOTU_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(NAM�V����)�擾�ɃG���[���������܂����I"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(NAM�Ɩ�����)�擾�`�F�b�N
if [ -z ${NAM_KYOTU_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(NAM�Ɩ�����)�擾�ɃG���[���������܂����I"                                           | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(NAM��Е�)�擾�`�F�b�N
if [ -z ${NAM_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(NAM��Е�)�擾�ɃG���[���������܂����I"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#DB�ڑ��q(ITK)�擾�`�F�b�N
if [ -z ${ITK_CONN} ]
then
  echo "DB�ڑ��q(ITK)�擾�ɃG���[���������܂����I"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(ITK�V����)�擾�`�F�b�N
if [ -z ${ITK_SINKYOTU_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(ITK�V����)�擾�ɃG���[���������܂����I"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(ITK�Ɩ�����)�擾�`�F�b�N
if [ -z ${ITK_KYOTU_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(ITK�Ɩ�����)�擾�ɃG���[���������܂����I"                                           | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(ITK��Е�)�擾�`�F�b�N
if [ -z ${ITK_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(ITK��Е�)�擾�ɃG���[���������܂����I"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#DB�ڑ��q(JTK)�擾�`�F�b�N
if [ -z ${JTK_CONN} ]
then
  echo "DB�ڑ��q(JTK)�擾�ɃG���[���������܂����I"                                                     | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(JTK�V����)�擾�`�F�b�N
if [ -z ${JTK_SINKYOTU_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(JTK�V����)�擾�ɃG���[���������܂����I"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(JTK�Ɩ�����)�擾�`�F�b�N
if [ -z ${JTK_KYOTU_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(JTK�Ɩ�����)�擾�ɃG���[���������܂����I"                                           | tee -a ${LOG_FILE}
  exit 1
fi

#��SCHEMA��(JTK��Е�)�擾�`�F�b�N
if [ -z ${JTK_SOUR_SCHEMA} ]
then
  echo "��SCHEMA��(JTK��Е�)�擾�ɃG���[���������܂����I"                                             | tee -a ${LOG_FILE}
  exit 1
fi

#��Ɨp�i�[�ꏊ���݃`�F�b�N
if [ ! -d ${MASK_DUMP_TMP_PATH} ]
then
  mkdir -p ${MASK_DUMP_TMP_PATH}
fi

#�C���|�[�g�p���O�t�@�C���̊i�[�ꏊ���݃`�F�b�N
if [ ! -d ${LOG_PATH}/ASAITI_IMP ]
then
  mkdir -p ${LOG_PATH}/ASAITI_IMP
fi

#######################################################
#    �֐�:UNZIP_ANY_DMP�@�@��DMP�t�@�C��
#######################################################
UNZIP_ANY_DMP()
{
  DUMP_NAME_TMP=$1

  ls ${MASK_DUMP_PATH} | grep "${DUMP_NAME_TMP}.dmp.gz" > /dev/null
  TS_STATUS=$?
  #���k�_�v�t�@�C���̑��݃`�F�b�N
  if [ ${TS_STATUS} -ne 0 ]
  then
    #���k�_�v�t�@�C�������݂��Ă��Ȃ��ꍇ�A���b�N�t�@�C���폜
    echo "�p�X�u${MASK_DUMP_PATH}�v�Ɉ��k�_�v�t�@�C���u${DUMP_NAME_TMP}.dmp.gz�v�����݂��Ȃ��̂ŁAERR" | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi

  cp ${MASK_DUMP_PATH}/${DUMP_NAME_TMP}.dmp.gz  ${MASK_DUMP_TMP_PATH}
  chmod 777 ${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp.gz
  gunzip -f "${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp.gz"
  TS_STATUS=$?
  if [ ${TS_STATUS} -ne 0 ]
  then
    #��DMP�t�@�C���̃`�F�b�N
    echo "���k�_�v�t�@�C���u${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp.gz�v���𓀎��s�ł��̂ŁAERR"    | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi

  #�𓀌�̃_�v�t�@�C���̑��݃`�F�b�N
  if [ ! -f "${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp" ]
  then
    #�𓀌�̃_�v�t�@�C�������݂��Ă��Ȃ��ꍇ�A���b�N�t�@�C���폜
    echo "�_�v�t�@�C��(${MASK_DUMP_TMP_PATH}/${DUMP_NAME_TMP}.dmp)���Ȃ����߁AERR"                     | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi
}

#######################################################
#    �֐�:DROP_ANY_TABLES�@�@�e�[�u���폜�uITK��ЕʈȊO�v
#######################################################
DROP_ANY_TABLES()
{
  TENGUN_KBN=$1
  DB_CONN=$2

  case "${TENGUN_KBN}" in
  "CMN")
     echo "�e�[�u���폜 �J�n �i`date`�j"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_CMN.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP CMN TABLES ERR"                                                                      | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     echo "�e�[�u���폜 ���� �i`date`�j"                                                               | tee -a ${LOG_FILE}
  ;;
  "NAM")
     #NAM�V���ʂ̏ꍇ
     echo "�e�[�u���폜 �J�n �i`date`�j"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_NAM.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP NAM_SINKYOTU TABLES ERR"                                                             | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #NAM�Ɩ����ʂ̏ꍇ
     NAM_GYOUMUCMN_DROP="${SQL_PATH}/drop_NAM_GYOUMUCMN.sql"
     echo "spool ${LOG_PATH}/drop_NAM_GYOUMUCMN.log"                                                  >  ${NAM_GYOUMUCMN_DROP}
     echo "set echo on"                                                                               >> ${NAM_GYOUMUCMN_DROP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "TBWF|TBWI|TBWM|TBWS|TBWT|_1\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${NAM_GYOUMUCMN_DROP}
     done
     echo "spool off"                                                                                 >> ${NAM_GYOUMUCMN_DROP}
     echo "exit"                                                                                      >> ${NAM_GYOUMUCMN_DROP}
     sqlplus ${DB_CONN} @${NAM_GYOUMUCMN_DROP}
     TS_STATUS=$?
     rm -f ${NAM_GYOUMUCMN_DROP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP NAM_GYOUMUCMN TABLES ERR"                                                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #NAM��Еʂ̏ꍇ
     NAM_KAISYABETU_DORP="${SQL_PATH}/drop_NAM_KAISYABETU.sql"
     echo "spool ${LOG_PATH}/drop_NAM_KAISYABETU.log"                                                 >  ${NAM_KAISYABETU_DORP}
     echo "set echo on"                                                                               >> ${NAM_KAISYABETU_DORP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "_1001\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${NAM_KAISYABETU_DORP}
     done
     echo "spool off"                                                                                 >> ${NAM_KAISYABETU_DORP}
     echo "exit"                                                                                      >> ${NAM_KAISYABETU_DORP}
     sqlplus ${DB_CONN} @${NAM_KAISYABETU_DORP}
     TS_STATUS=$?
     rm -f ${NAM_KAISYABETU_DORP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP NAM_KAISYABETU TABLES ERR"                                                           | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     echo "�e�[�u���폜 ���� �i`date`�j"                                                               | tee -a ${LOG_FILE}
   ;;
   "JTK")
     #JTK�V���ʂ̏ꍇ
     echo "�e�[�u���폜 �J�n �i`date`�j"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_JTK.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP JTK_SINKYOTU TABLES ERR"                                                             | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #JTK�Ɩ����ʂ̏ꍇ
     JTK_GYOUMUCMN_DROP="${SQL_PATH}/drop_JTK_GYOUMUCMN.sql"
     echo "spool ${LOG_PATH}/drop_JTK_GYOUMUCMN.log"                                                  >  ${JTK_GYOUMUCMN_DROP}
     echo "set echo on"                                                                               >> ${JTK_GYOUMUCMN_DROP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "TBWF|TBWI|TBWM|TBWS|TBWT|_2\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${JTK_GYOUMUCMN_DROP}
     done
     echo "spool off"                                                                                 >> ${JTK_GYOUMUCMN_DROP}
     echo "exit"                                                                                      >> ${JTK_GYOUMUCMN_DROP}
     sqlplus ${DB_CONN} @${JTK_GYOUMUCMN_DROP}
     TS_STATUS=$?
     rm -f ${JTK_GYOUMUCMN_DROP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP JTK_GYOUMUCMN TABLES ERR"                                                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #JTK��Еʂ̏ꍇ
     JTK_KAISYABETU_DORP="${SQL_PATH}/drop_JTK_KAISYABETU.sql"
     echo "spool ${LOG_PATH}/drop_JTK_KAISYABETU.log"                                                 >  ${JTK_KAISYABETU_DORP}
     echo "set echo on"                                                                               >> ${JTK_KAISYABETU_DORP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "_2001\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${JTK_KAISYABETU_DORP}
     done
     echo "spool off"                                                                                 >> ${JTK_KAISYABETU_DORP}
     echo "exit"                                                                                      >> ${JTK_KAISYABETU_DORP}
     sqlplus ${DB_CONN} @${JTK_KAISYABETU_DORP}
     TS_STATUS=$?
     rm -f ${JTK_KAISYABETU_DORP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP JTK_KAISYABETU TABLES ERR"                                                           | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     echo "�e�[�u���폜 ���� �i`date`�j"                                                               | tee -a ${LOG_FILE}
   ;;
   "ITK")
     #ITK�V���ʂ̏ꍇ
     echo "�e�[�u���폜 �J�n �i`date`�j"                                                               | tee -a ${LOG_FILE}
     sqlplus ${DB_CONN} @${SQL_PATH}/drop_ITK.sql
     TS_STATUS=$?
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP ITK_SINKYOTU TABLES ERR"                                                             | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
     #ITK�Ɩ����ʂ̏ꍇ
     ITK_GYOUMUCMN_DROP="${SQL_PATH}/drop_ITK_GYOUMUCMN.sql"
     echo "spool ${LOG_PATH}/drop_ITK_GYOUMUCMN.log"                                                  >  ${ITK_GYOUMUCMN_DROP}
     echo "set echo on"                                                                               >> ${ITK_GYOUMUCMN_DROP}
     cat "${PARAM_PATH}/TBL.lst" | grep -E "TBWF|TBWI|TBWM|TBWS|TBWT|_1\b" | while read TBLNAME
     do
       echo "drop table ${TBLNAME} cascade constraints purge;"                                        >> ${ITK_GYOUMUCMN_DROP}
     done
     echo "spool off"                                                                                 >> ${ITK_GYOUMUCMN_DROP}
     echo "exit"                                                                                      >> ${ITK_GYOUMUCMN_DROP}
     sqlplus ${DB_CONN} @${ITK_GYOUMUCMN_DROP}
     TS_STATUS=$?
     rm -f ${ITK_GYOUMUCMN_DROP}
     if [ ${TS_STATUS} -ne 0 ]
     then
       #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
       echo "DROP ITK_GYOUMUCMN TABLES ERR"                                                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                            | tee -a ${LOG_FILE}
       echo "***************************************************"                                      | tee -a ${LOG_FILE}
       rm -f "${LOCK_FILE}"
       exit 1
     fi
   ;;
  esac
}

#######################################################
#    �֐�:DROP_ITK_TABLES    �e�[�u���폜�uITK��Еʁv
#######################################################
DROP_ITK_TABLES()
{
  KAISYACD=$1
  DB_CONN=$2

  ITK_KAISYABETU_DORP="${SQL_PATH}/drop_ITK_${KAISYACD}.sql"
  echo "spool ${LOG_PATH}/drop_ITK_${KAISYACD}.log"                                                   >  ${ITK_KAISYABETU_DORP}
  echo "set echo on"                                                                                  >> ${ITK_KAISYABETU_DORP}
  cat "${PARAM_PATH}/TBL.lst" | grep "_${KAISYACD}" | while read TBLNAME
  do
    echo "drop table ${TBLNAME} cascade constraints purge;"                                           >> ${ITK_KAISYABETU_DORP}
  done
  echo "spool off"                                                                                    >> ${ITK_KAISYABETU_DORP}
  echo "exit"                                                                                         >> ${ITK_KAISYABETU_DORP}
  sqlplus ${DB_CONN} @${ITK_KAISYABETU_DORP}
  TS_STATUS=$?
  rm -f ${ITK_KAISYABETU_DORP}
  if [ ${TS_STATUS} -ne 0 ]
  then
    #DROP�G���[�̏ꍇ�A���b�N�t�@�C���폜
    echo "DROP ITK_KAISYABETU TABLES ERR"                                                              | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                               | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi
  echo "�e�[�u���폜 ���� �i`date`�j"                                                                  | tee -a ${LOG_FILE}
}

#######################################################
#   �֐�:IMPORT_TO_DB�@�}�X�N�ς݃f�[�^�C���|�[�g����
#######################################################
IMPORT_TO_DB()
{
  DB_CONN=$1
  IMPORT_LOG=$2".log"
  IMPORT_DUMP_NAME=$2".dmp"
  FROM_SCHEMA=$3

  TO_SCHEMA=`echo ${DB_CONN} | awk -F\/ '{print $1}'`
  sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${DB_CONN} ${MASK_DUMP_TMP_PATH}/${IMPORT_DUMP_NAME} ${IMPORT_LOG} "TABLES=${FROM_SCHEMA}.%" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" > ${LOG_PATH}/ASAITI_IMP/${IMPORT_LOG} 2>&1
  TS_STATUS=$?
  if [ ${TS_STATUS} -ne 0 ]
  then
    #IMPORT�G���[�̏ꍇ�A���b�N�t�@�C���폜
    echo "�}�X�N�ς݃f�[�^�u${IMPORT_DUMP_NAME}�vIMPORT ERR"                                           | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    echo "SHL(${SHELL_NAME}) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"                               | tee -a ${LOG_FILE}
    echo "***************************************************"                                         | tee -a ${LOG_FILE}
    rm -f "${LOCK_FILE}"
    exit 1
  fi
}

#######################################################
#    MAIN ����
#######################################################
echo "��-----------------------------------------------------------��"                                 | tee -a ${LOG_FILE}
echo "�� ��n�}�X�N�ς݃f�[�^�C���|�[�g�����J�n(`date`)"                                             | tee -a ${LOG_FILE}
echo "��-----------------------------------------------------------��"                                 | tee -a ${LOG_FILE}

##################### CMN�̏ꍇ #######################
DUMP_FNAME="exp_YDC_CMN_${NOW}_m"
#IMPORT�O�ɁA����DB�e�[�u�����폜����
DROP_ANY_TABLES "CMN" ${CMN_CONN}
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#�_�v�t�@�C����IMPORT
IMPORT_TO_DB ${CMN_CONN} ${DUMP_FNAME} ${CMN_SOUR_SCHEMA}

##################### NAM�̏ꍇ #######################
#NAM�V���ʂ̏ꍇ
DUMP_FNAME="exp_YDC_NAM_SINKYOTU_${NOW}_m"
#IMPORT�O�ɁA����DB�e�[�u�����폜����
DROP_ANY_TABLES "NAM" ${NAM_CONN}
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�V���ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${NAM_CONN} ${DUMP_FNAME} ${NAM_SINKYOTU_SOUR_SCHEMA}

#NAM�Ɩ����ʂ̏ꍇ
DUMP_FNAME="exp_YDC_NAM_${NOW}_1000_m"
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�Ɩ����ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${NAM_CONN} ${DUMP_FNAME} ${NAM_KYOTU_SOUR_SCHEMA}

#NAM��Еʂ̏ꍇ
DUMP_FNAME="exp_YDC_NAM_${NOW}_1001_m"
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�Ɩ����ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${NAM_CONN} ${DUMP_FNAME} ${NAM_SOUR_SCHEMA}

##################### JTK�̏ꍇ #######################
#JTK�V���ʂ̏ꍇ
DUMP_FNAME="exp_YDC_JTK_SINKYOTU_${NOW}_m"
#IMPORT�O�ɁA����DB�e�[�u�����폜����
DROP_ANY_TABLES "JTK" ${JTK_CONN}
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�V���ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${JTK_CONN} ${DUMP_FNAME} ${JTK_SINKYOTU_SOUR_SCHEMA}

#JTK�Ɩ����ʂ̏ꍇ
DUMP_FNAME="exp_YDC_JTK_${NOW}_2000_m"
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�Ɩ����ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${JTK_CONN} ${DUMP_FNAME} ${JTK_KYOTU_SOUR_SCHEMA}

#JTK��Еʂ̏ꍇ
DUMP_FNAME="exp_YDC_JTK_${NOW}_2001_m"
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#JTK�Ɩ����ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${JTK_CONN} ${DUMP_FNAME} ${JTK_SOUR_SCHEMA}

##################### ITK�̏ꍇ #######################
#ITK�V���ʂ̏ꍇ
DUMP_FNAME="exp_YDC_ITK_SINKYOTU_${NOW}_m"
#IMPORT�O�ɁA����DB�e�[�u�����폜����
DROP_ANY_TABLES "ITK" ${ITK_CONN}
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�V���ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${ITK_CONN} ${DUMP_FNAME} ${ITK_SINKYOTU_SOUR_SCHEMA}

#ITK�Ɩ����ʂ̏ꍇ
DUMP_FNAME="exp_YDC_ITK_${NOW}_1000_m"
#�𓀃_�v�t�@�C��
UNZIP_ANY_DMP ${DUMP_FNAME}
#NAM�Ɩ����ʃ_�v�t�@�C����IMPORT
IMPORT_TO_DB ${ITK_CONN} ${DUMP_FNAME} ${ITK_KYOTU_SOUR_SCHEMA}

#ITK��Еʂ̏ꍇ
while read KAISYACD
do
  DUMP_FNAME="exp_YDC_ITK_${NOW}_${KAISYACD}_m"
  #IMPORT�O�ɁA����DB�e�[�u�����폜����
  DROP_ITK_TABLES ${KAISYACD} ${ITK_CONN}
  #�𓀃_�v�t�@�C��
  UNZIP_ANY_DMP ${DUMP_FNAME}
  #NAM�Ɩ����ʃ_�v�t�@�C����IMPORT
  IMPORT_TO_DB ${ITK_CONN} ${DUMP_FNAME} ${ITK_SOUR_SCHEMA}
done < ${PARAM_PATH}/ITK_CODE.lst

#����I��
rm -f "${LOCK_FILE}"
echo "��-----------------------------------------------------------��"                                 | tee -a ${LOG_FILE}
echo "�� ��n�}�X�N�ς݃f�[�^�C���|�[�g���� ����I��(`date`)"                                        | tee -a ${LOG_FILE}
echo "��-----------------------------------------------------------��"                                 | tee -a ${LOG_FILE}
exit 0
