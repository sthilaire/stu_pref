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
PASSWORD_TEMP   VARCHAR2 (2000),
PASSWORD_ENC    RAW      (2000),
DESCRIPTION     VARCHAR2 (2000),
API_EDIT        VARCHAR2 (1   ),
API_VIEW        VARCHAR2 (1   ),
CREATED_BY      VARCHAR2 (50  ),
CREATED_ON      DATE,
UPDATED_BY      VARCHAR2 (50  ),
UPDATED_ON      DATE,
REVISION        NUMBER
);

--                  123456789012345678901234567890
CREATE UNIQUE INDEX PK_STU_PREF ON STU_PREF (PREF_ID);
CREATE UNIQUE INDEX UK1_STU_PREF ON STU_PREF (PREF_NAME);


-- Table Comments
COMMENT ON TABLE  "STU_PREF" IS  'Contains main measures list and attributes';
COMMENT ON COLUMN "STU_PREF"."PREF_ID"    IS 'Primary Key ID';
COMMENT ON COLUMN "STU_PREF"."CREATED_BY" IS 'Standard Who/When';
COMMENT ON COLUMN "STU_PREF"."CREATED_ON" IS 'Standard Who/When';
COMMENT ON COLUMN "STU_PREF"."UPDATED_BY" IS 'Standard Who/When';
COMMENT ON COLUMN "STU_PREF"."UPDATED_ON" IS 'Standard Who/When';
COMMENT ON COLUMN "STU_PREF"."REVISION"   IS 'Standard Used to determine if a message was updated.';

PROMPT == STU_PREF_UTIL Package Spec

create or replace
PACKAGE STU_PREF_UTIL IS

-----------------------------------------------------------------------
--
--               Copyright(C) 2015 Tim St. Hilaire 
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
-- 1.3    20-NOV-2015   Updated to STU_PREF for GitHub
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
                           p_value STU_PREF.VALUE1%TYPE);

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
FUNCTION GET_PREF_PW ( p_name  VARCHAR2) RETURN STU_PREF.PASSWORD_TEMP%TYPE;


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

--                        123456789012345678901234567890
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
    IF :NEW.PASSWORD_TEMP IS NOT NULL THEN
      :NEW.PASSWORD_ENC := STU_PREF_UTIL.encrypt(P_VALUE => :NEW.PASSWORD_TEMP,
                                                 P_KEY   => :NEW.PREF_ID);
      :NEW.PASSWORD_TEMP:=NULL;
    END IF;
  END IF;

  IF UPDATING THEN
    :NEW.UPDATED_ON := SYSDATE;
    :NEW.UPDATED_BY := nvl(wwv_flow.g_user,nvl(:NEW.UPDATED_BY,USER));
    IF :NEW.PASSWORD_TEMP IS NOT NULL THEN
      :NEW.PASSWORD_ENC := STU_PREF_UTIL.encrypt(P_VALUE => :NEW.PASSWORD_TEMP,
                                                 P_KEY   => :NEW.PREF_ID);
      :NEW.PASSWORD_TEMP:=NULL;
    END IF;
  END IF;
 
  -- Increment the revision field
  :NEW.REVISION:=nvl(:OLD.REVISION,0)+1;
 

END;
/

PROMPT == STU_PREF_UTIL Package Body

create or replace
PACKAGE BODY STU_PREF_UTIL AS

---------------------------------------------------------------------
--
--               Copyright(C) 2015 Tim St. Hilaire
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
-- 1.3    20-NOV-2015   Updated to STU_PREF for GitHub
-- 1.2    04-OCT-2014   Next revision with improved update capabilities
-- 1.1    01-SEP-2014   Simplified table (hard to beleive)
-----------------------------------------------------------------------

--=====================================================================
--< PRIVATE TYPES AND GLOBALS >--------------------------------------
--=====================================================================


--=====================================================================
--< PRIVATE METHODS >==================================================
--=====================================================================

-------------------------------------------------------------------------------
--< LOG >----------------------------------------------------------------------
-------------------------------------------------------------------------------
--  Purpose : Put the if logic here to simplify code
--
--  Comments:
--
-------------------------------------------------------------------------------
PROCEDURE LOG (
  p_message VARCHAR2, 
  p_level NUMBER DEFAULT 1, 
  p_marker VARCHAR2 DEFAULT NULL
)
IS
  -- PRAGMA AUTONOMOUS_TRANSACTION; -- only use for custom table logging when needed
  lv_message VARCHAR2(32767);
BEGIN
    -- alter the message
    lv_message:= substr($$PLSQL_UNIT||':'|| p_marker||':'||p_message,1,2000);

    -- logger.log(lv_message);
    -- STU_SIMPLE_LOG_UTIL.WRITE(lv_message,p_level);
    
    -- to show in APEX logs
    apex_application.debug(lv_message);

