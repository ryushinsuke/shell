#!/bin/sh
source ~/.bash_profile
#------------------------------------------------------------------------
#DMP取得シェルをコール
#------------------------------------------------------------------------
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 ITK 0 1
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 JTK 0 1
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 NAM 0 1
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 CMN 0 1
#締め後データは別の親シェル起動に変更（20121023）
#/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 2 all 0 1
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 ITK_KYO 0 1
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 JTK_KYO 0 1
/home/ftpuser/syuu/maskdb/sh/GET_YDC_dmp.sh 1 1 1 2 1 NAM_KYO 0 1
#------------------------------------------------------------------------
exit 0
