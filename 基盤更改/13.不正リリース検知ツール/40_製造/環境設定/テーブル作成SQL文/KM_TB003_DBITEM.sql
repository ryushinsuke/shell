-- Create table
create table KM_TB003_DBITEM
(
  TBL_ID               VARCHAR2(30) default ' ' not null,
  TBL_NM               VARCHAR2(60) default ' ' not null,
  TBL_ITEM_ID          VARCHAR2(30) default ' ' not null,
  TBL_ITEM_NM          VARCHAR2(60) default ' ' not null,
  TBL_ITEM_DATA_TYPE   VARCHAR2(10) default ' ' not null,
  TBL_ITEM_NUM         NUMBER(4)    default '0' not null,
  TBL_ITEM_NULL_SEIY   VARCHAR2(1)  default ' ' not null,
  TBL_ITEM_DEF_VAL     VARCHAR2(20) default ' ' not null,
  PK_KBN               VARCHAR2(2)  default ' ' not null,
  TBL_ITEM_NO          NUMBER(3)    default '0' not null,
  TBL_ITEM_HYOUJI_KBN  VARCHAR2(1)  default ' ' not null
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
comment on column KM_TB003_DBITEM.TBL_ID
  is 'テーブルID';
comment on column KM_TB003_DBITEM.TBL_NM
  is 'テーブル名称';
comment on column KM_TB003_DBITEM.TBL_ITEM_ID
  is 'テーブル項目ID';
comment on column KM_TB003_DBITEM.TBL_ITEM_NM
  is 'テーブル項目名称';
comment on column KM_TB003_DBITEM.TBL_ITEM_DATA_TYPE
  is 'データタイプ';
comment on column KM_TB003_DBITEM.TBL_ITEM_NUM
  is '項目桁数';
comment on column KM_TB003_DBITEM.TBL_ITEM_NULL_SEIY
  is 'NULL制約';
comment on column KM_TB003_DBITEM.TBL_ITEM_DEF_VAL
  is 'ディフォルト値';
comment on column KM_TB003_DBITEM.PK_KBN
  is 'PK区分';
comment on column KM_TB003_DBITEM.TBL_ITEM_NO
  is '項目順番';
comment on column KM_TB003_DBITEM.TBL_ITEM_HYOUJI_KBN
  is '表示区分';
-- Create/Recreate primary, unique and foreign key constraints 
alter table KM_TB003_DBITEM
  add primary key (TBL_ID, TBL_ITEM_ID)
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
