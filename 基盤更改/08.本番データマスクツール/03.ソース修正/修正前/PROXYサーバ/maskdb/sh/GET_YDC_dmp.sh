#!/bin/sh
source ~/.bash_profile
#---------------------------------------------------------------
#����f�[�^�擾(YDC��PROXY���w��T�[�o)
#---------------------------------------------------------------
GET_DATA_FROM_YDC()
{
local_path=$1
asaiti_file_name=$2
expect << EOF
set timeout 1800
set TERM xterm

spawn ftp

expect "ftp>"
send "open ${ACCESS_CHK_IP}\r"
expect "Name (${ACCESS_CHK_IP}:ftpuser):"
send "${ACCESS_CHK_USR}\r"
expect "Password:"
send "${ACCESS_CHK_PWD}\r"
expect "ftp>"
send "user apl@${hb_ipadd}\r"
expect "Password:"
send "${YDC_PWD}\r"
expect "230 login accepted"

send "bin\r"
expect "ftp>"
send "lcd ${local_path}\r"
expect "ftp>"
send "cd ${x_ydc_path}\r"
expect "ftp>"
send "prompt off\r"
expect "ftp>"
send "mget ${asaiti_file_name}\r"
expect "ftp>"
send "close\r"
expect "221 goodbye"
send "open ${FTP_SAKI_IP}\r"
expect "Name (${FTP_SAKI_IP}:ftpuser):"
send "${FTP_SAKI_USR}\r"
expect "Password:"
send "${FTP_SAKI_PWD}\r"
expect "ftp>"
send "mkdir ${ftp_saki_dmp_path}\r"
expect "ftp>"
send "cd ${ftp_saki_dmp_path}\r"
expect "250 Directory successfully changed."
send "mput ${asaiti_file_name}\r"
expect "ftp>"
send "bye\r"

expect "221 Goodbye."
send "exit\r"

interact
EOF
}
#---------------------------------------------------------------
#PROXY�T�[�o�]���@�@20100809�ǉ�
#---------------------------------------------------------------
GET_PROXY_FROM_YDC()
{
local_path=$1
asaiti_file_name=$2
expect << EOF
set timeout 1800
set TERM xterm

spawn ftp

expect "ftp>"
send "open ${ACCESS_CHK_IP}\r"
expect "Name (${ACCESS_CHK_IP}:ftpuser):"
send "${ACCESS_CHK_USR}\r"
expect "Password:"
send "${ACCESS_CHK_PWD}\r"
expect "ftp>"
send "user apl@${hb_ipadd}\r"
expect "Password:"
send "${YDC_PWD}\r"
expect "230 login accepted"

send "bin\r"
expect "ftp>"
send "lcd ${local_path}\r"
expect "ftp>"
send "cd ${x_ydc_path}\r"
expect "ftp>"
send "prompt off\r"
expect "ftp>"
send "get ${asaiti_file_name}\r"
expect "ftp>"
send "bye\r"
expect "221 goodbye"
interact
EOF
}

