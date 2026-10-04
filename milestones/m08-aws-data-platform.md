# Milestone 8 — AWS & Data Platform

| Field | Value |
| --- | --- |
| **Milestone ID** | M8 |
| **Target timeline** | Week 10 (after M7) |
| **Curriculum alignment** | Sessions 28–30 — Core AWS, messaging/Kinesis/DynamoDB, Glue/data lake pipeline |
| **Primary output** | Secured AWS baseline, enhanced messaging, analytics pipeline, reconciliation |
| **Previous** | [Milestone 7 — AI/RAG Mortgage Assistant](./m07-ai-rag-assistant.md) |
| **Next milestone** | [Milestone 9 — CI/CD, Terraform & Observability](./m09-cicd-terraform-observability.md) |
| **Estimated effort** | 20–28 hours per team (Week 10) |

---

## Prerequisites & shared references

**From M3/M5:** Existing S3 bucket and SNS/SQS—**reuse** names from [standards.md](../guides/standards.md); do not create duplicate buckets.

**IAM matrix template:** add rows to `docs/architecture/aws-iam-matrix.md` per role.

**Pipeline zones:** raw `s3://capstone-mortgage-analytics-dev/raw/pg-export/`, curated `.../curated/delinquency_report/`.

---

## Objective

Operationalize **cloud and data-platform** capabilities: **least-privilege IAM**, **S3** document storage, **Lambda** processing, enhanced **SNS/SQS/Kinesis** patterns, **DynamoDB** fast lookup, and a **PostgreSQL → S3 → Glue → curated S3 → analytics** pipeline with **reconciliation** and **schema-drift** handling.

---

## Scope

### In scope (M8)

- IAM roles/policies per service (document in `docs/architecture/aws-iam-matrix.md`)
- S3 buckets: raw documents, curated analytics (naming convention documented)
- Lambda triggered by S3 upload or schedule (metadata extraction, validation stub)
- Kinesis stream for servicing updates **or** documented alternative if sandbox-limited
- DynamoDB table for borrower/mortgage lookup by partition key design
- Glue job (or AWS Glue-compatible ETL script) from exported PG data to curated zone
- Reconciliation report job/script
- Schema drift test case (Session 30 mini exercise)

### Out of scope (M8)

- Full EMR cluster production sizing (awareness doc OK)
- Multi-region DR
- Terraform modules (M9)—may reference resources created manually or import later

**Note:** M3/M5 may have created SNS/SQS/S3—**extend and harden**, do not duplicate unrelated buckets.

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **28** | IAM, S3, Lambda, ECS/EKS awareness doc |
| **29** | SNS/SQS/Kinesis, DynamoDB partition keys |
| **30** | Data lake zones, Glue ETL, reconciliation, schema drift |

---

## Tasks

### Task 8.1 — IAM least privilege

**Steps:**

1. Create roles: `mortgage-analytics-role`, `mortgage-api-role`, `lambda-doc-processor-role`.
2. Policies: allow only required actions on specific bucket ARNs, queues, tables.
3. Document in **`docs/architecture/aws-iam-matrix.md`** (role → services → actions).
4. Mini exercise: fix over-permissioned policy in repo JSON and show diff.

---

### Task 8.2 — S3 document workflow

**Steps:**

1. Buckets with encryption (SSE-S3 or KMS) and block public access.
2. Integrate mortgage Java/Python upload paths to use bucket policies and IAM roles (not long-lived keys on EC2).
3. Lifecycle rule for nonprod cleanup (optional).

---

### Task 8.3 — Lambda processing

**Steps:**

1. Lambda on `s3:ObjectCreated` — validate file type, write metadata row to PostgreSQL or DynamoDB.
2. CloudWatch logs structured JSON; error alarm stub documented.
3. Deploy via zip or container image per program standard; document command.

---

### Task 8.4 — Messaging and DynamoDB

**Steps:**

