create table FS_TB001_FUSEI_RELEASE
(
  SVR_KBN                   VARCHAR2 (6)   default ' ' not null,
  SVR_GRP_ID                VARCHAR2 (255) default ' ' not null,
  SVR_ID                    VARCHAR2 (255) default ' ' not null,
  HONGW_DSTSK_PATH          VARCHAR2 (255) default ' ' not null,
  KNRBKKN_FILE_ID           VARCHAR2 (255) default ' ' not null,
  COMPARE_FLAG              VARCHAR2 (1)   default ' ' not null,
  ELIBSYS_KNRBKKN_TIMESTAMP VARCHAR2 (14)  default ' ' not null,
  ELIBSYS_KNRBKKN_SIZE      VARCHAR2 (10)  default ' ' not null,
  ELIBSYS_HON_REP_LIBTHM_ID VARCHAR2 (100) default ' ' not null,
  HONBAN_KNRBKKN_TIMESTAMP  VARCHAR2 (14)  default ' ' not null,
  HONBAN_KNRBKKN_SIZE       VARCHAR2 (10)  default ' ' not null,
  HONBAN_CHECK_SUM          VARCHAR2 (32)  default ' ' not null,
  THEME_LEADER              VARCHAR2 (255) default ' ' not null,
  STATUS                    VARCHAR2 (1)   default ' ' not null,
  RELIEVE_STATUS            VARCHAR2 (1)   default ' ' not null,
  COMPARE_DATE              VARCHAR2 (8)   default ' ' not null,
  STATUS_UPDATE_DATE        VARCHAR2 (8)   default ' ' not null,
  UPD_SEL_DATE              VARCHAR2 (8)   default ' ' not null,
  ERROR_TYPE                VARCHAR2 (1)   default ' ' not null,
  BKO                       VARCHAR2 (300) default ' ' not null
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
comment on column FS_TB001_FUSEI_RELEASE.SVR_KBN
  is '�T�[�o�[�敪';
comment on column FS_TB001_FUSEI_RELEASE.SVR_GRP_ID
  is '�T�[�o�[�O���[�vID';
comment on column FS_TB001_FUSEI_RELEASE.SVR_ID
  is '�T�[�o�[ID';
comment on column FS_TB001_FUSEI_RELEASE.HONGW_DSTSK_PATH
  is '�{��GW�z�z��p�X';
comment on column FS_TB001_FUSEI_RELEASE.KNRBKKN_FILE_ID
  is '�Ǘ������t�@�C��ID';
comment on column FS_TB001_FUSEI_RELEASE.COMPARE_FLAG
  is '�R���y�A�t���O';
comment on column FS_TB001_FUSEI_RELEASE.ELIBSYS_KNRBKKN_TIMESTAMP
  is 'eLIBSYS_�Ǘ������^�C���X�^���v';
comment on column FS_TB001_FUSEI_RELEASE.ELIBSYS_KNRBKKN_SIZE
  is 'eLIBSYS_�Ǘ������T�C�Y';
comment on column FS_TB001_FUSEI_RELEASE.ELIBSYS_HON_REP_LIBTHM_ID
  is 'eLIBSYS_�{�ԃ��|�W�g��LIB�e�[�}ID';
comment on column FS_TB001_FUSEI_RELEASE.HONBAN_KNRBKKN_TIMESTAMP
  is '�{��_�Ǘ������^�C���X�^���v';
comment on column FS_TB001_FUSEI_RELEASE.HONBAN_KNRBKKN_SIZE
  is '�{��_�Ǘ������T�C�Y';
comment on column FS_TB001_FUSEI_RELEASE.HONBAN_CHECK_SUM
  is '�{��_�`�F�b�N�T��';
comment on column FS_TB001_FUSEI_RELEASE.THEME_LEADER
  is '�e�[�}�S����';
comment on column FS_TB001_FUSEI_RELEASE.STATUS
  is '�X�e�[�^�X';
comment on column FS_TB001_FUSEI_RELEASE.RELIEVE_STATUS
  is '�����X�e�[�^�X';
comment on column FS_TB001_FUSEI_RELEASE.COMPARE_DATE
  is '�s�������[�X���o��';
comment on column FS_TB001_FUSEI_RELEASE.STATUS_UPDATE_DATE
  is '�X�e�[�^�X�X�V��';
comment on column FS_TB001_FUSEI_RELEASE.UPD_SEL_DATE
  is '�X�����o��';
comment on column FS_TB001_FUSEI_RELEASE.ERROR_TYPE
  is '�s���^�C�v';
comment on column FS_TB001_FUSEI_RELEASE.BKO
  is '���l';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FS_TB001_FUSEI_RELEASE
  add primary key (SVR_KBN,SVR_GRP_ID,SVR_ID,HONGW_DSTSK_PATH,KNRBKKN_FILE_ID,COMPARE_FLAG,ELIBSYS_KNRBKKN_TIMESTAMP,ELIBSYS_KNRBKKN_SIZE,HONBAN_KNRBKKN_TIMESTAMP,HONBAN_KNRBKKN_SIZE,HONBAN_CHECK_SUM)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    minextents 1
    maxextents unlimited
  );

exit
