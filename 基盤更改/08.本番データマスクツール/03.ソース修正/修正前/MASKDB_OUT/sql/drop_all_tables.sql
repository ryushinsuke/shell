--********************************************************************
--* $Header$
--********************************************************************
--*
--* �V�X�e���h�c   : T-STAR
--* �V�X�e������   : �����s�|�r�s�`�q�_�E���T�C�W���O
--* �r�p�k�h�c     : drop_all_tables.sql
--* �r�p�k����     : �S�e�[�u���폜�pSQL
--* �r�p�k�@�\�T�v : �Ȃ�
--* �Q�Ƃc�a       : �Ȃ�
--* �g�p�t�@�C��   : �Ȃ�
--* ����           : �Ȃ�
--* ��������
--* �N����   �敪 ����       �S����  ���e
--* -------- ---- ---------- ------  --------------------------------
--* 20100122 �V�K GUT        ���Q    �V�K�쐬
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       ��{�̒�`                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- �G���[�R�[�h�̒�`
VARIABLE    sts     NUMBER
WHENEVER SQLERROR EXIT &ERR_CD ROLLBACK
--********************************************************************
--*       �ϐ��̒�`                                                 *
--********************************************************************
DECLARE
    err_msg            VARCHAR2(200);          -- SQL�G���[���b�Z�[�W
    X_SQL              VARCHAR2(256);
    X_DROP             VARCHAR2(256);
    X_TBL_NAME         USER_TABLES.TABLE_NAME%TYPE;
    X_VIEW_NAME        USER_VIEWS.VIEW_NAME%TYPE;
    X_SEQUENCE_NAME    USER_SEQUENCES.SEQUENCE_NAME%TYPE;

    TYPE CUR_PROC      IS REF CURSOR;
    C_PROC             CUR_PROC;

--********************************************************************
--*       �J�n����                                                   *
--********************************************************************
BEGIN
    :sts             :=  0;                     -- ���^�[���R�[�h������
    X_TBL_NAME       := '';
    X_SQL            := '';
    X_DROP           := '';
    X_VIEW_NAME      := '';
    X_SEQUENCE_NAME  := '';
--********************************************************************
--*     �e�[�u���N���A�`�F�b�N                                       *
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
--    DBMS_OUTPUT.PUT_LINE(X_TBL_NAME||'�폜�����B');
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
--*           �G���[����                                             *
--********************************************************************
EXCEPTION
    WHEN    OTHERS          THEN
        err_msg := SUBSTR( SQLERRM, 1,100 );
        dbms_output.put_line( err_msg );
        ROLLBACK;
        dbms_output.put_line('���[���o�b�N���������܂����B');
        :sts     :=   &ERR_CD;      -- ���^�[���R�[�h�ɃG���[�Z�b�g
END;
/
--********************************************************************
--*           PL/SQL�̃��^�[���R�[�h�擾                             *
--********************************************************************
COLUMN  pl_sql_sts  NEW_VALUE   rtcd
SELECT  :sts AS pl_sql_sts  FROM DUAL;
EXIT rtcd
dbms_output.put_line( 'rtcd = ' || rtcd || );
