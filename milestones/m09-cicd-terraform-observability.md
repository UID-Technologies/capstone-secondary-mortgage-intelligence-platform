# Milestone 9 — CI/CD, Terraform & Observability

| Field | Value |
| --- | --- |
| **Milestone ID** | M9 |
| **Target timeline** | Week 11 (after M8) |
| **Curriculum alignment** | Sessions 31–33 — GitLab CI/CD, Terraform IaC, Splunk/SRE/incident response |
| **Primary output** | Full pipeline, Terraform modules, Splunk dashboards/alerts, RCA |
| **Previous** | [Milestone 8 — AWS & Data Platform](./m08-aws-data-platform.md) |
| **Next milestone** | [Milestone 10 — Testing & Production Readiness](./m10-testing-production-readiness.md) |
| **Estimated effort** | 22–30 hours per team (Week 11) |

---

## Prerequisites & shared references

**From M5:** Dockerfiles and images to build in CI.

**From M8:** AWS resources to reference in Terraform (import or recreate consistently).

**CI reference:** [reference/gitlab-ci-stub.yml](../reference/gitlab-ci-stub.yml).

**Splunk:** instructor-provided HEC URL/token—store as CI variables `SPLUNK_HEC_URL`, `SPLUNK_HEC_TOKEN` (never commit).

---

## Objective

Automate **build, test, security scan, containerize, and deploy** via **GitLab CI/CD**; provision reproducible infrastructure with **Terraform**; implement **observability** (structured logs, correlation IDs → **Splunk**, dashboards, alerts, SLI/SLO); execute an **incident simulation** and deliver an **RCA**.

---

## Scope

### In scope (M9)

- Multi-stage `.gitlab-ci.yml` (see pipeline below)
- Environment promotion dev → test → prod (prod may be dry-run)
- Terraform under `infrastructure/terraform/` with modules and env folders
- VPC/security groups baseline (Session 32)
- Splunk ingestion from apps (HEC or forwarder—per lab environment)
- Dashboards: mortgage KPIs + error rate; at least one security-relevant panel
- Alert: payment latency or error spike (simulated)
- Incident simulation + **`docs/operations/rca-*.md`**
- Update `docs/operations/runbook.md` and `incident-response.md`

### Out of scope (M9)

- Playwright E2E in pipeline (M10—wire job stub OK)
- Full production CAB approval (document checklist)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **31** | GitLab pipeline, branching, release automation |
| **32** | Terraform modules, VPC, drift detection |
| **33** | Splunk, SLI/SLO, incident triage, RCA |

---

## Tasks

### Task 9.1 — GitLab CI/CD pipeline

**Target stages:**

```text
Build → Unit Test → SAST → SCA → Secret Scan → Container Build → Container Scan → Integration Tests → Deploy
```

**Steps:**

1. Jobs for Java (`mvn`), Python (`pytest`), TS client (`npm test`) as applicable.
2. Build Docker images; push to registry with semver/tag from CI.
3. Container scan (Trivy/GitLab scanner); fail on Critical (policy documented).
4. Deploy to **dev** automatically; **test** manual or gated; **prod** dry-run job.
5. Artifact: JUnit reports, scan reports stored in GitLab.
6. Extend M6 security jobs; single pipeline file documented in `docs/operations/cicd.md`.

---

### Task 9.2 — Terraform infrastructure

**Structure:**

```text
infrastructure/terraform/
├── modules/
│   ├── networking/
│   ├── security/
│   ├── storage/
│   ├── compute/
│   └── messaging/
└── environments/
    ├── dev/
    ├── test/
    └── prod/
```

**Steps:**

1. Modules wrap S3, SQS/SNS, RDS or EC2/ECS placeholder, IAM roles from M8 matrix.
2. Remote state (S3 + DynamoDB lock) documented; no state in Git.
3. `terraform plan/apply` for dev from CI with manual approval for prod.
4. Drift detection mini exercise: note manual change → plan shows diff → remediate via code.

---

### Task 9.3 — Observability