#---------------------------------------------------------------
#���ߌ���t�`��(PROXY�����[�NDB�T�[�o)
#---------------------------------------------------------------
FTP_PUT()
{
local_pth=$1
ftp_saki_pth=$2
ftp_file=$3

expect << EOF
set timeout 1800
set TERM xterm

spawn ftp
expect "ftp>"
send "open ${FTP_SAKI_IP}\r"
expect "Name (${FTP_SAKI_IP}:ftpuser):"
send "${FTP_SAKI_USR}\r"
expect "Password:"
send "${FTP_SAKI_PWD}\r"
expect "ftp>"
send "bin\r"
expect "ftp>"
send "lcd ${local_pth}\r"
expect "ftp>"
send "cd ${ftp_saki_pth}\r"
expect "ftp>"
send "prompt off\r"
expect "ftp>"
send "put ${ftp_file}\r"
expect "ftp>"
send "bye\r"

interact
EOF
}
#---------------------------------------------------------------
#�ǌ�f�[�^�擾(YDC��PROXY���w��T�[�o)
#---------------------------------------------------------------
GET_YDCtoE_model()
{
expect << EOF_M
set timeout 1800
set TERM xterm

spawn ftp

expect "ftp>"
send "open ${ACCESS_CHK_IP}\r"
expect "Name (${ACCESS_CHK_IP}:ftpuser):"
send "${ACCESS_CHK_USR}\r"
expect "Password:"
send "${ACCESS_CHK_PWD}\r"
expect "ftp>"
send "user apl@${TX_HB_IP}\r"
expect "Password:"
send "${YDC_PWD}\r"
expect "230 login accepted"

expect "ftp>"
send "bin\r"
expect "ftp>"
send "lcd ${proxy_data_pth}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.1/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.2/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.3/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.4/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.5/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.6/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.7/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.8/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.9/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.10/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.11/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.12/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.13/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.14/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.15/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.16/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.17/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.18/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.19/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.20/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.21/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.22/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.23/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.24/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.25/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.26/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.27/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.28/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.29/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.30/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.31/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.32/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.33/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.34/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.35/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.36/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.37/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.38/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.39/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.40/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.41/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.42/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.43/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.44/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.45/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.46/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.47/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.48/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.49/${KIJUN_YMD}\r"
expect "ftp>"
send "cd /ext/expdata/cycle.50/${KIJUN_YMD}\r"
expect "ftp>"
send "get ${YDC_FILE}\r"
expect "ftp>"
send "close\r"

expect "ftp>"
send "open ${FTP_SAKI_IP}\r"
expect "Name (${FTP_SAKI_IP}:ftpuser):"
send "${FTP_SAKI_USR}\r"
expect "Password:"
send "${FTP_SAKI_PWD}\r"
expect "ftp>"
send "mkdir ${ftp_saki_dmp_path}\r"
expect "ftp>"
send "cd ${ftp_saki_dmp_path}\r"
expect "ftp>"
send "put ${YDC_FILE}\r"
expect "ftp>"
send "bye\r"

expect "221 Goodbye."
send "exit\r"

interact
EOF_M
}

#---------------------------------------------------------------
#����f�[�^�擾(HDD���w��T�[�o)
#---------------------------------------------------------------
GET_HDD_DATA_for_E_ASAITI()
{
expect << EOF
set timeout 1800
set TERM xterm

spawn telnet
expect "telnet>"
send "open ${FTP_SAKI_IP} 23\r"
expect "login:"
send "${FTP_SAKI_USR}\r"
expect "Password:"
send "${FTP_SAKI_PWD}\r"
expect "~]"
send "ftp ${HDD_IP}\r"
expect "Name"
send "${HDD_USR}\r"
expect "Password:"
send "${HDD_PWD}\r"
expect "ftp>"
send "bin\r"
expect "ftp>"
send "lcd ${ftp_saki_dmp_path}\r"
expect "ftp>"
send "cd ${hdd_data_pth}\r"
expect "ftp>"
send "prompt off\r"
expect "ftp>"
send "mget ${F_1}\r"
expect "ftp>"
send "bye\r"
expect "221"
send "exit\r"

interact
EOF
}

