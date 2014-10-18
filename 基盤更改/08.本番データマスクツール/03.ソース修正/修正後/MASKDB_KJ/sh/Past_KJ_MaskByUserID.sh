#!/bin/sh
source ~/.bash_profile
# ========================================================================
# システムＩＤ  ： Past_KJ_MaskByUserID
# システム名称  ： 基準系過去分データマスク会社別処理
# 処理概要      ： 基準系過去分データマスク会社別処理
# 入力引数      ： データ接続子
#               ： マスク日付
#               ： ユーザー名
#               ： 処理区分　1:朝一データ　2:締め後データ
# リターンコード： 0：正常終了
#                  1：異常終了
# 改訂履歴
# 年月日   区分 担当者   内容
# -------- ---- -------- --------------------------------------
# 20100122 新規 GUT      新規作成
# 20131108 修正 GUT高楽　基盤更改
# ========================================================================
# @(# ] %M% ver.%I% [ %E% %U%)
#------------------------------------------------------------------------
# 処理開始
#------------------------------------------------------------------------
PBUDBCONN=$1
PBUMASK_DATE=$2
PBUserID=$3
SYORIKBN=$4
PBUMASKHOME="$(cd $(dirname $0);pwd)/.."
. ${PBUMASKHOME}"/conf/Past_KJ_MaskByUserID.conf"
#基盤更改の修正　START
. ${PBUMASKHOME}"/conf/backup_daily.conf"
TO_SCHEMA="`echo ${PBUDBCONN} | awk -F\/ '{print $1}'`"
#基盤更改の修正　END
#--- LOGのパス
LOG_PATH="${PBUMASKHOME}/log/Past_KJ_MaskByUserID"
test -e "${LOG_PATH}" \
  || mkdir -p "${LOG_PATH}"
PBULogFile="${LOG_PATH}/Past_KJ_MaskByUserID_${PBUserID}_${SYORIKBN}.log"

#--- HISTORY ファイル
PBUMASKHISTORY=${PBUMASKHOME}/Mask_Histroy.txt
#------------------------------------------------------------------------
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-START"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
#------------------------------------------------------------------------
# ステップ-010  # パラメータ数チェック
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK010
#基盤更改の修正　START
if [ $# -ne 4 ]
#基盤更改の修正　END
then
echo "usage: $1 pbudbconn $2 pbumask_date $3 pbuserid $4 syorikbn" | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#基盤更改の修正　START
if [ ! ${SYORIKBN} == 1 -a ! ${SYORIKBN} == 2 ]
#基盤更改の修正　END
then
echo "指定した処理区分[${SYORIKBN}]は不正です。[1/2]"         | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-020  # 会社別朝一データマスク処理
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK020
if [ ${SYORIKBN} == 1 ]
then
#if [ ! -e ${PBUASAIN_PATH} ]
#then
#   PBUASAIN_PATH=${PBUASAIN_PATH_PAST}
#   if [ ! -e ${PBUASAIN_PATH} ];then
#      echo "入力パス[${PBUASAIN_PATH}]が存在しません"               | tee -a $PBULogFile
#      echo "***************************************************"    >>$PBULogFile
#      echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
#      echo "***************************************************"    >>$PBULogFile
#      TS_RCODE=1
#      exit $TS_RCODE
#   fi
#fi
#------------------------------------------------------------------------
# ステップ-021  # 対象DUMPファイル名list作成
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK021
case ${PBUserID} in
0000)
#CMNの場合
DUMP_FNAME=exp_YDC_CMN_${PBUMASK_DATE}
;;
0001)
#NAMの新共通の場合
DUMP_FNAME=exp_YDC_NAM_SINKYOTU_${PBUMASK_DATE}
;;
0002)
#受託の新共通の場合
DUMP_FNAME=exp_YDC_JTK_SINKYOTU_${PBUMASK_DATE}
;;
0003)
#委託の新共通の場合
DUMP_FNAME=exp_YDC_ITK_SINKYOTU_${PBUMASK_DATE}
;;
1000)
#委託の業務共通の場合
DUMP_FNAME=exp_YDC_ITK_${PBUMASK_DATE}
;;
10001)
#NAMの業務共通の場合
DUMP_FNAME=exp_YDC_NAM_${PBUMASK_DATE}
;;
2000)
#受託の業務共通の場合
DUMP_FNAME=exp_YDC_JTK_${PBUMASK_DATE}
;;
1001)
#NAMの会社別の場合
DUMP_FNAME=exp_YDC_NAM_${PBUMASK_DATE}
;;
2001)
#受託の会社別の場合
DUMP_FNAME=exp_YDC_JTK_${PBUMASK_DATE}
;;
*)
#委託の会社別の場合
DUMP_FNAME=exp_YDC_ITK_${PBUMASK_DATE}
;;
esac
#------------------------------------------------------------------------
# ステップ-022  # INPUT DUMPファイル名読み込み
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK022
dmp_file="${PBUASAIN_PATH_TMP}/${DUMP_FNAME}.dmp"
if [ ! -f "${dmp_file}" ] && [ ! -f "${dmp_file}.gz" ];then
  #--- PATHが存在しない場合、作成する
  test -e "${PBUASAIN_PATH_TMP}" \
