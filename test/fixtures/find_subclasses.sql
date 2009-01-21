DROP TABLE IF EXISTS find_subclasses_records;

CREATE TABLE find_subclasses_records (
    id int primary key auto_increment,
    value varchar(255),
    type_name varchar(255),
    associate_id int
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO find_subclasses_records(id, value, associate_id, type_name) values
    (1, 'Mooo!',    1, 'TestBaseclass'),
    (2, 'Baaa!', NULL, 'TestSubclass'),
    (3, 'Mooo!', NULL, 'TestSubSubclass'),
    (4, 'Baaa!', NULL, 'TestSubclassInAnotherFile'),
    (5, 'Mooo!',    1, 'TestModule::TestInsideModuleSubclass'),
    (6, 'Baaa!',    1, 'TestOutsideModuleSubSubclass');


DROP TABLE IF EXISTS find_subclasses_associates;

CREATE TABLE find_subclasses_associates (
    id int primary key auto_increment,
    value varchar(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO find_subclasses_associates (id, value) values(1, 'Cool stuff');


DROP TABLE IF EXISTS find_subclasses_non_existent;

CREATE TABLE find_subclasses_non_existent (
    id int primary key auto_increment,
    value varchar(255),
    type varchar(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO find_subclasses_non_existent(id, value, type) values(1, 'Badger', 'SurelyThereIsNoClassWithThisName');
