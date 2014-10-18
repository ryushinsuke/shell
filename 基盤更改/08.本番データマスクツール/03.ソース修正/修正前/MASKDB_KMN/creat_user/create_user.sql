--********************************************************************
--* $Header$
--********************************************************************
--*
--* システムＩＤ   : T-STAR
--* システム名称   : 次期Ｔ－ＳＴＡＲダウンサイジング
--* ＳＱＬＩＤ     : 
--* ＳＱＬ名称     : 
--* ＳＱＬ機能概要 : なし
--* 参照ＤＢ       : なし
--* 使用ファイル   : なし
--* 引数           : &1 ユーザ名
--*                  
--* 改訂履歴
--* 年月日   区分 所属       担当者  内容
--* -------- ---- ---------- ------  --------------------------------
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       基本の定義                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- エラーコードの定義
DEFINE      USER_ID   = &1
VARIABLE    sts     NUMBER
WHENEVER SQLERROR EXIT &ERR_CD ROLLBACK
--********************************************************************
--*       変数の定義                                                 *
--********************************************************************
DECLARE
    err_msg            VARCHAR2(200);          -- SQLエラーメッセージ
    X_SQL              VARCHAR2(256);
    X_SQL1             VARCHAR2(256);
    X_SQL2             VARCHAR2(512);
    X_UPDATE           VARCHAR2(3800);
    X_MASK_TBNAME      VARCHAR2(30);
    X_TBL_NAME         USER_TABLES.TABLE_NAME%TYPE;
    SET_SQL            VARCHAR2(512);
    WHERE_SQL          VARCHAR2(256);
    X_FLG              NUMBER;

    TYPE CUR_PROC      IS REF CURSOR;
    C_PROC             CUR_PROC;
    C_PROC1            CUR_PROC;
    C_PROC2            CUR_PROC;

--********************************************************************
--*       開始処理                                                   *
--********************************************************************
BEGIN
    :sts             :=  0;                     -- リターンコード初期化
    X_MASK_TBNAME    := '';
    X_TBL_NAME       := '';
    X_SQL            := '';
    X_SQL1           := '';
    X_SQL2           := '';
    X_UPDATE         := '';
    SET_SQL          := '';
    WHERE_SQL        := '';
    X_FLG            :=  0;
--********************************************************************
--*     マスク処理                                                   *
--********************************************************************
-- Create the user 
X_SQL := 'create user &USER_ID 
          identified by "&USER_ID"
          default tablespace USERS
          temporary tablespace TEMP
          profile DEFAULT
          quota unlimited on users';
X_SQL1 := 'create sequence &USER_ID' || '.SEQ_9003_9999
           minvalue 1
           maxvalue 999999999999999999999999999
           start with 1
           increment by 1
           cache 1000';
X_SQL2 := 'create sequence &USER_ID' || '.SEQ_9005_9999
           minvalue 1
           maxvalue 999999999999999999999999999
           start with 1
           increment by 1
           cache 1000';
EXECUTE IMMEDIATE  X_SQL ;
-- Grant/Revoke role privileges 
EXECUTE IMMEDIATE 'grant aq_administrator_role to &USER_ID';
EXECUTE IMMEDIATE 'grant ktstar to ' || '&USER_ID';
EXECUTE IMMEDIATE 'grant EXP_FULL_DATABASE to ' || '&USER_ID';
EXECUTE IMMEDIATE 'grant IMP_FULL_DATABASE to ' || '&USER_ID';
EXECUTE IMMEDIATE  X_SQL1 ;
EXECUTE IMMEDIATE  X_SQL2 ;
EXECUTE IMMEDIATE 'grant RESOURCE to ' || '&USER_ID';

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
