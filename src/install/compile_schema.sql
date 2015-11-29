PROMPT  =============================================================================
PROMPT  == R E C O M P I L E   C O R E   S C H E M A
PROMPT  =============================================================================

BEGIN
dbms_utility.compile_schema(user);
END;
/