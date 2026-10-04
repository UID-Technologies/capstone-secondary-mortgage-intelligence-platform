# Milestone 2 — Agile + Database Foundation

| Field | Value |
| --- | --- |
| **Milestone ID** | M2 |
| **Target timeline** | Week 2 (after M1) |
| **Curriculum alignment** | Sessions 4–6 — Agile/Scrum, Data Modeling & SQL, DevSecOps Introduction |
| **Primary output** | Product backlog, ERD, PostgreSQL schema/migrations/seed, secure Git baseline |
| **Previous** | [Milestone 1 — Project Foundation](./m01-project-foundation.md) |
| **Next milestone** | [Milestone 3 — Python Analytics Service](./m03-python-analytics-service.md) |
| **Estimated effort** | 14–20 hours per team (Week 2) |

---

## Prerequisites & shared references

**From M1 (required):** repo on `develop`, `docs/requirements/project-scope.md`, `personas.md`, `backlog-epics.md`, architecture pack.

**Use in this milestone:**

- [standards.md](../guides/standards.md) — delinquency rule, ID formats (`MTG-1001`), env var names
- [reference-data-model.md](../guides/reference-data-model.md) — ERD baseline and demo IDs
- [reference/sample-starter-schema.sql](../reference/sample-starter-schema.sql) — copy/adapt to `database/migrations/001_core_schema.sql`
- [reference/sample-seed-data.sql](../reference/sample-seed-data.sql) — extend for full seed
- [reference/gitlab-ci-stub.yml](../reference/gitlab-ci-stub.yml) — merge into root `.gitlab-ci.yml`

---

## Objective

Turn M1 epics into an **INVEST-style backlog** with acceptance criteria and sprint plans, finalize the **relational model** for the mortgage domain, implement **PostgreSQL** schema with migrations and seed data, and establish a **DevSecOps baseline** on the repository (branch protection, scans, review checklist).

---

## Scope

### In scope (M2)

- User stories under each epic in `docs/requirements/backlog-epics.md`
- Sprint 1 and Sprint 2 plans (curriculum capstone)
- ERD and physical schema for core entities
- Migration and seed scripts runnable against local PostgreSQL
- DevSecOps: branch protection, PR checks, secret/dependency scanning (as tooling allows)
- Optional: sample optimized queries documented for mortgage search

### Out of scope (M2)

- Python/Java application services (M3–M4)
- Full GitLab multi-stage deploy pipeline (M9)
- Authentication/RBAC implementation (M6)
- AWS Glue/data lake (M8)

---

## Concepts applied

| Session | Title (curriculum) | Capstone application |
| --- | --- | --- |
| **4** | Agile, Scrum, engineering workflow | User stories, sprint boards, Sprint 1/2 plans |
| **5** | Data foundations, SQL, relational modeling | ERD, PostgreSQL schema, indexes, sample queries |
| **6** | DevSecOps introduction | Secure Git workflow, secret scan, dependency checks |

---

## Tasks

### Task 2.1 — Product backlog and user stories

**Goal:** Every epic from M1 has traceable stories with Given/When/Then acceptance criteria.

**Steps:**

1. Open **`docs/requirements/user-stories.md`** (create if missing).
2. For **each epic**, add at least **two user stories** with IDs: `US-BOR-###`, `US-MTG-###`, etc.
3. Use this story template:

   ```text
   US-MTG-001

   As a servicing agent,
   I want to retrieve mortgage servicing history
   so that I can understand the current status of a loan.

   Acceptance Criteria:
   Given a valid mortgage ID
   When servicing history is requested
   Then the system returns servicing events in chronological order.
   ```

4. Prioritize stories for **Sprint 1** and **Sprint 2** in **`docs/requirements/sprint-plans.md`**:
   - Sprint 1: focus on data model + foundational read paths (stories that unblock M3/M4)
   - Sprint 2: payment/delinquency/servicing write paths
5. Link each story to persona from `personas.md`.

**Evidence:** Minimum 20 user stories across epics; two sprint plans with story IDs listed.

**Suggested minimum stories (add more):**

