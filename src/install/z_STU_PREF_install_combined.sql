PROMPT == STU_PREF Table

--DROP TABLE STU_PREF;

/* 
Table used to add instrumentation to code
*/
--           123456789012345678901234567890
CREATE TABLE STU_PREF 
(
PREF_ID         NUMBER,
PREF_NAME       VARCHAR2 (255 ),
VALUE1          VARCHAR2 (2000),
NUMBER1         NUMBER,
DATE1           DATE,
VALUE_PW        VARCHAR2 (2000),
PW_RAW          RAW      (2000),
DESCRIPTION     VARCHAR2 (2000),
USER_EDIT       VARCHAR2 (1   ),
CREATED_BY      VARCHAR2 (50  ),
CREATED_ON      DATE,
UPDATED_BY      VARCHAR2 (50  ),
UPDATED_ON      DATE
);

--                  123456789012345678901234567890
CREATE UNIQUE INDEX PK_STU_PREF ON STU_PREF (PREF_ID);

CREATE UNIQUE INDEX UK1_STU_PREF ON STU_PREF (PREF_NAME);

  PROMPT == STU_PREF_UTIL Package Spec

create or replace
PACKAGE STU_PREF_UTIL IS

-----------------------------------------------------------------------
--
--               Copyright(C) 2015 T. St. Hilaire 
--                         All Rights Reserved
-- 
-----------------------------------------------------------------------
--  Application   : STU_PREF
--  Subsystem     : Preferences
--  Package Name  : STU_PREF_UTIL
--  Purpose       : Utility for managing settings for an application.
--
--  Comments:       
-----------------------------------------------------------------------
--
-- 1.2    04-OCT-2014   Next revision with improved update capabilities
-- 1.1    01-SEP-2014   Simplified table (hard to beleive)
-----------------------------------------------------------------------

--=====================================================================
--< PUBLIC TYPES AND GLOBALS >-----------------------------------------
--=====================================================================

SUBTYPE gt_pref_record IS STU_PREF%ROWTYPE;

--=====================================================================
--< PUBLIC METHODS >===================================================
--=====================================================================


-----------------------------------------------------------------------
--< ENCRYPT >----------------------------------------------------------
-----------------------------------------------------------------------
--  Purpose: 
--  Allows the information in the settings table to be encrypted via trigger
--
--  p_value: The thing to be encrypted 
--  p_key:   Key to use to encrypt the value
--
--  Comments:  
--
------------------------------------------------------------------------
FUNCTION encrypt( p_value  VARCHAR2,  
                  p_key    VARCHAR2 ) RETURN RAW;

-------------------------------------------------------------------
--< SET_PREF >-----------------------------------------------------
-------------------------------------------------------------------
--  Purpose : Quick Set the value for the setting table
-------------------------------------------------------------------
PROCEDURE SET_PREF       ( p_name STU_PREF.PREF_NAME%TYPE, 
                           p_value STU_PREF.value1%TYPE);

-------------------------------------------------------------------
--< SET_PREF >-----------------------------------------------------
-------------------------------------------------------------------
--  Purpose : Quick Set the value for the setting table
-------------------------------------------------------------------
PROCEDURE SET_PREF       ( p_name STU_PREF.PREF_NAME%TYPE, 
                           p_value STU_PREF.NUMBER1%TYPE);

-------------------------------------------------------------------
--< SET_PREF >-----------------------------------------------------
-------------------------------------------------------------------
--  Purpose : Quick Set the value for the setting table
-------------------------------------------------------------------
PROCEDURE SET_PREF       ( p_name STU_PREF.PREF_NAME%TYPE, 
                           p_value STU_PREF.DATE1%TYPE);

-------------------------------------------------------------------
--< GET_PREF_VALUE >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_VALUE ( p_name  VARCHAR2) RETURN STU_PREF.value1%TYPE;


-------------------------------------------------------------------
--< GET_PREF_NUMBER >----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_NUMBER ( p_name  VARCHAR2) RETURN STU_PREF.NUMBER1%TYPE;

