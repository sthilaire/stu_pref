SET SERVEROUTPUT ON

--
-- EXEC Insert
--
DECLARE
  lt_rec AS_PREF_UTIL.gt_pref_record;
  lv_name AS_PREF.PREF_NAME%TYPE :='TEST_PREF';
BEGIN

  -- set values
  lt_rec.PREF_NAME := lv_name;
  lt_rec.VALUE1 := 'VARCHAR Value Here';
  lt_rec.NUMBER1 := 1000;
  lt_rec.DATE1 := SYSDATE;
  lt_rec.VALUE_PW := 'I can not be seen...';
  lt_rec.DESCRIPTION := 'This is a test record';
  lt_rec.USER_EDIT := 'Y';

  AS_PREF_UTIL.INSERT_UPDATE_RECORD(lt_rec);

  commit;
  DBMS_OUTPUT.PUT_LINE('Insert Completed');
  DBMS_OUTPUT.PUT_LINE('Value='|| AS_PREF_UTIL.GET_PREF_VALUE(lv_name));
  DBMS_OUTPUT.PUT_LINE('Number='|| AS_PREF_UTIL.GET_PREF_NUMBER(lv_name));
  DBMS_OUTPUT.PUT_LINE('Date='|| AS_PREF_UTIL.GET_PREF_DATE(lv_name));
  DBMS_OUTPUT.PUT_LINE('PW='|| AS_PREF_UTIL.GET_PREF_PW(lv_name));

END;
/

-- view results of insert
COLUMN PREF_NAME   FORMAT A20
COLUMN VALUE1      FORMAT A20
COLUMN NUMBER1     FORMAT  999999
COLUMN DATE1       FORMAT A20
COLUMN VALUE_PW    FORMAT A8
COLUMN PW_RAW      HEADING 'PW-stored'   FORMAT A8

-- show results
SELECT PREF_NAME, VALUE1, DATE1, NUMBER1, VALUE_PW, PW_RAW  FROM AS_PREF;

--
-- UPDATE VALUE
--
DECLARE
  lt_rec AS_PREF_UTIL.gt_pref_record;
  ln_id  AS_PREF.PREF_ID%TYPE;
  lv_name AS_PREF.PREF_NAME%TYPE :='TEST_PREF';

BEGIN

  -- get routine is by ID - should be gained through CRUD from
  SELECT PREF_ID INTO ln_id FROM AS_PREF
  WHERE PREF_NAME ='TEST_PREF';

  lt_rec:=AS_PREF_UTIL.GET_RECORD(p_id => ln_id);
  
  -- Change values
  lt_rec.PREF_NAME := lv_name;
  lt_rec.VALUE1 := 'New Value';
  lt_rec.NUMBER1 := NULL;
  lt_rec.DATE1 := NULL;
  lt_rec.VALUE_PW := 'New PW';
  lt_rec.DESCRIPTION := 'This has been updated';
  lt_rec.USER_EDIT := 'N';

  -- same insert update call
  AS_PREF_UTIL.INSERT_UPDATE_RECORD(lt_rec);

  commit;
  DBMS_OUTPUT.PUT_LINE('Update Completed');

END;
/

-- view results of insert
COLUMN PREF_NAME   FORMAT A20
COLUMN VALUE1      FORMAT A20
COLUMN NUMBER1     FORMAT 999999
COLUMN DATE1       FORMAT A20
COLUMN VALUE_PW    FORMAT A8
COLUMN PW_RAW      HEADING 'PW-stored'   FORMAT A8
COLUMN PW_DEC      HEADING 'PW-decrypt'  FORMAT A20
-- show results
SELECT PREF_NAME, VALUE1, DATE1, NUMBER1, VALUE_PW, PW_RAW, AS_PREF_UTIL.GET_PREF_PW('TEST_PREF') as PW_DEC  FROM AS_PREF;


-- Reset table after TEST 
DELETE FROM AS_PREF where PREF_NAME = 'TEST_PREF';