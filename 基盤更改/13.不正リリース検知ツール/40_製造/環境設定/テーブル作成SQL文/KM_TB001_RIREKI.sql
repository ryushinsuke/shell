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
  is 'サーバー区分';
comment on column KM_TB001_RIREKI.SVR_GRP_ID
  is 'サーバーグループID';
comment on column KM_TB001_RIREKI.SVR_ID
  is 'サーバーID';
comment on column KM_TB001_RIREKI.HONGW_DSTSK_PATH
  is '本番GW配布先パス';
comment on column KM_TB001_RIREKI.KNRBKKN_FILE_ID
  is '管理物件ファイルID';
comment on column KM_TB001_RIREKI.COMPARE_FLAG
  is 'コンペアフラグ';
comment on column KM_TB001_RIREKI.ELIBSYS_KNRBKKN_TIMESTAMP
  is 'eLIBSYS_管理物件タイムスタンプ';
comment on column KM_TB001_RIREKI.ELIBSYS_KNRBKKN_SIZE
  is 'eLIBSYS_管理物件サイズ';
comment on column KM_TB001_RIREKI.HONBAN_KNRBKKN_TIMESTAMP
  is '本番_管理物件タイムスタンプ';
comment on column KM_TB001_RIREKI.HONBAN_KNRBKKN_SIZE
  is '本番_管理物件サイズ';
comment on column KM_TB001_RIREKI.HONBAN_CHECK_SUM
  is '本番_チェックサム';
comment on column KM_TB001_RIREKI.THEME_LEADER_BEF
  is '変更前_テーマ担当者';
comment on column KM_TB001_RIREKI.STATUS_BEF
  is '変更前_ステータス';
comment on column KM_TB001_RIREKI.RELIEVE_STATUS_BEF
  is '変更前_解消ステータス';
comment on column KM_TB001_RIREKI.BKO_BEF
  is '変更前_備考';
comment on column KM_TB001_RIREKI.THEME_LEADER_AFT
  is '変更後_テーマ担当者';
comment on column KM_TB001_RIREKI.STATUS_AFT
  is '変更後_ステータス';
comment on column KM_TB001_RIREKI.RELIEVE_STATUS_AFT
  is '変更後_解消ステータス';
comment on column KM_TB001_RIREKI.BKO_AFT
  is '変更後_備考';
comment on column KM_TB001_RIREKI.REC_UPDATE_USER
  is 'レコード更新者';
comment on column KM_TB001_RIREKI.REC_UPDATE_DATE
  is 'レコード更新日付';
comment on column KM_TB001_RIREKI.REC_UPDATE_TIME
  is 'レコード更新時間';

exit
