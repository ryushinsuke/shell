#!/bin/sh
source ~/.bash_profile

################
##  �����ݒ�  ##
################
TARGET_DATE=$1

#################################################################
## PATH(/share/YDC_DMP) �����̎w����t�t�H���_(def:�O���O)�폜 ##
#################################################################
WORK_PATH=$(cd $(dirname $0);pwd)
TARGET_PATH="/share/YDC_DMP"
if [ $# -eq 0 ];then
  TARGET_DATE=`date -d '3 days ago' '+%Y%m%d'`
fi
test -z "${TARGET_DATE}" && (echo "�폜���������t�t�H���_���w�肵�Ă��������I" && exit 1)
LOG_FILE="${WORK_PATH}/../log/TmpFolderDel.log"
test -e "${WORK_PATH}/../log" || mkdir -p "${WORK_PATH}/../log"

#�p�X�`�F���W
cd ${TARGET_PATH} 2>/dev/null || (echo "PATH(${TARGET_PATH})�`�F���W ERROR." && exit 1)

############################################################
##     Main Shell                                         ##
############################################################
echo "PATH(${TARGET_PATH})����DATE(${TARGET_DATE})��Folder�폜�J�n(`date`)" | tee -a ${LOG_FILE}
for rm_target_path in `find  -name "${TARGET_DATE}" -type d`
do
  cd ${TARGET_PATH} && rm -r ${rm_target_path}
  echo "���tPATH(${rm_target_path})���폜���܂����B"                        | tee -a ${LOG_FILE}
done
echo "PATH(${TARGET_PATH})����DATE(${TARGET_DATE})��Folder�폜�I��(`date`)" | tee -a ${LOG_FILE}

#����I��
exit 0
