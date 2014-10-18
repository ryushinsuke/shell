#!/bin/sh
source ~/.bash_profile
# ========================================================================
# �V�X�e���h�c  �F  Past_KJ_MaskByUserID
# �V�X�e������  �F  ��n�ߋ����f�[�^�}�X�N��Еʏ���
# �����T�v      �F  ��n�ߋ����f�[�^�}�X�N��Еʏ���
# ���^�[���R�[�h�F 0�F����I��
#                  1�F�ُ�I��
# ��������
# �N����   �敪 �S����   ���e
# -------- ---- -------- --------------------------------------
# 20100122 �V�K GUT      �V�K�쐬
#
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# �����J�n
#------------------------------------------------------------------------
PBUDBCONN=$1
PBUMASK_DATE=$2
PBUserID=$3
SYORIKBN=$4
PBUMASKHOME="$(cd $(dirname $0);pwd)/.."
. ${PBUMASKHOME}"/conf/Past_KJ_MaskByUserID.conf"

#--- LOG�̃p�X
LOG_PATH="${PBUMASKHOME}/log/Past_KJ_MaskByUserID"
test -e "${LOG_PATH}" \
  || mkdir -p "${LOG_PATH}"
PBULogFile="${LOG_PATH}/Past_KJ_MaskByUserID_${PBUserID}_${SYORIKBN}.log"

#--- HISTORY �t�@�C��
PBUMASKHISTORY=${PBUMASKHOME}/Mask_Histroy.txt
#------------------------------------------------------------------------
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
#------------------------------------------------------------------------
# �X�e�b�v-010  # �p�����[�^���`�F�b�N
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK010
if [ $# -ne 4 ];
then
echo "usage: $1 pbudbconn $2 pbumask_date $3 pbuserid $4 syorikbn" | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
if [ ! ${SYORIKBN} == 1 -a ! ${SYORIKBN} == 2 ];
then
echo "�w�肵�������敪[${SYORIKBN}]�͕s���ł��B[1/2]"         | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-020  # ��Еʒ���f�[�^�}�X�N����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK020
if [ ${SYORIKBN} == 1 ]
then
#if [ ! -e ${PBUASAIN_PATH} ]
#then
#   PBUASAIN_PATH=${PBUASAIN_PATH_PAST}
#   if [ ! -e ${PBUASAIN_PATH} ];then
#      echo "���̓p�X[${PBUASAIN_PATH}]�����݂��܂���"               | tee -a $PBULogFile
#      echo "***************************************************"    >>$PBULogFile
#      echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
#      echo "***************************************************"    >>$PBULogFile
#      TS_RCODE=1
#      exit $TS_RCODE
#   fi
#fi
#------------------------------------------------------------------------
# �X�e�b�v-021  # �Ώ�DUMP�t�@�C����list�쐬
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK021
case ${PBUserID} in
0000)
#CMN�̏ꍇ
DUMP_FNAME=exp_YDC_CMN_${PBUMASK_DATE}
;;
0001)
#NAM�̐V���ʂ̏ꍇ
DUMP_FNAME=exp_YDC_NAM_SINKYOTU_${PBUMASK_DATE}
;;
0002)
#����̐V���ʂ̏ꍇ
DUMP_FNAME=exp_YDC_JTK_SINKYOTU_${PBUMASK_DATE}
;;
0003)
#�ϑ��̐V���ʂ̏ꍇ
DUMP_FNAME=exp_YDC_ITK_SINKYOTU_${PBUMASK_DATE}
;;
1000)
#�ϑ��̋Ɩ����ʂ̏ꍇ
DUMP_FNAME=exp_YDC_ITK_${PBUMASK_DATE}
;;
10001)
#NAM�̋Ɩ����ʂ̏ꍇ
DUMP_FNAME=exp_YDC_NAM_${PBUMASK_DATE}
;;
2000)
#����̋Ɩ����ʂ̏ꍇ
DUMP_FNAME=exp_YDC_JTK_${PBUMASK_DATE}
;;
1001)
#NAM�̉�Еʂ̏ꍇ
DUMP_FNAME=exp_YDC_NAM_${PBUMASK_DATE}
;;
2001)
#����̉�Еʂ̏ꍇ
DUMP_FNAME=exp_YDC_JTK_${PBUMASK_DATE}
;;
*)
#�ϑ��̉�Еʂ̏ꍇ
DUMP_FNAME=exp_YDC_ITK_${PBUMASK_DATE}
;;
esac
#------------------------------------------------------------------------
# �X�e�b�v-022  # INPUT DUMP�t�@�C�����ǂݍ���
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK022
dmp_file="${PBUASAIN_PATH_TMP}/${DUMP_FNAME}.dmp"
if [ ! -f "${dmp_file}" ] && [ ! -f "${dmp_file}.gz" ];then
  #--- PATH�����݂��Ȃ��ꍇ�A�쐬����
  test -e "${PBUASAIN_PATH_TMP}" \
    || mkdir "${PBUASAIN_PATH_TMP}"

  #--- �{��DMP�i�[�̏ꏊ��DMP�̑��݃`�F�b�N
  ls ${PBUASAIN_PATH} | grep "${DUMP_FNAME}.dmp" > /dev/null
  RE_STATUS=$?
  if [ ${RE_STATUS} -eq 0 ] ;then
    cp ${PBUASAIN_PATH}/${DUMP_FNAME}.dmp.* ${PBUASAIN_PATH_TMP}
  else
    #--- �{��DMP�i�[(BAK)�̏ꏊ��DMP�̑��݃`�F�b�N
    ls ${PBUASAIN_PATH_PAST} | grep "${DUMP_FNAME}.dmp" > /dev/null
    RE_STATUS2=$?
    test ${RE_STATUS2} -eq 0 \
      && (cp ${PBUASAIN_PATH_PAST}/${DUMP_FNAME}.dmp.* ${PBUASAIN_PATH_TMP})
  fi