#基盤更改の修正　START
    || mkdir -p "${PBUASAIN_PATH_TMP}"
#基盤更改の修正　END

  #--- 本番DMP格納の場所にDMPの存在チェック
  ls ${PBUASAIN_PATH} | grep "${DUMP_FNAME}.dmp" > /dev/null
  RE_STATUS=$?
  if [ ${RE_STATUS} -eq 0 ] ;then
    cp ${PBUASAIN_PATH}/${DUMP_FNAME}.dmp.* ${PBUASAIN_PATH_TMP}
  else
    #--- 本番DMP格納(BAK)の場所にDMPの存在チェック
    ls ${PBUASAIN_PATH_PAST} | grep "${DUMP_FNAME}.dmp" > /dev/null
    RE_STATUS2=$?
    test ${RE_STATUS2} -eq 0 \
      && (cp ${PBUASAIN_PATH_PAST}/${DUMP_FNAME}.dmp.* ${PBUASAIN_PATH_TMP})
  fi
fi

#--- 解凍中のDMP待ち
SLEEP_COUNT=0
while [ -f "${dmp_file}" -a -f "${dmp_file}.gz" ]
do
  echo "DMP(${dmp_file}.gz)が解凍されていますので、WAIT"             | tee -a $PBULogFile
  sleep 60
  SLEEP_COUNT=`expr ${SLEEP_COUNT} + 1`
  if [ ${SLEEP_COUNT} -gt 60 ];then
    echo "DMP(${dmp_file}.gz)解凍時間が1時過ぎ、EXIT"                | tee -a $PBULogFile
    exit 1
  fi
done

#--- DMPは圧縮された場合、解凍する
if [ ! -f "${dmp_file}" -a -f "${dmp_file}.gz" ];then
   gunzip "${dmp_file}.gz"
fi

#--- 待ち
sleep 60

#--- 解凍後のDMPファイルの存在チェック
if [ ! -f "${dmp_file}" ] ;then
   echo "DUMPファイル(${dmp_file})がないため、ERR"                  | tee -a $PBULogFile
   exit 1
fi

#--- 出力パス作成
test -e ${PBUASAOUT_PATH} \
#基盤更改の修正　START
  || mkdir -p ${PBUASAOUT_PATH}
#test -e ${PBUASAOUT_EXT_PATH} \
#  || mkdir ${PBUASAOUT_EXT_PATH}
#基盤更改の修正　END

#------------------------------------------------------------------------
# ステップ-023  # DROP ALL TABLES
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
# ステップ-024  # DUMPファイルをIMPORT処理
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK024
if [ ! -d "${PBUMASKHOME}/log/ASAITI_WKDB_IMP" ];then
   mkdir -pm 755 "${PBUMASKHOME}/log/ASAITI_WKDB_IMP"
