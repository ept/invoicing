DROP TABLE IF EXISTS line_item_records;

CREATE TABLE line_item_records (
    id2 int primary key auto_increment,
    type2 varchar(255),
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


-- Can you spot which make of computer I have?

INSERT INTO line_item_records
    (id2, type2, ledger_item_id2, net_amount2, tax_amount2, uuid2,                              tax_point2,   tax_rate_id2, price_id2, quantity2, creator_id2, created_at,            updated_at) values
    (1,   'SuperLineItem',     1, 100.00,      15.00,   '0cc659f0-cfac-012b-481d-0017f22d32c0', '2008-06-31', 1,            1,         1,         42,          '2008-06-31 12:34:56', '2008-06-31 12:34:56'),
    (2,   'SubLineItem',       1, 200.00,      0,       '0cc65e20-cfac-012b-481d-0017f22d32c0', '2008-06-25', 2,            2,         4,         42,          '2008-06-31 21:43:56', '2008-06-31 21:43:56'),
    (3,   'OtherLineItem',     2, 123.45,      18.52,   '0cc66060-cfac-012b-481d-0017f22d32c0', '2009-01-01', 1,            NULL,      1,         43,          '2008-12-25 00:00:00', '2008-12-26 00:00:00'),
    (4,   'UntaxedLineItem',   5, 432.10,      NULL,    '0cc662a0-cfac-012b-481d-0017f22d32c0', '2007-04-23', NULL,         3,         NULL,      99,          '2007-04-03 12:34:00', '2007-04-03 12:34:00'),
    (5,   'SuperLineItem',     3, -50.00,      -7.50,   'eab28cf0-d1b4-012b-48a5-0017f22d32c0', '2008-07-13', 1,            1,         0.5,       42,          '2008-07-13 09:13:14', '2008-07-13 09:13:14'),
    (6,   'OtherLineItem',     6, 666666.66,   NULL,    'b5e66b50-d1b9-012b-48a5-0017f22d32c0', '2009-01-01', 3,            NULL,      0,         666,         '2009-01-23 00:00:00', '2009-01-23 00:00:00'),
    (7,   'SubLineItem',       9, 10.00,       1.50,    '6f362040-d1be-012b-48a5-0017f22d32c0', '2009-01-31', 1,            1,         0.1,       NULL,        '2009-12-23 00:00:00', '2009-12-23 00:00:00'),
    (8,   'SubLineItem',      10, 427588.15,   4610.62, '3d12c020-d1bf-012b-48a5-0017f22d32c0', '2009-01-31', NULL,         NULL,      NULL,      42,          '2009-12-23 00:00:00', '2009-12-23 00:00:00');