fi

#--- �𓀒���DMP�҂�
SLEEP_COUNT=0
while [ -f "${dmp_file}" -a -f "${dmp_file}.gz" ]
do
  echo "DMP(${dmp_file}.gz)���𓀂���Ă��܂��̂ŁAWAIT"             | tee -a $PBULogFile
  sleep 60
  SLEEP_COUNT=`expr ${SLEEP_COUNT} + 1`
  if [ ${SLEEP_COUNT} -gt 60 ];then
    echo "DMP(${dmp_file}.gz)�𓀎��Ԃ�1���߂��AEXIT"                | tee -a $PBULogFile
    exit 1
  fi
done

#--- DMP�͈��k���ꂽ�ꍇ�A�𓀂���
if [ ! -f "${dmp_file}" -a -f "${dmp_file}.gz" ];then
   gunzip "${dmp_file}.gz"
fi

#--- �҂�
sleep 60

#--- �𓀌��DMP�t�@�C���̑��݃`�F�b�N
if [ ! -f "${dmp_file}" ] ;then
   echo "DUMP�t�@�C��(${dmp_file})���Ȃ����߁AERR"                  | tee -a $PBULogFile
   exit 1
fi

#--- �o�̓p�X�쐬
test -e ${PBUASAOUT_PATH} \
  || mkdir ${PBUASAOUT_PATH}
test -e ${PBUASAOUT_EXT_PATH} \
  || mkdir ${PBUASAOUT_EXT_PATH}

#------------------------------------------------------------------------
# �X�e�b�v-023  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK023
sqlplus ${PBUDBCONN} @${PBUMASKHOME}"/sql/drop_any_tables.sql" ${PBUserID}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DROP ANY TABLES ERR"                                    | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-024  # DUMP�t�@�C����IMPORT����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK024
if [ ! -d "${PBUMASKHOME}/log/ASAITI_WKDB_IMP" ];then
   mkdir -pm 755 "${PBUMASKHOME}/log/ASAITI_WKDB_IMP"
fi
imp_log="${PBUMASKHOME}/log/ASAITI_WKDB_IMP/${DUMP_FNAME}_${PBUserID}_m_imp.log"
case ${PBUserID} in
0000|0001|0002|0003)
   imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(%) commit=y
;;
1000|10001)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
      tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
   else
      echo "�e�[�u�����X�g�t�@�C��(${PBUMASKHOME}/param/TBL.lst)�����݂��܂���I" | tee -a $PBULogFile
      exit 1
   fi
   imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(${tblname_1_lst}) commit=y