-------------------------------------------------------------------
--< GET_PREF_DATE >------------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_DATE ( p_name  VARCHAR2) RETURN STU_PREF.DATE1%TYPE;


-------------------------------------------------------------------
--< GET_PREF_PW >--------------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_PW ( p_name  VARCHAR2) RETURN STU_PREF.VALUE_PW%TYPE;


---------------------------------------------------------------------
--< GET_RECORD >-----------------------------------------------------
---------------------------------------------------------------------
--  Purpose : Returns a full record
--  
--  Comments:  Intended for TABLE report type use
--
---------------------------------------------------------------------
FUNCTION GET_RECORD (p_id   IN NUMBER) RETURN gt_pref_record;

---------------------------------------------------------------------
--< GET_RECORD >-----------------------------------------------------
---------------------------------------------------------------------
--  Purpose : Returns a full record
--  
--  Comments:  Overloaded Preference fetch by NAME
--
---------------------------------------------------------------------
FUNCTION GET_RECORD (p_name   IN STU_PREF.PREF_NAME%TYPE) RETURN gt_pref_record;

---------------------------------------------------------------------
--< INSERT_UPDATE_RECORD >-------------------------------------------
---------------------------------------------------------------------
--  Purpose : INSERT_UPDATE_RECORD designed to evaluate INSERT vs UPDATE
--
--             ID included = UPDATE
--             Otherwise a new record will be created.
--  Comments:
--
---------------------------------------------------------------------
PROCEDURE INSERT_UPDATE_RECORD (p_record    IN OUT gt_pref_record,
                                p_id           OUT NUMBER);

---------------------------------------------------------------------
--< INSERT_UPDATE_RECORD >-------------------------------------------
---------------------------------------------------------------------
--  Purpose : Same as above - without the RETURN values
--  Comments:
---------------------------------------------------------------------
PROCEDURE INSERT_UPDATE_RECORD (p_record    IN gt_pref_record);       

---------------------------------------------------------------------
--< DELETE_RECORD >--------------------------------------------------
---------------------------------------------------------------------
--  Purpose : Returns a full record
--  
--  Comments:  Note - record activities are done by PREF_ID, not name
--
---------------------------------------------------------------------
PROCEDURE DELETE_RECORD (p_id   IN NUMBER);


END STU_PREF_UTIL;

/

PROMPT == STU_PREF Trigger

--                         123456789012345678901234567890
CREATE OR REPLACE TRIGGER BIU_STU_PREF
BEFORE INSERT OR UPDATE ON  STU_PREF
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
BEGIN
  IF INSERTING THEN 
    IF :NEW.PREF_ID IS NULL THEN
      SELECT to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
        INTO :NEW.PREF_ID FROM DUAL;
    END IF;
    :NEW.CREATED_ON := SYSDATE;
    :NEW.CREATED_BY := nvl(wwv_flow.g_user,nvl(:NEW.CREATED_BY,USER));
    IF :NEW.VALUE_PW IS NOT NULL THEN
      :NEW.PW_RAW := STU_PREF_UTIL.encrypt(P_VALUE => :NEW.VALUE_PW,
                                            P_KEY => :NEW.PREF_ID);
      :NEW.VALUE_PW:=NULL;
    END IF;
  END IF;
  IF UPDATING THEN
    :NEW.UPDATED_ON := SYSDATE;
    :NEW.UPDATED_BY := nvl(wwv_flow.g_user,nvl(:NEW.UPDATED_BY,USER));
    IF :NEW.VALUE_PW IS NOT NULL THEN
      :NEW.PW_RAW := STU_PREF_UTIL.encrypt(P_VALUE => :NEW.VALUE_PW,
                                            P_KEY => :NEW.PREF_ID);
      :NEW.VALUE_PW:=NULL;
    END IF;
  END IF;
 
  
END;
/

PROMPT == STU_PREF_UTIL Package Body

create or replace
PACKAGE BODY STU_PREF_UTIL AS