END LOG;



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
  
  IF lt_record.PREF_NAME IS NULL 
  THEN
    IF STU_PREF_UTIL.GET_PREF_VALUE(p_name=>'STU_PREF-CreateOnSet')='Y'
    THEN
      -- new record name to set
      lt_record.PREF_NAME := p_name;
    ELSE
      RETURN;
    END IF;
  END IF;

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
  
  IF lt_record.PREF_NAME IS NULL 
  THEN
    IF STU_PREF_UTIL.GET_PREF_VALUE(p_name=>'STU_PREF-CreateOnSet')='Y'
    THEN
      -- new record name to set
      lt_record.PREF_NAME := p_name;
    ELSE
      RETURN;
    END IF;
  END IF;

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
  
  IF lt_record.PREF_NAME IS NULL 
  THEN
    IF STU_PREF_UTIL.GET_PREF_VALUE(p_name=>'STU_PREF-CreateOnSet')='Y'
    THEN
      -- new record name to set
      lt_record.PREF_NAME := p_name;
    ELSE
      RETURN;
    END IF;
  END IF;

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
--  A version of this used to contain more than one value.  
--  This feature has been removed
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
   WHERE PREF_NAME = p_name
     AND API_VIEW = 'Y';

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
--  A version of this used to contain more than one value.  
--  This feature has been removed
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
   WHERE PREF_NAME = p_name
     AND API_VIEW = 'Y';

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
--  A version of this used to contain more than one value.  
--  This feature has been removed
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
   WHERE PREF_NAME = p_name
     AND API_VIEW = 'Y';

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
    log('Error when decrypting value:'|| p_key,3,'DECRYPT');
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
  FUNCTION GET_PREF_PW ( p_name VARCHAR2) RETURN STU_PREF.PASSWORD_TEMP%TYPE
  IS
    l_value_raw STU_PREF.PASSWORD_ENC%TYPE;
    l_id        STU_PREF.PREF_ID%TYPE;
    l_return    STU_PREF.PASSWORD_TEMP%TYPE;
  BEGIN
    
    SELECT PASSWORD_ENC, PREF_ID
    INTO   l_value_raw, l_id
    FROM   STU_PREF 
    WHERE  PREF_NAME = p_name
      AND  PASSWORD_ENC IS NOT NULL;
    
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
    PASSWORD_TEMP,
    -- PASSWORD_ENC       , -- managed by trigger
    DESCRIPTION  ,
    API_EDIT     ,  
    API_VIEW  
    -- CREATED_BY   ,-- managed by trigger
    -- CREATED_ON   ,-- managed by trigger
    -- UPDATED_BY   ,-- managed by trigger
    -- UPDATED_ON   ,-- managed by trigger
  )
  VALUES
  (
    trim(p_record.PREF_NAME),
    trim(p_record.VALUE1),
    p_record.NUMBER1,
    p_record.DATE1,
    p_record.PASSWORD_TEMP,
    trim(p_record.DESCRIPTION) ,
    nvl(p_record.API_EDIT,'Y'),  
    nvl(p_record.API_VIEW,'Y')
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
                   -- if this flag is set - Edit only through UI
                   AND p_record.API_EDIT = 'Y' 
                   -- check to see if there is any difference
                   AND (
                      p_record.PASSWORD_TEMP is not null
                    OR DECODE(PREF_NAME,p_record.PREF_NAME,'SAME','DIFF')='DIFF'
                    OR DECODE(VALUE1,p_record.VALUE1,'SAME','DIFF')='DIFF'
                    OR DECODE(NUMBER1,p_record.NUMBER1,'SAME','DIFF')='DIFF'
                    OR DECODE(DATE1,p_record.DATE1,'SAME','DIFF')='DIFF'
                    OR DECODE(DESCRIPTION,p_record.DESCRIPTION,'SAME','DIFF')='DIFF'
                    OR DECODE(API_EDIT,p_record.API_EDIT,'SAME','DIFF')='DIFF'
                    OR DECODE(API_VIEW,p_record.API_VIEW,'SAME','DIFF')='DIFF'
                    OR DECODE(REVISION,p_record.REVISION,'SAME','DIFF')='DIFF'
                   )
                )
  LOOP
  
    -- Only update if something changed
    UPDATE STU_PREF SET
      PREF_NAME     = p_record.PREF_NAME,
      VALUE1        = p_record.VALUE1,
      NUMBER1       = p_record.NUMBER1,
      DATE1         = p_record.DATE1,
      PASSWORD_TEMP = p_record.PASSWORD_TEMP,
      DESCRIPTION   = p_record.DESCRIPTION,
      API_EDIT      = p_record.API_EDIT,
      API_VIEW      = p_record.API_VIEW
    WHERE PREF_ID   = p_record.PREF_ID;
  
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
      NULL as PASSWORD_TEMP,   /* active choice to not pass value */
      NULL as PASSWORD_ENC,    /* active choice to not pass value */ 
      DESCRIPTION,
      API_EDIT,
      API_VIEW,
      CREATED_BY, 
      CREATED_ON, 
      UPDATED_BY, 
      UPDATED_ON,
      REVISION 
  INTO lt_pref_record
  FROM STU_PREF
  WHERE PREF_ID = p_id
    AND API_VIEW = 'Y';

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
      NULL as PASSWORD_TEMP,   /* active choice to not pass value */
      NULL as PASSWORD_ENC,    /* active choice to not pass value */ 
      DESCRIPTION,
      API_EDIT,
      API_VIEW,
      CREATED_BY, 
      CREATED_ON, 
      UPDATED_BY, 
      UPDATED_ON,
      REVISION 
  INTO lt_pref_record
  FROM STU_PREF
  WHERE PREF_NAME = p_name
    AND API_VIEW = 'Y';

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
  DELETE FROM STU_PREF 
  WHERE PREF_ID = p_id
  AND API_EDIT = 'Y';

END DELETE_RECORD;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


   
END STU_PREF_UTIL;

/

INSERT INTO STU_PREF (PREF_NAME, VALUE1, DESCRIPTION) VALUES ('STU_PREF-CreateOnSet', 'Y', 'On Set Value - if record does not exist - should it be created?');

commit;