| Epic | Story IDs to include |
| --- | --- |
| Borrower Management | `US-BOR-001` create borrower, `US-BOR-002` get borrower |
| Mortgage Management | `US-MTG-001` create mortgage, `US-MTG-002` get mortgage |
| Servicing | `US-SRV-001` servicing history (example in task 2.1) |
| Payment | `US-PAY-001` post payment, `US-PAY-002` list payments |
| Delinquency | `US-DEL-001` get delinquency status |
| Analytics | `US-ANL-001` portfolio summary |
| Security | `US-SEC-001` deny unauthorized (for M6) |
| AI Assistant | `US-AI-001` grounded Q&A (for M7) |

---

### Task 2.2 — ER diagram and data dictionary

**Goal:** Logical model agreed before DDL.

**Steps:**

1. Create **`docs/architecture/erd.md`** with diagram (Mermaid `erDiagram` or image in `docs/architecture/images/`).
2. Include entities (minimum):

   ```text
   Borrower
   Loan
   Mortgage
   Payment
   ServicingHistory
   Delinquency
   Document
   ```

3. For each entity document in **`docs/architecture/data-dictionary.md`**:
   - Primary key, foreign keys, cardinality (1:N, etc.)
   - Constraints (NOT NULL, UNIQUE, CHECK where applicable)
   - Recommended indexes (e.g. mortgage lookup by borrower_id, payment by mortgage_id + date)
4. Peer review: confirm alignment with `business-flow.md` from M1.

**Evidence:** ERD + data dictionary merged to `develop`.

---

### Task 2.3 — PostgreSQL schema and migrations

**Goal:** Reproducible database from scripts in repo.

**Steps:**

1. Under **`database/schema/`**, add baseline DDL (e.g. `001_core_schema.sql`) matching ERD.
2. Under **`database/migrations/`**, use ordered scripts or Flyway/Liquibase if team standardizes (plain SQL is acceptable for capstone).
3. Document connection settings in **`database/README.md`** (use env vars; example `.env.example` without secrets):

   ```text
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5432
   POSTGRES_DB=mortgage_intel
   POSTGRES_USER=mortgage_app
   POSTGRES_PASSWORD=<set locally>
   ```

4. Apply migrations locally:

   ```powershell
   psql -U postgres -c "CREATE DATABASE mortgage_intel;"
   psql -U mortgage_app -d mortgage_intel -f database/migrations/001_core_schema.sql
   ```

5. Verify tables: `\dt` in `psql`.

**Evidence:** Clean apply on empty DB; README documents steps.

**DDL alignment:** Tables and columns should match [reference-data-model.md](../guides/reference-data-model.md). If you rename columns, update `data-dictionary.md` and notify the team—M3/M4 depend on the same names.

**Create app DB user (example):**

```sql
CREATE USER mortgage_app WITH PASSWORD 'change-me-locally';
GRANT CONNECT ON DATABASE mortgage_intel TO mortgage_app;
GRANT USAGE ON SCHEMA public TO mortgage_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO mortgage_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO mortgage_app;
```

---

### Task 2.4 — Seed data

**Goal:** Synthetic mortgage portfolio for dev/demo (no real PII).

**Steps:**

1. Add **`database/seed/seed_mortgage_data.sql`** (or CSV + load script).
2. Include at minimum:
   - 5+ borrowers
   - 10+ mortgages/loans with varied status
   - Payment history including at least 2 delinquent scenarios
   - Servicing history events
   - Sample document metadata rows (files not required yet)
3. Add **`database/scripts/reset-dev-db.ps1`** or `.sh` to drop/recreate schema + seed (optional but recommended).
4. In **`database/README.md`**, document demo IDs per [standards](../guides/standards.md): **`MTG-1001`** (ACTIVE), **`MTG-1002`** (DELINQUENT, ≥30 DPD).

**Evidence:** Seed runs after migrations; counts documented in `database/README.md`.

**Validation query (delinquency):**

```sql
SELECT mortgage_external_id, status FROM mortgage WHERE mortgage_external_id IN ('MTG-1001','MTG-1002');
```

---

### Task 2.5 — SQL lab artifacts (Session 5)

**Goal:** Show query thinking for mortgage operations.

**Steps:**

1. Create **`database/scripts/sample-queries.sql`** with:
   - Borrower-to-loan join
   - Outstanding balance aggregation
   - Delinquent loans report
   - One “slow query” + index fix comment (mini exercise alignment)
2. Capture `EXPLAIN` output for optimized query in comments or `docs/architecture/query-notes.md`.

**Evidence:** File committed; at least one index justified in comments.

---

### Task 2.6 — DevSecOps baseline

**Goal:** Secure engineering flow before application code volume grows.