1. Enhance event flow with Kinesis stream **or** justify SQS-only in ADR if account limits apply.
2. DynamoDB table `MortgageLookup` with partition key design avoiding hot partitions (Session 29 exercise documented).
3. Servicing or analytics service read path uses DynamoDB for ID lookup demo.

---

### Task 8.5 — Analytics data pipeline

**Pipeline:**

```text
PostgreSQL → export/S3 Raw → Glue → S3 Curated → Analytics (Python/Pandas or Athena query)
```

**Steps:**

1. Scheduled or manual export of delinquency/portfolio tables to `s3://.../raw/`.
2. Glue job transforms to Parquet/CSV in `curated/` with column schema file.
3. Update analytics service or notebook to read curated data for one report.
4. **`docs/operations/data-pipeline-runbook.md`**: schedule, owners, failure steps.

---

### Task 8.6 — Reconciliation and schema drift

**Steps:**

1. Reconciliation script: compare row counts/sums PG vs curated (tolerances documented).
2. Schema drift test: add column to export, run Glue with schema evolution or fail-with-alert; document fix in runbook.

**DynamoDB `MortgageLookup` (example):**

| Attribute | Type | Notes |
| --- | --- | --- |
| PK `mortgageExternalId` | String | `MTG-1001` |
| `borrowerExternalId` | String | GSI optional |
| `status` | String | Cached from PG |
| `outstandingBalance` | Number | Updated on payment event |

**Partition key exercise:** avoid monotonic PK; use `mortgageExternalId` not `borrower_id` alone if hot-spot risk on bulk load.

**Reconciliation tolerances (document):**

| Check | Tolerance |
| --- | --- |
| Row count PG vs curated | 0 difference |
| Sum outstanding balance | ± 0.01 currency unit |

**Export command example (run from `database/scripts/`):**

```powershell
psql -U mortgage_app -d mortgage_intel -c "\copy (SELECT * FROM mortgage) TO 'mortgage_export.csv' CSV HEADER"
aws s3 cp mortgage_export.csv s3://capstone-mortgage-analytics-dev/raw/pg-export/date=2026-03-15/
```

---

## Implementation requirements

- Tag resources: `Project=mortgage-intelligence`, `Environment=dev|test`.
- No access keys in Git; use IAM roles for Lambda/ECS tasks.
- Cost awareness: tear down or use sandbox quotas.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `infrastructure/aws/` or `scripts/aws/` | IAM JSON, deploy scripts |
| `docs/architecture/aws-iam-matrix.md` | IAM map |
| `docs/operations/data-pipeline-runbook.md` | Pipeline ops |
| Glue script in `infrastructure/glue/` or similar | ETL |
| Service updates for DynamoDB/S3/Lambda ARNs | Integration |

---

## Validation

- [ ] Upload document → Lambda runs → metadata visible
- [ ] DynamoDB lookup returns mortgage by key
- [ ] Raw and curated S3 prefixes populated after pipeline run
- [ ] Reconciliation report PASS on seed export
- [ ] Schema drift scenario documented with before/after

---

## Definition of done

```text
☐ IAM configured with least privilege and documented
☐ S3 integrated with encryption and no public access
☐ Lambda workflow demonstrated
☐ Messaging enhanced (Kinesis or documented SQS pattern)
☐ DynamoDB lookup use case demonstrated
☐ Data pipeline PostgreSQL → S3 → Glue → Curated implemented
☐ Reconciliation implemented
☐ Schema drift scenario tested and documented
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. Show IAM matrix for one service role (2 min).
2. Upload doc → Lambda log line (3 min).
3. Run pipeline; show curated file (3 min).
4. Reconciliation output (2 min).
5. Explain partition key choice for DynamoDB (2 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| New buckets ignoring M3 paths | Consolidate naming |
| `*` actions in IAM | Resource-scoped policies |
| Glue without schema file | Commit expected schema |
| Skipping reconciliation | Required for data trust |

---

## What comes next

**Milestone 9** adds **GitLab CI/CD** full pipeline, **Terraform** modules/environments, **Splunk** observability, and **RCA** from incident simulation.

---

*Capstone — Milestone 8 (Week 10)*
