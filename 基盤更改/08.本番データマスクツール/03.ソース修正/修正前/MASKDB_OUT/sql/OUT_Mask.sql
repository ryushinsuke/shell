--********************************************************************
--* $Header$
--********************************************************************
--*
--* �V�X�e���h�c   : T-STAR
--* �V�X�e������   : �����s�|�r�s�`�q�_�E���T�C�W���O
--* �r�p�k�h�c     : OUT_Mask.sql
--* �r�p�k����     : OUT�n�f�[�^�}�X�N�pSQL
--* �r�p�k�@�\�T�v : �Ȃ�
--* �Q�Ƃc�a       : �Ȃ�
--* �g�p�t�@�C��   : �Ȃ�
--* ����           : ���X�L�[�}��
--* ��������
--* �N����   �敪 ����       �S����  ���e
--* -------- ---- ---------- ------  --------------------------------
--* 20100127 �V�K GUT        ���Q    �V�K�쐬
--*
--********************************************************************
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
--********************************************************************
--*       ��{�̒�`                                                 *
--********************************************************************
DEFINE      ERR_CD      = 8                  -- �G���[�R�[�h�̒�`
DEFINE      JHDBNAME    = &1
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
--�}�X�N�Ώۏ��e�[�u������A�Ώۘ_���e�[�u�����擾
X_SQL := ' SELECT TABLE_NAME,WHERE_NAIYOU FROM '
      || '&JHDBNAME'
      || '.MASK_DB_O GROUP BY TABLE_NAME,WHERE_NAIYOU ';
OPEN C_PROC FOR X_SQL;
LOOP
    FETCH C_PROC INTO X_MASK_TBNAME,WHERE_SQL;
    EXIT WHEN C_PROC%NOTFOUND;
    --�}�X�N�ΏۃX�L�[�}���ɁA���ۑΏۃe�[�u�����擾
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
        --�Y���_���e�[�u���̍X�V���e�擾
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
            --�擾�������e����A�X�V�pSQL�쐬
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
        --�擾�����X�V��������A�X�V�pSQL�쐬
        IF WHERE_SQL IS NOT NULL
        THEN
            X_UPDATE := X_UPDATE
                     || ' WHERE '
                     || WHERE_SQL;
        END IF;
        --�X�V�pSQL�쐬�����A���s����
        EXECUTE IMMEDIATE  X_UPDATE ;
    END LOOP;
    CLOSE C_PROC1;
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
