DELETE FROM FS_TB002_MODULE_ELIB B
 WHERE (B.SVR_GRP_ID, B.HONGW_DSTSK_PATH, B.KNRBKKN_FILE_ID, B.KNRBKKN_TIMESTAMP) NOT IN
       (SELECT A.SVR_GRP_ID,
               A.HONGW_DSTSK_PATH,
               A.KNRBKKN_FILE_ID,
               MAX(A.KNRBKKN_TIMESTAMP)
          FROM FS_TB002_MODULE_ELIB A
         GROUP BY A.SVR_GRP_ID, A.HONGW_DSTSK_PATH, A.KNRBKKN_FILE_ID);