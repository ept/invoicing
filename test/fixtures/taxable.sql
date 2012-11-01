DROP TABLE IF EXISTS taxable_records;

CREATE TABLE taxable_records (
    id int primary key auto_increment,
    currency_code varchar(3),
    amount decimal(20,4),
    gross_amount decimal(20,4),
    tax_factor decimal(10,9)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO taxable_records(id, currency_code, amount, gross_amount, tax_factor) values
    (1, 'GBP', 123.45, 141.09, 0.142857143);

ALTER SEQUENCE taxable_records_id_seq restart 1000;
