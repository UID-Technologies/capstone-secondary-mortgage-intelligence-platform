# Milestone 4 — Java & Spring Boot Backend

| Field | Value |
| --- | --- |
| **Milestone ID** | M4 |
| **Target timeline** | Weeks 4–5 (after M3) |
| **Curriculum alignment** | Sessions 10–15 — Java core, Maven, REST APIs, Spring Boot, JPA, resilience |
| **Primary output** | `services/mortgage-service`, `services/servicing-service` with REST + PostgreSQL |
| **Previous** | [Milestone 3 — Python Analytics Service](./m03-python-analytics-service.md) |
| **Next milestone** | [Milestone 5 — Microservices, Events & Containers](./m05-microservices-events-containers.md) |
| **Estimated effort** | 28–36 hours per team (Weeks 4–5) |

---

## Prerequisites & shared references

**From M2–M3:** PostgreSQL seed with `MTG-1001` / `MTG-1002`; analytics delinquency definition in [standards.md](../guides/standards.md).

**Contracts:** [reference/sample-api-contracts.md](../reference/sample-api-contracts.md) — use as Postman/OpenAPI examples.

**Ports:** mortgage **8080**, servicing **8081** ([standards.md](../guides/standards.md)).

**Week 4 focus:** domain, Maven, CRUD APIs, logging. **Week 5 focus:** JPA, transactions, resilience, API tests.

---

## Objective

Build **persistent Java/Spring Boot** services for core mortgage operations: domain model, layered architecture, **REST APIs**, **Spring Data JPA** on M2 PostgreSQL, transactional payment/servicing updates, and **production-style reliability** (logging, errors, health, retry/timeout/circuit breaker where applicable).

---

## Scope

### In scope (M4)

- Multi-module or two standalone Maven/Gradle projects under `services/`
- Domain entities aligned with ERD: Borrower, Mortgage, Loan, Payment, ServicingHistory, Delinquency
- Minimum API set below; DTOs and mappers
- Global exception handler, validation, pagination on list endpoints
- Actuator health/readiness; correlation ID filter
- API tests (MockMvc or REST Assured) under `tests/api/`

### Out of scope (M4)

- JWT/RBAC (M6)
- SNS/SQS consumers (M5)
- Docker (M5)
- Full CI deploy (M9)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **10** | Java domain model, validation, exceptions |
| **11** | Maven multi-module, profiles dev/test |
| **12** | REST CRUD, logging, Postman collection |
| **13** | Spring Boot bootstrap, externalized config |
| **14** | JPA repositories, transactions, query tuning |
| **15** | Retry, timeout, circuit breaker, health probes |

---

## Tasks

### Task 4.1 — Domain and project structure

**Steps:**

1. Create **`services/mortgage-service`** and **`services/servicing-service`** (or parent POM with modules).
2. Package layout per service:

   ```text
   mortgage-service/
   ├── src/main/java/.../controller/
   ├── service/
   ├── repository/
   ├── entity/
   ├── dto/
   ├── mapper/
   ├── exception/
   └── configuration/
   ```

3. Map JPA entities to M2 tables; document any `@Column` name overrides.
4. Externalize config: `application-dev.yml`, `application-test.yml` with env placeholders.

---

### Task 4.2 — Mortgage service APIs (minimum)

```text
POST /api/v1/borrowers
GET  /api/v1/borrowers/{id}

POST /api/v1/mortgages
GET  /api/v1/mortgages/{id}
GET  /api/v1/mortgages?borrowerId=&page=&size=

POST /api/v1/mortgages/{id}/payments
GET  /api/v1/mortgages/{id}/payments
```

**Steps:**

1. Request validation (`@Valid`), consistent error envelope `{ code, message, correlationId }`.
2. POST payment updates balance/history **transactionally**; create servicing history row.
3. Add **`docs/api/postman/mortgage-service.json`** or OpenAPI export.

**Sample curl (after seed):**

```powershell
curl -s http://localhost:8080/api/v1/borrowers/BOR-001
curl -s -X POST http://localhost:8080/api/v1/mortgages/MTG-1001/payments `
  -H "Content-Type: application/json" `
  -H "X-Correlation-Id: m4-pay-001" `
  -d "{\"dueDate\":\"2026-04-01\",\"paidDate\":\"2026-04-02\",\"amount\":1850.00,\"status\":\"POSTED\"}"
