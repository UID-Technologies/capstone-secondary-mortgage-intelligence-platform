# Milestone 1 — Project Foundation

| Field | Value |
| --- | --- |
| **Milestone ID** | M1 |
| **Target timeline** | Week 1 (complete before Milestone 2) |
| **Curriculum alignment** | Sessions 1–3 — Engineering Foundations, Workstation Setup, Networking & Cloud Basics |
| **Primary output** | Git repository, baseline folder structure, requirements & architecture documentation |
| **Next milestone** | [Milestone 2 — Agile + Database Foundation](./m02-agile-database-foundation.md) |
| **Estimated effort** | 12–18 hours per team (Week 1) |

---

## Prerequisites & shared references

- No prior milestone. Complete **before** writing application code.
- Adopt naming early from [standards.md](../guides/standards.md) (IDs, correlation header, error JSON).
- Data and API shapes later align with [reference-data-model.md](../guides/reference-data-model.md) — keep epic/story names consistent with M1 `backlog-epics.md`.

---

## Objective

Establish the **Fannie Mae–Style Secondary Mortgage Intelligence Platform** as an enterprise-style capstone: a version-controlled repository, a agreed project structure, documented scope and personas, a mortgage lifecycle business flow, and initial architecture (including deployment topology and trust boundaries). No application services are required in M1—only foundation artifacts that every later milestone builds on.

---

## Scope

### In scope (M1)

- Git repository setup, branching model, and contribution workflow
- Local developer environment validated (tools from Session 2)
- Baseline monorepo folder layout (empty placeholders are acceptable)
- Requirements documents: scope, personas, business flow, stakeholder map, team charter
- High-level backlog **epics** (titles and one-line descriptions only; detailed stories come in M2)
- Architecture documents and diagrams: system context, application view, deployment topology, trust boundaries
- Root `README.md` with project overview and links to all M1 docs

### Out of scope (M1)

- PostgreSQL schema, migrations, or seed data (Milestone 2)
- Python, Java, or Spring Boot source code (Milestones 3–4)
- AWS resource provisioning, Docker images, or CI/CD pipelines (later milestones)
- Authentication, threat model completion, or security testing (Milestone 6)
- Production-ready APIs or automated tests beyond optional smoke checks on repo structure

---

## Concepts applied

Map classroom labs to this milestone as you complete Week 1:

| Session | Title (curriculum) | Capstone application |
| --- | --- | --- |
| **1** | Program kickoff, SDLC, secondary mortgage ecosystem | Scope, personas, stakeholder map, team charter, epic list |
| **2** | Windows + Linux workstation mastery | Tool validation, SSH keys, clone/push repository, create folder structure |
| **3** | Networking, cloud basics, security zones | Deployment topology, request path, trust boundaries, TLS/DMZ concepts in architecture |

---

## Tasks

Complete tasks in order. Each task lists **steps** you should perform and **evidence** to leave in the repository.

### Task 1.1 — Create and configure the Git repository

**Goal:** A shared remote repository named for the capstone (recommended: `mortgage-intelligence-platform`) with an enterprise-style Git workflow.

**Steps:**

1. Create an empty remote repository (GitLab, GitHub, or organization standard). Do **not** commit secrets, `.env` files with real credentials, or personal access tokens.
2. Clone the repository to your workstation.
3. Add a root **`.gitignore`** appropriate for Java, Python, Node/TypeScript, IDE files, OS junk, and local env files. Include at minimum: `*.env`, `.env.*`, `__pycache__/`, `target/`, `.idea/`, `.vscode/settings.json` (if personal), `*.log`.
4. Create branch **`main`** (or **`master`** if your org requires it) as the protected default.
5. Create branch **`develop`** from default; day-to-day integration happens via merges into `develop`.
6. Document **feature branch naming**: `feature/<ticket-or-short-description>` (example: `feature/M1-project-structure`).
7. Document **commit message convention** (recommended: `type(scope): summary` — e.g. `docs(requirements): add personas and scope`).
8. Document **pull request workflow**: feature branch → PR to `develop` → at least one peer review → merge. No direct commits to `develop` without review once team policy is active.
9. Push `main` and `develop` to remote.

**Evidence:** Remote URL in team notes; both branches visible on remote; `.gitignore` committed.

