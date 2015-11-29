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
COMMENT ON TABLE  "AS_MY_TABLE" IS  'Contains main measures list and attributes';
COMMENT ON COLUMN "AS_MY_TABLE"."AS_MY_TABLE_ID"    IS 'Primary Key ID';
COMMENT ON COLUMN "AS_MY_TABLE"."CREATED_BY" IS 'Standard Who/When';
COMMENT ON COLUMN "AS_MY_TABLE"."CREATED_ON" IS 'Standard Who/When';
COMMENT ON COLUMN "AS_MY_TABLE"."UPDATED_BY" IS 'Standard Who/When';
COMMENT ON COLUMN "AS_MY_TABLE"."UPDATED_ON" IS 'Standard Who/When';
COMMENT ON COLUMN "AS_MY_TABLE"."REVISION"   IS 'Standard Used to determine if a message was updated.  LOBs are difficult to checksum.';