;;
2000)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
      tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
   else
      echo "�e�[�u�����X�g�t�@�C��(${PBUMASKHOME}/param/TBL.lst)�����݂��܂���I" | tee -a $PBULogFile
      exit 1
   fi
   imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(${tblname_2_lst}) commit=y
;;
*)
   imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(TB%_${PBUserID},FN%_${PBUserID}) commit=y
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMP�t�@�C��${PBUASAIN_PATH_TMP}/${DUMP_FNAME}.dmp IMPORT ERR" | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-025  # MASK����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK025
sqlplus ${PBUDBCONN} @${PBUMASKHOME}"/sql/Past_KJ_MaskByUserID.sql" ${PBUJHDBUSER} ${PBUserID}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "           MASK ERR"                                    | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-026  # �o��DUMP�t�@�C����EXPORT����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK026
exp_asaiti_dmpfile="" #20100422
exp_asaiti_logfile="" #20100422
case ${PBUserID} in
0000|0001|0002|0003)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_m.log"
   exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(%) direct=y
;;
1000)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.log"
   exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(${tblname_1_lst}) direct=y
;;
2000)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.log"
   exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(${tblname_2_lst}) direct=y
;;
10001)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_1000_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_1000_m.log"
   exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(${tblname_1_lst}) direct=y
;;
*)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.log"
   exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(TB%_${PBUserID},FN%_${PBUserID}) direct=y
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMP�t�@�C���u${DUMP_FNAME}�vEXPORT ERR"                | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-027-1  # ��DUMP��gzip����
#------------------------------------------------------------------------
#--- 2010/08/19 �d�l�ύX�A��Ɨp�R�s�[���ꂽDMP�̈��k����������
##process_cnt=99
##case ${PBUserID} in
##0000|0001|0002|0003)
##   process_cnt=`ps -ef|grep "${PBUMASKHOME}/sh/${PBUshid}.sh "|grep -E " ${PBUMASK_DATE} ${PBUserID} 1\b"|wc -l`
##;;
##1001|10001)
##   process_cnt=`ps -ef|grep "${PBUMASKHOME}/sh/${PBUshid}.sh "|grep -E " ${PBUMASK_DATE} 100[0-1]{1,2} 1\b"|grep -v " ${PBUMASK_DATE} 1000 1"|wc -l`
##;;
##2001|2000)
##   process_cnt=`ps -ef|grep "${PBUMASKHOME}/sh/${PBUshid}.sh "|grep -E " ${PBUMASK_DATE} 200[0-1]{1} 1\b"|wc -l`
##;;
##1*)
##   process_cnt=`ps -ef|grep "${PBUMASKHOME}/sh/${PBUshid}.sh "|grep " ${PBUMASK_DATE} "|awk '{print $12,$13}'|grep -E '^1[0-9]{3} 1\b'|grep -v '1001 1'|wc -l`
##;;
##esac
##if [ ${process_cnt} -le 2 ];then
##   if [ -f "${dmp_file}" ] && [ ! -f "${dmp_file}.gz" ];then
##      echo "�t�@�C���i${dmp_file}�j���k�J�n" | tee -a $PBULogFile
##      gzip "${dmp_file}"
##      echo "�t�@�C���i${dmp_file}�j���k����" | tee -a $PBULogFile
##   fi
##else
##   echo "DMP�t�@�C�����g�p����܂��̂ŁA���k�����X�L�b�v....." | tee -a $PBULogFile
##fi
#------------------------------------------------------------------------
# �X�e�b�v-027  # �o��DUMP��gzip����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK027
gzip -f ${exp_asaiti_dmpfile}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "gzip -f ${PBUASAOUT_PATH}/${DUMP_FNAME} ERR"            | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-027-2  # �o��DUMP�ړ�
#------------------------------------------------------------------------
mv "${exp_asaiti_dmpfile}.gz" ${PBUASAOUT_EXT_PATH}
mv "${exp_asaiti_logfile}" ${PBUASAOUT_EXT_PATH}
#------------------------------------------------------------------------
# �X�e�b�v-023-2  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK0232
sqlplus ${PBUDBCONN} @${PBUMASKHOME}"/sql/drop_any_tables.sql" ${PBUserID}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DROP ANY TABLES ERR"                                    | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
fi
#------------------------------------------------------------------------
# �X�e�b�v-030  # ��Еʒ��ߌ�f�[�^�}�X�N����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK030
if [ ${SYORIKBN} == 2 ]
then
#------------------------------------------------------------------------
# �X�e�b�v-031  # �Ώ�DUMP�t�@�C����list�쐬
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK031
case ${PBUserID} in
1000)
#�ϑ��̋Ɩ����ʂ̏ꍇ
DUMP_FNAME=1000_itk
;;
10001)
#NAM�̋Ɩ����ʂ̏ꍇ
DUMP_FNAME=1000_nam
;;
2000)
#����̋Ɩ����ʂ̏ꍇ
DUMP_FNAME=2000_jtk
;;
1001)
#NAM�̉�Еʂ̏ꍇ
DUMP_FNAME=1001_nam
;;
2001)
#����̉�Еʂ̏ꍇ
DUMP_FNAME=2001_jtk
;;
*)
#�ϑ��̉�Еʂ̏ꍇ
DUMP_FNAME=${PBUserID}_itk
;;
esac
#------------------------------------------------------------------------
# �X�e�b�v-032  # INPUT DUMP�t�@�C�����ǂݍ���
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK032
dmp_file="${PBUSIMEIN_PATH_TMP}/${DUMP_FNAME}.exp"