---

### Task 1.2 — Bootstrap local developer environment

**Goal:** Confirm every team member can build and run tools used in later milestones (Session 2 lab).

**Steps:**

1. Install and verify versions (record in `docs/requirements/engineering-standards.md` or team wiki section):

   ```powershell
   git --version
   java -version
   python --version
   docker --version
   psql --version
   ```

2. Configure **SSH keys** for Git (or HTTPS with credential manager)—never store private keys in the repo.
3. Configure Git identity (`user.name`, `user.email`) locally; do not change global git config on shared machines if policy forbids it.
4. Clone the capstone repo again on a second path (or have a peer clone) to confirm access works.
5. Optional: add a **`docs/requirements/dev-environment-checklist.md`** with one row per teammate and checkmarks for tool validation.

**Evidence:** Engineering standards doc lists minimum tool versions; team can clone and push a test commit.

---

### Task 1.3 — Create baseline project structure

**Goal:** Create the capstone monorepo skeleton so later milestones add code in predictable locations.

**Steps:**

1. From repository root, create the folder tree below. Empty folders may use a **`.gitkeep`** file so Git tracks them.

   ```text
   mortgage-intelligence-platform/
   ├── README.md
   ├── .gitignore
   ├── docs/
   │   ├── requirements/
   │   ├── architecture/
   │   ├── adr/
   │   ├── security/
   │   └── operations/
   ├── database/
   │   ├── schema/
   │   ├── migrations/
   │   ├── seed/
   │   └── scripts/
   ├── services/
   │   ├── mortgage-service/
   │   └── servicing-service/
   ├── analytics/
   │   └── mortgage-analytics-service/
   ├── ai/
   │   └── mortgage-knowledge-assistant/
   ├── infrastructure/
   │   └── terraform/
   ├── docker/
   ├── monitoring/
   └── tests/
       ├── api/
       ├── integration/
       ├── security/
       └── e2e/
   ```

2. Add placeholder `README.md` files inside `services/`, `analytics/`, and `ai/` subprojects stating “Implemented in Milestone X” (one sentence each).
3. Commit on a feature branch; open PR to `develop`; merge after review.

**Evidence:** Tree matches structure above; placeholders committed; no duplicate ad-hoc top-level folders.

---

### Task 1.4 — Team charter and engineering standards

**Goal:** Capture how the team works (Session 1 lab: working agreement).

**Steps:**

1. Create **`docs/requirements/team-charter.md`** including:
   - Team name and roles (dev, scrum facilitator, doc owner, security liaison—adjust to team size)
   - Meeting cadence and communication channel
   - Definition of “done” for documentation (reviewed, merged to `develop`, linked from root README)
   - Escalation path when blocked
2. Create or extend **`docs/requirements/engineering-standards.md`** including:
   - Branch and commit conventions (from Task 1.1)
   - Code review checklist (short bullet list; expand in M2 with DevSecOps)
   - Documentation location rule: “All capstone docs live under `docs/`”
   - PII rule: no real borrower data in repo; use synthetic/fake data only in later milestones

**Evidence:** Both files merged; linked from root README.

---

### Task 1.5 — Project scope and stakeholders

**Goal:** Define *what* the capstone platform is and *who* cares about it (Session 1 capstone progress).

**Steps:**

1. Create **`docs/requirements/project-scope.md`** with these sections filled in (use paragraphs, not single-word bullets):

   | Section | Content guidance |
   | --- | --- |
   | **Problem statement** | Why a secondary mortgage intelligence platform matters (servicing visibility, delinquency risk, document handling, analytics). |
   | **Objectives** | 3–5 measurable goals aligned to the 12-week capstone (e.g. “Expose servicing history via API by Week 5”). |
   | **In-scope functionality** | Borrower/mortgage lifecycle areas you will implement over the program (onboarding, underwriting support, servicing, payments, delinquency, analytics, documents, security, AI assistant, ops). |
   | **Out-of-scope** | Explicit exclusions (e.g. real securitization trading desk, mobile app store release, production Fannie Mae integration). |
   | **Assumptions** | Synthetic data, dev/test environments, cloud sandbox accounts, etc. |
   | **Stakeholders** | Internal roles (product owner proxy, compliance, ops)—can reference stakeholder map. |
   | **Non-functional requirements (initial)** | Security, auditability, availability targets at a high level (detail later). |

