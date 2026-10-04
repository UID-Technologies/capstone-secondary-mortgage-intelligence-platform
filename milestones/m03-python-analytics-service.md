# Milestone 3 — Python Analytics Service

| Field | Value |
| --- | --- |
| **Milestone ID** | M3 |
| **Target timeline** | Week 3 (after M2) |
| **Curriculum alignment** | Sessions 7–9 — Python fundamentals, Pandas/APIs, AWS SDK integration |
| **Primary output** | `analytics/mortgage-analytics-service/` with normalization, analytics, REST API, S3 workflow |
| **Previous** | [Milestone 2 — Agile + Database Foundation](./m02-agile-database-foundation.md) |
| **Next milestone** | [Milestone 4 — Java & Spring Boot Backend](./m04-java-spring-backend.md) |
| **Estimated effort** | 16–24 hours per team (Week 3) |

---

## Prerequisites & shared references

**From M2 (required):** PostgreSQL running with migrations + seed; demo IDs **`MTG-1001`**, **`MTG-1002`** documented in `database/README.md`.

**Canonical rules:**

- [standards.md](../guides/standards.md) — delinquency formula, ports (`8000`), error JSON, `X-Correlation-Id`
- [reference-data-model.md](../guides/reference-data-model.md) — column names for SQL reads
- [reference/sample-api-contracts.md](../reference/sample-api-contracts.md) — response shapes

**Recommended stack (unless instructor specifies otherwise):** Python 3.11, **FastAPI**, **Uvicorn**, **SQLAlchemy** or **psycopg2**, **Pandas**, **boto3**, **pytest**, **httpx** TestClient.

---

## Objective

Deliver the first runnable **application service**: a Python **mortgage analytics** component that normalizes borrower/loan/payment inputs, computes portfolio metrics with **Pandas**, exposes **REST** endpoints, and integrates **AWS SDK** (S3 document workflow, optional SNS publish) with **structured logging** and **correlation IDs**.

---

## Scope

### In scope (M3)

- Project layout under `analytics/mortgage-analytics-service/`
- Read **live PostgreSQL** (preferred) using M2 schema
- Virtual environment, `requirements.txt`, `.env.example`
- Data normalization, Pandas analytics, REST API, unit/API tests
- S3 upload for documents; correlation ID in logs
- Optional: SNS publish `DocumentUploaded` (prepare for M5)

### Out of scope (M3)

- Spring Boot CRUD (M4)
- JWT (M6)—optional static `API_KEY` for local only, documented
- DLQ/event consumers (M5)
- Glue pipeline (M8)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **7** | Package structure, logging, exception handling, normalization |
| **8** | Pandas analytics, REST API, PostgreSQL reads |
| **9** | Retries, timeouts, S3, correlation IDs |

---

## Tasks

### Task 3.1 — Scaffold Python service

**Steps:**

1. Create structure:

   ```text
   analytics/mortgage-analytics-service/
   ├── src/
   │   ├── api/
   │   │   ├── main.py          # FastAPI app factory
   │   │   ├── routes/
   │   │   └── dependencies.py
   │   ├── models/              # Pydantic request/response
   │   ├── services/
   │   ├── repositories/
   │   ├── analytics/
   │   └── utils/
   │       └── logging_config.py
   ├── tests/
   ├── requirements.txt
   ├── README.md
   └── .env.example
   ```

2. **`requirements.txt`** minimum: `fastapi`, `uvicorn[standard]`, `pandas`, `sqlalchemy`, `psycopg2-binary`, `boto3`, `pytest`, `httpx`, `python-dotenv`.

3. **`.env.example`:**

   ```text
   SERVICE_NAME=mortgage-analytics-service
   LOG_LEVEL=INFO
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5432
   POSTGRES_DB=mortgage_intel
   POSTGRES_USER=mortgage_app
   POSTGRES_PASSWORD=change-me
   AWS_REGION=us-east-1
   AWS_PROFILE=capstone-dev
   S3_BUCKET_DOCUMENTS=capstone-mortgage-docs-dev
   ```

4. **Run locally:**

   ```powershell
   cd analytics/mortgage-analytics-service
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   uvicorn src.api.main:app --reload --port 8000
   ```

---

### Task 3.2 — Repository layer (PostgreSQL)

**Steps:**

1. Implement `MortgageRepository` with SQL aligned to M2 tables (`borrower`, `mortgage`, `payment`, `delinquency`).
2. Map rows to Python dataclasses or Pydantic models; use `mortgage_external_id` in APIs (not internal UUID) unless documented.
3. Connection pool settings in config; fail fast with clear log if DB unreachable.

**Column mapping reference:**

| Analytics concept | Table.column |
| --- | --- |
| Mortgage status | `mortgage.status` |
| Outstanding balance | `mortgage.outstanding_balance` |
| Payment timeline | `payment.due_date`, `payment.paid_date`, `payment.status` |
| Delinquency | `delinquency.days_past_due` or `mortgage.status = 'DELINQUENT'` |

---

### Task 3.3 — Data normalization

**Steps:**

1. Build normalized **DataFrames** for borrowers, mortgages, payments (Session 7).
2. **Validation rules (minimum):**

   | Field | Rule |
   | --- | --- |
   | `status` | Must be in allowed enum from [standards.md](../guides/standards.md) |
   | `outstanding_balance` | ≥ 0 |
   | `paid_date` | If status POSTED, `paid_date` required |
   | Missing email | Flag row, exclude from borrower risk export or default `unknown@example.test` in dev only |