#---------------------------------------------------------------
#20100303 for ���ߌ���t�擾
#---------------------------------------------------------------
GET_SIMEGO_DATE()
{
#YDC����END�t�@�C����]��
expect << EOF
set timeout 1800
set TERM xterm

spawn ftp
expect "ftp>"
send "open ${ACCESS_CHK_IP}\r"
expect "Name (${ACCESS_CHK_IP}:ftpuser):"
send "${ACCESS_CHK_USR}\r"
expect "Password:"
send "${ACCESS_CHK_PWD}\r"
expect "ftp>"
send "user apl@${hb_ipadd}\r"
expect "Password:"
send "${YDC_PWD}\r"
expect "230 login accepted"

send "bin\r"
expect "ftp>"
send "lcd ${proxy_data_pth_simego_all}\r"
expect "ftp>"
send "cd ${x_ydc_path}\r"
expect "ftp>"
send "prompt off\r"
expect "ftp>"
send "ls 2??????? simego_date.tmp\r"
expect "ftp>"
send "bye\r"

expect "221"
send "exit\r"

interact
EOF
}
#---------------------------------------------------------------
#���ߌ���t�`��(PROXY�����[�NDB�T�[�o)
#---------------------------------------------------------------
FTP_FILE()
{
local_pth=$1
ftp_saki_pth=$2
ftp_file=$3

expect << EOF
set timeout 1800
set TERM xterm

spawn ftp
expect "ftp>"
send "open ${FTP_SAKI_IP}\r"
expect "Name"
send "${FTP_SAKI_USR}\r"
expect "Password:"
send "${FTP_SAKI_PWD}\r"
expect "ftp>"
send "bin\r"
expect "ftp>"
send "lcd ${local_pth}\r"
expect "ftp>"
send "cd ${ftp_saki_pth}\r"
expect "ftp>"
send "prompt off\r"
expect "ftp>"
send "mput ${ftp_file}\r"
expect "ftp>"
send "bye\r"

interact
EOF
}
#---------------------------------------------------------------
#�t�@�C�����݃`�F�b�N
#---------------------------------------------------------------
IsHaveFile()
{
fun_file=$1
if [ ! -f "${fun_file}" ];then
   echo "�����t�@�C��(${fun_file})�����݂��Ȃ��A�ُ�I��(`date`)...."
   exit 1
fi
}
#---------------------------------------------------------------
# Main����
#---------------------------------------------------------------
#�����ݒ�
KIJUN_YMD=$1 #def :1
YDC_FILE=$2
YDC_PATH=$3  #def :1
JYOHO_FILE=$4    #def :1
sh_kbn=$5    #1:����,2:�ǌ�,3:�ږ�,4:���̑�
dmp_kbn=$6   #ITK,NAM,JTK,CMN,itk,nam,jtk,kmn,all
kaisha_cd=$7 #1000,1001,�E�E�E
data_basho=$8 #1,2,�E�E�E
#---------------------------------------------------------------
# �ϐ�������
#---------------------------------------------------------------
HOME_PATH="$(cd $(dirname $0);pwd)/.."
NOW=`date '+%Y%m%d'`
TIME=`date '+%H%M'`
#���O�t�@�C���ݒ�
LOG_FILE=$HOME_PATH/log/download_YDC_2_${FTP_SAKI_IP}_${NOW}_${TIME}.log

#log�t�H���_�쐬
if [ ! -d "${HOME_PATH}/log" ];then
   mkdir -pm 755 "${HOME_PATH}/log"
fi