2. Create **`docs/requirements/stakeholder-map.md`** with a table or diagram: stakeholder → interest → influence → capstone touchpoint (e.g. Servicing Ops → payment accuracy → high → servicing APIs).

3. Create **`docs/requirements/backlog-epics.md`** listing epics only (user stories and acceptance criteria come in M2):

   ```text
   Borrower Management
   Mortgage Management
   Underwriting
   Servicing
   Payment
   Delinquency
   Analytics
   Document Management
   Security
   AI Assistant
   Operations
   ```

   For each epic, write 2–3 sentences describing business value in mortgage terms.

**Evidence:** Three files complete; epics align with later milestones.

---

### Task 1.6 — Personas

**Goal:** Document who uses the platform and what they need.

**Steps:**

1. Create **`docs/requirements/personas.md`**.
2. Include **at minimum** these personas (add goals, pain points, and primary capstone features for each):

   | Persona | Typical goals |
   | --- | --- |
   | **Underwriter** | Evaluate loan risk, access policy/guidance, approve or decline |
   | **Servicing Agent** | View loan status, payment history, servicing events |
   | **Risk Analyst** | Portfolio delinquency trends, risk summaries |
   | **Administrator** | User/role management, configuration |
   | **Security Analyst** | Threat visibility, access reviews, incident support |
   | **Support Engineer** | Troubleshoot failures, correlate logs, run runbooks |

3. Optionally add a **Borrower** persona if your scope includes borrower-facing flows in later E2E tests.

**Evidence:** Each persona has goals, pain points, and at least one “capstone feature” tied to an epic.

---

### Task 1.7 — Business flow (mortgage lifecycle)

**Goal:** Single agreed lifecycle diagram for demos and later test journeys.

**Steps:**

1. Create **`docs/requirements/business-flow.md`**.
2. Document the end-to-end flow (adjust labels if your scope differs, but keep the same stages for curriculum alignment):

   ```text
   Borrower
      ↓
   Mortgage Onboarding
      ↓
   Underwriting
      ↓
   Loan Approval
      ↓
   Servicing
      ↓
   Payments
      ↓
   Delinquency (when payments missed)
      ↓
   Analytics & Reporting
   ```

3. For **each stage**, write 3–5 bullets: primary actor (persona), inputs, outputs, systems involved (even if “future microservice”).
4. Add a **Mermaid** flowchart or attach a diagram image under `docs/architecture/images/` (create folder if using images).

**Example Mermaid (starter—you may refine):**

   ```mermaid
   flowchart TD
     A[Borrower] --> B[Onboarding]
     B --> C[Underwriting]
     C --> D[Loan Approval]
     D --> E[Servicing]
     E --> F[Payments]
     F --> G{Payment missed?}
     G -->|Yes| H[Delinquency]
     G -->|No| E
     H --> I[Analytics]
     E --> I
   ```

**Evidence:** `business-flow.md` with narrative + diagram.

---

### Task 1.8 — Initial architecture and deployment topology

**Goal:** Architecture baseline before coding (Sessions 1 and 3 capstone progress).

**Steps:**

1. Create **`docs/architecture/system-context.md`**
   - C4 Level 1–style context: platform, users (personas), external systems (identity provider placeholder, document storage placeholder, observability placeholder).
   - Include a context diagram (Mermaid or exported image).

2. Create **`docs/architecture/application-architecture.md`**
   - Logical components you will build over 12 weeks: portal/API consumers (placeholder), `mortgage-service`, `servicing-service`, `mortgage-analytics-service`, `mortgage-knowledge-assistant`, PostgreSQL, messaging (placeholder), object storage (placeholder).
   - Show **planned** interactions (dashed lines OK for not-yet-built parts).

3. Create **`docs/architecture/deployment-architecture.md`**
   - Environments: **dev**, **test**, **prod** (names may match your org).
   - Topology: client → ingress/load balancer → API layer → services → database; AI service; S3 (future); security zones (DMZ, app tier, data tier) per Session 3.
   - Label **trust boundaries** (Internet / DMZ / application / data).

