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
  is 'サーバーグループID';
comment on column FS_TB006_SVR_JOUHOU.SVR_ID
  is 'サーバーID';
comment on column FS_TB006_SVR_JOUHOU.OS_GRP_ID
  is 'OS分類';
comment on column FS_TB006_SVR_JOUHOU.OLD_COMPARE_DATE
  is '前回検知日';
comment on column FS_TB006_SVR_JOUHOU.NEW_COMPARE_DATE
  is '最新検知日';
comment on column FS_TB006_SVR_JOUHOU.NEW_COMPARE_FLAG
  is '最新検知フラグ';
comment on column FS_TB006_SVR_JOUHOU.COMPARE_RESULT
  is 'コンペア結果';
comment on column FS_TB006_SVR_JOUHOU.SVR_KBN
  is 'サーバー区分';
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
