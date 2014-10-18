-- Create table
create table KM_TB004_EXCLUDE_DATA
(
  SVR_GRP_ID       VARCHAR2(255) default ' ' not null,
  HONGW_DSTSK_PATH VARCHAR2(255) default ' ' not null,
  KNRBKKN_FILE_ID  VARCHAR2(255) default ' ' not null,
  HON_SVR_ID       VARCHAR2(255) default ' ' not null,
  SVR_KBN          VARCHAR2(3)   default ' ' not null,
  ITEM_KBN         VARCHAR2(1)   default ' ' not null,
  CLASSIFG_KBN     VARCHAR2(10)  default ' ' not null,
  ADMIT_LEADER     VARCHAR2(255) default ' ' not null,
  ADMIT_DATA       VARCHAR2(8)   default ' ' not null,
  ADMIT_REASON     VARCHAR2(300) default ' ' not null
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
comment on column KM_TB004_EXCLUDE_DATA.SVR_GRP_ID
  is '�T�[�o�[�O���[�vID';
comment on column KM_TB004_EXCLUDE_DATA.HONGW_DSTSK_PATH
  is '�{��GW�z�z��p�X';
comment on column KM_TB004_EXCLUDE_DATA.KNRBKKN_FILE_ID
  is '�Ǘ������t�@�C��ID';
comment on column KM_TB004_EXCLUDE_DATA.HON_SVR_ID
  is '�{�ԃT�[�o�[ID';
comment on column KM_TB004_EXCLUDE_DATA.SVR_KBN
  is '�T�[�o�[�敪';
comment on column KM_TB004_EXCLUDE_DATA.ITEM_KBN
  is '�ΏۊO�f�[�^���ڋ敪';
comment on column KM_TB004_EXCLUDE_DATA.CLASSIFG_KBN
  is '�ΏۊO�f�[�^����';
comment on column KM_TB004_EXCLUDE_DATA.ADMIT_LEADER
  is '���F�S����';
comment on column KM_TB004_EXCLUDE_DATA.ADMIT_DATA
  is '���F���t';
comment on column KM_TB004_EXCLUDE_DATA.ADMIT_REASON
  is '���F���R';

exit
