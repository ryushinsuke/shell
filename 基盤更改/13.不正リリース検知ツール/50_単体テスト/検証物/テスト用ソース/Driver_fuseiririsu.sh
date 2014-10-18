#!/bin/sh
#set -x
#環境変数を設定
export SJ_PEX_FRAME=TEST_GUT_TX
#シェルを実行
sh B21SMA200.sh
if [ "$?" != 0 ]
then
   echo "B21SMA200は異常終了です。"
   exit 9
fi

sh B21SMA202.sh
if [ "$?" != 0 ]
then
   echo "B21SMA202は異常終了です。"
   exit 9
fi

sh B21SMA204.sh NEW
if [ "$?" != 0 ]
then
   echo "B21SMA204_NEWは異常終了です。"
   exit 9
fi

sh B21SMA203.sh
if [ "$?" != 0 ]
then
   echo "B21SMA203は異常終了です。"
   exit 9
fi

sh B21SMA204.sh OLD
if [ "$?" != 0 ]
then
   echo "B21SMA204_OLDは異常終了です。"
   exit 9
fi

sh B21SMA205.sh
if [ "$?" != 0 ]
then
   echo "B21SMA205は異常終了です。"
   exit 9
fi

sh B21SMA206.sh
if [ "$?" != 0 ]
then
   echo "B21SMA206は異常終了です。"
   exit 9
fi

sh B21SMA207.sh
if [ "$?" != 0 ]
then
   echo "B21SMA207は異常終了です。"
   exit 9
fi