---------------------------------------------------------------------
--
--               Copyright(C) 2015 T. St. Hilaire
--                         All Rights Reserved
-- 
---------------------------------------------------------------------
--  Application   : STU_PREF
--  Subsystem     : Preferences
--  Package Name  : STU_PREF_UTIL
--  Purpose       : Utility for managing settings for an application.
--
--  Comments:       
-----------------------------------------------------------------------
--
-- 1.2    04-OCT-2014   Next revision with improved update capabilities
-- 1.1    01-SEP-2014   Simplified table (hard to beleive)
-----------------------------------------------------------------------

--=====================================================================
--< PRIVATE TYPES AND GLOBALS >--------------------------------------
--=====================================================================

  gn_debug_level               NUMBER; -- store the value of the DEBUG setting for the session
  --gn_debug_purge               NUMBER; -- only run the log purge once per session

--=====================================================================
--< PRIVATE METHODS >==================================================
--=====================================================================

  -------------------------------------------------------------------
  --< DEBUG >--------------------------------------------------------
  -------------------------------------------------------------------
  --  Purpose : Put the if logic here to simplify code
  --
  --  Comments:
  --
  -------------------------------------------------------------------
  PROCEDURE DEBUG (p_message VARCHAR2, p_level NUMBER DEFAULT 1)
  IS
    -- PRAGMA AUTONOMOUS_TRANSACTION; -- only use for custom table logging when needed
  BEGIN
    
    -- fetch the debug setting only once
    if gn_debug_level IS NULL THEN
      -- read the debug setting from source
      gn_debug_level:=nvl(GET_PREF_NUMBER('DEBUG_LOG_LEVEL'),-1); 
    end if; 

    -- log debug messages when > 0
    -- only log if the current level is higher than the requested level
    IF gn_debug_level >= p_level THEN
      
      -- 
      --logger.log('STU_PREF_UTIL: ' ||p_message);
      
      -- to show in APEX logs
      apex_application.debug(p_message);
      
      -- to show on SQL*PLUS logging - testing ONLY
      --DBMS_OUTPUT.PUT_LINE('STU_PREF_UTIL: ' ||p_message);
      
      -- custom table example  -- use LOGGER if it is an option
      /*\
      INSERT INTO LDAP_LOGGER (LOG_LINE)  VALUES ( 'STU_PREF_UTIL: ' ||p_message);
      
      IF gn_debug_purge IS NULL THEN
         gn_debug_purge :=1;
         -- only purge the log once per session connection
         DELETE FROM LDAP_LOGGER WHERE CREATED_ON < trunc(sysdate-14);
         INSERT INTO LDAP_LOGGER (LOG_LINE)  VALUES ( 'STU_PREF_UTIL: LDAP_LOGGER PURGE older than 14 days.' );   
      END IF;
      \*/
    
    END IF;
    
    -- NOTE:  PRAGMA AUTONOMOUS_TRANSACTION;
    -- commit; -- only use for custom table logging when needed

  END DEBUG;


--=====================================================================
--< PUBLIC METHODS >===================================================
--=====================================================================

-------------------------------------------------------------------
--< SET_PREF >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
PROCEDURE SET_PREF ( p_name STU_PREF.PREF_NAME%TYPE, 
                     p_value STU_PREF.value1%TYPE)
IS
  lt_record gt_pref_record;
BEGIN

  lt_record := GET_RECORD (p_name => p_name);
  
  if lt_record.PREF_NAME IS NULL then
    -- new record name to set
    lt_record.PREF_NAME := p_name;
  end if;

  -- set new value
  lt_record.value1:=p_value;

  -- use the update routine to set values
  INSERT_UPDATE_RECORD(p_record => lt_record);

END SET_PREF;

-------------------------------------------------------------------
--< SET_PREF >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
PROCEDURE SET_PREF ( p_name STU_PREF.PREF_NAME%TYPE, 
                     p_value STU_PREF.NUMBER1%TYPE)
IS
  lt_record gt_pref_record;
