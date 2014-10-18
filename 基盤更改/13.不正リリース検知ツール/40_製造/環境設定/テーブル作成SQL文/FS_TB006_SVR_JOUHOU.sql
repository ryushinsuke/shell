create table FS_TB006_SVR_JOUHOU
(
  SVR_GRP_ID       VARCHAR2 (255) default ' ' not null,
  SVR_ID           VARCHAR2 (255) default ' ' not null,
  OS_GRP_ID        VARCHAR2 (1)   default ' ' not null,
  OLD_COMPARE_DATE VARCHAR2 (8)   default ' ' not null,
  NEW_COMPARE_DATE VARCHAR2 (8)   default ' ' not null,
  NEW_COMPARE_FLAG VARCHAR2 (1)   default ' ' not null,
  COMPARE_RESULT   VARCHAR2 (1)   default ' ' not null,
  SVR_KBN          VARCHAR2 (3)   default ' ' not null
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
comment on column FS_TB006_SVR_JOUHOU.SVR_GRP_ID
  is '�T�[�o�[�O���[�vID';
comment on column FS_TB006_SVR_JOUHOU.SVR_ID
  is '�T�[�o�[ID';
comment on column FS_TB006_SVR_JOUHOU.OS_GRP_ID
  is 'OS����';
comment on column FS_TB006_SVR_JOUHOU.OLD_COMPARE_DATE
  is '�O�񌟒m��';
comment on column FS_TB006_SVR_JOUHOU.NEW_COMPARE_DATE
  is '�ŐV���m��';
comment on column FS_TB006_SVR_JOUHOU.NEW_COMPARE_FLAG
  is '�ŐV���m�t���O';
comment on column FS_TB006_SVR_JOUHOU.COMPARE_RESULT
  is '�R���y�A����';
comment on column FS_TB006_SVR_JOUHOU.SVR_KBN
  is '�T�[�o�[�敪';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FS_TB006_SVR_JOUHOU
  add primary key (SVR_GRP_ID,SVR_ID,SVR_KBN)
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