**Steps:**

1. Extend **`docs/requirements/engineering-standards.md`** with **code review checklist** (security, tests, no secrets, migration review).
2. Enable on remote repository (GitLab/GitHub):
   - **Branch protection** on `main` and `develop` (require PR, no force push)
   - **Secret scanning** if available
   - **Dependency scanning** (SCA) or document manual `pip audit` / OWASP dependency-check plan until M9 pipeline
3. Add **`.gitlab-ci.yml`** stub with stages `validate` running secret scan or lint-only (full pipeline in M9)—minimum: fail on detected secrets in repo.
4. Document PR template in **`.gitlab/merge_request_templates/default.md`** or `docs/requirements/pr-template.md`.

**Evidence:** Screenshot or config export in `docs/operations/devsecops-baseline.md` (no tokens).

---

## Implementation requirements

- Story IDs must remain stable once sprint starts (rename via new ID, don’t reuse).
- All DDL under `database/`; no manual-only schema on one laptop.
- Seed data must be **synthetic** (faker-style names, fake SSN patterns if used).
- Migrations must be idempotent or documented as “run once on empty DB.”
- Foreign keys and transactions considered for payment/delinquency consistency (used heavily in M4).

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `docs/requirements/user-stories.md` | Backlog |
| `docs/requirements/sprint-plans.md` | Sprint 1 & 2 |
| `docs/architecture/erd.md` | ER diagram |
| `docs/architecture/data-dictionary.md` | Columns, keys, indexes |
| `database/schema/`, `database/migrations/` | DDL |
| `database/seed/` | Sample data |
| `database/README.md` | Setup instructions |
| `docs/operations/devsecops-baseline.md` | Scan/branch protection evidence |
| `.gitlab-ci.yml` (minimal) | Early quality gate |

---

## Expected output

- Reviewer can run migrations + seed and query delinquent loans from SQL.
- Sprint board (Jira/GitLab Issues) mirrors `sprint-plans.md` story IDs.
- Repository rejects or flags obvious secret commits per team policy.

---

## Validation

```powershell
psql -U mortgage_app -d mortgage_intel -c "\dt"
psql -U mortgage_app -d mortgage_intel -f database/scripts/sample-queries.sql
```

- [ ] All seven core entities exist as tables
- [ ] Seed data loads without FK errors
- [ ] At least 20 user stories with acceptance criteria
- [ ] Sprint 1 and 2 plans list story IDs
- [ ] Branch protection enabled (verify in Git UI)
- [ ] CI/stub pipeline runs on MR

---

## Deliverables

| Deliverable | Location |
| --- | --- |
| User stories + sprints | `docs/requirements/` |
| ERD + dictionary | `docs/architecture/` |
| Migrations + seed | `database/` |
| DevSecOps evidence | `docs/operations/devsecops-baseline.md` |

---

## Definition of done

```text
☐ Epics populated with user stories and acceptance criteria
☐ Sprint 1 and Sprint 2 plans documented
☐ ERD completed with PK/FK/cardinality
☐ Data dictionary completed
☐ PostgreSQL schema created via migration scripts
☐ Seed data available and documented
☐ Sample queries and index rationale documented
☐ Branch protection and PR workflow configured
☐ Secret/dependency checks documented or automated
☐ Code review checklist updated
☐ All work merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. Show **sprint plan** and one story walkthrough (Given/When/Then) (2 min).
2. Display **ERD** and explain Borrower → Mortgage → Payment (2 min).
3. Run **migration + seed** live or show fresh DB (2 min).
4. Execute **delinquent loans query** from `sample-queries.sql` (2 min).
5. Show **branch protection** and last MR with review (2 min).

---

## Common mistakes

| Mistake | What to do instead |
| --- | --- |
| Stories without testable acceptance criteria | Use Given/When/Then |
| Schema drift (manual DB edits) | All changes via migration files |
| Real borrower data in seed | Synthetic data only |
| Skipping indexes until “later” | Document indexes in M2 for M4 performance |
| Deferring DevSecOps until Week 11 | Baseline scans and protected branches now |

---

## What comes next

**Milestone 3** builds `analytics/mortgage-analytics-service/` using Python, Pandas, and early AWS document workflow—reading from PostgreSQL or normalized files aligned with your seed data.

---

*Capstone: Fannie Mae–Style Secondary Mortgage Intelligence Platform — Milestone 2 (Week 2)*
