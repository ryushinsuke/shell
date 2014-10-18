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
  is 'サーバーグループID';
comment on column KM_TB004_EXCLUDE_DATA.HONGW_DSTSK_PATH
  is '本番GW配布先パス';
comment on column KM_TB004_EXCLUDE_DATA.KNRBKKN_FILE_ID
  is '管理物件ファイルID';
comment on column KM_TB004_EXCLUDE_DATA.HON_SVR_ID
  is '本番サーバーID';
comment on column KM_TB004_EXCLUDE_DATA.SVR_KBN
  is 'サーバー区分';
comment on column KM_TB004_EXCLUDE_DATA.ITEM_KBN
  is '対象外データ項目区分';
comment on column KM_TB004_EXCLUDE_DATA.CLASSIFG_KBN
  is '対象外データ分類';
comment on column KM_TB004_EXCLUDE_DATA.ADMIT_LEADER
  is '承認担当者';
comment on column KM_TB004_EXCLUDE_DATA.ADMIT_DATA
  is '承認日付';
comment on column KM_TB004_EXCLUDE_DATA.ADMIT_REASON
  is '承認理由';

exit
