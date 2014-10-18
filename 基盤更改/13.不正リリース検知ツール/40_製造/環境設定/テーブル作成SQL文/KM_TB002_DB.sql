-- Create table
create table KM_TB002_DB
(
  TBL_ID            VARCHAR2(30) default ' ' not null,
  TBL_NAM           VARCHAR2(50) default ' ' not null,
  UYOU_KBN          VARCHAR2(1)  default ' ' not null,
  REC_UPDATE_DATE   VARCHAR2(8)  default ' ' not null,
  REC_UPDATE_TIME   VARCHAR2(6)  default ' ' not null
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
comment on column KM_TB002_DB.TBL_ID
  is 'テーブルID';
comment on column KM_TB002_DB.TBL_NAM
  is 'テーブル名称';
comment on column KM_TB002_DB.UYOU_KBN
  is '運用区分';
comment on column KM_TB002_DB.REC_UPDATE_DATE
  is 'レコード更新日付';
comment on column KM_TB002_DB.REC_UPDATE_TIME
  is 'レコード更新時間';
-- Create/Recreate primary, unique and foreign key constraints 
alter table KM_TB002_DB
  add primary key (TBL_ID)
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
