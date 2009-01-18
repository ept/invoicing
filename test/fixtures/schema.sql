-- 
-- This SQL file is executed once before all tests run. Use it to set up a database
-- schema and any contents (fixtures) required by the tests.
-- Tests are run in transactions and rolled back, so the database should be restored
-- back to the state defined in this file after each test.
-- 

DROP TABLE IF EXISTS cached_records;

CREATE TABLE cached_records (
    id int primary key auto_increment
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;