3. Raise `ValidationError` → HTTP 400 with standard error envelope.
4. Log validation warnings with `correlationId`.

---

### Task 3.4 — Pandas analytics

Implement in `src/analytics/portfolio.py` (names flexible):

| Metric | Implementation hint |
| --- | --- |
| Total mortgages | `len(df_mortgages)` or SQL COUNT |
| Outstanding balance | `df['outstanding_balance'].sum()` |
| Delinquent loans | filter `status == 'DELINQUENT'` |
| Delinquency rate | per [standards.md](../guides/standards.md) formula |
| Borrower risk summary | group by `borrower_external_id`, sum balance, count delinquent loans |
| Payment trends | `pd.Grouper` on `paid_date` monthly, sum `amount`, compute on-time ratio |

Document formulas in service **`README.md`**.

---

### Task 3.5 — REST API

**Routes:** see [reference/sample-api-contracts.md](../reference/sample-api-contracts.md).

**Steps:**

1. `GET /health` → `{ "status": "UP", "service": "mortgage-analytics-service" }`
2. Implement analytics routes under `/api/v1/analytics/...`
3. Middleware: read/generate **`X-Correlation-Id`**, bind to logging context.
4. Global exception handler returning [error envelope](../guides/standards.md).

**Example curl:**

```powershell
curl -s -H "X-Correlation-Id: demo-m3-001" http://localhost:8000/api/v1/analytics/portfolio-summary | jq
curl -s http://localhost:8000/api/v1/analytics/delinquency
curl -s http://localhost:8000/api/v1/analytics/borrowers/BOR-001/risk-summary
curl -s "http://localhost:8000/api/v1/analytics/payment-trends?from=2025-01-01&to=2026-12-31"
```

**Cross-check:** `delinquentMortgages` should be ≥ 1 when seed includes `MTG-1002`.

---

### Task 3.6 — S3 document workflow (Session 9)

**Steps:**

1. `POST /api/v1/documents/upload` — accept metadata + file (multipart preferred); store to `s3://{S3_BUCKET_DOCUMENTS}/mortgages/{mortgageExternalId}/{uuid}-{fileName}`.
2. Insert/update row in `document` table with `s3_key`.
3. **boto3** with retries (`Config(retries={'max_attempts': 3})`), timeout; on failure return 502 with error envelope.
4. Optional: publish SNS message with `eventType: DocumentUploaded` (see [event examples](../reference/payload-examples.json)).

**Local without AWS:** use [LocalStack](https://localstack.cloud/) or moto in tests; document in README.

---

### Task 3.7 — Tests

**Steps:**

1. `tests/test_normalization.py` — bad status, negative balance.
2. `tests/test_analytics.py` — fixture CSV or in-memory DB with known delinquency rate.
3. `tests/test_api.py` — TestClient + mocked repository or test DB.
4. `tests/test_s3.py` — moto mock bucket.

Target: **≥ 80%** line coverage on `analytics/` and `services/` packages (team goal).

---

## Implementation requirements

- Python 3.10+; type hints on public functions.
- No AWS keys in Git; use `AWS_PROFILE` / IAM role.
- Delinquency logic **must** match [standards.md](../guides/standards.md) and M2 seed.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `analytics/mortgage-analytics-service/**` | Full service |
| `docs/api/analytics-openapi.yaml` | Optional OpenAPI export |
| Root `README.md` | Link + run instructions |

---

## Validation

```powershell
cd analytics/mortgage-analytics-service
pytest -v
uvicorn src.api.main:app --port 8000
curl http://localhost:8000/health
```

**Manual cross-check:**

```sql
SELECT COUNT(*) FROM mortgage WHERE status = 'DELINQUENT';
```

Compare count to `delinquentMortgages` in API response.

- [ ] Health 200
- [ ] Portfolio summary matches SQL aggregates (± rounding)
- [ ] Correlation ID in logs for `demo-m3-001`
- [ ] S3 upload succeeds (sandbox or LocalStack)
- [ ] Tests pass

---

## Deliverables

| Deliverable | Location |
| --- | --- |
| Analytics service source | `analytics/mortgage-analytics-service/` |
| `.env.example` | Same folder |
| API examples | README + optional OpenAPI |
| Test report | CI artifact or `pytest` log in MR |

---

## Definition of done

```text
☐ Python project scaffolded and runnable on port 8000
☐ PostgreSQL repository reads M2 schema
☐ Normalization with tests
☐ All six analytics metric areas implemented
☐ REST API matches sample contracts where applicable
☐ Structured logging + correlation ID
☐ S3 document upload demonstrated
☐ pytest suite passing
☐ README: formulas, env, curl, AWS setup
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. `/health` and portfolio summary vs SQL (3 min).
2. Delinquency endpoint highlights `MTG-1002` (2 min).
3. Document upload → S3 key + DB row (3 min).
4. Logs with correlation ID (1 min).
5. `pytest -v` (1 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Hard-coded delinquency counts | Compute from DB per standards |
| UUID in URL without docs | Use `MTG-*` external IDs in API |
| S3 failures crash process | Catch ClientError, return 502 |
| No `.env.example` | Required for teammate onboarding |

---

## What comes next

**Milestone 4** — Java **mortgage-service** / **servicing-service** on ports **8080** / **8081** using the same PostgreSQL data.

---

*Capstone — Milestone 3 (Week 3)*
