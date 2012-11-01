DROP TABLE IF EXISTS currency_value_records;

CREATE TABLE currency_value_records (
    id int primary key auto_increment,
    currency_code varchar(3),
    amount decimal(20,4),
    tax_amount decimal(20,4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO currency_value_records(id, currency_code, amount, tax_amount) values
    (1, 'GBP', 123.45, NULL),
    (2, 'EUR', 98765432, 0.02),
    (3, 'CNY', 5432, 0),
    (4, 'JPY', 8888, 123),
    (5, 'XXX', 123, NULL);

ALTER SEQUENCE currency_value_records_id_seq restart 1000;

    
DROP TABLE IF EXISTS no_currency_column_records;

CREATE TABLE no_currency_column_records (
    id int primary key auto_increment,
    amount decimal(20,4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO no_currency_column_records(id, amount) values(1, '95.15');

ALTER SEQUENCE no_currency_column_records_id_seq restart 1000;