fi
imp_log="${PBUMASKHOME}/log/ASAITI_WKDB_IMP/${DUMP_FNAME}_${PBUserID}_m_imp.log"
case ${PBUserID} in
0000|0001|0002|0003)
#基盤更改の修正　START
#  imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(%) commit=y
   case ${PBUserID} in
   0000)
      FROM_SCHEMA="`echo ${CMN_CONN} | awk -F\/ '{print $1}'`"
   ;;
   0001)
      FROM_SCHEMA="`echo ${NAM_SINKYOTU_CONN} | awk -F\/ '{print $1}'`"
   ;;
   0002)
      FROM_SCHEMA="`echo ${JTK_SINKYOTU_CONN} | awk -F\/ '{print $1}'`"
   ;;
   0003)
      FROM_SCHEMA="`echo ${ITK_SINKYOTU_CONN} | awk -F\/ '{print $1}'`"
   ;;
   esac
   if [ "${FROM_SCHEMA}" == "" ];then
      FROM_SCHEMA="apl"
   fi
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_${PBUserID}_m_imp.log "TABLES=${FROM_SCHEMA}.%" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${imp_log} 2>&1
#基盤更改の修正　END
;;
1000|10001)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
#基盤更改の修正　START
#      tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
      if [ ${PBUserID} == "1000" ];then
         FROM_SCHEMA="`echo ${ITK_CONN} | awk -F\/ '{print $1}'`"
      else
         FROM_SCHEMA="`echo ${NAM_CONN} | awk -F\/ '{print $1}'`"
      fi
      if [ "${FROM_SCHEMA}" == "" ];then
         FROM_SCHEMA="apl"
      fi
      tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | sed "s/^/&$FROM_SCHEMA./g" | xargs | sed "s/ /,/g"`
#基盤更改の修正　END
   else
      echo "テーブルリストファイル(${PBUMASKHOME}/param/TBL.lst)が存在しません！" | tee -a $PBULogFile
      exit 1
   fi
#基盤更改の修正　START
   #imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(${tblname_1_lst}) commit=y
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_${PBUserID}_m_imp.log "TABLES=${tblname_1_lst}" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${imp_log} 2>&1
#基盤更改の修正　END
;;
2000)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
#基盤更改の修正　START
#      tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
      FROM_SCHEMA="`echo ${JTK_CONN} | awk -F\/ '{print $1}'`"
      if [ "${FROM_SCHEMA}" == "" ];then
         FROM_SCHEMA="apl"
      fi
      tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | sed "s/^/&$FROM_SCHEMA./g" | xargs | sed "s/ /,/g"`
#基盤更改の修正　END
   else
      echo "テーブルリストファイル(${PBUMASKHOME}/param/TBL.lst)が存在しません！" | tee -a $PBULogFile
      exit 1
   fi
