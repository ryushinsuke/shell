spool /share/TOOLS/Mask_KJ_imp/log/drop_CMN.log
set echo on
drop table TOC0SE80 cascade constraints purge;
drop table TOC0SE60 cascade constraints purge;
drop table TOC0SE61 cascade constraints purge;
drop table TOC0DA21 cascade constraints purge;
drop table TOC0DA22 cascade constraints purge;
drop table TOC0DA23 cascade constraints purge;
drop table TOC0DA24 cascade constraints purge;
drop table TOC0DA25 cascade constraints purge;
drop table TOC0DA26 cascade constraints purge;
drop table TOC0EE11 cascade constraints purge;
drop table TOC0EE12 cascade constraints purge;
drop table TOC0EE13 cascade constraints purge;
drop table TOC0EE14 cascade constraints purge;
drop table TOC0EE15 cascade constraints purge;
drop table TOC0EE16 cascade constraints purge;
drop table TOC0SE17 cascade constraints purge;
drop table TOC0SE20 cascade constraints purge;
drop table TOC0SE21 cascade constraints purge;
drop table TOC0SE23 cascade constraints purge;
drop table TOC0EE10 cascade constraints purge;
drop table TOC0SE22 cascade constraints purge;

spool off
exit

