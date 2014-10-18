INSERT /*+ APPEND */
INTO FS_TB001_FUSEI_RELEASE
  SELECT '&1',
         T.SVR_GRP_ID,
         T.SVR_ID,
         T.HONGW_DSTSK_PATH,
         T.KNRBKKN_FILE_ID,
         T.COMPARE_FLAG,
         T.ELIBSYS_KNRBKKN_TIMESTAMP,
         T.ELIBSYS_KNRBKKN_SIZE,
         T.ELIBSYS_HON_REP_LIBTHM_ID,
         T.HONBAN_KNRBKKN_TIMESTAMP,
         T.HONBAN_KNRBKKN_SIZE,
         T.HONBAN_CHECK_SUM,
         ' ',
         '1',
         ' ',
         TO_CHAR(SYSDATE, 'YYYYMMDD'),
         ' ',
         ' ',
         T.ERROR_TYPE,
         ' '
    FROM FS_TB005_NEW_FUSEI_&1 T
   WHERE NOT EXISTS
        (SELECT NULL FROM FS_TB001_FUSEI_RELEASE M
          WHERE M.SVR_KBN                   = '&1'
            AND M.SVR_GRP_ID                = T.SVR_GRP_ID
            AND M.SVR_ID                    = T.SVR_ID
            AND M.HONGW_DSTSK_PATH          = T.HONGW_DSTSK_PATH
            AND M.KNRBKKN_FILE_ID           = T.KNRBKKN_FILE_ID
            AND M.COMPARE_FLAG              = T.COMPARE_FLAG
            AND M.ELIBSYS_KNRBKKN_TIMESTAMP = T.ELIBSYS_KNRBKKN_TIMESTAMP
            AND M.ELIBSYS_KNRBKKN_SIZE      = T.ELIBSYS_KNRBKKN_SIZE
            AND M.HONBAN_KNRBKKN_TIMESTAMP  = T.HONBAN_KNRBKKN_TIMESTAMP
            AND M.HONBAN_KNRBKKN_SIZE       = T.HONBAN_KNRBKKN_SIZE
            AND M.HONBAN_CHECK_SUM          = T.HONBAN_CHECK_SUM );
COMMIT;
