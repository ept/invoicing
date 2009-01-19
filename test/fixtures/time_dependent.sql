DROP TABLE IF EXISTS time_dependent_records;

CREATE TABLE time_dependent_records (
    id2 int primary key auto_increment,
    valid_from2 datetime not null,
    valid_until2 datetime,
    replaced_by_id2 int,
    value2 varchar(255) not null,
    is_default2 tinyint(1) not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--  2008 -> 2009 -> 2010 -> 2011
--
--  1    -> none
--  2    -> 3    -> 4
--  5    -> 3
--  none -> 6*   -> 7*   -> none
--  8                    -> 9*
--  10
--
--  * = default

INSERT INTO time_dependent_records(id2, valid_from2, valid_until2, replaced_by_id2, value2, is_default2) values
	( 1, '2008-01-01 00:00:00', '2009-01-01 00:00:00', NULL, 'One',   0),
	( 2, '2008-01-01 00:00:00', '2009-01-01 00:00:00', 3,    'Two',   0),
	( 3, '2009-01-01 00:00:00', '2010-01-01 00:00:00', 4,    'Three', 0),
	( 4, '2010-01-01 00:00:00', NULL,                  NULL, 'Four',  0),
	( 5, '2008-01-01 00:00:00', '2009-01-01 00:00:00', 3,    'Five',  0),
	( 6, '2009-01-01 00:00:00', '2010-01-01 00:00:00', 7,    'Six',   1),
	( 7, '2010-01-01 00:00:00', '2011-01-01 00:00:00', NULL, 'Seven', 1),
	( 8, '2008-01-01 00:00:00', '2011-01-01 00:00:00', 9,    'Eight', 0),
	( 9, '2011-01-01 00:00:00', NULL,                  NULL, 'Nine',  1),
	(10, '2008-01-01 00:00:00', NULL,                  NULL, 'Ten',   0);
