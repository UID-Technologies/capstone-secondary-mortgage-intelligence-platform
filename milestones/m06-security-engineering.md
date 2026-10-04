# Milestone 6 — Security Engineering

| Field | Value |
| --- | --- |
| **Milestone ID** | M6 |
| **Target timeline** | Weeks 7–8 (after M5) |
| **Curriculum alignment** | Sessions 19–24 — Secure API consumer, pentest, DevSecOps CI gates, Auth/RBAC, OWASP, threat modeling |
| **Primary output** | JWT auth, RBAC, hardened APIs, security docs, remediation evidence |
| **Previous** | [Milestone 5 — Microservices, Events & Containers](./m05-microservices-events-containers.md) |
| **Next milestone** | [Milestone 7 — AI/RAG Mortgage Assistant](./m07-ai-rag-assistant.md) |
| **Estimated effort** | 26–34 hours per team (Weeks 7–8) |

---

## Prerequisites & shared references

**From M4–M5:** APIs on 8080/8081; error envelope from [standards.md](../guides/standards.md).

**Seed users & roles:** [standards.md](../guides/standards.md#security-roles-m6) (`servicing@capstone.local`, etc.).

**Threat model template:** [reference/threat-model-outline.md](../reference/threat-model-outline.md).

**CI:** extend [reference/gitlab-ci-stub.yml](../reference/gitlab-ci-stub.yml) with SAST/SCA jobs (Session 21).

**Week 7:** TS consumer + pentest backlog + pipeline gates. **Week 8:** JWT/RBAC + OWASP + STRIDE docs.

---

## Objective

Secure the mortgage platform for enterprise-style assessment: **authenticate** users, enforce **JWT-based authorization** with **RBAC**, apply **OWASP** controls, run **controlled security testing**, and deliver **threat model, risk register, vulnerability report, and remediation backlog**. Establish **secure API consumption** (TypeScript client) and **baseline secure CI gates** (extended from M2, full pipeline in M9).

---

## Scope

### In scope (M6)

- Authentication login/token endpoint (or integration stub with documented JWT claims)
- Roles: `ADMIN`, `UNDERWRITER`, `SERVICING_AGENT`, `RISK_ANALYST`, `SUPPORT`
- Method-level or route-level authorization on sensitive mortgage endpoints
- Input validation, security headers, rate limiting, injection defenses
- Secrets via env/vault pattern; encryption in transit (TLS) documented; encryption at rest strategy doc
- **`clients/mortgage-api-consumer/`** TypeScript client with token refresh/retry pattern (Session 19)
- Security artifacts under `docs/security/`
- Pentest/lab findings → vulnerability report + remediation
- Extend `.gitlab-ci.yml` with SAST/SCA/secret scan jobs (Session 21)—deploy stage still M9

### Out of scope (M6)

- Full Ping Identity/SailPoint production integration (awareness/docs OK)
- Production WAF rule implementation (document request process)
- Complete SOC/Splunk SIEM rules (M9)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **19** | TypeScript API consumer, JWT handling |
| **20** | API pentest, remediation backlog |
| **21** | SAST/DAST/SCA in GitLab pipeline |
| **22** | AuthN/Z, RBAC, data classification, encryption strategy |
| **23** | OWASP hardening, rate limits, validation |
| **24** | STRIDE threat model, risk register, NIST CSF mapping |

---

## Tasks

### Task 6.1 — Authentication and JWT

**Steps:**

1. Implement auth in `mortgage-service` (or dedicated `auth` module): login with username/password against seed users **or** OAuth2 resource server stub—document approach.
2. Issue JWT with claims: `sub`, `roles`, `exp`, `iss`.
3. Validate JWT on protected routes; reject expired/tampered tokens (401/403).
4. Store password hashes with BCrypt; never log tokens or passwords.

**JWT claims (minimum payload):**

```json
{
  "sub": "servicing@capstone.local",
  "roles": ["SERVICING_AGENT"],
  "iss": "capstone-mortgage-auth",
  "exp": 1710510000
}
```

**Login contract:** [sample-api-contracts.md](../reference/sample-api-contracts.md#auth-m6-post-apiv1authlogin).

**Spring Security (checklist):**

- [ ] `SecurityFilterChain` with JWT filter before `UsernamePasswordAuthenticationFilter`
- [ ] CSRF disabled for stateless APIs (document why)
- [ ] Public: `/actuator/health`, `/api/v1/auth/login`
- [ ] All `/api/v1/mortgages/**` mutations require authenticated user

---

### Task 6.2 — RBAC

**Steps:**

1. Map roles to permissions (matrix in `docs/security/security-controls.md`):

   | Endpoint example | ADMIN | UNDERWRITER | SERVICING_AGENT | RISK_ANALYST | SUPPORT |
   | --- | --- | --- | --- | --- | --- |
   | POST /mortgages | ✓ | ✓ | ✗ | ✗ | ✗ |
   | GET servicing-history | ✓ | ✓ | ✓ | ✓ | ✓ |
   | Delinquency write | ✓ | ✗ | ✓ | ✗ | ✗ |

2. Enforce with Spring Security `@PreAuthorize` or equivalent.
3. Add integration tests: wrong role → 403.

---

### Task 6.3 — OWASP and API hardening

**Steps:**

1. Bean validation on all POST/PUT bodies.
2. Security headers (CSP baseline, X-Content-Type-Options, etc.) via filter.
3. Rate limiting on auth and sensitive endpoints.
4. Parameterized SQL via JPA; sanitize any dynamic queries.
5. Regression test for one patched vulnerability from lab (Session 23 mini exercise).

---

### Task 6.4 — TypeScript secure API consumer

**Steps:**

1. Create **`clients/mortgage-api-consumer/`** with TypeScript, `package.json`, README.
2. Functions: login, get mortgage, get servicing history with **Authorization** header.
3. Handle expired token: refresh or re-login flow (Session 19 mini exercise).
4. Do not commit tokens; use env for base URL.

**Suggested layout:**

```text
clients/mortgage-api-consumer/
├── src/
│   ├── auth.ts
│   ├── mortgageClient.ts
│   └── index.ts
├── package.json
├── tsconfig.json
└── README.md
```

**Run:**

```powershell
cd clients/mortgage-api-consumer
npm install
$env:MORTGAGE_API_BASE="http://localhost:8080"
npm run demo
```

**Demo flow:** login → store token in memory → GET `/api/v1/mortgages/MTG-1001` → on 401 refresh/login.

---

### Task 6.5 — Data protection documentation

**Steps:**

1. Update **`docs/security/security-controls.md`**: classification (Public/Internal/Confidential/Restricted) for borrower fields.
2. Document **encryption in transit** (TLS termination from M1 deployment doc) and **at rest** (RDS/disk/KMS plan).
3. Secrets rotation approach paragraph in `docs/operations/runbook.md`.

---

### Task 6.6 — Security testing and artifacts

**Steps:**

1. Run controlled pentest exercises (Session 20 lab) against staging/local; record in **`docs/security/vulnerability-report.md`**.
2. **`docs/security/risk-register.md`**: ID, risk, likelihood, impact, owner, status.
3. **`docs/security/threat-model.md`**: STRIDE on architecture diagram; trust boundaries from M1.
4. **`docs/security/remediation-backlog.md`**: prioritized fixes; link commits for Critical/High.
5. Remediate all **Critical** findings before M6 sign-off.

---

### Task 6.7 — Secure CI/CD gates (baseline extension)

**Steps:**

1. Add GitLab jobs: secret detection, SAST, dependency scanning (Session 21).
2. Document how pipeline **blocks merge** on critical findings.
3. Store redacted pipeline screenshot in `docs/operations/devsecops-baseline.md`.

---

## Implementation requirements

- Use HTTPS in non-local environments; local HTTP OK with warning in README.
- JWT secret from env var minimum 256-bit equivalent.
- Align with M2 DevSecOps; no bypass of protected branches.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `services/*/.../security/` | Spring Security config |
| `clients/mortgage-api-consumer/` | TS client |
| `docs/security/*.md` | Threat model, risks, vulns |
| `.gitlab-ci.yml` | Security scan stages |
| `tests/security/` | Auth/RBAC tests |

---

## Validation

- [ ] Login returns JWT; protected endpoint works with Bearer token
- [ ] SUPPORT cannot call underwriter-only endpoint (403)
- [ ] TS consumer completes login + GET flow
- [ ] Threat model and risk register reviewed by peer
- [ ] No Critical open vulnerabilities in report
- [ ] Pipeline fails on intentional test secret (then remove)

---

## Definition of done

```text
☐ Authentication implemented
☐ JWT validation on protected APIs
☐ RBAC implemented and tested for all five roles
☐ Sensitive endpoints protected
☐ OWASP controls applied (validation, headers, rate limit)
☐ Encryption and classification documented
☐ TypeScript API consumer demonstrated
☐ Threat model completed (STRIDE)
☐ Risk register and vulnerability report completed
☐ Critical vulnerabilities remediated
☐ Secure CI gates configured (SAST/SCA/secrets)
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. Login as SERVICING_AGENT; GET servicing history (2 min).
2. Same token on restricted POST → 403 (2 min).
3. Run TS consumer script (2 min).
4. Walk one STRIDE threat and mitigation in threat model (3 min).
5. Show pipeline security job passing (1 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| RBAC only in UI/client | Enforce on server |
| JWT without expiry | Short TTL + document refresh |
| Threat model generic | Reference your diagrams/services |
| Skipping TS consumer | Required for Session 19 alignment |

---

## What comes next

**Milestone 7** delivers **`ai/mortgage-knowledge-assistant/`** with RAG, citations, and human-in-the-loop rules.

---

*Capstone — Milestone 6 (Weeks 7–8)*
