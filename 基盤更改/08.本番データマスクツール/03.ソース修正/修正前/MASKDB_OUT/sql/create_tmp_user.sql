--********************************************************************
--* $Header$
--********************************************************************
--*
--* システムＩＤ   : T-STAR
--* システム名称   : 次期Ｔ－ＳＴＡＲダウンサイジング
--* ＳＱＬＩＤ     : create_tmp_user.sql
--* ＳＱＬ名称     : TMPユーザ新規用SQL
--* ＳＱＬ機能概要 : なし
--* 参照ＤＢ       : なし
--* 使用ファイル   : なし
--* 引数           : なし
--* 改訂履歴
--* 年月日   区分 所属       担当者  内容
--* -------- ---- ---------- ------  --------------------------------
--* 20100125 新規 GUT        羅鵬    新規作成
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       基本の定義                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- エラーコードの定義
DEFINE      X_USERNAME  = &1
DEFINE      X_USERPWD  = &2
VARIABLE    sts     NUMBER
WHENEVER SQLERROR EXIT &ERR_CD ROLLBACK
--********************************************************************
--*       変数の定義                                                 *
--********************************************************************
DECLARE
    err_msg            VARCHAR2(200);          -- SQLエラーメッセージ
    X_SQL              VARCHAR2(512);
    X_COUNT            NUMBER;
--********************************************************************
--*       開始処理                                                   *
--********************************************************************
BEGIN
    :sts             :=  0;                     -- リターンコード初期化
    X_COUNT          :=  0;
    X_SQL            := '';
--********************************************************************
--*     TMPユーザ新規                                                *
--********************************************************************
SELECT COUNT(USERNAME) INTO X_COUNT FROM ALL_USERS WHERE USERNAME = '&X_USERNAME';
IF X_COUNT = 0
THEN
    X_SQL := 'CREATE USER '
          || '&X_USERNAME'
          || ' IDENTIFIED BY "'
          || '&X_USERPWD'
          || '" DEFAULT TABLESPACE TBS_COMMON'
          || ' TEMPORARY TABLESPACE TEMP'
          || ' PROFILE DEFAULT '
          || 'QUOTA UNLIMITED ON TBS_COMMON';
--          || 'QUOTA UNLIMITED ON TBS_CMN_AQ '
--          || 'QUOTA UNLIMITED ON TBS_CMN_COMMON '
--          || 'QUOTA UNLIMITED ON TBS_ITK_COMMON '
--          || 'QUOTA UNLIMITED ON TBS_JTK_COMMON '
--          || 'QUOTA UNLIMITED ON TBS_NAM_COMMON '
--          || 'QUOTA UNLIMITED ON USERS';
    EXECUTE IMMEDIATE  X_SQL ;
    X_SQL := 'GRANT exp_full_database TO '
          || '&X_USERNAME';
    EXECUTE IMMEDIATE  X_SQL ;
    X_SQL := 'GRANT imp_full_database TO '
          || '&X_USERNAME';
    EXECUTE IMMEDIATE  X_SQL ;
    X_SQL := 'GRANT resource TO '
          || '&X_USERNAME';
    EXECUTE IMMEDIATE  X_SQL ;
    X_SQL := 'GRANT tstar_connect TO '
          || '&X_USERNAME';
    EXECUTE IMMEDIATE  X_SQL ;
END IF;
COMMIT;
--********************************************************************
--*           エラー処理                                             *
--********************************************************************
EXCEPTION
    WHEN    OTHERS          THEN
        err_msg := SUBSTR( SQLERRM, 1,100 );
        dbms_output.put_line( err_msg );
        ROLLBACK;
        dbms_output.put_line('ロールバックが完了しました。');
        :sts     :=   &ERR_CD;      -- リターンコードにエラーセット
END;
/
--********************************************************************
--*           PL/SQLのリターンコード取得                             *
--********************************************************************
COLUMN  pl_sql_sts  NEW_VALUE   rtcd
SELECT  :sts AS pl_sql_sts  FROM DUAL;
EXIT rtcd
dbms_output.put_line( 'rtcd = ' || rtcd || );
