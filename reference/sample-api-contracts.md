# Sample API contracts (reference)

Normative rules: [engineering standards](../guides/standards.md). Use these payloads in Postman, tests, and OpenAPI examples.

---

## Mortgage service (Java) — port 8080

### POST `/api/v1/borrowers`

Request:

```json
{
  "borrowerExternalId": "BOR-010",
  "firstName": "Alex",
  "lastName": "Rivera",
  "email": "alex.rivera@example.test",
  "phone": "+1-555-0100",
  "dateOfBirth": "1988-04-12"
}
```

Response `201`:

```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "borrowerExternalId": "BOR-010",
  "firstName": "Alex",
  "lastName": "Rivera",
  "email": "alex.rivera@example.test"
}
```

### POST `/api/v1/mortgages`

```json
{
  "mortgageExternalId": "MTG-1010",
  "borrowerExternalId": "BOR-001",
  "originalAmount": 320000.00,
  "outstandingBalance": 318500.00,
  "originationDate": "2025-06-01",
  "loan": {
    "loanExternalId": "LOAN-2010",
    "interestRate": 0.0650,
    "termMonths": 360,
    "underwritingDecision": "APPROVED"
  }
}
```

### POST `/api/v1/mortgages/{mortgageExternalId}/payments`

Headers: `X-Correlation-Id`, optional `Idempotency-Key: pay-MTG-1001-2026-03-01`

```json
{
  "dueDate": "2026-03-01",
  "paidDate": "2026-03-02",
  "amount": 1850.00,
  "status": "POSTED"
}
```

---

## Servicing service — port 8081

### GET `/api/v1/mortgages/MTG-1001/servicing-history`

Response `200`:

```json
{
  "mortgageExternalId": "MTG-1001",
  "events": [
    {
      "eventTime": "2025-06-15T10:00:00Z",
      "eventType": "ONBOARDING_COMPLETE",
      "description": "Mortgage onboarded to servicing"
    },
    {
      "eventTime": "2026-02-01T09:30:00Z",
      "eventType": "PAYMENT_POSTED",
      "description": "Payment 1850.00 posted"
    }
  ]
}
```

### GET `/api/v1/mortgages/MTG-1002/delinquency`

```json
{
  "mortgageExternalId": "MTG-1002",
  "status": "DELINQUENT",
  "delinquentSince": "2026-01-10",
  "daysPastDue": 45,
  "severity": "MODERATE"
}
```

---

## Analytics service (Python) — port 8000

### GET `/api/v1/analytics/portfolio-summary`

```json
{
  "totalMortgages": 12,
  "activeMortgages": 10,
  "delinquentMortgages": 2,
  "outstandingBalanceTotal": 3842500.00,
  "delinquencyRate": 0.2,
  "asOf": "2026-03-15T12:00:00Z"
}
```

### GET `/api/v1/analytics/payment-trends?from=2025-01-01&to=2026-12-31`

```json
{
  "from": "2025-01-01",
  "to": "2026-12-31",
  "buckets": [
    { "period": "2026-01", "postedAmount": 22000.00, "onTimeRate": 0.95 },
    { "period": "2026-02", "postedAmount": 19800.00, "onTimeRate": 0.90 }
  ]
}
```

### POST `/api/v1/documents/upload`

```json
{
  "mortgageExternalId": "MTG-1001",
  "documentType": "INCOME_VERIFICATION",
  "fileName": "paystub-redacted.pdf",
  "contentBase64": "<base64-or-multipart-in-real-impl>"
}
```

Response includes `documentId`, `s3Key`, `correlationId`.

---

## Auth (M6+) — POST `/api/v1/auth/login`

```json
{ "username": "servicing@capstone.local", "password": "<from-instructor>" }
```

Response:

```json
{
  "accessToken": "<jwt>",
  "expiresInSeconds": 3600,
  "roles": ["SERVICING_AGENT"]
}
```

Use header: `Authorization: Bearer <jwt>`.
