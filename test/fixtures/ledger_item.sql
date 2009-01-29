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


-- INSERT INTO ledger_item_records
--    (id2, type2, sender_id2, recipient_id2, identifier2, issue_date2, currency2, total_amount2, tax_amount2, status2, period_start2, period_end2, uuid2, due_date2, created_at, updated_at) values
--    ();
