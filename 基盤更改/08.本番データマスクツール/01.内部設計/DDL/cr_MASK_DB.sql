--**********************************************************
--  �V�X�e����:  �ږ�ODW
--  �e�[�u��ID:  MASK_DB
--  �e�[�u����:  ��n�}�X�N�e�[�u��
--      �쐬��:  2013/10/08
--      �쐬��:  GUT
--    �ύX����:  ���ō쐬
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

--    �J�����R�����g
COMMENT ON COLUMN MASK_DB.TABLE_NAME                                      IS '�e�[�u��ID'
/
COMMENT ON COLUMN MASK_DB.WHERE_NAIYOU                                    IS '�}�X�N�Ώ�'
/
COMMENT ON COLUMN MASK_DB.UP_CLM_NAME                                     IS '���ږ�'
/
COMMENT ON COLUMN MASK_DB.SET_JOUHOU                                      IS '�}�X�N����e'
/
COMMENT ON COLUMN MASK_DB.UPD_USER                                        IS '�X�V��'
/
COMMENT ON COLUMN MASK_DB.UPD_YMD                                         IS '�X�V���t'
/