#基盤更改の修正　START
   #imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(${tblname_2_lst}) commit=y
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_${PBUserID}_m_imp.log "TABLES=${tblname_2_lst}" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${imp_log} 2>&1
#基盤更改の修正　END
;;
*)
#基盤更改の修正　START
   #imp ${PBUDBCONN} file="${dmp_file}" log="${imp_log}" TABLES=(TB%_${PBUserID},FN%_${PBUserID}) commit=y
   if [ ${PBUserID} == "1001" ];then
      FROM_SCHEMA="`echo ${NAM_CONN} | awk -F\/ '{print $1}'`"
   elif [ ${PBUserID} == "2001" ];then
      FROM_SCHEMA="`echo ${JTK_CONN} | awk -F\/ '{print $1}'`"
   else
      FROM_SCHEMA="`echo ${ITK_CONN} | awk -F\/ '{print $1}'`"
   fi
   if [ "${FROM_SCHEMA}" == "" ];then
      FROM_SCHEMA="apl"
   fi
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_${PBUserID}_m_imp.log "TABLES=${FROM_SCHEMA}.TB%_${PBUserID},${FROM_SCHEMA}.FN%_${PBUserID}" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${imp_log} 2>&1
#基盤更改の修正　END
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMPファイル${PBUASAIN_PATH_TMP}/${DUMP_FNAME}.dmp IMPORT ERR" | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-025  # MASK処理
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
# ステップ-026  # 出力DUMPファイルをEXPORT処理
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK026
#基盤更改の修正　START
tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
#基盤更改の修正　END
exp_asaiti_dmpfile="" #20100422
exp_asaiti_logfile="" #20100422
case ${PBUserID} in
0000|0001|0002|0003)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_m.log"
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(%) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_asaiti_dmpfile} ${DUMP_FNAME}_m.log "TABLES=%" >> ${exp_asaiti_logfile} 2>&1
#基盤更改の修正　END
;;
1000)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.log"
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(${tblname_1_lst}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_asaiti_dmpfile} ${DUMP_FNAME}_${PBUserID}_m.log "TABLES=${tblname_1_lst}" >> ${exp_asaiti_logfile} 2>&1
#基盤更改の修正　END
;;
2000)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.log"
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(${tblname_2_lst}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_asaiti_dmpfile} ${DUMP_FNAME}_${PBUserID}_m.log "TABLES=${tblname_2_lst}" >> ${exp_asaiti_logfile} 2>&1
#基盤更改の修正　END
;;
10001)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_1000_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_1000_m.log"
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(${tblname_1_lst}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_asaiti_dmpfile} ${DUMP_FNAME}_1000_m.log "TABLES=${tblname_1_lst}" >> ${exp_asaiti_logfile} 2>&1
#基盤更改の修正　END
;;
*)
   exp_asaiti_dmpfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.dmp"
   exp_asaiti_logfile="${PBUASAOUT_PATH}/${DUMP_FNAME}_${PBUserID}_m.log"
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_asaiti_dmpfile} log=${exp_asaiti_logfile} TABLES=(TB%_${PBUserID},FN%_${PBUserID}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_asaiti_dmpfile} ${DUMP_FNAME}_${PBUserID}_m.log "TABLES=TB%_${PBUserID},FN%_${PBUserID}" >> ${exp_asaiti_logfile} 2>&1
#基盤更改の修正　END
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMPファイル「${DUMP_FNAME}」EXPORT ERR"                | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-027-1  # 元DUMPをgzip処理
#------------------------------------------------------------------------
#--- 2010/08/19 仕様変更、作業用コピーされたDMPの圧縮処理取り消し
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
##      echo "ファイル（${dmp_file}）圧縮開始" | tee -a $PBULogFile
##      gzip "${dmp_file}"
##      echo "ファイル（${dmp_file}）圧縮完了" | tee -a $PBULogFile
##   fi
##else
##   echo "DMPファイルが使用されますので、圧縮処理スキップ....." | tee -a $PBULogFile
##fi
#------------------------------------------------------------------------
# ステップ-027  # 出力DUMPをgzip処理
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
# ステップ-027-2  # 出力DUMP移動
#------------------------------------------------------------------------
#基盤更改の修正　START
#mv "${exp_asaiti_dmpfile}.gz" ${PBUASAOUT_EXT_PATH}
#mv "${exp_asaiti_logfile}" ${PBUASAOUT_EXT_PATH}
#基盤更改の修正　END
#------------------------------------------------------------------------
# ステップ-023-2  # DROP ALL TABLES
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
# ステップ-030  # 会社別締め後データマスク処理
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK030
if [ ${SYORIKBN} == 2 ]
then
#------------------------------------------------------------------------
# ステップ-031  # 対象DUMPファイル名list作成
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK031
case ${PBUserID} in
1000)
#委託の業務共通の場合
DUMP_FNAME=1000_itk
;;
10001)
#NAMの業務共通の場合
DUMP_FNAME=1000_nam
;;
2000)
#受託の業務共通の場合
DUMP_FNAME=2000_jtk
;;
1001)
#NAMの会社別の場合
DUMP_FNAME=1001_nam
;;
2001)
#受託の会社別の場合
DUMP_FNAME=2001_jtk
;;
*)
#委託の会社別の場合
DUMP_FNAME=${PBUserID}_itk
;;
esac
#------------------------------------------------------------------------
# ステップ-032  # INPUT DUMPファイル名読み込み
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK032
dmp_file="${PBUSIMEIN_PATH_TMP}/${DUMP_FNAME}.exp"

