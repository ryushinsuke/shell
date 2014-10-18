--********************************************************************
--* $Header$
--********************************************************************
--*
--* システムＩＤ   : T-STAR
--* システム名称   : 次期Ｔ－ＳＴＡＲダウンサイジング
--* ＳＱＬＩＤ     : OUT_Mask.sql
--* ＳＱＬ名称     : OUT系データマスク用SQL
--* ＳＱＬ機能概要 : なし
--* 参照ＤＢ       : なし
--* 使用ファイル   : なし
--* 引数           : 情報スキーマ名
--* 改訂履歴
--* 年月日   区分 所属       担当者  内容
--* -------- ---- ---------- ------  --------------------------------
--* 20100127 新規 GUT        羅鵬    新規作成
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       基本の定義                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- エラーコードの定義
DEFINE      JHDBNAME    = &1
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
--マスク対象情報テーブルから、対象論理テーブル名取得
X_SQL := ' SELECT TABLE_NAME,WHERE_NAIYOU FROM '
      || '&JHDBNAME'
      || '.MASK_DB_O GROUP BY TABLE_NAME,WHERE_NAIYOU ';
OPEN C_PROC FOR X_SQL;
LOOP
    FETCH C_PROC INTO X_MASK_TBNAME,WHERE_SQL;
    EXIT WHEN C_PROC%NOTFOUND;
    --マスク対象スキーマ中に、実際対象テーブル名取得
    X_SQL1 := ' SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE '''
           || X_MASK_TBNAME
           || '%''';
    OPEN C_PROC1 FOR X_SQL1;
    LOOP
        FETCH C_PROC1 INTO X_TBL_NAME;
        EXIT WHEN C_PROC1%NOTFOUND;
        X_UPDATE := 'UPDATE '
                 || X_TBL_NAME
                 || ' SET ';
        --該当論理テーブルの更新内容取得
        IF WHERE_SQL IS NOT NULL
        THEN
            X_SQL2 := ' SELECT UP_CLM_NAME || ''='' || SET_JOUHOU FROM '
                   || '&JHDBNAME'
                   || '.MASK_DB_O WHERE TABLE_NAME = '''
                   || X_MASK_TBNAME
                   || ''' AND WHERE_NAIYOU = '''
                   || REPLACE(WHERE_SQL,'''','''''')
                   || '''';
        ELSE
            X_SQL2 := ' SELECT UP_CLM_NAME || ''='' || SET_JOUHOU FROM '
                   || '&JHDBNAME'
                   || '.MASK_DB_O WHERE TABLE_NAME = '''
                   || X_MASK_TBNAME
                   || ''' AND WHERE_NAIYOU IS NULL ' ;
        END IF;
        X_FLG := 1;
        OPEN C_PROC2 FOR X_SQL2;
        LOOP
            FETCH C_PROC2 INTO SET_SQL;
            EXIT WHEN C_PROC2%NOTFOUND;
            --取得した内容から、更新用SQL作成
            IF SET_SQL <> '='
            THEN
                IF X_FLG = 1
                THEN
                    X_UPDATE := X_UPDATE
                             || SET_SQL;
                ELSE
                    X_UPDATE := X_UPDATE
                             || ','
                             || SET_SQL;
                END IF;
                X_FLG := X_FLG + 1;
            END IF;
        END LOOP;
        CLOSE C_PROC2;
        --取得した更新条件から、更新用SQL作成
        IF WHERE_SQL IS NOT NULL
        THEN
            X_UPDATE := X_UPDATE
                     || ' WHERE '
                     || WHERE_SQL;
        END IF;
        --更新用SQL作成した、実行する
        EXECUTE IMMEDIATE  X_UPDATE ;
    END LOOP;
    CLOSE C_PROC1;
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
