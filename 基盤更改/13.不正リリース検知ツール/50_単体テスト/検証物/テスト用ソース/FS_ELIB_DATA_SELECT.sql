SELECT C.svr_grp_id,
       C.hongw_dstsk_path,
       A.file_id,
       DATE_FORMAT(A.knrbkkn_timestamp, '%Y%m%d%H%i%s') AS knrbkkn_timestamp,
       A.knrbkkn_size,
       A.hon_rep_libthm_id
  FROM t_hon_knrbkkn_jokyo A, m_knrbkkn B, m_dst_langtype C
 WHERE A.site_id = B.site_id
   AND A.prj_id = B.prj_id
   AND A.system_id = B.system_id
   AND A.knrbkkn_id = B.knrbkkn_id
   AND A.knrbkkn_skey = B.knrbkkn_skey
   AND A.hon_lib_ver =
       (SELECT MAX(E.hon_lib_ver)
          FROM t_hon_knrbkkn_jokyo E
         WHERE E.site_id = B.site_id
           AND E.prj_id = B.prj_id
           AND E.system_id = B.system_id
           AND E.knrbkkn_id = B.knrbkkn_id
           AND E.knrbkkn_skey = B.knrbkkn_skey)
   AND B.type_id = C.type_id
/*  2014/03/12 eLIBSYS2.0でのモジュール廃止機能への対応 START */
/*   AND B.system_id = C.dstsk_bnri_id; */
   AND B.system_id = C.dstsk_bnri_id
   AND B.del_flg = '0'
   AND C.del_flg = '0';
/*  2014/03/12 eLIBSYS2.0でのモジュール廃止機能への対応 END */