#--- DMPファイル準備
ls ${dmp_file}* > /dev/null
RE_STATUS=$?
if [ ${RE_STATUS} -ne 0 ] ;then
  #--- PATHが存在しない場合、作成する
  test -e "${PBUSIMEIN_PATH_TMP}" \
#基盤更改の修正　START
    || mkdir -p "${PBUSIMEIN_PATH_TMP}"
#基盤更改の修正　END

  #--- 本番DMP格納の場所にDMPの存在チェック
  ls ${PBUSIMEIN_PATH} | grep "${DUMP_FNAME}.exp" > /dev/null
  RE_STATUS=$?
  if [ ${RE_STATUS} -eq 0 ] ;then
    cp ${PBUSIMEIN_PATH}/${DUMP_FNAME}.exp.* ${PBUSIMEIN_PATH_TMP}
  else
    #--- 本番DMP格納(BAK)の場所にDMPの存在チェック
    ls ${PBUSIMEIN_PATH_PAST} | grep "${DUMP_FNAME}.exp" > /dev/null
    RE_STATUS2=$?
    test ${RE_STATUS2} -eq 0 \
      && (cp ${PBUSIMEIN_PATH_PAST}/${DUMP_FNAME}.exp.* ${PBUSIMEIN_PATH_TMP})
  fi
fi

#--- 解凍中DMP(.Z)ファイルチェック
SLEEP_COUNT=0
while [ -f "${dmp_file}" -a -f "${dmp_file}.Z" ]
do
  echo "DMP(${dmp_file}.Z)が解凍されていますので、WAIT"              | tee -a $PBULogFile
  sleep 60
  SLEEP_COUNT=`expr ${SLEEP_COUNT} + 1`
  if [ ${SLEEP_COUNT} -gt 30 ];then
    echo "DMP(${dmp_file}.Z)解凍時間が半時過ぎ、ERR"                 | tee -a $PBULogFile
    exit 1
  fi
done

#--- 解凍中DMP(.gz)ファイルチェック
SLEEP_COUNT=0
while [ -f "${dmp_file}" -a -f "${dmp_file}.gz" ]
do
  echo "DMP(${dmp_file}.gz)が解凍されていますので、WAIT"              | tee -a $PBULogFile
  sleep 60
  SLEEP_COUNT=`expr ${SLEEP_COUNT} + 1`
  if [ ${SLEEP_COUNT} -gt 30 ];then
    echo "DMP(${dmp_file}.gz)解凍時間が半時過ぎ、ERR"                 | tee -a $PBULogFile
    exit 1
  fi
done

#--- 圧縮ファイル(.Z)解凍
if [ ! -f "${dmp_file}" -a -f "${dmp_file}.Z" ] ;then
  uncompress "${dmp_file}.Z"
fi

#--- 圧縮ファイル(.gz)解凍
if [ ! -f "${dmp_file}" -a -f "${dmp_file}.gz" ];then
  gunzip "${dmp_file}.gz"
fi

#--- DMPファイルの存在チェック
if [ ! -f "${dmp_file}" ];then
  echo "DUMPファイル(${dmp_file})がないため、ERR"                     | tee -a $PBULogFile
  exit 1
fi

#--- 出力パス作成
test -e ${PBUSIMEOUT_PATH} \
#基盤更改の修正　START
  || mkdir -p ${PBUSIMEOUT_PATH}
#test -e ${PBUSIMEOUT_EXT_PATH} \
#  || mkdir ${PBUSIMEOUT_EXT_PATH}
#基盤更改の修正　END

#------------------------------------------------------------------------
# ステップ-033  # DROP ALL TABLES
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
# ステップ-034  # DUMPファイルをIMPORT処理
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK034
if [ ! -d "${PBUMASKHOME}/log/SIMEGO_WKDB_IMP" ];then
   mkdir -pm 755 "${PBUMASKHOME}/log/SIMEGO_WKDB_IMP"