**Steps:**

1. Confirm all services emit structured logs with **correlationId**, service name, trace-friendly fields.
2. Configure Splunk ingestion (index naming: `mortgage_dev`).
3. Create dashboard: request rate, 5xx rate, payment API latency, DLQ depth (if metric available).
4. Define **SLI/SLO** in `docs/operations/slo.md` (example: 99% payment API success over 7d).
5. Alert triggers on threshold; link to runbook section.

---

### Task 9.4 — Incident simulation and RCA

**Steps:**

1. Inject failure: stop DB, flood errors, or disable consumer—coordinate with instructor.
2. Triage using Splunk search; escalate per `incident-response.md`.
3. Write **`docs/operations/rca-<date>.md`**: timeline, root cause, corrective/preventive actions.
4. Session 33 mini exercise: payment latency RCA template filled with real timestamps from sim.

**RCA template sections (`docs/operations/rca-YYYY-MM-DD.md`):**

1. Summary (1 paragraph)
2. Impact (users, duration, SLI breach)
3. Timeline (UTC timestamps)
4. Root cause (technical + contributing factors)
5. Corrective actions (owners, dates)
6. Preventive actions (monitoring, tests, runbook updates)

**Splunk searches (examples):**

```text
index=mortgage_dev correlationId="7c9e6679-7425-40de-944b-e07fc1f90ae7"
index=mortgage_dev service=mortgage-service level=ERROR earliest=-1h
```

**SLI examples (`docs/operations/slo.md`):**

| SLI | SLO target |
| --- | --- |
| Payment API success rate | 99.5% / 30d |
| p95 payment latency | < 500ms |

**Terraform backend (document in `infrastructure/terraform/README.md`):**

```hcl
terraform {
  backend "s3" {
    bucket = "capstone-mortgage-tfstate-dev"
    key    = "mortgage-intelligence/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Implementation requirements

- Pipeline must not print secrets; masked variables in GitLab CI/CD settings.
- Terraform and application AWS access separate roles.
- Deploy rollback procedure documented in `docs/operations/runbook.md`.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `.gitlab-ci.yml` | Full pipeline |
| `infrastructure/terraform/**` | IaC |
| `docs/operations/cicd.md` | Pipeline guide |
| `docs/operations/slo.md` | SLI/SLO |
| `docs/operations/rca-*.md` | Incident RCA |
| `monitoring/splunk/` | Saved searches/export JSON if applicable |

---

## Validation

- [ ] Pipeline green on `develop` with tests + scans
- [ ] Container images published with tag
- [ ] `terraform apply` succeeds in dev
- [ ] Logs searchable in Splunk by correlationId
- [ ] Dashboard renders; alert fired during sim
- [ ] RCA reviewed and linked in MR

---

## Definition of done

```text
☐ CI/CD pipeline working end-to-end
☐ Security gates (SAST/SCA/secrets/container scan) working
☐ Docker images built and stored in registry
☐ Deployment automated to dev (test/prod gated)
☐ Terraform modules and environments created
☐ Infrastructure reproducible from IaC
☐ Logs available in Splunk with correlation IDs
☐ Dashboard created for mortgage KPIs/errors
☐ Alert created and tested
☐ Incident simulation completed
☐ RCA submitted and linked in docs/operations
☐ Runbook and incident-response updated
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. Push commit → pipeline stages green through deploy dev (4 min).
2. Show Terraform plan/apply artifact (2 min).
3. Splunk search by correlationId from live API call (2 min).
4. Walk dashboard + alert that fired during sim (2 min).
5. RCA summary (2 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Deploy without scan gates | Block on Critical CVEs |
| Terraform monolith single file | Use modules per curriculum |
| Logs not JSON | Parser breaks in Splunk |
| RCA blame-only | Include systemic fixes |

---

## What comes next

**Milestone 10** — **Playwright + Cucumber** E2E, five mandatory journeys, production readiness checklist, **final capstone demo**.

---

*Capstone — Milestone 9 (Week 11)*