4. Create **`docs/architecture/data-flow.md`** (high level for M1)
   - Trace one path from Session 3 lab: **browser or API client → API → database → cloud storage** for a mortgage document upload scenario (conceptual; implementation comes later).
   - Note where **TLS** terminates and where **PII** is stored.

5. Create **`docs/architecture/trust-boundaries.md`** (optional separate file if not fully covered in deployment doc)
   - List boundaries, controls at each (authn/z, encryption in transit, network segmentation).

**Evidence:** Four architecture files; deployment doc explicitly mentions portal, APIs, AI service, and database layer.

---

### Task 1.9 — Root README and milestone traceability

**Goal:** Anyone opening the repo understands the project and finds M1 artifacts in under two minutes.

**Steps:**

1. Update root **`README.md`** with:
   - Project title and one-paragraph description
   - Link to `docs/requirements/project-scope.md`
   - Link to architecture index (`docs/architecture/system-context.md`)
   - Table of milestones M1–M10 with status (M1 = In progress / Done)
   - Team members and repository remote URL (if policy allows)
   - “Getting started” pointing to engineering standards and dev environment checklist
2. Ensure all M1 docs are linked from README (requirements + architecture).

**Evidence:** README renders correctly on Git hosting; all links resolve.

---

## Implementation requirements

- **Documentation format:** Markdown (`.md`) in UTF-8; diagrams in Mermaid in-repo or PNG/SVG under `docs/architecture/images/`.
- **Language:** English for all learner-facing capstone docs unless your program specifies otherwise.
- **Naming:** kebab-case file names; no spaces in paths.
- **Security:** No real borrower PII, production credentials, or private keys in Git history. Use placeholders for URLs and account IDs.
- **Consistency:** Epic names in `backlog-epics.md` must match names used in Milestone 2 user stories.
- **Reviews:** Every M1 deliverable reaches `develop` via pull request with at least one reviewer.

---

## Expected repository changes

After M1, these paths should exist and contain meaningful content (not empty templates with “TBD” only):

| Path | Purpose |
| --- | --- |
| `README.md` | Project entry point |
| `.gitignore` | Safe ignores for polyglot repo |
| `docs/requirements/project-scope.md` | Scope |
| `docs/requirements/personas.md` | Personas |
| `docs/requirements/business-flow.md` | Lifecycle |
| `docs/requirements/stakeholder-map.md` | Stakeholders |
| `docs/requirements/team-charter.md` | Team agreement |
| `docs/requirements/engineering-standards.md` | Git, review, PII rules |
| `docs/requirements/backlog-epics.md` | Epic list |
| `docs/architecture/system-context.md` | Context diagram |
| `docs/architecture/application-architecture.md` | Logical architecture |
| `docs/architecture/deployment-architecture.md` | Environments & topology |
| `docs/architecture/data-flow.md` | Request/document flow |
| Baseline folders under `services/`, `analytics/`, `database/`, etc. | Structure for later milestones |

---

## Expected output

At the end of Milestone 1:

- Cloning the repository gives a **clear documentation trail** from README → requirements → architecture.
- A new team member can explain the **mortgage lifecycle**, **six personas**, and **planned system components** without reading application code.
- **`develop`** branch contains the full folder skeleton; **`main`** reflects program policy (may match `develop` after first release tag optional).
- Instructors can open **`deployment-architecture.md`** and see portal, APIs, AI service, DB, and trust boundaries.

---

## Validation

Run these checks before marking M1 complete.

### Repository and Git

```powershell
git branch -a
git log --oneline -5
```

- [ ] Remote has `main` (or default) and `develop`
- [ ] `.gitignore` excludes env secrets and build artifacts
- [ ] No files named `.env` with real secrets in history

### Structure

```powershell
# From repo root — adjust if using Git Bash on Windows
Get-ChildItem -Recurse -Directory docs, database, services, analytics, ai, infrastructure, tests | Select-Object FullName
```

- [ ] All baseline folders from Task 1.3 exist
- [ ] Each required `docs/requirements/*.md` and `docs/architecture/*.md` file exists

### Documentation quality (peer review)

- [ ] Scope doc has all required sections (Task 1.5 table)
- [ ] Each persona has goals and capstone feature mapping
- [ ] Business flow matches curriculum stages (onboarding → analytics)
- [ ] Deployment topology includes API, AI, database, and security zones
- [ ] Epic list matches M2 preparation list