fi
simego_imp_log="${PBUMASKHOME}/log/SIMEGO_WKDB_IMP/${DUMP_FNAME}_m_imp_${PBUMASK_DATE}.log"
case ${PBUserID} in
1000|10001)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
#基盤更改の修正　START
#      tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
      if [ ${PBUserID} == "1000" ];then
         FROM_SCHEMA="`echo ${ITK_CONN} | awk -F\/ '{print $1}'`"
      else
         FROM_SCHEMA="`echo ${NAM_CONN} | awk -F\/ '{print $1}'`"
      fi
      if [ "${FROM_SCHEMA}" == "" ];then
         FROM_SCHEMA="apl"
      fi
      tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | sed "s/^/&$FROM_SCHEMA./g" | xargs | sed "s/ /,/g"`
#基盤更改の修正　END
   else
      echo "テーブルリストファイル(${PBUMASKHOME}/param/TBL.lst)が存在しません！" | tee -a $PBULogFile
      exit 1
   fi
#基盤更改の修正　START
   #imp ${PBUDBCONN} file="${dmp_file}" log="${simego_imp_log}" TABLES=(${tblname_1_lst}) commit=y
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_m_imp_${PBUMASK_DATE}.log "TABLES=${tblname_1_lst}" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${simego_imp_log} 2>&1
#基盤更改の修正　END
;;
2000)
   if [ -f "${PBUMASKHOME}/param/TBL.lst" ];then
#基盤更改の修正　START
#      tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
      FROM_SCHEMA="`echo ${JTK_CONN} | awk -F\/ '{print $1}'`"
      if [ "${FROM_SCHEMA}" == "" ];then
         FROM_SCHEMA="apl"
      fi
      tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | sed "s/^/&$FROM_SCHEMA./g" | xargs | sed "s/ /,/g"`
#基盤更改の修正　END
   else
      echo "テーブルリストファイル(${PBUMASKHOME}/param/TBL.lst)が存在しません！" | tee -a $PBULogFile
      exit 1
   fi
#基盤更改の修正　START
   #imp ${PBUDBCONN} file="${dmp_file}" log="${simego_imp_log}" TABLES=(${tblname_2_lst}) commit=y
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_m_imp_${PBUMASK_DATE}.log "TABLES=${tblname_2_lst}" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${simego_imp_log} 2>&1
#基盤更改の修正　END
;;
*)
#基盤更改の修正　START
   #imp ${PBUDBCONN} file="${dmp_file}" log="${simego_imp_log}" TABLES=(TB%_${PBUserID},FN%_${PBUserID}) commit=y
   if [ ${PBUserID} == "1001" ];then
      FROM_SCHEMA="`echo ${NAM_CONN} | awk -F\/ '{print $1}'`"
   elif [ ${PBUserID} == "2001" ];then
      FROM_SCHEMA="`echo ${JTK_CONN} | awk -F\/ '{print $1}'`"
   else
      FROM_SCHEMA="`echo ${ITK_CONN} | awk -F\/ '{print $1}'`"
   fi
   if [ "${FROM_SCHEMA}" == "" ];then
      FROM_SCHEMA="apl"
   fi
   sh BCZC0070.sh imp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${dmp_file} ${DUMP_FNAME}_m_imp_${PBUMASK_DATE}.log "TABLES=${FROM_SCHEMA}.TB%_${PBUserID},${FROM_SCHEMA}.FN%_${PBUserID}" "REMAP_SCHEMA=${FROM_SCHEMA}:${TO_SCHEMA}" >> ${simego_imp_log} 2>&1
