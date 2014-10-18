DELETE FROM &1 B
 WHERE EXISTS (SELECT *
          FROM (SELECT SVR_GRP_ID
                  FROM KM_TB004_EXCLUDE_DATA
                 WHERE SVR_KBN = '&2'
                   AND ITEM_KBN = '1'
                   AND CLASSIFG_KBN = '&3') A
         WHERE A.SVR_GRP_ID = B.SVR_GRP_ID);
COMMIT;
DELETE FROM &1 B
 WHERE EXISTS (SELECT *
          FROM (SELECT SVR_GRP_ID,
                       HONGW_DSTSK_PATH
                  FROM KM_TB004_EXCLUDE_DATA
                 WHERE SVR_KBN = '&2'
                   AND ITEM_KBN = '2'
                   AND CLASSIFG_KBN = '&3') A
         WHERE A.SVR_GRP_ID = B.SVR_GRP_ID
           AND A.HONGW_DSTSK_PATH = B.HONGW_DSTSK_PATH);
COMMIT;
DELETE FROM &1 B
 WHERE EXISTS (SELECT *
          FROM (SELECT SVR_GRP_ID,
                       HONGW_DSTSK_PATH,
                       KNRBKKN_FILE_ID
                  FROM KM_TB004_EXCLUDE_DATA
                 WHERE SVR_KBN = '&2'
                   AND ITEM_KBN = '3'
                   AND CLASSIFG_KBN = '&3') A
         WHERE A.SVR_GRP_ID = B.SVR_GRP_ID
           AND A.HONGW_DSTSK_PATH = B.HONGW_DSTSK_PATH
           AND A.KNRBKKN_FILE_ID = B.KNRBKKN_FILE_ID);
COMMIT;
DELETE FROM &1 B
 WHERE EXISTS (SELECT *
          FROM (SELECT HON_SVR_ID
                  FROM KM_TB004_EXCLUDE_DATA
                 WHERE SVR_KBN = '&2'
                   AND ITEM_KBN = '4'
                   AND CLASSIFG_KBN = '&3') A
         WHERE A.HON_SVR_ID = B.SVR_ID);
COMMIT;
DELETE FROM &1 B
 WHERE EXISTS (SELECT *
          FROM (SELECT SVR_GRP_ID,
                       HONGW_DSTSK_PATH,
                       KNRBKKN_FILE_ID,
                       HON_SVR_ID
                  FROM KM_TB004_EXCLUDE_DATA
                 WHERE SVR_KBN = '&2'
                   AND ITEM_KBN = '5'
                   AND CLASSIFG_KBN = '&3') A
         WHERE A.SVR_GRP_ID = B.SVR_GRP_ID
           AND A.HONGW_DSTSK_PATH = B.HONGW_DSTSK_PATH
           AND A.KNRBKKN_FILE_ID = B.KNRBKKN_FILE_ID
           AND A.HON_SVR_ID = B.SVR_ID);
COMMIT;
DELETE FROM &1 B
 WHERE EXISTS (SELECT *
          FROM (SELECT SVR_GRP_ID,
                       HONGW_DSTSK_PATH,
                       KNRBKKN_FILE_ID
                  FROM KM_TB004_EXCLUDE_DATA
                 WHERE SVR_KBN = '&2'
                   AND ITEM_KBN = '6'
                   AND CLASSIFG_KBN = '&3') A
         WHERE A.SVR_GRP_ID = B.SVR_GRP_ID
           AND A.HONGW_DSTSK_PATH = B.HONGW_DSTSK_PATH
           AND B.KNRBKKN_FILE_ID LIKE A.KNRBKKN_FILE_ID);
COMMIT;