### Optional link check

- [ ] Every link in root `README.md` opens the correct file in the browser/Git UI

---

## Deliverables

Submit or present evidence as required by your instructor:

| Deliverable | Location |
| --- | --- |
| Repository URL | README or LMS submission |
| Scope document | `docs/requirements/project-scope.md` |
| Personas | `docs/requirements/personas.md` |
| Business flow + diagram | `docs/requirements/business-flow.md` |
| Stakeholder map | `docs/requirements/stakeholder-map.md` |
| Team charter | `docs/requirements/team-charter.md` |
| Backlog epics | `docs/requirements/backlog-epics.md` |
| Architecture pack | `docs/architecture/*.md` |
| PR history | At least one merged PR for M1 work |

---

## Definition of done

Milestone 1 is **complete** when all items below are true:

```text
☐ Git repository created and remote configured
☐ Branches main (or default) and develop exist on remote
☐ Branching, commit, and PR conventions documented
☐ .gitignore committed and appropriate for Java/Python/IDE
☐ Local developer environment validated (Git, Java, Python, Docker, PostgreSQL)
☐ Baseline project folder structure created and merged to develop
☐ project-scope.md complete (all sections)
☐ personas.md includes all six required personas
☐ business-flow.md documents lifecycle with diagram
☐ stakeholder-map.md and team-charter.md complete
☐ backlog-epics.md lists all program epics with descriptions
☐ system-context, application-architecture, deployment-architecture, data-flow documented
☐ Deployment topology covers portal, APIs, AI service, database, trust boundaries
☐ Root README links to all M1 documentation
☐ All M1 work merged to develop via reviewed pull request(s)
☐ Repository pushed to remote (instructor can clone)
```

---

## Demo scenario (trainer / milestone review)

**Duration:** 10 minutes per team  

**Script:**

1. Open the repository on **`develop`** and show the folder tree (30 seconds).
2. Walk through **`project-scope.md`**: problem, in-scope vs out-of-scope (2 minutes).
3. Pick **two personas** and explain how an epic supports each (2 minutes).
4. Present **business flow** diagram from onboarding to analytics (2 minutes).
5. Open **`deployment-architecture.md`**: trace request path browser → API → DB → storage; point out **two trust boundaries** (2 minutes).
6. Show **Git evidence**: feature branch, merged PR, commit message convention (1 minute).
7. Answer one impromptu question: *“What is explicitly deferred to Milestone 2?”* (expected: user stories, ERD, PostgreSQL schema, DevSecOps pipeline details).

---

## Common mistakes

| Mistake | Why it hurts | What to do instead |
| --- | --- | --- |
| Starting Java/Python services in Week 1 | Diverts time from alignment docs; messy repo layout | Keep `services/` as README placeholders until M3/M4 |
| Vague scope (“build a mortgage app”) | M2 stories and M10 E2E journeys lack anchor | Use concrete lifecycle stages and epics |
| Skipping deployment topology | Session 3 and later AWS/security milestones lack baseline | Complete `deployment-architecture.md` in M1 |
| Committing secrets or real PII | Security incident, history rewrite | Use `.gitignore`, synthetic data only, secret scanning in M2 |
| Everyone commits directly to `develop` | No review habit for enterprise delivery | Use feature branches and PRs from M1 onward |
| Different epic names in every doc | Backlog fragmentation in M2 | Copy epic names from `backlog-epics.md` verbatim |
| Architecture diagrams without legend | Reviewers cannot follow trust zones | Label zones: Internet, DMZ, App, Data |
| Empty architecture files with “TODO” only | Fails demo and blocks M5 decomposition | Minimum viable diagrams + narrative per Task 1.8 |

---

## What comes next

In **Milestone 2**, you will turn epics into **user stories with acceptance criteria**, build the **ERD**, implement **PostgreSQL schema/migrations/seed**, and establish the **DevSecOps baseline** (branch protection, secret scanning). Have `backlog-epics.md` and architecture docs stable before starting M2.

---

*Capstone: Fannie Mae–Style Secondary Mortgage Intelligence Platform — Milestone 1 (Week 1)*
