SET SERVEROUTPUT ON

-- Single procedrue to test writing, reading, and removing of records

--
-- EXEC Insert
--
DECLARE
  lt_rec_push    STU_PREF_UTIL.gt_pref_record;
  lt_rec_push_id STU_PREF.PREF_ID%TYPE;
  lt_rec_pull    STU_PREF_UTIL.gt_pref_record;
  lv_pw          VARCHAR2(32767);
  lv_name        STU_PREF.PREF_NAME%TYPE :='TEST_PREF';
  lv_test_result VARCHAR2(32767);
BEGIN

  -- set values
  lt_rec_push.PREF_NAME := lv_name;
  lt_rec_push.VALUE1 := 'VARCHAR Value Here';
  lt_rec_push.NUMBER1 := 1000;
  lt_rec_push.DATE1 := SYSDATE;
  lv_pw := 'I can not be seen...';
  lt_rec_push.PASSWORD_TEMP := lv_pw;
  lt_rec_push.DESCRIPTION := 'This is a test record';
  lt_rec_push.API_EDIT := 'Y';
  lt_rec_push.API_VIEW := 'Y';

  STU_PREF_UTIL.INSERT_UPDATE_RECORD(lt_rec_push, lt_rec_push_id);
  lt_rec_pull:=STU_PREF_UTIL.GET_RECORD(lt_rec_push_id);
  commit;

  DBMS_OUTPUT.PUT_LINE('Insert Completed');
  IF (lt_rec_pull.VALUE1 = lt_rec_push.VALUE1) 
     AND
     (STU_PREF_UTIL.GET_PREF_VALUE(lv_name) = lt_rec_push.VALUE1)
  THEN 
     DBMS_OUTPUT.PUT_LINE('PASS - VALUE1='|| STU_PREF_UTIL.GET_PREF_VALUE(lv_name));
  ELSE
     DBMS_OUTPUT.PUT_LINE('FAIL - VALUE1='|| STU_PREF_UTIL.GET_PREF_VALUE(lv_name));
  END IF;

  IF (lt_rec_pull.NUMBER1 = lt_rec_push.NUMBER1) 
     AND
     (STU_PREF_UTIL.GET_PREF_NUMBER(lv_name) = lt_rec_push.NUMBER1)
  THEN 
     DBMS_OUTPUT.PUT_LINE('PASS - NUMBER1='|| STU_PREF_UTIL.GET_PREF_NUMBER(lv_name));
  ELSE
     DBMS_OUTPUT.PUT_LINE('FAIL - NUMBER1='|| STU_PREF_UTIL.GET_PREF_NUMBER(lv_name));
  END IF;

  IF (lt_rec_pull.DATE1 = lt_rec_push.DATE1) 
     AND
     (STU_PREF_UTIL.GET_PREF_DATE(lv_name) = lt_rec_push.DATE1)
  THEN 
     DBMS_OUTPUT.PUT_LINE('PASS - DATE1='|| STU_PREF_UTIL.GET_PREF_DATE(lv_name));
  ELSE
     DBMS_OUTPUT.PUT_LINE('FAIL - DATE1='|| STU_PREF_UTIL.GET_PREF_DATE(lv_name));
  END IF;


  IF (lt_rec_pull.PASSWORD_TEMP IS NULL)
     AND 
     (lt_rec_push.PASSWORD_TEMP = lv_pw) 
     AND
     (STU_PREF_UTIL.GET_PREF_PW(lv_name) = lv_pw)
  THEN 
     DBMS_OUTPUT.PUT_LINE('PASS - PW='|| STU_PREF_UTIL.GET_PREF_PW(lv_name));
  ELSE
     DBMS_OUTPUT.PUT_LINE('FAIL - PW='|| STU_PREF_UTIL.GET_PREF_PW(lv_name));
  END IF;

  -- remove the record
  STU_PREF_UTIL.DELETE_RECORD(lt_rec_push_id);
  commit;

  IF STU_PREF_UTIL.GET_PREF_VALUE(lv_name) IS NULL 
  THEN 
     DBMS_OUTPUT.PUT_LINE('PASS - Delete confirmed');
  ELSE
     DBMS_OUTPUT.PUT_LINE('FAIL - Record still exists');
  END IF;


END;
/

