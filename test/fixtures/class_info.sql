DROP TABLE IF EXISTS class_info_test_records;

CREATE TABLE class_info_test_records (
    id int primary key auto_increment,
    value int,
    type varchar(255)
);

INSERT INTO class_info_test_records (id, value, type) values
    (1, 2, 'ClassInfoTestRecord'),
    (2, 3, 'ClassInfoTestSubclass'),
    (3, 3, 'ClassInfoTestSubclass2'),
    (4, 3, 'ClassInfoTestSubSubclass');

ALTER SEQUENCE class_info_test_records_id_seq start 1000;


DROP TABLE IF EXISTS class_info_test2_records;

CREATE TABLE class_info_test2_records (
    id int primary key auto_increment,
    value int,
    okapi varchar(255)
);

INSERT INTO class_info_test2_records(id, value, okapi) values(1, 1, 'OKAPI!');

ALTER SEQUENCE class_info_test2_records_id_seq start 1000;
