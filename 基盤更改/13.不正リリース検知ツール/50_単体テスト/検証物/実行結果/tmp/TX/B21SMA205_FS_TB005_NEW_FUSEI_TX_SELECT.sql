spool /home/apl/test_gut/tmp/TX/B21SMA205_FS_TB005_NEW_FUSEI_TX_SELECT.txt
select TBL_ID,TBL_ITEM_ID,TBL_ITEM_DATA_TYPE,TBL_ITEM_NUM,TBL_ITEM_NULL_SEIY,PK_KBN
from KM_TB003_DBITEM where TBL_ID = 'FS_TB005_NEW_FUSEI_TX' order by TBL_ITEM_NO; 
spool off
