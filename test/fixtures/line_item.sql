DROP TABLE IF EXISTS line_item_records;

CREATE TABLE line_item_records (
    id2 int primary key auto_increment,
    type2 varchar(255) not null,
    ledger_item_id2 int not null,
    net_amount2 decimal(20,4) not null,
    tax_amount2 decimal(20,4),
    uuid2 varchar(40),
    tax_point2 datetime,
    tax_rate_id2 int,
    price_id2 int,
    quantity2 decimal(10,5),
    creator_id2 int,
    created_at datetime,
    updated_at datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- INSERT INTO line_item_records
--    (id2, type2, ledger_item_id2, net_amount2, tax_amount2, uuid2, tax_point2, tax_rate_id2, price_id2, quantity2, creator_id2, created_at, updated_at) values
--    ();
