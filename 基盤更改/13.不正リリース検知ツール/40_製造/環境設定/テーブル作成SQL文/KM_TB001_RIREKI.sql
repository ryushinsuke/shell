create table KM_TB001_RIREKI
(
  SVR_KBN                   VARCHAR2 (6)   default ' ' not null,
  SVR_GRP_ID                VARCHAR2 (255) default ' ' not null,
  SVR_ID                    VARCHAR2 (255) default ' ' not null,
  HONGW_DSTSK_PATH          VARCHAR2 (255) default ' ' not null,
  KNRBKKN_FILE_ID           VARCHAR2 (255) default ' ' not null,
  COMPARE_FLAG              VARCHAR2 (1)   default ' ' not null,
  ELIBSYS_KNRBKKN_TIMESTAMP VARCHAR2 (14)  default ' ' not null,
  ELIBSYS_KNRBKKN_SIZE      VARCHAR2 (10)  default ' ' not null,
  HONBAN_KNRBKKN_TIMESTAMP  VARCHAR2 (14)  default ' ' not null,
  HONBAN_KNRBKKN_SIZE       VARCHAR2 (10)  default ' ' not null,
  HONBAN_CHECK_SUM          VARCHAR2 (32)  default ' ' not null,
  THEME_LEADER_BEF          VARCHAR2 (255) default ' ' not null,
  STATUS_BEF                VARCHAR2 (1)   default ' ' not null,
  RELIEVE_STATUS_BEF        VARCHAR2 (1)   default ' ' not null,
  BKO_BEF                   VARCHAR2 (300) default ' ' not null,
  THEME_LEADER_AFT          VARCHAR2 (255) default ' ' not null,
  STATUS_AFT                VARCHAR2 (1)   default ' ' not null,
  RELIEVE_STATUS_AFT        VARCHAR2 (1)   default ' ' not null,
  BKO_AFT                   VARCHAR2 (300) default ' ' not null,
  REC_UPDATE_USER           VARCHAR2 (100) default ' ' not null,
  REC_UPDATE_DATE           VARCHAR2 (8)   default ' ' not null,
  REC_UPDATE_TIME           VARCHAR2 (6)   default ' ' not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 960K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column KM_TB001_RIREKI.SVR_KBN
  is '�T�[�o�[�敪';
comment on column KM_TB001_RIREKI.SVR_GRP_ID
  is '�T�[�o�[�O���[�vID';
comment on column KM_TB001_RIREKI.SVR_ID
  is '�T�[�o�[ID';
comment on column KM_TB001_RIREKI.HONGW_DSTSK_PATH
  is '�{��GW�z�z��p�X';
comment on column KM_TB001_RIREKI.KNRBKKN_FILE_ID
  is '�Ǘ������t�@�C��ID';
comment on column KM_TB001_RIREKI.COMPARE_FLAG
  is '�R���y�A�t���O';
comment on column KM_TB001_RIREKI.ELIBSYS_KNRBKKN_TIMESTAMP
  is 'eLIBSYS_�Ǘ������^�C���X�^���v';
comment on column KM_TB001_RIREKI.ELIBSYS_KNRBKKN_SIZE
  is 'eLIBSYS_�Ǘ������T�C�Y';
comment on column KM_TB001_RIREKI.HONBAN_KNRBKKN_TIMESTAMP
  is '�{��_�Ǘ������^�C���X�^���v';
comment on column KM_TB001_RIREKI.HONBAN_KNRBKKN_SIZE
  is '�{��_�Ǘ������T�C�Y';
comment on column KM_TB001_RIREKI.HONBAN_CHECK_SUM
  is '�{��_�`�F�b�N�T��';
comment on column KM_TB001_RIREKI.THEME_LEADER_BEF
  is '�ύX�O_�e�[�}�S����';
comment on column KM_TB001_RIREKI.STATUS_BEF
  is '�ύX�O_�X�e�[�^�X';
comment on column KM_TB001_RIREKI.RELIEVE_STATUS_BEF
  is '�ύX�O_�����X�e�[�^�X';
comment on column KM_TB001_RIREKI.BKO_BEF
  is '�ύX�O_���l';
comment on column KM_TB001_RIREKI.THEME_LEADER_AFT
  is '�ύX��_�e�[�}�S����';
comment on column KM_TB001_RIREKI.STATUS_AFT
  is '�ύX��_�X�e�[�^�X';
comment on column KM_TB001_RIREKI.RELIEVE_STATUS_AFT
  is '�ύX��_�����X�e�[�^�X';
comment on column KM_TB001_RIREKI.BKO_AFT
  is '�ύX��_���l';
comment on column KM_TB001_RIREKI.REC_UPDATE_USER
  is '���R�[�h�X�V��';
comment on column KM_TB001_RIREKI.REC_UPDATE_DATE
  is '���R�[�h�X�V���t';
comment on column KM_TB001_RIREKI.REC_UPDATE_TIME
  is '���R�[�h�X�V����';

exit
