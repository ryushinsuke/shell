spool /ext/mnt5/export/MASKDB/sh/../tmp/TBNAME_2001_CD.txt
SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE '%/_2001' ESCAPE '/' AND SUBSTR(TABLE_NAME,1,INSTR(TABLE_NAME,'_2001')-1) NOT IN (SELECT DISTINCT TABLE_NAME FROM DATAMASK_JYOUHOU.MASK_DB_O);
spool off
