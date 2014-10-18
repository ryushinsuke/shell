--********************************************************************
--* $Header$
--********************************************************************
--*
--* �V�X�e���h�c   : T-STAR
--* �V�X�e������   : �����s�|�r�s�`�q�_�E���T�C�W���O
--* �r�p�k�h�c     : create_tmp_user.sql
--* �r�p�k����     : TMP���[�U�V�K�pSQL
--* �r�p�k�@�\�T�v : �Ȃ�
--* �Q�Ƃc�a       : �Ȃ�
--* �g�p�t�@�C��   : �Ȃ�
--* ����           : �Ȃ�
--* ��������
--* �N����   �敪 ����       �S����  ���e
--* -------- ---- ---------- ------  --------------------------------
--* 20100125 �V�K GUT        ���Q    �V�K�쐬
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       ��{�̒�`                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- �G���[�R�[�h�̒�`
DEFINE      X_USERNAME  = &1
DEFINE      X_USERPWD  = &2
VARIABLE    sts     NUMBER
WHENEVER SQLERROR EXIT &ERR_CD ROLLBACK
--********************************************************************
--*       �ϐ��̒�`                                                 *
--********************************************************************
DECLARE
    err_msg            VARCHAR2(200);          -- SQL�G���[���b�Z�[�W
    X_SQL              VARCHAR2(512);
    X_COUNT            NUMBER;
--********************************************************************
--*       �J�n����                                                   *
--********************************************************************
BEGIN
    :sts             :=  0;                     -- ���^�[���R�[�h������
    X_COUNT          :=  0;
    X_SQL            := '';
--********************************************************************
--*     TMP���[�U�V�K                                                *
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