#�����`�F�b�N
if [ $# -ne 8 ];then
   echo '�������� Parameter ERR ��������'                                                                             |tee -a ${LOG_FILE}
   echo 'usage: $1 ���       [ �����F1   | ���̑��F���t                                                         ]' |tee -a ${LOG_FILE}
   echo 'usage: $2 ̧�ٖ�  (��) [ def�F1    | ���̑��F�t�@�C����                                                   ]' |tee -a ${LOG_FILE}
   echo 'usage: $3 ̧���߽ (��) [ def�F1    | ���̑��F�t�@�C���p�[�X                                               ]' |tee -a ${LOG_FILE}
   echo 'usage: $4 ���̧��(��) [ E�ʁF1    | ���[�NDB�F2         | ���̑��F���t�@�C���w��                       ]' |tee -a ${LOG_FILE}
   echo 'usage: $5 �ް��敪     [ ����F1   | ���ߌ�F2 | �ږ�F3 | ���̑��F4                                      ]' |tee -a ${LOG_FILE}
   echo 'usage: $6 DMP �敪     [ ITK | NAM | JTK | CMN | ITK_KYO | JTK_KYO | NAM_KYO | itk | nam | jtk | kmn | all]' |tee -a ${LOG_FILE}
   echo 'usage: $7 ��к���     [ 1000| 1001| XXXX                                                                 ]' |tee -a ${LOG_FILE}
   echo 'usage: $8 �ް��ꏊ     [ �{�ԁF1   | HDD�F2                                                               ]' |tee -a ${LOG_FILE}
   exit 1
fi

#FTP��Conf�t�@�C���`�F�b�N
IsHaveFile "${HOME_PATH}/conf/GET_YDC_dmp.conf" | tee -a ${LOG_FILE}
. "${HOME_PATH}/conf/GET_YDC_dmp.conf"
#---------------------------------------------------------------
# �ϐ��l�]��
#---------------------------------------------------------------
if [ "${KIJUN_YMD}" = "1" ];then
   KIJUN_YMD="${NOW}"
   KMN_KIJUN_YMD="1"
else
   KMN_KIJUN_YMD=${KIJUN_YMD}
fi

#conf�t�@�C���ݒ�
if [ "${JYOHO_FILE}" = "1" ];then
   IsHaveFile "${HOME_PATH}/conf/FTP_SAKI_E.conf" | tee -a ${LOG_FILE}
   . "${HOME_PATH}/conf/FTP_SAKI_E.conf"
elif [ "${JYOHO_FILE}" = "2" ];then
   IsHaveFile "${HOME_PATH}/conf/FTP_SAKI_WKDB.conf" | tee -a ${LOG_FILE}
   . "${HOME_PATH}/conf/FTP_SAKI_WKDB.conf"
else
   IsHaveFile "${HOME_PATH}/conf/${JYOHO_FILE}" | tee -a ${LOG_FILE}
   . "${HOME_PATH}/conf/${JYOHO_FILE}"
fi

#ftp��p�[�X�ݒ�
if [ "${JYOHO_FILE}" = "1" ];then
   if [ "${sh_kbn}" = "1" ];then
      ftp_saki_dmp_path="${FTP_SAKI_ASAITI_DMP_PATH}"
   elif [ "${sh_kbn}" = "2" ];then
      ftp_saki_dmp_path="${FTP_SAKI_SIMEGO_DMP_PATH}/${KIJUN_YMD}SIMEGO"
   fi
else
   if [ "${sh_kbn}" = "1" ];then
      ftp_saki_dmp_path="${FTP_SAKI_ASAITI_DMP_PATH}/${KIJUN_YMD}"
   elif [ "${sh_kbn}" = "2" ];then
      ftp_saki_dmp_path="${FTP_SAKI_SIMEGO_DMP_PATH}/${KIJUN_YMD}"
   fi
fi

#�{�ԃp�[�X�ݒ�
if [ "${YDC_PATH}" = "1" ];then
   x_ydc_path="${YDC_DMP_PATH}"
   X_KMN_PATH="${KMN_DMP_PATH}"
fi

#---------------------------------------------------------------
# �{�ԃp�X���[�h�擾 
#---------------------------------------------------------------
HOST_NAME=thblid01
YDC_PWD=`/home/ftpuser/syuu/BACKUP_DAILY/PASSWORD/GET_PASSWD.sh ${HOST_NAME}`
KMN_HOST_NAME=thblrd01
KMN_YDC_PWD=`/home/ftpuser/syuu/BACKUP_DAILY/PASSWORD/GET_PASSWD.sh ${KMN_HOST_NAME}`

#---------------------------------------------------------------
# �f�[�^�敪�F���� �`������
#---------------------------------------------------------------
proxy_data_pth=$HOME_PATH/data

if [ "${sh_kbn}" = "1" ];then
   hb_ipadd=${TX_HB_IP}
   hdd_data_pth="${HDD_ASAITI_DATA_PTH}"
   #�t�@�C��
   case "$dmp_kbn" in
   "ITK"|"NAM"|"JTK"|"CMN")
       echo $x_ydc_path
       F_1="exp_YDC_${dmp_kbn}_${KIJUN_YMD}.*"
       ;;
   "ITK_KYO")
       F_1="exp_YDC_ITK_SINKYOTU_${KIJUN_YMD}.*"
       ;;
   "NAM_KYO")
       F_1="exp_YDC_NAM_SINKYOTU_${KIJUN_YMD}.*"
       ;;
   "JTK_KYO")
       F_1="exp_YDC_JTK_SINKYOTU_${KIJUN_YMD}.*"
       ;;
   esac
   if [ "$data_basho" = "1" ];then
     echo "������ YDC�� ${FTP_SAKI_IP} �����ꁚ�f�[�^($dmp_kbn)�擾�J�n�i`date`�j ������" | tee -a $LOG_FILE
     #20100303 for END�t�@�C���擾_START
     case "${dmp_kbn}" in
       "ITK" | "JTK" | "NAM")
         #END�t�@�C��
         END_FILE="exp_YDC_${dmp_kbn}_${KIJUN_YMD}.END"
         TIME_COUNT=0
         while [ "${TIME_COUNT}" -lt "6" -a ! -f "${proxy_data_pth}/${END_FILE}" ]
         do
           if [ "${NOW}" != "${KIJUN_YMD}" ];then
              break
           fi
           GET_DATA_FROM_YDC ${proxy_data_pth} ${END_FILE}
           if [ -f "${proxy_data_pth}/${END_FILE}" ];then
              break
           else
              sleep 300
              let TIME_COUNT=TIME_COUNT+1
           fi
         done
       ;;
     esac
     #20100303 for END�t�@�C���擾_END
     #DMP�`��
     GET_DATA_FROM_YDC ${proxy_data_pth} ${F_1}                                             | tee -a $LOG_FILE
     ls ${proxy_data_pth}/${F_1} >/dev/null 2>&1
     TS_STATUS=$?
     if [ "${TS_STATUS}" != "0" ];then
        echo "������ YDC�� ${FTP_SAKI_IP} �����ꁚ�f�[�^($dmp_kbn)�擾���ُ큦�I���i`date`�j ������" | tee -a $LOG_FILE
        exit 1
     else
        rm -f ${proxy_data_pth}/${F_1} |tee -a $LOG_FILE 2>&1
        echo "������ YDC�� ${FTP_SAKI_IP} �����ꁚ�f�[�^($dmp_kbn)�擾����I���i`date`�j ������" | tee -a $LOG_FILE
     fi
   fi
   if [ "$data_basho" = "2" ];then
     echo "������ HDD�� ${FTP_SAKI_IP} �����ꁚ�f�[�^($dmp_kbn)�擾�J�n�i`date`�j ������" | tee -a $LOG_FILE
     GET_HDD_DATA_for_E_ASAITI                                                  | tee -a $LOG_FILE
     TS_STATUS=$?
     if [ "${TS_STATUS}" != "0" ];then
        echo "������ HDD�� ${FTP_SAKI_IP} �����ꁚ�f�[�^($dmp_kbn)�擾���ُ큦�I���i`date`�j ������" | tee -a $LOG_FILE
        exit 1
     else
        echo "������ HDD�� ${FTP_SAKI_IP} �����ꁚ�f�[�^($dmp_kbn)�擾����I���i`date`�j ������" | tee -a $LOG_FILE
     fi
   fi
