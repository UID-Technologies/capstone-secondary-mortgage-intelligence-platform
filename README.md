# Capstone learner handbook

**Project:** Fannie Mae–Style Secondary Mortgage Intelligence Platform  
**Program:** 12 weeks · 36 sessions · complete milestones in order unless your instructor approves parallel work.

## Folder layout

```text
├── README.md              ← you are here
├── guides/                Shared standards and data model
├── milestones/            Week-by-week tasks (M1–M10)
└── reference/             Copy-paste templates (SQL, API, CI, events)
```

## Master progress tracker

| ID | Milestone | Week | Doc |
| --- | --- | --- | --- |
| M1 | Foundation & architecture | 1 | [m01](./milestones/m01-project-foundation.md) |
| M2 | Agile & data foundation | 2 | [m02](./milestones/m02-agile-database-foundation.md) |
| M3 | Python analytics | 3 | [m03](./milestones/m03-python-analytics-service.md) |
| M4 | Java / Spring backend | 4–5 | [m04](./milestones/m04-java-spring-backend.md) |
| M5 | Microservices & events | 6 | [m05](./milestones/m05-microservices-events-containers.md) |
| M6 | Security engineering | 7–8 | [m06](./milestones/m06-security-engineering.md) |
| M7 | AI / RAG assistant | 9 | [m07](./milestones/m07-ai-rag-assistant.md) |
| M8 | AWS & data platform | 10 | [m08](./milestones/m08-aws-data-platform.md) |
| M9 | CI/CD, Terraform, observability | 11 | [m09](./milestones/m09-cicd-terraform-observability.md) |
| M10 | Testing & production readiness | 12 | [m10](./milestones/m10-testing-production-readiness.md) |

## Reference templates

| File | Use |
| --- | --- |
| [reference/sample-starter-schema.sql](./reference/sample-starter-schema.sql) | M2 PostgreSQL DDL |
| [reference/sample-seed-data.sql](./reference/sample-seed-data.sql) | M2 seed excerpt |
| [reference/sample-api-contracts.md](./reference/sample-api-contracts.md) | M3, M4, M6 JSON examples |
| [reference/payload-examples.json](./reference/payload-examples.json) | M5 events |
| [reference/gitlab-ci-stub.yml](./reference/gitlab-ci-stub.yml) | M2, M6, M9 CI |
| [reference/threat-model-outline.md](./reference/threat-model-outline.md) | M6 STRIDE |

## Start here

1. [guides/standards.md](./guides/standards.md) and [guides/reference-data-model.md](./guides/reference-data-model.md) before **M2**.
2. [milestones/m01-project-foundation.md](./milestones/m01-project-foundation.md) — do not skip.
3. Copy files from [reference/](./reference/) into your project repo as each milestone directs.

## How to use

- Each milestone includes prerequisites, tasks, validation, definition of done, and a demo script.
- Merge capstone **code** to your project repo’s `develop` branch via pull request.
- Session mapping lives under **Concepts applied** in each milestone file.
