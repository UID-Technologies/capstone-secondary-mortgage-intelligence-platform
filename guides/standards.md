# Capstone engineering standards

Use this document across **all milestones**. Do not invent parallel conventions per service unless you record an ADR.

---

## Identifiers and formats

| Item | Convention | Example |
| --- | --- | --- |
| Borrower business ID | `BOR-{3 digits}` | `BOR-001` |
| Mortgage business ID | `MTG-{4 digits}` | `MTG-1001` |
| Loan business ID | `LOAN-{4 digits}` | `LOAN-2001` |
| Document ID | UUID v4 | `550e8400-e29b-41d4-a716-446655440000` |
| Event ID | UUID v4 | same |
| Correlation ID | UUID v4 (header) | `X-Correlation-Id: 7c9e6679-7425-40de-944b-e07fc1f90ae7` |
| Money | `DECIMAL(15,2)` in DB; JSON number with 2 decimal places | `325000.00` |
| Dates | ISO-8601 UTC in JSON APIs | `2026-03-15T14:30:00Z` |
| API version | Path prefix | `/api/v1/` |

---

## Default local ports

| Service | Port | Health |
| --- | --- | --- |
| `mortgage-service` | `8080` | `GET /actuator/health` |
| `servicing-service` | `8081` | `GET /actuator/health` |
| `mortgage-analytics-service` | `8000` | `GET /health` |
| `mortgage-knowledge-assistant` | `8001` | `GET /health` |
| PostgreSQL | `5432` | `pg_isready` |

Document overrides in each service `README.md`.

---

## Delinquency business rule (canonical)

Used by **M2 seed**, **M3 analytics**, **M4 servicing**, **M5 events**, and **M10 E2E**.

1. A mortgage payment is **due** on the `due_date` of each billing period.
2. If no successful payment posts within **30 calendar days** after `due_date`, status becomes **`DELINQUENT`**.
3. **`PaymentMissed`** event fires when a scheduled payment date passes with no payment (batch or on next payment attempt).
4. **`LoanDelinquent`** event fires when delinquency status is assigned or updated.
5. **Delinquency rate** (analytics): `count(mortgages where status = 'DELINQUENT') / count(mortgages where status in ('ACTIVE','DELINQUENT'))`.

Seed data must include:

- At least **2** mortgages **`ACTIVE`** with on-time payments.
- At least **2** mortgages **`DELINQUENT`** per the 30-day rule (document which `MTG-*` IDs in `database/README.md`).

---

## Mortgage / loan status enums

| Enum | Values | Notes |
| --- | --- | --- |
| `MortgageStatus` | `PENDING`, `ACTIVE`, `DELINQUENT`, `CLOSED`, `FORECLOSURE` | Capstone minimum: use first four |
| `PaymentStatus` | `SCHEDULED`, `POSTED`, `FAILED`, `REVERSED` | |
| `UnderwritingDecision` | `PENDING`, `APPROVED`, `DECLINED` | Stub approval in M4 for events |

---

## HTTP API error envelope

All Java and Python services return errors in this shape:

```json
{
  "code": "MORTGAGE_NOT_FOUND",
  "message": "Mortgage MTG-9999 was not found",
  "correlationId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "timestamp": "2026-03-15T14:30:00Z"
}
```

| HTTP | When |
| --- | --- |
| 400 | Validation failure |
| 401 | Missing/invalid token (M6+) |
| 403 | Valid token, insufficient role |
| 404 | Resource not found |
| 409 | Conflict (duplicate idempotency key) |
| 500 | Unexpected server error (no stack trace in body) |

---

## Security roles (M6+)

| Role | Code |
| --- | --- |
| Administrator | `ADMIN` |
| Underwriter | `UNDERWRITER` |
| Servicing agent | `SERVICING_AGENT` |
| Risk analyst | `RISK_ANALYST` |
| Support | `SUPPORT` |

Seed users (synthetic passwords—**change locally**, never commit real passwords):

| Username | Role | Purpose |
| --- | --- | --- |
| `admin@capstone.local` | ADMIN | Full access |
| `underwriter@capstone.local` | UNDERWRITER | Approve/decline |
| `servicing@capstone.local` | SERVICING_AGENT | Payments, history |
| `risk@capstone.local` | RISK_ANALYST | Analytics read |
| `support@capstone.local` | SUPPORT | Read-only + deny tests |

Store BCrypt hashes in seed or `data.sql`; document default dev password in `database/README.md` only (not in Git if policy forbids—use instructor handout).

---

## Environment variables (naming)

| Variable | Used by | Example |
| --- | --- | --- |
| `POSTGRES_HOST` | All DB clients | `localhost` |
| `POSTGRES_PORT` | | `5432` |
| `POSTGRES_DB` | | `mortgage_intel` |
| `POSTGRES_USER` | | `mortgage_app` |
| `POSTGRES_PASSWORD` | | local secret |
| `AWS_REGION` | Python/Java AWS | `us-east-1` |
| `AWS_PROFILE` | Local dev | `capstone-dev` |
| `S3_BUCKET_DOCUMENTS` | M3, M8 | `capstone-mortgage-docs-dev` |
| `SNS_TOPIC_MORTGAGE_EVENTS` | M5+ | ARN or LocalStack URL |
| `SQS_QUEUE_SERVICING_EVENTS` | M5+ | URL |
| `JWT_SECRET` | M6+ | 32+ char secret in env |
| `LOG_LEVEL` | All | `INFO` |

Commit **`.env.example`** per service with keys and placeholder values only.

---

## AWS resource naming (sandbox)

Pattern: `capstone-mortgage-{resource}-{env}` where `env` is `dev`, `test`, or `prod`.

Examples:

- S3: `capstone-mortgage-docs-dev`
- SNS: `capstone-mortgage-lifecycle-dev`
- SQS: `capstone-mortgage-servicing-dev` + DLQ `capstone-mortgage-servicing-dlq-dev`
- DynamoDB: `CapstoneMortgageLookup-dev` (table names PascalCase if required)

Tag all resources: `Project=mortgage-intelligence`, `Environment=dev`, `Team=<your-team>`.

---

## Logging (structured)

Minimum JSON fields:

```json
{
  "timestamp": "2026-03-15T14:30:00Z",
  "level": "INFO",
  "service": "mortgage-service",
  "correlationId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "message": "Payment posted",
  "mortgageId": "MTG-1001"
}
```

Never log: passwords, JWT, full SSN, full bank account numbers.

---

## Git and documentation

- Feature branches → PR → `develop` (see M1).
- ADRs in `docs/adr/` for service split, shared DB vs API-only, event schema changes.
- OpenAPI files in `docs/api/` named `{service}-openapi.yaml`.

---

## Cross-milestone consistency checklist

Before closing any milestone, verify:

- [ ] Delinquency rule matches this document
- [ ] IDs in tests match seed data (`MTG-1001`, etc.)
- [ ] Error JSON matches envelope above
- [ ] Correlation ID propagated HTTP → logs → events (M5+)
