DROP TABLE IF EXISTS ledger_item_records;

CREATE TABLE ledger_item_records (
    id2 int primary key auto_increment,
    type2 varchar(255) not null,
    sender_id2 int,
    recipient_id2 int,
    identifier2 varchar(255),
    issue_date2 datetime,
    currency2 varchar(5),
    total_amount2 decimal(20,4),
    tax_amount2 decimal(20,4),
    status2 varchar(100),
    period_start2 datetime,
    period_end2 datetime,
    uuid2 varchar(40),
    due_date2 datetime,
    created_at datetime,
    updated_at datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


INSERT INTO ledger_item_records
    (id2, type2,             sender_id2, recipient_id2, identifier2, issue_date2,  currency2, total_amount2, tax_amount2, status2,     period_start2, period_end2,  uuid2,                                  due_date2,    created_at,            updated_at) values
    (1, 'MyInvoice',                  1, 2,             '1',         '2008-06-30', 'GBP',            315.00,       15.00, 'closed',    '2008-06-01',  '2008-07-01', '30f4f680-d1b9-012b-48a5-0017f22d32c0', '2008-07-30', '2008-06-02 12:34:00', '2008-07-01 00:00:00'),
    (2, 'InvoiceSubtype',             2, 1,             '12-ASDF',   '2009-01-01', 'GBP',            141.97,       18.52, 'closed',    '2008-01-01',  '2009-01-01', 'fe4d20a0-d1b9-012b-48a5-0017f22d32c0', '2009-01-31', '2008-12-25 00:00:00', '2008-12-26 00:00:00'),
    (3, 'MyCreditNote',               1, 2,             'putain!',   '2008-07-13', 'GBP',            -57.50,       -7.50, 'closed',    '2008-06-01',  '2008-07-01', '671a05d0-d1ba-012b-48a5-0017f22d32c0', NULL,         '2008-07-13 09:13:14', '2008-07-13 09:13:14'),
    (4, 'MyPayment',                  1, 2,             '14BC4E0F',  '2008-07-06', 'GBP',            256.50,        0.00, 'cleared',   NULL,          NULL,         'cfdf2ae0-d1ba-012b-48a5-0017f22d32c0', NULL,         '2008-07-06 01:02:03', '2008-07-06 02:03:04'),
    (5, 'MyLedgerItem',               2, 3,             NULL,        '2007-04-23', 'USD',            432.10,        NULL, 'closed',    NULL,          NULL,         'f6d6a700-d1ae-012b-48a5-0017f22d32c0', '2011-02-27', '2008-01-01 00:00:00', '2008-01-01 00:00:00'),
    (6, 'CorporationTaxLiability',    4, 1,             'OMGWTFBBQ', '2009-01-01', 'GBP',         666666.66,        NULL, 'closed',    '2008-01-01',  '2009-01-01', '7273c000-d1bb-012b-48a5-0017f22d32c0', '2009-04-23', '2009-01-23 00:00:00', '2009-01-23 00:00:00'),
    (7, 'MyPayment',                  1, 2,             'nonsense',  '2009-01-23', 'GBP',        1000000.00,        0.00, 'failed',    NULL,          NULL,         'af488310-d1bb-012b-48a5-0017f22d32c0', NULL,         '2009-01-23 00:00:00', '2009-01-23 00:00:00'),
    (8, 'MyPayment',                  1, 2,             '1quid',     '2008-12-23', 'GBP',              1.00,        0.00, 'pending',   NULL,          NULL,         'df733560-d1bb-012b-48a5-0017f22d32c0', NULL,         '2009-12-23 00:00:00', '2009-12-23 00:00:00'),
    (9, 'MyInvoice',                  1, 2,             '9',         '2009-01-23', 'GBP',             11.50,        1.50, 'open',      '2009-01-01',  '2008-02-01', 'e5b0dac0-d1bb-012b-48a5-0017f22d32c0', '2009-02-01', '2009-12-23 00:00:00', '2009-12-23 00:00:00'),
    (10,'MyInvoice',                  1, 2,             'a la con',  '2009-01-23', 'GBP',         432198.76,     4610.62, 'cancelled', '2008-12-01',  '2009-01-01', 'eb167b10-d1bb-012b-48a5-0017f22d32c0', NULL,         '2009-12-23 00:00:00', '2009-12-23 00:00:00'),
    (11,'MyInvoice',                  1, 2,             'no_lines',  '2009-01-24', 'GBP',              NULL,        NULL, 'closed',    '2009-01-23',  '2009-01-24', '9ed54a00-d99f-012b-592c-0017f22d32c0', '2009-01-25', '2009-01-24 23:59:59', '2009-01-24 23:59:59');

-- Invoice 10 is set to not add up correctly; total_amount is 0.01 too little to test error handling