#--- DMP�t�@�C������
ls ${dmp_file}* > /dev/null
RE_STATUS=$?
if [ ${RE_STATUS} -ne 0 ] ;then
  #--- PATH�����݂��Ȃ��ꍇ�A�쐬����
  test -e "${PBUSIMEIN_PATH_TMP}" \
    || mkdir "${PBUSIMEIN_PATH_TMP}"

  #--- �{��DMP�i�[�̏ꏊ��DMP�̑��݃`�F�b�N
  ls ${PBUSIMEIN_PATH} | grep "${DUMP_FNAME}.exp" > /dev/null
  RE_STATUS=$?
  if [ ${RE_STATUS} -eq 0 ] ;then
    cp ${PBUSIMEIN_PATH}/${DUMP_FNAME}.exp.* ${PBUSIMEIN_PATH_TMP}
  else
    #--- �{��DMP�i�[(BAK)�̏ꏊ��DMP�̑��݃`�F�b�N
    ls ${PBUSIMEIN_PATH_PAST} | grep "${DUMP_FNAME}.exp" > /dev/null
    RE_STATUS2=$?
    test ${RE_STATUS2} -eq 0 \
      && (cp ${PBUSIMEIN_PATH_PAST}/${DUMP_FNAME}.exp.* ${PBUSIMEIN_PATH_TMP})
  fi
fi

#--- �𓀒�DMP(.Z)�t�@�C���`�F�b�N
SLEEP_COUNT=0
while [ -f "${dmp_file}" -a -f "${dmp_file}.Z" ]
do
  echo "DMP(${dmp_file}.Z)���𓀂���Ă��܂��̂ŁAWAIT"              | tee -a $PBULogFile
  sleep 60
  SLEEP_COUNT=`expr ${SLEEP_COUNT} + 1`
  if [ ${SLEEP_COUNT} -gt 30 ];then
    echo "DMP(${dmp_file}.Z)�𓀎��Ԃ������߂��AERR"                 | tee -a $PBULogFile
    exit 1
  fi
done

#--- �𓀒�DMP(.gz)�t�@�C���`�F�b�N
SLEEP_COUNT=0
while [ -f "${dmp_file}" -a -f "${dmp_file}.gz" ]
do
  echo "DMP(${dmp_file}.gz)���𓀂���Ă��܂��̂ŁAWAIT"              | tee -a $PBULogFile
  sleep 60
  SLEEP_COUNT=`expr ${SLEEP_COUNT} + 1`
  if [ ${SLEEP_COUNT} -gt 30 ];then
    echo "DMP(${dmp_file}.gz)�𓀎��Ԃ������߂��AERR"                 | tee -a $PBULogFile
    exit 1
  fi
done

#--- ���k�t�@�C��(.Z)��
if [ ! -f "${dmp_file}" -a -f "${dmp_file}.Z" ] ;then
  uncompress "${dmp_file}.Z"
fi

#--- ���k�t�@�C��(.gz)��
if [ ! -f "${dmp_file}" -a -f "${dmp_file}.gz" ];then
  gunzip "${dmp_file}.gz"