BEGIN

  lt_record := GET_RECORD (p_name => p_name);
  
  if lt_record.PREF_NAME IS NULL then
    -- new record name to set
    lt_record.PREF_NAME := p_name;
  end if;

  -- set new value
  lt_record.number1:=p_value;

  -- use the update routine to set values
  INSERT_UPDATE_RECORD(p_record => lt_record);

END SET_PREF;

-------------------------------------------------------------------
--< SET_PREF >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
PROCEDURE SET_PREF ( p_name STU_PREF.PREF_NAME%TYPE, 
                     p_value STU_PREF.DATE1%TYPE)
IS
  lt_record gt_pref_record;
BEGIN

  lt_record := GET_RECORD (p_name => p_name);
  
  if lt_record.PREF_NAME IS NULL then
    -- new record name to set
    lt_record.PREF_NAME := p_name;
  end if;

  -- set new value
  lt_record.date1:=p_value;

  -- use the update routine to set values
  INSERT_UPDATE_RECORD(p_record => lt_record);

END SET_PREF;

-------------------------------------------------------------------
--< GET_PREF_VALUE >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_VALUE ( p_name  VARCHAR2) RETURN STU_PREF.value1%TYPE
IS
  l_value1 STU_PREF.value1%TYPE;
  -- l_value2 VARCHAR2(2000);
  -- l_value3 VARCHAR2(2000);
BEGIN
  
  SELECT value1
    INTO l_value1
    FROM STU_PREF 
   WHERE PREF_NAME = p_name;

  -- Option:if preference will contain more than one of each... 
  -- CASE p_value
  -- WHEN 1 THEN
  --   RETURN l_value1;
  -- WHEN 2 THEN
  --   RETURN l_value2;
  -- WHEN 3 THEN
  --   RETURN l_value3;
  -- ELSE
  --   RETURN NULL;
  -- END CASE;

  RETURN l_value1;

EXCEPTION WHEN NO_DATA_FOUND THEN
  -- request for an unknown value - return NULL
  RETURN NULL;
END GET_PREF_VALUE;
  
-------------------------------------------------------------------
--< GET_PREF_NUMBER >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_NUMBER ( p_name  VARCHAR2) RETURN STU_PREF.number1%TYPE
IS
  l_number1 STU_PREF.number1%TYPE;
  -- l_value2 VARCHAR2(2000);
  -- l_value3 VARCHAR2(2000);
BEGIN
  
  SELECT number1
    INTO l_number1
    FROM STU_PREF 
   WHERE PREF_NAME = p_name;

  RETURN l_number1;

EXCEPTION WHEN NO_DATA_FOUND THEN
  -- request for an unknown value - return NULL
  RETURN NULL;
END GET_PREF_NUMBER;


-------------------------------------------------------------------
--< GET_PREF_DATE >-----------------------------------------------
-------------------------------------------------------------------
--  Purpose : Get the settings value form the setting table
--
--  Comments:
--
-------------------------------------------------------------------
FUNCTION GET_PREF_DATE ( p_name  VARCHAR2) RETURN STU_PREF.date1%TYPE
IS
  l_date1 STU_PREF.date1%TYPE;
  -- l_value2 VARCHAR2(2000);
  -- l_value3 VARCHAR2(2000);
BEGIN
  
  SELECT date1
    INTO l_date1
    FROM STU_PREF 
   WHERE PREF_NAME = p_name;

  RETURN l_date1;

EXCEPTION WHEN NO_DATA_FOUND THEN
  -- request for an unknown value - return NULL
  RETURN NULL;
END GET_PREF_DATE;

---------------------------------------------------------------------
--< DECRYPT >--------------------------------------------------------
---------------------------------------------------------------------
--  Purpose : See Specification 
--    
--  Comments:
--
---------------------------------------------------------------------
FUNCTION decrypt( p_crypt  RAW,  
                  p_key    VARCHAR2 ) RETURN VARCHAR2 AS
/*
http://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_obtool.htm
http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:685421699413
*/
  l_key          RAW(32767);
  l_value_raw    RAW(2000);
  l_value        VARCHAR2(32767);
