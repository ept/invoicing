DROP TABLE IF EXISTS find_subclasses_records;

CREATE TABLE find_subclasses_records (
    id int primary key auto_increment,
    type_name varchar(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO find_subclasses_records(id, type_name) values
    (1, 'TestBaseclass'),
    (2, 'TestSubclass'),
    (3, 'TestSubSubclass'),
    (4, 'TestSubclassInAnotherFile'),
    (5, 'TestModule::TestInsideModuleSubclass'),
    (6, 'TestOutsideModuleSubSubclass');


DROP TABLE IF EXISTS find_subclasses_non_existent;

CREATE TABLE find_subclasses_non_existent (
    id int primary key auto_increment,
    type varchar(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO find_subclasses_non_existent(id, type) values(1, 'SurelyThereIsNoClassWithThisName');