fi

#--- DMP�t�@�C���̑��݃`�F�b�N
if [ ! -f "${dmp_file}" ];then
  echo "DUMP�t�@�C��(${dmp_file})���Ȃ����߁AERR"                     | tee -a $PBULogFile
  exit 1
fi

#--- �o�̓p�X�쐬
test -e ${PBUSIMEOUT_PATH} \
  || mkdir ${PBUSIMEOUT_PATH}
test -e ${PBUSIMEOUT_EXT_PATH} \
  || mkdir ${PBUSIMEOUT_EXT_PATH}

#------------------------------------------------------------------------
# �X�e�b�v-033  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK033
sqlplus ${PBUDBCONN} @${PBUMASKHOME}"/sql/drop_any_tables.sql" ${PBUserID}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DROP ANY TABLES ERR"                                    | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-034  # DUMP�t�@�C����IMPORT����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK034
if [ ! -d "${PBUMASKHOME}/log/SIMEGO_WKDB_IMP" ];then
   mkdir -pm 755 "${PBUMASKHOME}/log/SIMEGO_WKDB_IMP"
fi
simego_imp_log="${PBUMASKHOME}/log/SIMEGO_WKDB_IMP/${DUMP_FNAME}_m_imp_${PBUMASK_DATE}.log"
case ${PBUserID} in
1000|10001)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
      tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
   else
      echo "�e�[�u�����X�g�t�@�C��(${PBUMASKHOME}/param/TBL.lst)�����݂��܂���I" | tee -a $PBULogFile
      exit 1
   fi
   imp ${PBUDBCONN} file="${dmp_file}" log="${simego_imp_log}" TABLES=(${tblname_1_lst}) commit=y
;;
2000)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
      tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
   else
      echo "�e�[�u�����X�g�t�@�C��(${PBUMASKHOME}/param/TBL.lst)�����݂��܂���I" | tee -a $PBULogFile
      exit 1
   fi
   imp ${PBUDBCONN} file="${dmp_file}" log="${simego_imp_log}" TABLES=(${tblname_2_lst}) commit=y
;;
*)
   imp ${PBUDBCONN} file="${dmp_file}" log="${simego_imp_log}" TABLES=(TB%_${PBUserID},FN%_${PBUserID}) commit=y
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMP�t�@�C��${PBUSIMEIN_PATH_TMP}/${DUMP_FNAME}.exp IMPORT ERR" | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#imp�t�@�C�����`�F�b�N
#simego_imp_cnt=`grep 'IMP-' "${simego_imp_log}"|wc -l`
#if [ ${simego_imp_cnt} -ne 0 ];then
#   echo "�t�@�C��(${simego_imp_log})�̒��ɁA�x�������̓G���[������܂��I" >>${PBUMASKHISTORY}
#fi
#------------------------------------------------------------------------
# �X�e�b�v-035  # MASK����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK035
sqlplus ${PBUDBCONN} @${PBUMASKHOME}"/sql/Past_KJ_MaskByUserID.sql" ${PBUJHDBUSER} ${PBUserID}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "           MASK ERR"                                    | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-036  # �o��DUMP�t�@�C����EXPORT����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK036
exp_simego_dmpfile="${PBUSIMEOUT_PATH}/${DUMP_FNAME}_m.exp" #20100422
exp_simego_logfile="${PBUSIMEOUT_PATH}/${DUMP_FNAME}_m.log" #20100422
case ${PBUserID} in
1000|10001)
   exp ${PBUDBCONN}  file=${exp_simego_dmpfile} log=${exp_simego_logfile} TABLES=(${tblname_1_lst}) direct=y
;;
2000)
   exp ${PBUDBCONN}  file=${exp_simego_dmpfile} log=${exp_simego_logfile} TABLES=(${tblname_2_lst}) direct=y
