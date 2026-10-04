# Milestone 10 — Testing & Production Readiness

| Field | Value |
| --- | --- |
| **Milestone ID** | M10 |
| **Target timeline** | Week 12 (final milestone) |
| **Curriculum alignment** | Sessions 34–36 — Playwright/Cucumber, production readiness, final demonstration & handover |
| **Primary output** | E2E regression suite, readiness package, go-live recommendation, final demo |
| **Previous** | [Milestone 9 — CI/CD, Terraform & Observability](./m09-cicd-terraform-observability.md) |
| **Next milestone** | Program completion — operational handover |
| **Estimated effort** | 24–32 hours per team (Week 12) |

---

## Prerequisites & shared references

**From M6:** RBAC users for Journey 4 (`support@capstone.local` vs `underwriter@capstone.local`).

**From M7:** Assistant on port **8001** for Journey 5.

**Demo IDs:** [reference-data-model.md](../guides/reference-data-model.md) — `MTG-1001`, `MTG-1002`, `BOR-001`.

**E2E strategy:** if no UI, use **API-level Cucumber** steps with `fetch`/Playwright `request` context—document in `tests/e2e/README.md`.

---

## Objective

Prove the platform is **release-ready**: comprehensive **automated tests** (unit/API/integration/security/**E2E**), **Playwright + Cucumber** journeys for core mortgage flows, **production readiness** validation, and a **final integrated demonstration** with **operational handover** artifacts.

---

## Scope

### In scope (M10)

- Test layout under `tests/` (unit, api, integration, security, e2e)
- Playwright + Cucumber framework with Page Object Model patterns
- Five mandatory E2E journeys (below) in CI quality gate
- Production readiness checklist and go-live recommendation
- Performance smoke (baseline metrics, not full load test unless required)
- Security validation closure against M6 risk register
- KT/handover checklist for L1/L2 support
- Final session 36 end-to-end scenario rehearsal

### Out of scope (M10)

- Post-program production cutover to real Fannie Mae systems
- Unlimited performance tuning (document known limits)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **34** | Playwright + Cucumber, regression in CI |
| **35** | Readiness dry run, vuln validation, release rehearsal |
| **36** | E2E demo, handover, career roadmap (personal deliverable) |

---

## Tasks

### Task 10.1 — Test pyramid completion

**Steps:**

1. Organize tests:

   ```text
   tests/
   ├── unit/           # Java/Python unit (or colocated in services)
   ├── api/            # REST contract tests
   ├── integration/    # DB, messaging, multi-service
   ├── security/       # Auth/RBAC regression
   └── e2e/            # Playwright + Cucumber
   ```

2. Coverage: document targets in `docs/operations/test-strategy.md` (e.g. critical paths 100% E2E).
3. Wire **e2e** stage in M9 pipeline (may run nightly if slow).

---

### Task 10.2 — Playwright + Cucumber framework

**Steps:**

1. Initialize under `tests/e2e/` with `package.json`, playwright config, cucumber features.
2. Page objects for login, borrower onboarding UI **or** API-backed UI stub (if no frontend, use API steps with Playwright for admin portal minimal HTML—document approach).
3. Parallel execution and retry for flaky tests (Session 34).
4. Publish HTML report as CI artifact.

---

### Task 10.3 — Mandatory E2E journeys

Implement features covering:

| Journey | Scenario outline |
| --- | --- |
| **J1** | Borrower → Mortgage onboarding |
| **J2** | Mortgage → Payment → Servicing history visible |
| **J3** | Missed payment → Delinquency state/event |
| **J4** | Unauthorized user → restricted endpoint → access denied |
| **J5** | Mortgage question → RAG assistant → grounded response with citation |

**Example Gherkin (J4):**

```gherkin
Feature: Authorization
  Scenario: Unauthorized role cannot approve mortgage
    Given user "support@example.com" is authenticated with role SUPPORT
    When the user posts loan approval for mortgage "MTG-1001"
    Then the response status should be 403
```

Link each journey to M2 user story IDs where possible.

**Example feature (Journey 4) — `tests/e2e/features/authorization.feature`:**

```gherkin
Feature: Role-based access control
  Scenario: Support user cannot post loan approval
    Given the user "support@capstone.local" obtains a JWT
    When the user POSTs loan approval for mortgage "MTG-1001"
    Then the response status should be 403
    And the error code should be "ACCESS_DENIED"
```

**Journey mapping:**

| Journey | Stories | Automation focus |
| --- | --- | --- |
| J1 Onboarding | `US-MTG-001`, `US-BOR-001` | POST borrower + mortgage |
| J2 Payment/history | `US-PAY-001`, `US-SRV-001` | POST payment + GET history |
| J3 Delinquency | `US-DEL-001` | Assert `MTG-1002` delinquent |
| J4 Auth deny | `US-SEC-001` | 403 on restricted route |
| J5 RAG | `US-AI-001` | citation array non-empty |

**Playwright config hints:** `retries: 1`, `trace: on-first-retry`, baseURL `http://localhost:8080`.

---

### Task 10.4 — Production readiness validation

**Steps:**

1. Complete checklist in **`docs/operations/production-readiness.md`**:

   ```text
   ☐ Functional validation
   ☐ Security validation
   ☐ Performance validation (smoke)
   ☐ CI/CD validation
   ☐ Infrastructure validation
   ☐ Monitoring validation
   ☐ Backup/recovery considerations
   ☐ Rollback procedure tested
   ☐ Runbook complete
   ☐ Known issues documented
   ☐ Risk register updated
   ☐ Go-live recommendation signed by team
   ```

2. Session 35 lab: readiness dry run notes appended to same doc.
3. Vulnerability re-scan; confirm Critical/High closed or accepted with exception record.

---

### Task 10.5 — Final demonstration script

**Steps:**

1. Create **`docs/operations/final-demo-script.md`**: 20–30 minute flow matching Session 36:
   - Onboarding → underwriting touchpoint → payment → delinquency → analytics dashboard → security deny → RAG question → Splunk correlation → incident/runbook mention
2. Assign demo roles per team member.
3. Record rehearsal checklist with timestamps.

---

### Task 10.6 — Operational handover

**Steps:**

1. Update **`docs/operations/runbook.md`**: startup, deploy, rollback, common failures.
2. **`docs/operations/kt-checklist.md`**: artifacts for L1/L2 (repos, URLs, on-call, Splunk queries, escalation).
3. Known issues and workarounds in README or `docs/operations/known-issues.md`.

**Go-live recommendation outline (`production-readiness.md` appendix):**

- Recommendation: GO / NO-GO / GO with conditions
- Residual risks (top 5) with owners
- Rollback: revert to tag `v1.0.0-capstone-rc1`, scale down ECS/task, restore DB snapshot if applicable
- Support contacts and escalation (L1/L2/SME)

**Release tag:**

```powershell
git tag -a v1.0.0-capstone -m "Final capstone submission"
git push origin v1.0.0-capstone
```

---

## Implementation requirements

- E2E tests must run against **test** environment with seed data; no production borrower data.
- Journey J5 may call assistant API directly if no UI—steps must still be automatable.
- Go-live recommendation must list residual risks honestly.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `tests/e2e/**` | Playwright/Cucumber |
| `docs/operations/test-strategy.md` | Test approach |
| `docs/operations/production-readiness.md` | Readiness sign-off |
| `docs/operations/final-demo-script.md` | Demo runbook |
| `docs/operations/kt-checklist.md` | Handover |
| `.gitlab-ci.yml` | E2E job |

---

## Validation

```powershell
cd tests/e2e
npm ci
npx playwright test
npm run cucumber
```

- [ ] All five journeys pass in test env
- [ ] Security journey proves 403/401
- [ ] RAG journey asserts citation field non-empty
- [ ] Readiness checklist 100% checked or exceptions approved
- [ ] Pipeline includes e2e or documented schedule with last green run ID

---

## Definition of done

```text
☐ Unit/API/integration/security tests organized and passing
☐ Playwright + Cucumber framework in repo
☐ Journey 1–5 automated and passing
☐ E2E integrated into CI or scheduled gate with evidence
☐ Production readiness checklist completed
☐ Performance smoke documented
☐ Security validation closed against risk register
☐ Rollback procedure tested
☐ Runbook and KT checklist complete
☐ Go-live recommendation documented
☐ Final demo rehearsed using final-demo-script.md
☐ Capstone tagged release (e.g. v1.0.0-capstone) on main/develop per policy
☐ Merged to develop/main via reviewed PR(s)
```

---

## Demo scenario (final assessment)

Execute **`final-demo-script.md`** end-to-end for instructors (25–30 min):

1. **Lifecycle** — onboarding through payment (5 min).
2. **Delinquency** — missed payment path + analytics/Splunk glance (5 min).
3. **Security** — RBAC deny (3 min).
4. **AI** — RAG with citation (3 min).
5. **Ops** — CI/CD status, Terraform summary, runbook/RCA pointer (4 min).
6. **Q&A** — architecture and one ADR decision (5 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| E2E only happy path | Include J3 delinquency + J4 deny |
| Flaky locators | POM + auto-waiting (Session 34) |
| Readiness checkbox without evidence | Link pipeline run, scan report, RCA |
| Demo only slides | Live system on test environment |

---

## Program completion

Congratulations on delivering the **Fannie Mae–Style Secondary Mortgage Intelligence Platform**. Archive repo access for instructors, export Splunk dashboards if allowed, and complete personal **role-based upskilling roadmap** from Session 36 mini exercise (outside repo if preferred).

---

*Capstone — Milestone 10 (Week 12)*
