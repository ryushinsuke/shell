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
  is 'サーバー区分';
comment on column FS_TB001_FUSEI_RELEASE.SVR_GRP_ID
  is 'サーバーグループID';
comment on column FS_TB001_FUSEI_RELEASE.SVR_ID
  is 'サーバーID';
comment on column FS_TB001_FUSEI_RELEASE.HONGW_DSTSK_PATH
  is '本番GW配布先パス';
comment on column FS_TB001_FUSEI_RELEASE.KNRBKKN_FILE_ID
  is '管理物件ファイルID';
comment on column FS_TB001_FUSEI_RELEASE.COMPARE_FLAG
  is 'コンペアフラグ';
comment on column FS_TB001_FUSEI_RELEASE.ELIBSYS_KNRBKKN_TIMESTAMP
  is 'eLIBSYS_管理物件タイムスタンプ';
comment on column FS_TB001_FUSEI_RELEASE.ELIBSYS_KNRBKKN_SIZE
  is 'eLIBSYS_管理物件サイズ';
comment on column FS_TB001_FUSEI_RELEASE.ELIBSYS_HON_REP_LIBTHM_ID
  is 'eLIBSYS_本番リポジトリLIBテーマID';
comment on column FS_TB001_FUSEI_RELEASE.HONBAN_KNRBKKN_TIMESTAMP
  is '本番_管理物件タイムスタンプ';
comment on column FS_TB001_FUSEI_RELEASE.HONBAN_KNRBKKN_SIZE
  is '本番_管理物件サイズ';
comment on column FS_TB001_FUSEI_RELEASE.HONBAN_CHECK_SUM
  is '本番_チェックサム';
comment on column FS_TB001_FUSEI_RELEASE.THEME_LEADER
  is 'テーマ担当者';
comment on column FS_TB001_FUSEI_RELEASE.STATUS
  is 'ステータス';
comment on column FS_TB001_FUSEI_RELEASE.RELIEVE_STATUS
  is '解消ステータス';
comment on column FS_TB001_FUSEI_RELEASE.COMPARE_DATE
  is '不正リリース検出日';
comment on column FS_TB001_FUSEI_RELEASE.STATUS_UPDATE_DATE
  is 'ステータス更新日';
comment on column FS_TB001_FUSEI_RELEASE.UPD_SEL_DATE
  is '更正検出日';
comment on column FS_TB001_FUSEI_RELEASE.ERROR_TYPE
  is '不正タイプ';
comment on column FS_TB001_FUSEI_RELEASE.BKO
  is '備考';
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