```

**Payment transaction (single `@Transactional` service method):**

1. Insert `payment` row.
2. Update `mortgage.outstanding_balance`.
3. Insert `servicing_history` event `PAYMENT_POSTED`.
4. If payment missed per rules, update `delinquency` / status (or defer full rules to servicing service—document in ADR).

**Idempotency (recommended):** accept header `Idempotency-Key`; store hash in table `idempotency_record` or reject duplicate with 409.

---

### Task 4.3 — Servicing service APIs (minimum)

```text
GET  /api/v1/mortgages/{id}/servicing-history
GET  /api/v1/mortgages/{id}/delinquency
POST /api/v1/mortgages/{id}/servicing-events   # optional internal event
```

Align with user stories US-MTG-* from M2. Servicing service may share DB or call mortgage-service—document choice in **`docs/adr/ADR-001-service-data-ownership.md`**.

---

### Task 4.4 — Persistence and transactions

**Steps:**

1. Spring Data JPA repositories with derived and `@Query` where needed.
2. `@Transactional` on payment and delinquency state changes.
3. Fix one **N+1** scenario (Session 14 mini exercise)—document in service README.
4. Add indexes if missing from M2 migrations (new migration file `002_*.sql`).

---

### Task 4.5 — Reliability and observability

**Steps:**

1. Structured logging (JSON or key=value) with **correlation ID** MDC.
2. `GlobalExceptionHandler` for 404/409/400/500.
3. Actuator: `/actuator/health`, `/actuator/readiness` (custom if needed).
4. Resilience4j or Spring Retry on downstream calls (if analytics client added)—or DB retry policy documented.
5. Simulate DB failure in test profile; verify graceful degradation message.

---

### Task 4.6 — API testing

**Steps:**

1. Tests in `tests/api/` or module `src/test/java`.
2. Cover happy path + not found + validation error for at least 5 endpoints.
3. Optional: Testcontainers PostgreSQL for integration tests.

**Minimum test cases:**

| Test | Expected |
| --- | --- |
| GET `MTG-1001` servicing history | 200, events ordered by time |
| GET `MTG-1002` delinquency | 200, `daysPastDue` ≥ 30 |
| POST payment invalid amount | 400, error envelope with `correlationId` |
| GET unknown mortgage | 404 |

**`application-dev.yml` snippet (env placeholders):**

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST:localhost}:${POSTGRES_PORT:5432}/${POSTGRES_DB:mortgage_intel}
    username: ${POSTGRES_USER:mortgage_app}
    password: ${POSTGRES_PASSWORD}
server:
  port: 8080
management:
  endpoints:
    web:
      exposure:
        include: health,readiness
```

---

## Implementation requirements

- Java 17+; Spring Boot 3.x unless program standard differs.
- API prefix `/api/v1/`; idempotent POST design where curriculum requires (document payment idempotency key if used).
- No secrets in `application.yml`; use env vars.
- Align delinquency rules with M3 analytics definitions or document differences.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `services/mortgage-service/**` | Primary CRUD/payments |
| `services/servicing-service/**` | History/delinquency reads |
| `database/migrations/002_*.sql` | Optional schema tweaks |
| `docs/api/postman/*.json` | Manual test collection |
| `docs/adr/ADR-001-*.md` | Data ownership between services |

---

## Validation

```powershell
cd services/mortgage-service
mvn spring-boot:run
curl -X POST http://localhost:8080/api/v1/borrowers -H "Content-Type: application/json" -d "{...}"
mvn test
```

- [ ] Create borrower → mortgage → payment flow works against seed DB
- [ ] Servicing history returns chronological events
- [ ] Delinquency endpoint reflects missed payment scenario in seed
- [ ] Health UP with DB connected
- [ ] API tests pass

---

## Definition of done

```text
☐ Domain model and JPA entities implemented
☐ mortgage-service and servicing-service run locally
☐ Minimum REST APIs implemented and documented
☐ PostgreSQL integrated with transactions on payments
☐ Global error handling and validation in place
☐ Structured logging and correlation IDs working
☐ Health/readiness endpoints working
☐ Retry/timeout/circuit breaker or documented resilience pattern
☐ API tests passing
☐ Postman/OpenAPI published in docs/api
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. POST borrower and mortgage (2 min).
2. POST payment; GET servicing history (3 min).
3. Show delinquency for seeded missed-payment mortgage (2 min).
4. Show correlation ID in logs across one request (1 min).
5. Run `mvn test` (1 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Anemic domain, logic only in controllers | Service layer owns business rules |
| No transactional payment updates | Single transaction for payment + history |
| Entity exposed directly in API | Use DTOs |
| Different delinquency definition than analytics | Document in README/ADR |

---

## What comes next

**Milestone 5** splits boundaries formally, adds **SNS/SQS** lifecycle events, **DLQ**, and **Docker** for all three services.

---

*Capstone — Milestone 4 (Weeks 4–5)*
