# Milestone 5 — Microservices, Events & Containers

| Field | Value |
| --- | --- |
| **Milestone ID** | M5 |
| **Target timeline** | Week 6 (after M4) |
| **Curriculum alignment** | Sessions 16–18 — Microservices decomposition, SNS/SQS, Docker |
| **Primary output** | Service boundaries, contracts, event backbone, Docker images |
| **Previous** | [Milestone 4 — Java & Spring Boot Backend](./m04-java-spring-backend.md) |
| **Next milestone** | [Milestone 6 — Security Engineering](./m06-security-engineering.md) |
| **Estimated effort** | 18–26 hours per team (Week 6) |

---

## Prerequisites & shared references

**From M4:** Both services run locally; payment POST works; PostgreSQL seed intact.

**Events:** [reference/event-payload-examples.json](../reference/payload-examples.json) — copy schemas to `docs/architecture/events/`.

**AWS naming:** [standards.md](../guides/standards.md) — `capstone-mortgage-lifecycle-dev`, DLQ suffix `-dlq-dev`.

**Local option:** [LocalStack](https://docs.localstack.cloud/) SNS/SQS on `localhost:4566` with `AWS_ENDPOINT_URL` documented in `.env.example`.

---

## Objective

Evolve the capstone from “multiple services in a repo” to a **documented microservice architecture** with **contract-first APIs**, **mortgage lifecycle events** over **SNS → SQS → consumers**, **DLQ and retries**, and **containerized** runnable services.

---

## Scope

### In scope (M5)

- Updated architecture diagrams and ownership matrix
- ADR for decomposition decision
- OpenAPI/AsyncAPI (or JSON Schema) for events
- Event types: `MortgageCreated`, `LoanApproved`, `PaymentReceived`, `PaymentMissed`, `LoanDelinquent`
- Producers/consumers in Java and/or Python as appropriate
- Dockerfiles for `mortgage-service`, `servicing-service`, `mortgage-analytics-service`
- Local/docker-compose optional for Postgres + LocalStack or AWS sandbox
- Container health checks

### Out of scope (M5)

- Full JWT security (M6)
- Terraform/ECS deploy (M9)
- Kinesis streaming depth (M8)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **16** | Bounded contexts, ADR, API boundaries |
| **17** | SNS/SQS, DLQ, retries, schema evolution note |
| **18** | Dockerfiles, health checks, image hardening basics |

---

## Tasks

### Task 5.1 — Service boundary documentation

**Steps:**

1. Update **`docs/architecture/application-architecture.md`** with service boundary diagram.
2. Create **`docs/architecture/service-ownership-matrix.md`**: service → tables/APIs/events owned.
3. Write **`docs/adr/ADR-002-microservice-decomposition.md`**: context, decision, consequences.
4. Remove or document any cyclic dependencies between services.

---

### Task 5.2 — API contracts

**Steps:**

1. Publish OpenAPI specs per service under `docs/api/` (or `services/*/src/main/resources/openapi.yaml`).
2. Version contracts (`v1`); breaking change policy one paragraph in ADR.
3. Consumer-driven check: servicing service expectations on mortgage IDs documented.

---

### Task 5.3 — Event schemas and catalog

**Steps:**

1. Create **`docs/architecture/event-catalog.md`** listing event name, producer, consumer, schema version.
2. Add JSON Schema files under `docs/architecture/events/` for each lifecycle event (minimum fields: `eventId`, `eventType`, `occurredAt`, `correlationId`, `payload`).
3. Implement **producer** on:
   - Mortgage create → `MortgageCreated`
   - Approval workflow stub → `LoanApproved`
   - Payment POST → `PaymentReceived` / `PaymentMissed`
   - Delinquency transition → `LoanDelinquent`

---

### Task 5.4 — SNS/SQS integration

**Architecture:**

```text
Producer Service
      ↓
     SNS (topic)
      ↓
     SQS (queue per consumer)
      ↓
Consumer Service
      ↓
   DLQ (on failure)
```

**Steps:**

1. Configure topics/queues in AWS sandbox (or LocalStack); document names in `.env.example`.
2. Implement consumer that writes **ServicingHistory** or triggers analytics refresh (minimal handler).
3. Configure **DLQ**, max receives, visibility timeout; document in `docs/operations/messaging-runbook.md`.
4. Idempotent consumer using `eventId` deduplication table or cache.

**Suggested queue topology:**

| Queue | Consumer | Notes |
| --- | --- | --- |
| `capstone-mortgage-servicing-dev` | servicing-service | ServicingHistory writes |
| `capstone-mortgage-analytics-dev` | analytics-service | Optional cache refresh |
| `capstone-mortgage-servicing-dlq-dev` | manual replay | After 3 failed receives |

**SQS settings (starting point):** visibility timeout ≥ 30s; maxReceiveCount = 3 before DLQ.

**Env vars (add to services):**

```text
SNS_TOPIC_MORTGAGE_EVENTS=arn:aws:sns:us-east-1:123456789012:capstone-mortgage-lifecycle-dev
SQS_QUEUE_SERVICING_EVENTS=https://sqs.us-east-1.amazonaws.com/123456789012/capstone-mortgage-servicing-dev
SQS_QUEUE_SERVICING_DLQ=<dlq-url>
AWS_ENDPOINT_URL=   # set for LocalStack only
```

**Idempotency table (optional migration `003_event_inbox.sql`):**

```sql
CREATE TABLE event_inbox (
  event_id UUID PRIMARY KEY,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

### Task 5.5 — Containerization

**Steps:**

1. Add **`docker/Dockerfile.mortgage-service`** (or per-service Dockerfile in service folder).
2. Multi-stage build where possible; non-root user if feasible.
3. **`docker-compose.yml`** at root or `docker/`: postgres + 3 services (profiles for optional AWS).
4. HEALTHCHECK instruction calling actuator `/actuator/health`.
5. Validate: `docker compose up --build` brings stack to healthy state.

**`docker-compose.yml` minimum services:**

| Service | Image build | Ports | Depends on |
| --- | --- | --- | --- |
| `postgres` | `postgres:15` | 5432 | — |
| `mortgage-service` | `docker/Dockerfile.mortgage-service` | 8080 | postgres |
| `servicing-service` | `docker/Dockerfile.servicing-service` | 8081 | postgres |
| `analytics-service` | `docker/Dockerfile.analytics-service` | 8000 | postgres |

Pass DB env vars via `environment:` block; mount no secrets into image layers.

**Verify:**

```powershell
docker compose up --build -d
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8000/health
```

---

## Implementation requirements

- Events must carry **correlationId** from HTTP layer when triggered by API.
- No credentials in images; inject via env at runtime.
- Log subscription errors and DLQ sends at ERROR level.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `docs/adr/ADR-002-*.md` | Decomposition |
| `docs/architecture/event-catalog.md` | Events |
| `docs/architecture/events/*.json` | Schemas |
| `docker/**`, `docker-compose.yml` | Containers |
| Service code: messaging packages | Producers/consumers |

---

## Deliverables

| Deliverable | Location |
| --- | --- |
| ADR decomposition | `docs/adr/ADR-002-*.md` |
| Event catalog + JSON schemas | `docs/architecture/events/` |
| Docker compose + Dockerfiles | `docker/`, `docker-compose.yml` |
| Messaging runbook | `docs/operations/messaging-runbook.md` |

---

## Validation

- [ ] Publish test event; consumer processes within expected time
- [ ] Force consumer failure → message lands in DLQ (demo)
- [ ] All three services start in containers and pass health check
- [ ] Event catalog matches implemented types

---

## Definition of done

```text
☐ Service boundaries and ownership documented
☐ API contracts published for each service
☐ Event schemas created and cataloged
☐ SNS/SQS integration working with retries
☐ DLQ configured and demonstrated
☐ Dockerfiles created for three services
☐ Services run as containers with health checks validated
☐ Messaging runbook documented
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. Create mortgage via API → show `MortgageCreated` on queue (3 min).
2. Post payment → `PaymentReceived` consumed; servicing history updated (3 min).
3. Break consumer → show DLQ message (2 min).
4. `docker compose ps` all healthy (2 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| SNS publish without schema versioning | Include `schemaVersion` in payload |
| Shared DB writes from every consumer | Respect ownership matrix |
| Missing idempotency | Dedupe by eventId |
| Fat images with dev tools | Multi-stage builds |

---

## What comes next

**Milestone 6** adds **authentication, RBAC, OWASP hardening**, TypeScript API consumer, pentest remediation, and **threat model**.

---

*Capstone — Milestone 5 (Week 6)*
