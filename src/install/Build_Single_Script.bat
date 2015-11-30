REM -- Make a single Object install script
REM -- /b prevents a SUB character at the end
REM -- /Y prevents prompt to overwrite the destination
REM copy /b /Y ^
REM ..\tbl\*table.sql+^
REM ..\vw\*.sql+^
REM ..\pkg\*.pks+^
REM ..\tbl\*trigger.sql+^
REM ..\pkg\*.pkb ^
REM z_STU_PREF_install_combined.sql

perl CreateInstallScripts.pl