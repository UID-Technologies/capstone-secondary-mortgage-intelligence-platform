-- Capstone baseline schema (PostgreSQL)
-- Copy to database/migrations/001_core_schema.sql and adjust with team review.
-- Requires: CREATE DATABASE mortgage_intel; role mortgage_app;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE borrower (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    borrower_external_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    date_of_birth DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE mortgage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mortgage_external_id VARCHAR(20) NOT NULL UNIQUE,
    borrower_id UUID NOT NULL REFERENCES borrower(id),
    status VARCHAR(30) NOT NULL CHECK (status IN ('PENDING','ACTIVE','DELINQUENT','CLOSED')),
    original_amount NUMERIC(15,2) NOT NULL,
    outstanding_balance NUMERIC(15,2) NOT NULL,
    origination_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE loan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_external_id VARCHAR(20) NOT NULL UNIQUE,
    mortgage_id UUID NOT NULL UNIQUE REFERENCES mortgage(id),
    interest_rate NUMERIC(6,4) NOT NULL,
    term_months INT NOT NULL,
    underwriting_decision VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE payment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mortgage_id UUID NOT NULL REFERENCES mortgage(id),
    due_date DATE NOT NULL,
    paid_date DATE,
    amount NUMERIC(15,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('SCHEDULED','POSTED','FAILED','REVERSED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE servicing_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mortgage_id UUID NOT NULL REFERENCES mortgage(id),
    event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_type VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE delinquency (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mortgage_id UUID NOT NULL UNIQUE REFERENCES mortgage(id),
    delinquent_since DATE NOT NULL,
    days_past_due INT NOT NULL,
    severity VARCHAR(20) NOT NULL DEFAULT 'MODERATE'
);

CREATE TABLE document (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mortgage_id UUID NOT NULL REFERENCES mortgage(id),
    document_type VARCHAR(50) NOT NULL,
    s3_key VARCHAR(512),
    file_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mortgage_borrower ON mortgage(borrower_id);
CREATE INDEX idx_mortgage_status ON mortgage(status);
CREATE INDEX idx_payment_mortgage_due ON payment(mortgage_id, due_date);
CREATE INDEX idx_servicing_mortgage_time ON servicing_history(mortgage_id, event_time);
CREATE INDEX idx_document_mortgage ON document(mortgage_id);
