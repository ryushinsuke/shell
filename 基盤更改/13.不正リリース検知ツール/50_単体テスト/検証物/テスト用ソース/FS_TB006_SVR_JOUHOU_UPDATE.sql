UPDATE FS_TB006_SVR_JOUHOU A
   SET COMPARE_RESULT = DECODE((SELECT COUNT(1)
                               FROM FS_TB005_NEW_FUSEI_&1 B
                              WHERE B.SVR_GRP_ID = A.SVR_GRP_ID
                                AND B.SVR_ID = A.SVR_ID),
                             0,
                             '0',
                             '1')
 WHERE A.NEW_COMPARE_FLAG = '1'
   AND A.SVR_KBN = '&1';