BEGIN
  
  -- Do not run if the needed values are not passed in.
  IF p_crypt is null or p_key is null then
    return NULL;
  END IF;
  
  -- using a 128 bit key of 16 bytes
  --l_key := UTL_RAW.cast_to_raw(substr(p_key,length(p_key)-16,length(p_key)));
  l_key := UTL_RAW.cast_to_raw(substr(p_key,length(p_key)-16,16));

  l_value_raw:=dbms_obfuscation_toolkit.DESDecrypt( 
             input     => p_crypt,
             key       => l_key );

  l_value:= utl_raw.cast_to_varchar2(l_value_raw);

  RETURN rtrim(l_value,chr(0));
EXCEPTION
  WHEN others THEN
    debug(3, 'DECRYPT: Error when decrypting value:'|| p_key);
    RETURN NULL;
END DECRYPT;


---------------------------------------------------------------------
--< ENCRYPT >--------------------------------------------------------
---------------------------------------------------------------------
--  Purpose : See Specification 
--    
--  Comments:
--
---------------------------------------------------------------------
FUNCTION encrypt( p_value  VARCHAR2,  
                  p_key    VARCHAR2 ) RETURN RAW AS
/*
http://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_obtool.htm
*/
  li_pad_count    integer;
  lr_key          RAW(32767);
  lr_padblock     RAW(2000);
  lr_crypt        RAW(2000);
BEGIN
  
  -- Do not run if the needed values are not passed in.
  IF p_value is null or p_key is null then
    return NULL;
  END IF;
  
  -- determine the padd block as a value divisible by 8 is required
  li_pad_count := 8-mod(length(p_value),8);

  -- needs to be a block of 8 - pad with spaces so it can be trimmed during decrypt
  lr_padblock := UTL_RAW.cast_to_raw(p_value||rpad(chr(0),li_pad_count,chr(0)));

  
  -- using a 128 bit key of 16 bytes
  lr_key := UTL_RAW.cast_to_raw(substr(p_key,length(p_key)-16,length(p_key)));
  --lr_key := hextoraw('AAAABBBBCCCCDDDD');

  lr_crypt:=dbms_obfuscation_toolkit.DESEncrypt(
               input        => lr_padblock,
               key          => lr_key );

  RETURN lr_crypt;
  
END encrypt;

  -------------------------------------------------------------------
  --< GET_PREF_PW >-----------------------------------------------
  -------------------------------------------------------------------
  --  Purpose : Get the settings value form the setting table
  --            In the case of password - it needs to be decrypted
  --  Comments:
  --
  -------------------------------------------------------------------
  FUNCTION GET_PREF_PW ( p_name VARCHAR2) RETURN STU_PREF.VALUE_PW%TYPE
  IS
    l_value_raw STU_PREF.PW_RAW%TYPE;
    l_id        STU_PREF.PREF_ID%TYPE;
    l_return    STU_PREF.VALUE_PW%TYPE;
  BEGIN
    
    SELECT PW_RAW, PREF_ID
    INTO   l_value_raw, l_id
    FROM   STU_PREF 
    WHERE  PREF_NAME = p_name
      AND  PW_RAW IS NOT NULL;
    
    l_return:=decrypt(l_value_raw,l_id);

    RETURN l_return;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END GET_PREF_PW;

---------------------------------------------------------------------
--< INSERT_RECORD >--------------------------------------------------
---------------------------------------------------------------------
--  Purpose : Insert Record API call
--    
--  Comments:
--
---------------------------------------------------------------------
PROCEDURE INSERT_RECORD (p_record     IN gt_pref_record,
                         p_id     OUT    NUMBER)
IS