fi
#---------------------------------------------------------------
# �f�[�^�敪�F���ߌ� �`������
#---------------------------------------------------------------
if [ "${sh_kbn}" = "2" ];then
   echo "������ YDC�� ${FTP_SAKI_IP} �����ߌず�f�[�^�擾�J�n�i`date`�j ������" | tee -a $LOG_FILE
   if [ "${dmp_kbn}" = "all" ];then
      hb_ipadd="${TX_HB_IP}"
      x_ydc_path="${HB_SIMEGO_ALL_DATA_PTH}"
      proxy_data_pth_simego_all=$HOME_PATH/simego_all
      if [ ! -f "${proxy_data_pth_simego_all}/get_simego_all.lock" ];then
         touch "${proxy_data_pth_simego_all}/get_simego_all.lock"
      else
         echo "�������ߌ�S�f�[�^���擾���ŁAexit�E�E�i`date`�j"                    | tee -a $LOG_FILE
         exit 1
      fi 
      rm -f "${proxy_data_pth_simego_all}/simego_date.tmp"
      GET_SIMEGO_DATE                                                           | tee -a $LOG_FILE 
      if [ -f "${proxy_data_pth_simego_all}/simego_date.tmp" ];then 
         simego_date_count=`cat "${proxy_data_pth_simego_all}/simego_date.tmp"|wc -l`
         if [ "${simego_date_count}" = "1" ];then
            SIMEGO_DATE=`cat "${proxy_data_pth_simego_all}/simego_date.tmp"|awk '{print $9;}'`
            x_ydc_path="${HB_SIMEGO_ALL_DATA_PTH}/${SIMEGO_DATE}"
            ftp_saki_dmp_path="${FTP_SAKI_SIMEGO_DMP_PATH}/${SIMEGO_DATE}"
            YDC_FILE="*.exp.Z"
            ##�擾���s
            GET_DATA_FROM_YDC "${proxy_data_pth_simego_all}" "${YDC_FILE}"          | tee -a $LOG_FILE
            TS_STATUS=$?
            if [ "${TS_STATUS}" != "0" ];then
               echo "������ YDC�� ${FTP_SAKI_IP} �����ߌず�f�[�^(ALL)�擾���ُ큦�I���i`date`�j ������" | tee -a $LOG_FILE
               rm -f "${proxy_data_pth_simego_all}/get_simego_all.lock"
               exit 1
            else
               echo "������ YDC�� ${FTP_SAKI_IP} �����ߌず�f�[�^(ALL)�擾����I���i`date`�j ������" | tee -a $LOG_FILE
            fi
         else
            echo "�����{�Ԋ��̃p�[�X�y${HB_SIMEGO_ALL_DATA_PTH}�z�����ɕ����̓��t�f�B���N�g��������܂��I" | tee -a $LOG_FILE
            exit 1
         fi
      else
         echo "�������ߌ���t�t�@�C��[${proxy_data_pth_simego_all}/simego_date.tmp]���쐬���܂���B�i`date`�j" | tee -a $LOG_FILE
         exit 1
      fi
      #���ߌ���t�t�@�C���`��(���[�NDB��)
      if [ "${JYOHO_FILE}" = "2" ];then
         echo "������ YDC�� ${FTP_SAKI_IP} �����ߌ���t���t�@�C���擾�J�n�i`date`�j ������"        | tee -a $LOG_FILE
         FTP_FILE "${proxy_data_pth_simego_all}" "${FTP_SAKI_TMP_PATH}" "simego_date.tmp"          | tee -a $LOG_FILE
         echo "������ YDC�� ${FTP_SAKI_IP} �����ߌ���t���t�@�C���擾�I���i`date`�j ������"        | tee -a $LOG_FILE
      fi
      rm -f ${proxy_data_pth_simego_all}/*.exp.Z
      rm -f "${proxy_data_pth_simego_all}/get_simego_all.lock"
   else
      YDC_FILE="${kaisha_cd}_${dmp_kbn}.exp.Z"
      GET_YDCtoE_model                                                                      | tee -a $LOG_FILE
      ls ${proxy_data_pth}/${YDC_FILE} >/dev/null 2>&1
      TS_STATUS=$?
      if [ "${TS_STATUS}" != "0" ];then
         echo "������ YDC�� ${FTP_SAKI_IP} �����ߌず�f�[�^(${YDC_FILE})�擾���ُ큦�I���i`date`�j ������" | tee -a $LOG_FILE
         exit 1
      else
         rm -f ${proxy_data_pth}/${YDC_FILE} |tee -a $LOG_FILE 2&>1
         echo "������ YDC�� ${FTP_SAKI_IP} �����ߌず�f�[�^(${YDC_FILE})�擾����I���i`date`�j ������" | tee -a $LOG_FILE
      fi
   fi
fi
#---------------------------------------------------------------
# �f�[�^�敪�F�ږ� �`������
#---------------------------------------------------------------
if [ "${sh_kbn}" = "3" ];then
   echo "������ YDC�� ${FTP_SAKI_IP} ���ږ⁚�f�[�^�擾�J�n�i`date`�j ������" | tee -a $LOG_FILE
   #---------------------------------------------------------------
   #---- �t�@�C���`�F�b�N�擾
   #---------------------------------------------------------------
   kmn_get_check()
   {
    #---- proxy�T�[�oEND�t�@�C�����폜
    rm -f "${proxy_data_pth_kmn}/${END_FILE}"
    if [ -f "${proxy_data_pth_kmn}/${proxy_hty_file}" ];then
       ZenKai_ymd=`tail -1 "${proxy_data_pth_kmn}/${proxy_hty_file}"`
    else
       ZenKai_ymd=00000000
    fi
    #---- YDC�T�[�oGETEND
    TIME_COUNT=0
    while [ "${TIME_COUNT}" -lt "12" -a ! -f "${proxy_data_pth_kmn}/${END_FILE}" ]
    do
      GET_PROXY_FROM_YDC "${proxy_data_pth_kmn}" "${END_FILE}"        | tee -a $LOG_FILE
      if [ ! -f "${proxy_data_pth_kmn}/${END_FILE}" ];then
         sleep 300
         let TIME_COUNT=TIME_COUNT+1
      else
         break
      fi
    done
    #---- YDC�T�[�oGET�`�F�b�N
    if [ -f "${proxy_data_pth_kmn}/${END_FILE}" ];then
       cat ${proxy_data_pth_kmn}/${END_FILE}
       hb_get_date=`cat ${proxy_data_pth_kmn}/${END_FILE} |sort |tail -1`
       if [ "${flag}" == "yitkin" ];then
          if [ "${KMN_KIJUN_YMD}" != "1" ];then
             hb_get_date="${KMN_KIJUN_YMD}"
          fi
       fi
       if [ $hb_get_date != "" -a $ZenKai_ymd -lt $hb_get_date -a hb_get_date != "${END_FILE}" ];then

          if [ "${flag}" == "yitkin" ];then
             x_ydc_path="${KMN_DMP_PATH}/${hb_get_date}"
             ftp_saki_dmp_path="${FTP_SAKI_KMN_DMP_PATH}/KOMON/${hb_get_date}"
          else
              #---- �p�����[�^�t�@�C���]��
              x_ydc_path="${KMN_DMP_PATH}/PARAM/"
              F_1="${hb_get_date}"
              ftp_saki_dmp_path="${FTP_SAKI_KMN_TMP_PATH}"
              GET_DATA_FROM_YDC "${proxy_data_pth_kmn}" "${F_1}"         | tee -a $LOG_FILE
              #---- �_���v�p�X�ݒ�
              x_ydc_path="${KMN_DMP_PATH}"
              ftp_saki_dmp_path="${FTP_SAKI_KMN_DMP_PATH}/KOMON/CURRENT"
          fi
          GET_DATA_FROM_YDC "${proxy_data_pth_kmn}" "${YDC_FILE}"                    | tee -a $LOG_FILE
          TS_STATUS=$?
          if [ "${TS_STATUS}" != "0" ];then
             echo "������ YDC�� ${FTP_SAKI_IP} ���ږ⁚�f�[�^(${YDC_FILE})�擾���ُ큦�I���i`date`�j ������" | tee -a $LOG_FILE
             #exit 1
          else
           #---- end�t�@�C���]��
           FTP_PUT "${proxy_data_pth_kmn}" "${FTP_SAKI_KMN_TMP_PATH}" "${END_FILE}"        | tee -a $LOG_FILE

           #---- �]���ς݂�DMP�t�@�C�����폜
		rm ${proxy_data_pth_kmn}/*kmn*


           echo "$hb_get_date�̃f�[�^���擾�����B"           | tee -a $LOG_FILE
           echo "$hb_get_date" >> "${proxy_data_pth_kmn}/${proxy_hty_file}" | tee -a $LOG_FILE
           fi
        fi
     else
     echo "[${proxy_data_pth_kmn}/${END_FILE} ]�����݂��܂���B"                 | tee -a $LOG_FILE
     #exit 1
     fi
   }
   #---------------------------------------------------------------
   #---- �T���擾
   #---------------------------------------------------------------
   #---- ��`������
   hb_ipadd="${TX_HB_IP}"
   YDC_FILE="*kmn_*.*"
   YDC_PWD="${YDC_PWD}"
   flag=yitkin
   #---- "YDC�T�[�o�p�X�w��"
   x_ydc_path="${KMN_DMP_PATH}"
   #----  "proxy�T�[�o�p�X�w��"
   proxy_data_pth_kmn=$HOME_PATH/data/kmn/KOMON
   mkdir -p ${proxy_data_pth_kmn}
   #----  "�e�X�g�ʃT�[�o�p�X�w��"
   ftp_saki_dmp_path=${FTP_SAKI_KMN_DMP_PATH}
   ##�G���h�t�@�C���擾�E�ϐ���`
   END_FILE="exp_YDC_KOMON.END"
   #---- �O����t�擾
   proxy_hty_file=proxy_KOMON_history.lst
   kmn_get_check
   #---------------------------------------------------------------
   #---- �����擾
   #---------------------------------------------------------------
   echo "�����������擾������"
   flag=tuni
   #---- "YDC�T�[�o�p�X�w��"
   x_ydc_path="${KMN_DMP_PATH}/CURRENT"
   #---- "proxy�T�[�o�p�X�w��"
   proxy_data_pth_kmn="$HOME_PATH/data/kmn/KOMON/CURRENT"
   mkdir -p ${proxy_data_pth_kmn}
   #---- �G���h�t�@�C���擾�E�ϐ���`
   KMN_DMP_PATH="${KMN_DMP_PATH}/CURRENT"
      #---- �G���h�t�@�C���擾�E�ϐ���`
   END_FILE="exp_YDC_CURRENT.END"
   proxy_hty_file=proxy_CURRENT_history.lst
   kmn_get_check
fi
exit 0
