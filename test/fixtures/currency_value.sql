DROP TABLE IF EXISTS currency_value_records;

CREATE TABLE currency_value_records (
    id int primary key auto_increment,
    currency_code varchar(3),
    amount decimal(20,4),
    tax_amount decimal(20,4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO currency_value_records(id, currency_code, amount, tax_amount) values
    (1, 'GBP', 123.45, NULL);