BEGIN
  
    -- INSERT INTO STU_PREF values p_record; --
    -- although this would work, I would prefer to have some values
    -- excluded to allow trigger and business logic to work.
    
    INSERT INTO STU_PREF
  (
    -- PREF_ID      ,-- managed by trigger
    PREF_NAME    ,
    VALUE1       ,
    NUMBER1      ,
    DATE1        ,
    VALUE_PW     ,
    -- PW_RAW       , -- managed by trigger
    DESCRIPTION  ,
    USER_EDIT  
    -- CREATED_BY   ,-- managed by trigger
    -- CREATED_ON   ,-- managed by trigger
    -- UPDATED_BY   ,-- managed by trigger
    -- UPDATED_ON   ,-- managed by trigger
  )
  VALUES
  (
    trim(p_record.PREF_NAME),
    trim(p_record.VALUE1   ),
    p_record.NUMBER1      ,
    p_record.DATE1        ,
    p_record.VALUE_PW     ,
    trim(p_record.DESCRIPTION) ,
    p_record.USER_EDIT  
  )
  RETURNING PREF_ID
  INTO p_id;
  
   

END INSERT_RECORD;


  ---------------------------------------------------------------------
  --< UPDATE_RECORD >--------------------------------------------------
  ---------------------------------------------------------------------
  --  Purpose : When an update is needed - this procedure executes the DML
  --
  --  Comments: Internal procedure only 
  ---------------------------------------------------------------------
PROCEDURE UPDATE_RECORD (p_record     IN OUT gt_pref_record)
IS
  lv_current_record VARCHAR2(1);
  lt_record         gt_pref_record;
BEGIN
  
  FOR l_rec in (
                SELECT 'X'
                  FROM STU_PREF
                 WHERE PREF_ID = p_record.PREF_ID 
                   -- check to see if there is any difference
                   AND (
                      p_record.VALUE_PW is not null
                    OR DECODE(PREF_NAME,p_record.PREF_NAME,'SAME','DIFF')='DIFF'
                    OR DECODE(VALUE1,p_record.VALUE1,'SAME','DIFF')='DIFF'
                    OR DECODE(NUMBER1,p_record.NUMBER1,'SAME','DIFF')='DIFF'
                    OR DECODE(DATE1,p_record.DATE1,'SAME','DIFF')='DIFF'
                    OR DECODE(DESCRIPTION,p_record.DESCRIPTION,'SAME','DIFF')='DIFF'
                    OR DECODE(USER_EDIT,p_record.USER_EDIT,'SAME','DIFF')='DIFF'
                   )
                )
  LOOP
  
    -- Only update if something changed
    UPDATE STU_PREF SET
      PREF_NAME    = p_record.PREF_NAME,
      VALUE1       = p_record.VALUE1,
      NUMBER1      = p_record.NUMBER1,
      DATE1        = p_record.DATE1,
      VALUE_PW     = p_record.VALUE_PW,
      DESCRIPTION  = p_record.DESCRIPTION,
      USER_EDIT    = p_record.USER_EDIT
    WHERE PREF_ID  = p_record.PREF_ID;
  
  END LOOP;

END UPDATE_RECORD;


  ---------------------------------------------------------------------
  --< GET_RECORD >--------------------------------------------------
  ---------------------------------------------------------------------
  --  Purpose : See Specification
  --
  --  Comments: 
  ---------------------------------------------------------------------
FUNCTION GET_RECORD (p_id   IN NUMBER)
RETURN   gt_pref_record
IS
    -- used as return value
    lt_pref_record  gt_pref_record;
BEGIN

  -- get full user record by ID
  SELECT 
      PREF_ID,    
      PREF_NAME,  
      VALUE1,     
      NUMBER1,    
      DATE1,      
      NULL as VALUE_PW,   
      NULL as PW_RAW,     
      DESCRIPTION,
      USER_EDIT,
      CREATED_BY, 
      CREATED_ON, 
      UPDATED_BY, 
      UPDATED_ON 
  INTO lt_pref_record
  FROM STU_PREF
  WHERE PREF_ID = p_id;

  -- additional security can be added as needed
  -- clear Password
  -- lt_pref_record.password:=NULL;
  
  -- return record
  RETURN lt_pref_record;

EXCEPTION WHEN NO_DATA_FOUND THEN
    -- bad ID passed - return null
    RETURN NULL;
