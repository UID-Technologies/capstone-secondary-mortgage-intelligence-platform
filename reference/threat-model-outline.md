# STRIDE threat model outline (Milestone 6)

Copy into `docs/security/threat-model.md` and fill for **your** deployment diagram.

## System overview

- **Components:** mortgage-service, servicing-service, analytics-service, knowledge-assistant, PostgreSQL, S3, SNS/SQS, GitLab, Splunk
- **Trust boundaries:** Internet → DMZ (ingress) → App tier → Data tier
- **Data assets:** borrower PII, payment history, underwriting documents, JWTs

## STRIDE worksheet (sample rows — add more)

| Component | Threat | STRIDE | Impact | Mitigation | Status |
| --- | --- | --- | --- | --- | --- |
| POST /auth/login | Credential stuffing | Spoofing | Account takeover | Rate limit, lockout, MFA roadmap | |
| JWT | Token theft/replay | Spoofing | Unauthorized API use | Short TTL, HTTPS only, secure storage | |
| GET /mortgages/{id} | IDOR | Elevation | Cross-borrower data leak | RBAC + ownership checks | |
| Payment API | Duplicate POST | Tampering | Double posting | Idempotency-Key | |
| SQL layer | Injection | Tampering | Data breach | Parameterized queries/JPA | |
| Logs | PII in Splunk | Info disclosure | Compliance | Redaction, field filtering | |
| S3 documents | Public bucket | Info disclosure | Document leak | Block public access, IAM | |
| Servicing API | No auth | Repudiation | Audit gap | JWT on all mutating routes | |

## Diagrams required

1. Annotated copy of M1 deployment architecture with trust zones numbered.
2. Data flow for **document upload** and **payment post** with threats marked.

## Sign-off

- [ ] Team peer review date
- [ ] Instructor review date
- [ ] Linked to risk register entries
