update TOC0SE16 set init_pwd = 'tstar';
commit;
update TOC0SE30 set user_name = sid || login_cmp_cd , pwd = '1aadea2e41f686a03e78e751c68f1e7ca1143c59' where sid = 'su';
commit;
exit
