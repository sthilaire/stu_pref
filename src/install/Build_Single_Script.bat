REM -- Make a single Object install script
REM -- /b prevents a SUB character at the end
REM -- /Y prevents prompt to overwrite the destination
copy /b /Y ^
..\tbl\*table.sql+^
..\vw\*.sql+^
..\pkg\*.pks+^
..\tbl\*trigger.sql+^
..\pkg\*.pkb ^
z_STU_PREF_install_combined.sql