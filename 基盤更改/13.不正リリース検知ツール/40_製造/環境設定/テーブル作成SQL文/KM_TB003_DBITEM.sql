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
  is '�e�[�u��ID';
comment on column KM_TB003_DBITEM.TBL_NM
  is '�e�[�u������';
comment on column KM_TB003_DBITEM.TBL_ITEM_ID
  is '�e�[�u������ID';
comment on column KM_TB003_DBITEM.TBL_ITEM_NM
  is '�e�[�u�����ږ���';
comment on column KM_TB003_DBITEM.TBL_ITEM_DATA_TYPE
  is '�f�[�^�^�C�v';
comment on column KM_TB003_DBITEM.TBL_ITEM_NUM
  is '���ڌ���';
comment on column KM_TB003_DBITEM.TBL_ITEM_NULL_SEIY
  is 'NULL����';
comment on column KM_TB003_DBITEM.TBL_ITEM_DEF_VAL
  is '�f�B�t�H���g�l';
comment on column KM_TB003_DBITEM.PK_KBN
  is 'PK�敪';
comment on column KM_TB003_DBITEM.TBL_ITEM_NO
  is '���ڏ���';
comment on column KM_TB003_DBITEM.TBL_ITEM_HYOUJI_KBN
  is '�\���敪';
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