END GET_RECORD;

  ---------------------------------------------------------------------
  --< GET_RECORD >--------------------------------------------------
  ---------------------------------------------------------------------
  --  Purpose : See Specification
  --
  --  Comments: 
  ---------------------------------------------------------------------
FUNCTION GET_RECORD (p_name   IN STU_PREF.PREF_NAME%TYPE)
RETURN   gt_pref_record
IS
    -- used as return value
    lt_pref_record  gt_pref_record;
BEGIN

  -- get full user record by ID
  SELECT 
      PREF_ID,    
      PREF_NAME,  
      VALUE1,     
      NUMBER1,    
      DATE1,      
      NULL as VALUE_PW,   
      NULL as PW_RAW,     
      DESCRIPTION,
      USER_EDIT,
      CREATED_BY, 
      CREATED_ON, 
      UPDATED_BY, 
      UPDATED_ON 
  INTO lt_pref_record
  FROM STU_PREF
  WHERE PREF_NAME = p_name;

  -- additional security can be added as needed
  -- clear Password
  -- lt_pref_record.password:=NULL;
  
  -- return record
  RETURN lt_pref_record;

EXCEPTION WHEN NO_DATA_FOUND THEN
    -- bad ID passed - return null
    RETURN NULL;
END GET_RECORD;


  ---------------------------------------------------------------------
  --< INSERT_UPDATE_RECORD >----------------------------------------------
  ---------------------------------------------------------------------
  --  Purpose : Provides the USER_ID and feedback
  --
  --  Comments: 
  ---------------------------------------------------------------------
PROCEDURE INSERT_UPDATE_RECORD (p_record    IN OUT gt_pref_record,
                                p_id           OUT NUMBER)
IS
    lv_id_check      number:=NULL;
    lt_record        gt_pref_record;
BEGIN

  -- evaluate UPDATE (already exists) vs. CREATE

  --
  -- ID method - and ID was passed in with the p_record record type
  -- Other matching routines can be included here if desired
  --
  IF  p_record.PREF_ID IS NOT NULL 
  THEN
    DBMS_OUTPUT.put_line('ID:' || p_record.PREF_ID);
    -- update by ID value
    UPDATE_RECORD(p_record);
  ELSE
    -- check for existing record by name
    lt_record:=GET_RECORD (p_name => p_record.PREF_NAME);
    
    -- If the record was found, the start an update to it.
    IF lt_record.PREF_ID IS NOT NULL
    THEN
      p_record.pref_id := lt_record.PREF_ID;
      -- update by ID value
      UPDATE_RECORD(p_record);
    ELSE
      -- not found by ID or NAME
      -- new record 
      INSERT_RECORD(p_record,p_id);      
    END IF;
  END IF;
        
END INSERT_UPDATE_RECORD;


  ---------------------------------------------------------------------
  --< INSERT_UPDATE_RECORD >----------------------------------------------
  ---------------------------------------------------------------------
  --  Purpose : No feedback version of insert
  --
  --  Comments: 
  ---------------------------------------------------------------------
PROCEDURE INSERT_UPDATE_RECORD (p_record           IN gt_pref_record)
IS
    ln_id  NUMBER;
    lt_record     gt_pref_record;
BEGIN
  
  -- convert to a local variable - due to OUTPUT variables
  lt_record:=p_record;
  
  -- call full version  
  INSERT_UPDATE_RECORD ( p_record    => lt_record,
                         p_id        => ln_id);


END INSERT_UPDATE_RECORD;

  ---------------------------------------------------------------------
  --< DELETE_RECORD >----------------------------------------------
  ---------------------------------------------------------------------
  --  Purpose : No feedback version of insert
  --
  --  Comments: 
  ---------------------------------------------------------------------
PROCEDURE DELETE_RECORD (p_id           IN NUMBER)
IS

BEGIN
  
  -- additional protections can be placed here
  DELETE FROM STU_PREF where PREF_ID = p_id;


END DELETE_RECORD;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


   
END STU_PREF_UTIL;

/

