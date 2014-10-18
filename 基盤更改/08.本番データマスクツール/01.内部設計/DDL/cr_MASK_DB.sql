--**********************************************************
--  システム名:  顧問ODW
--  テーブルID:  MASK_DB
--  テーブル名:  基準系マスクテーブル
--      作成日:  2013/10/08
--      作成者:  GUT
--    変更履歴:  初版作成
--**********************************************************

DROP TABLE MASK_DB
/

CREATE TABLE MASK_DB (
    TABLE_NAME                    VARCHAR2(30),
    WHERE_NAIYOU                  VARCHAR2(200),
    UP_CLM_NAME                   VARCHAR2(30),
    SET_JOUHOU                    VARCHAR2(300),
    UPD_USER                      VARCHAR2(30),
    UPD_YMD                       VARCHAR2(8)
    )
/

--    カラムコメント
COMMENT ON COLUMN MASK_DB.TABLE_NAME                                      IS 'テーブルID'
/
COMMENT ON COLUMN MASK_DB.WHERE_NAIYOU                                    IS 'マスク対象'
/
COMMENT ON COLUMN MASK_DB.UP_CLM_NAME                                     IS '項目名'
/
COMMENT ON COLUMN MASK_DB.SET_JOUHOU                                      IS 'マスク後内容'
/
COMMENT ON COLUMN MASK_DB.UPD_USER                                        IS '更新者'
/
COMMENT ON COLUMN MASK_DB.UPD_YMD                                         IS '更新日付'
/
