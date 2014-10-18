--********************************************************************
--* $Header$
--********************************************************************
--*
--* �V�X�e���h�c   : T-STAR
--* �V�X�e������   : �����s�|�r�s�`�q�_�E���T�C�W���O
--* �r�p�k�h�c     : 
--* �r�p�k����     : 
--* �r�p�k�@�\�T�v : �Ȃ�
--* �Q�Ƃc�a       : �Ȃ�
--* �g�p�t�@�C��   : �Ȃ�
--* ����           : &1 ���[�U��
--*                  
--* ��������
--* �N����   �敪 ����       �S����  ���e
--* -------- ---- ---------- ------  --------------------------------
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       ��{�̒�`                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- �G���[�R�[�h�̒�`
DEFINE      USER_ID   = &1
VARIABLE    sts     NUMBER
WHENEVER SQLERROR EXIT &ERR_CD ROLLBACK
--********************************************************************
--*       �ϐ��̒�`                                                 *
--********************************************************************
DECLARE
    err_msg            VARCHAR2(200);          -- SQL�G���[���b�Z�[�W
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
--*       �J�n����                                                   *
--********************************************************************
BEGIN
    :sts             :=  0;                     -- ���^�[���R�[�h������
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
--*     �}�X�N����                                                   *
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
