-- Synthetic seed excerpt — extend to 5+ borrowers, 10+ mortgages in database/seed/seed_mortgage_data.sql
-- Run after 001_core_schema.sql

INSERT INTO borrower (borrower_external_id, first_name, last_name, email, phone, date_of_birth) VALUES
  ('BOR-001', 'Jamie', 'Nguyen', 'jamie.nguyen@example.test', '+1-555-1001', '1985-03-20'),
  ('BOR-002', 'Morgan', 'Lee', 'morgan.lee@example.test', '+1-555-1002', '1990-11-02');

INSERT INTO mortgage (mortgage_external_id, borrower_id, status, original_amount, outstanding_balance, origination_date)
SELECT 'MTG-1001', id, 'ACTIVE', 310000.00, 305000.00, '2024-01-15' FROM borrower WHERE borrower_external_id = 'BOR-001';

INSERT INTO mortgage (mortgage_external_id, borrower_id, status, original_amount, outstanding_balance, origination_date)
SELECT 'MTG-1002', id, 'DELINQUENT', 280000.00, 279000.00, '2023-06-01' FROM borrower WHERE borrower_external_id = 'BOR-002';

INSERT INTO loan (loan_external_id, mortgage_id, interest_rate, term_months, underwriting_decision)
SELECT 'LOAN-2001', m.id, 0.0625, 360, 'APPROVED' FROM mortgage m WHERE m.mortgage_external_id = 'MTG-1001';

INSERT INTO delinquency (mortgage_id, delinquent_since, days_past_due, severity)
SELECT m.id, '2026-01-10', 45, 'MODERATE' FROM mortgage m WHERE m.mortgage_external_id = 'MTG-1002';

INSERT INTO payment (mortgage_id, due_date, paid_date, amount, status)
SELECT m.id, '2026-02-01', '2026-02-03', 1750.00, 'POSTED' FROM mortgage m WHERE m.mortgage_external_id = 'MTG-1001';

INSERT INTO payment (mortgage_id, due_date, paid_date, amount, status)
SELECT m.id, '2026-01-01', NULL, 1650.00, 'SCHEDULED' FROM mortgage m WHERE m.mortgage_external_id = 'MTG-1002';

INSERT INTO servicing_history (mortgage_id, event_time, event_type, description)
SELECT m.id, NOW() - INTERVAL '30 days', 'PAYMENT_POSTED', 'Payment posted on time'
FROM mortgage m WHERE m.mortgage_external_id = 'MTG-1001';
