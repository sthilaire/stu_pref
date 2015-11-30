SET SERVEROUTPUT ON

--
-- EXEC Insert
--
DECLARE
  lt_rec STU_PREF_UTIL.gt_pref_record;
  lv_name STU_PREF.PREF_NAME%TYPE :='TEST_PREF';
BEGIN

  -- set values
  lt_rec.PREF_NAME := lv_name;
  lt_rec.VALUE1 := 'VARCHAR Value Here';
  lt_rec.NUMBER1 := 1000;
  lt_rec.DATE1 := SYSDATE;
  lt_rec.PASSWORD_TEMP := 'I can not be seen...';
  lt_rec.DESCRIPTION := 'This is a test record';
  lt_rec.API_EDIT := 'Y';
  lt_rec.API_VIEW := 'Y';

  STU_PREF_UTIL.INSERT_UPDATE_RECORD(lt_rec);
  commit;

  DBMS_OUTPUT.PUT_LINE('Insert Completed');
  DBMS_OUTPUT.PUT_LINE('Value='|| STU_PREF_UTIL.GET_PREF_VALUE(lv_name));
  DBMS_OUTPUT.PUT_LINE('Number='|| STU_PREF_UTIL.GET_PREF_NUMBER(lv_name));
  DBMS_OUTPUT.PUT_LINE('Date='|| STU_PREF_UTIL.GET_PREF_DATE(lv_name));
  DBMS_OUTPUT.PUT_LINE('PW='|| STU_PREF_UTIL.GET_PREF_PW(lv_name));

END;
/

-- view results of insert
COLUMN PREF_NAME   FORMAT A20
COLUMN VALUE1      FORMAT A20
COLUMN NUMBER1     FORMAT  999999
COLUMN DATE1       FORMAT A15
COLUMN PASSWORD_TEMP   HEADING 'PW' FORMAT A4
COLUMN PASSWORD_ENC      HEADING 'PW-stored'   FORMAT A8

-- show results
SELECT PREF_NAME, VALUE1, DATE1, NUMBER1, PASSWORD_TEMP, PASSWORD_ENC  FROM STU_PREF;

--
-- UPDATE VALUE
--
DECLARE
  lt_rec STU_PREF_UTIL.gt_pref_record;
  ln_id  STU_PREF.PREF_ID%TYPE;
  lv_name STU_PREF.PREF_NAME%TYPE :='TEST_PREF';

BEGIN

  -- get routine is by ID - should be gained through CRUD from
  SELECT PREF_ID INTO ln_id FROM STU_PREF
  WHERE PREF_NAME ='TEST_PREF';

  lt_rec:=STU_PREF_UTIL.GET_RECORD(p_id => ln_id);
  
  -- Change values
  lt_rec.PREF_NAME := lv_name;
  lt_rec.VALUE1 := 'New Value';
  lt_rec.NUMBER1 := NULL;
  lt_rec.DATE1 := NULL;
  lt_rec.PASSWORD_TEMP := 'New PW';
  lt_rec.DESCRIPTION := 'This has been updated';
  lt_rec.API_EDIT := 'N';

  -- same insert update call
  STU_PREF_UTIL.INSERT_UPDATE_RECORD(lt_rec);

  commit;
  DBMS_OUTPUT.PUT_LINE('Update Completed');

END;
/

-- view results of insert
COLUMN PREF_NAME   FORMAT A20
COLUMN VALUE1      FORMAT A20
COLUMN NUMBER1     FORMAT 999999
COLUMN DATE1       FORMAT A20
COLUMN PASSWORD_TEMP    FORMAT A8
COLUMN PASSWORD_ENC      HEADING 'PW-stored'   FORMAT A8
COLUMN PW_DEC      HEADING 'PW-decrypt'  FORMAT A20
-- show results
SELECT PREF_NAME, VALUE1, DATE1, NUMBER1, PASSWORD_TEMP, PASSWORD_ENC, STU_PREF_UTIL.GET_PREF_PW('TEST_PREF') as PW_DEC  FROM STU_PREF;


-- Reset table after TEST 
DELETE FROM STU_PREF where PREF_NAME = 'TEST_PREF';