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