;;
*)
   exp ${PBUDBCONN}  file=${exp_simego_dmpfile} log=${exp_simego_logfile} TABLES=(TB%_${PBUserID},FN%_${PBUserID}) direct=y
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMP�t�@�C���u${DUMP_FNAME}�vEXPORT ERR"                | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-037-1  # ��DUMP��gzip����
#------------------------------------------------------------------------
#--- 2010/08/19 ��Ɨp�R�s�[���ꂽDMP�̈��k����������
##if [ ! -f "${dmp_file}.gz" -a -f "${dmp_file}" ];then
##   gzip "${dmp_file}"
##fi
#------------------------------------------------------------------------
# �X�e�b�v-037  #�o��DUMP��gzip����
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK037
gzip -f ${exp_simego_dmpfile}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "gzip -f ${PBUSIMEOUT_PATH}/${DUMP_FNAME}_m.exp ERR"     | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# �X�e�b�v-037-2  #�o��DUMP�ړ�
#------------------------------------------------------------------------
mv "${exp_simego_dmpfile}.gz" ${PBUSIMEOUT_EXT_PATH}
mv "${exp_simego_logfile}" ${PBUSIMEOUT_EXT_PATH}
#------------------------------------------------------------------------
# �X�e�b�v-033-2  # DROP ALL TABLES
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK0332
sqlplus ${PBUDBCONN} @${PBUMASKHOME}"/sql/drop_any_tables.sql" ${PBUserID}
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DROP ANY TABLES ERR"                                    | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
fi
#------------------------------------------------------------------------
# �X�e�b�v-038  # �o��DUMP�ƃ��O�t�@�C����ftp�]������
#------------------------------------------------------------------------
#STEPNAME=TKJMASK038
#if [ "${SYORIKBN}" = "1" ];then
#   FTP_SAKI_PATH="${FTP_SAKI_ASAITI_PATH}"
#   FTP_GEN_PATH="${PBUASAOUT_PATH}"
#   case ${PBUserID} in
#   0000|0001|0002|0003)
#      FTP_PUT_FILE="${DUMP_FNAME}_m.dmp.gz"
#      FTP_PUT_LOG="${DUMP_FNAME}_m.log"
#   ;;
#   10001)
#      FTP_PUT_FILE="${DUMP_FNAME}_1000_m.dmp.gz"
#      FTP_PUT_LOG="${DUMP_FNAME}_1000_m.log"
#   ;;
#   *)
#      FTP_PUT_FILE="${DUMP_FNAME}_${PBUserID}_m.dmp.gz"
#      FTP_PUT_LOG="${DUMP_FNAME}_${PBUserID}_m.log"
#   ;;
#   esac
#elif [ "${SYORIKBN}" = "2" ];then
#   FTP_SAKI_PATH="${FTP_SAKI_SIMEGO_PATH}"
#   FTP_GEN_PATH="${PBUSIMEOUT_PATH}"
#   FTP_PUT_FILE="${DUMP_FNAME}_m.exp.gz"
#   FTP_PUT_LOG="${DUMP_FNAME}_m.log"
#fi
#echo "MASK�ς݃t�@�C���i${FTP_PUT_FILE}�j�`���J�n..." | tee -a $PBULogFile
#ftp -n << EOF >> ${PBULogFile} 2>&1
#open ${FTP_IP}
#user ${FTP_USER} ${FTP_PWD}
#cd   ${FTP_SAKI_PATH}
#lcd  ${FTP_GEN_PATH}
#bin
#umask 0027
#mkdir "${FTP_SAKI_PATH}/${PBUMASK_DATE}"
#cd  "${PBUMASK_DATE}"
#put  "${FTP_PUT_FILE}"
#put  "${FTP_PUT_LOG}"
#bye
#EOF
#TS_STATUS=$?
#if [ ! $TS_STATUS == 0 ];then
#echo "DUMP�t�@�C��ftp�]�� ERR"                          | tee -a $PBULogFile
#echo "***************************************************"    >>$PBULogFile
#echo "SHL($Tshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
#echo "***************************************************"    >>$PBULogFile
#TS_RCODE=1
#exit $TS_RCODE
#fi
#echo "MASK�ς݃t�@�C���i${FTP_PUT_FILE}�j�`���I��..." | tee -a $PBULogFile
#------------------------------------------------------------------------
# �X�e�b�v-040  # ���튮��
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK040
echo "���t�F${PBUMASK_DATE}  ��ЃR�[�h�F${PBUserID}  �f�[�^�敪�F${SYORIKBN}  �}�X�N����(`date '+%Y%m%d%H%M%S'`)..."  >>${PBUMASKHISTORY}
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
exit 0

