DROP TABLE IF EXISTS cached_records;

CREATE TABLE cached_records (
    id2 int primary key auto_increment,
    value varchar(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO cached_records(id2, value) values(1, 'One'), (2, 'Two');

ALTER SEQUENCE cached_records_id2_seq restart 1000;


DROP TABLE IF EXISTS refers_to_cached_records;

CREATE TABLE refers_to_cached_records (
    id int primary key auto_increment,
    cached_record_id int
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO refers_to_cached_records(id, cached_record_id) values(1, 1), (2, 1), (3, NULL);

ALTER SEQUENCE refers_to_cached_records_id_seq restart 1000;
