update FS_TB006_SVR_JOUHOU 
set OLD_COMPARE_DATE = NEW_COMPARE_DATE, NEW_COMPARE_DATE = '20140324', 
NEW_COMPARE_FLAG = '1', COMPARE_RESULT = '0' 
where SVR_KBN = 'TX' and SVR_GRP_ID = 'pl' and SVR_ID = 'test'; 
commit;