#基盤更改の修正　END
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMPファイル${PBUSIMEIN_PATH_TMP}/${DUMP_FNAME}.exp IMPORT ERR" | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#impファイルをチェック
#simego_imp_cnt=`grep 'IMP-' "${simego_imp_log}"|wc -l`
#if [ ${simego_imp_cnt} -ne 0 ];then
#   echo "ファイル(${simego_imp_log})の中に、警告或いはエラーがあります！" >>${PBUMASKHISTORY}
#fi
#------------------------------------------------------------------------
# ステップ-035  # MASK処理
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
# ステップ-036  # 出力DUMPファイルをEXPORT処理
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK036
#基盤更改の修正　START
tblname_1_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_1\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
tblname_2_lst=`cat "${PBUMASKHOME}/param/TBL.lst" | grep -E "_2\b|TBWF|TBWI|TBWM|TBWS|TBWT" | xargs | sed "s/ /,/g"`
#基盤更改の修正　END
exp_simego_dmpfile="${PBUSIMEOUT_PATH}/${DUMP_FNAME}_m.exp" #20100422
exp_simego_logfile="${PBUSIMEOUT_PATH}/${DUMP_FNAME}_m.log" #20100422
case ${PBUserID} in
1000|10001)
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_simego_dmpfile} log=${exp_simego_logfile} TABLES=(${tblname_1_lst}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_simego_dmpfile} ${DUMP_FNAME}_m.log "TABLES=${tblname_1_lst}" >> ${exp_simego_logfile} 2>&1
#基盤更改の修正　END
;;
2000)
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_simego_dmpfile} log=${exp_simego_logfile} TABLES=(${tblname_2_lst}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_simego_dmpfile} ${DUMP_FNAME}_m.log "TABLES=${tblname_2_lst}" >> ${exp_simego_logfile} 2>&1
#基盤更改の修正　END
;;
*)
#基盤更改の修正　START
   #exp ${PBUDBCONN}  file=${exp_simego_dmpfile} log=${exp_simego_logfile} TABLES=(TB%_${PBUserID},FN%_${PBUserID}) direct=y
   sh BCZC0070.sh exp "`basename $0 | sed 's/.sh//g'`" ${PBUDBCONN} ${exp_simego_dmpfile} ${DUMP_FNAME}_m.log "TABLES=TB%_${PBUserID},FN%_${PBUserID}" >> ${exp_simego_logfile} 2>&1
#基盤更改の修正　END
;;
esac
TS_STATUS=$?
if [ ! $TS_STATUS == 0 ];then
echo "DUMPファイル「${DUMP_FNAME}」EXPORT ERR"                | tee -a $PBULogFile
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
TS_RCODE=1
exit $TS_RCODE
fi
#------------------------------------------------------------------------
# ステップ-037-1  # 元DUMPをgzip処理
#------------------------------------------------------------------------
#--- 2010/08/19 作業用コピーされたDMPの圧縮処理取り消し
##if [ ! -f "${dmp_file}.gz" -a -f "${dmp_file}" ];then
##   gzip "${dmp_file}"
##fi
#------------------------------------------------------------------------
# ステップ-037  #出力DUMPをgzip処理
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
# ステップ-037-2  #出力DUMP移動
#------------------------------------------------------------------------
#基盤更改の修正　START
#mv "${exp_simego_dmpfile}.gz" ${PBUSIMEOUT_EXT_PATH}
#mv "${exp_simego_logfile}" ${PBUSIMEOUT_EXT_PATH}
#基盤更改の修正　END
#------------------------------------------------------------------------
# ステップ-033-2  # DROP ALL TABLES
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
# ステップ-038  # 出力DUMPとログファイルをftp転送処理
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
#echo "MASK済みファイル（${FTP_PUT_FILE}）伝送開始..." | tee -a $PBULogFile
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
#echo "DUMPファイルftp転送 ERR"                          | tee -a $PBULogFile
#echo "***************************************************"    >>$PBULogFile
#echo "SHL($Tshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-ABEND"  >>$PBULogFile
#echo "***************************************************"    >>$PBULogFile
#TS_RCODE=1
#exit $TS_RCODE
#fi
#echo "MASK済みファイル（${FTP_PUT_FILE}）伝送終了..." | tee -a $PBULogFile
#------------------------------------------------------------------------
# ステップ-040  # 正常完了
#------------------------------------------------------------------------
#STEPNAME=PBUKJMASK040
echo "日付：${PBUMASK_DATE}  会社コード：${PBUserID}  データ区分：${SYORIKBN}  マスク完了(`date '+%Y%m%d%H%M%S'`)..."  >>${PBUMASKHISTORY}
echo "***************************************************"    >>$PBULogFile
echo "SHL($PBUshid) `date '+%y/%m/%d %H:%M:%S:%N'` SHELL-END"    >>$PBULogFile
echo "***************************************************"    >>$PBULogFile
exit 0

