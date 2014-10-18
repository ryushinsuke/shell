--********************************************************************
--* $Header$
--********************************************************************
--*
--* システムＩＤ   : T-STAR
--* システム名称   : 次期Ｔ－ＳＴＡＲダウンサイジング
--* ＳＱＬＩＤ     : drop_all_tables.sql
--* ＳＱＬ名称     : 全テーブル削除用SQL
--* ＳＱＬ機能概要 : なし
--* 参照ＤＢ       : なし
--* 使用ファイル   : なし
--* 引数           : なし
--* 改訂履歴
--* 年月日   区分 所属       担当者  内容
--* -------- ---- ---------- ------  --------------------------------
--* 20100122 新規 GUT        羅鵬    新規作成
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       基本の定義                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- エラーコードの定義
VARIABLE    sts     NUMBER
WHENEVER SQLERROR EXIT &ERR_CD ROLLBACK
--********************************************************************
--*       変数の定義                                                 *
--********************************************************************
DECLARE
    err_msg            VARCHAR2(200);          -- SQLエラーメッセージ
    X_SQL              VARCHAR2(256);
    X_DROP             VARCHAR2(256);
    X_TBL_NAME         USER_TABLES.TABLE_NAME%TYPE;
    X_VIEW_NAME        USER_VIEWS.VIEW_NAME%TYPE;
    X_SEQUENCE_NAME    USER_SEQUENCES.SEQUENCE_NAME%TYPE;

    TYPE CUR_PROC      IS REF CURSOR;
    C_PROC             CUR_PROC;

--********************************************************************
--*       開始処理                                                   *
--********************************************************************
BEGIN
    :sts             :=  0;                     -- リターンコード初期化
    X_TBL_NAME       := '';
    X_SQL            := '';
    X_DROP           := '';
    X_VIEW_NAME      := '';
    X_SEQUENCE_NAME  := '';
--********************************************************************
--*     テーブルクリアチェック                                       *
--********************************************************************
X_SQL := ' SELECT TABLE_NAME FROM USER_TABLES WHERE IOT_TYPE IS NULL ';
OPEN C_PROC FOR X_SQL;
LOOP
    FETCH C_PROC INTO X_TBL_NAME;
    EXIT WHEN C_PROC%NOTFOUND;
    IF X_TBL_NAME = 'AQ_TBL' OR SUBSTR(X_TBL_NAME,1,3) = 'AQ$'
    THEN
        DBMS_AQADM.DROP_QUEUE_TABLE(X_TBL_NAME,TRUE);
    ELSE
        X_DROP  :='DROP TABLE '
             || X_TBL_NAME
             || ' CASCADE CONSTRAINTS PURGE';
        EXECUTE IMMEDIATE  X_DROP ;
    END IF;
--    DBMS_OUTPUT.PUT_LINE(X_TBL_NAME||'削除完了。');
END LOOP ;
CLOSE C_PROC;
COMMIT;

--X_SQL := ' SELECT SEQUENCE_NAME FROM USER_SEQUENCES ';
--OPEN C_PROC FOR X_SQL;
--LOOP
--    FETCH C_PROC INTO X_SEQUENCE_NAME;
--    EXIT WHEN C_PROC%NOTFOUND;
--    X_DROP  :='DROP SEQUENCE '
--         || X_SEQUENCE_NAME;
--    EXECUTE IMMEDIATE  X_DROP ;
--END LOOP ;
--CLOSE C_PROC;
--COMMIT;

X_SQL := ' SELECT VIEW_NAME FROM USER_VIEWS ';
OPEN C_PROC FOR X_SQL;
LOOP
    FETCH C_PROC INTO X_VIEW_NAME;
    EXIT WHEN C_PROC%NOTFOUND;
    X_DROP  :='DROP VIEW '
         || X_VIEW_NAME;
    EXECUTE IMMEDIATE  X_DROP ;
END LOOP ;
CLOSE C_PROC;
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
