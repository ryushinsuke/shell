#!/bin/sh
#set -x
#���ϐ���ݒ�
export SJ_PEX_FRAME=TEST_GUT_TX
#�V�F�������s
sh B21SMA200.sh
if [ "$?" != 0 ]
then
   echo "B21SMA200�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA202.sh
if [ "$?" != 0 ]
then
   echo "B21SMA202�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA204.sh NEW
if [ "$?" != 0 ]
then
   echo "B21SMA204_NEW�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA203.sh
if [ "$?" != 0 ]
then
   echo "B21SMA203�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA204.sh OLD
if [ "$?" != 0 ]
then
   echo "B21SMA204_OLD�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA205.sh
if [ "$?" != 0 ]
then
   echo "B21SMA205�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA206.sh
if [ "$?" != 0 ]
then
   echo "B21SMA206�ُ͈�I���ł��B"
   exit 9
fi

sh B21SMA207.sh
if [ "$?" != 0 ]
then
   echo "B21SMA207�ُ͈�I���ł��B"
   exit 9
fi
