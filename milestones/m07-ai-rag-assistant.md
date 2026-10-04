# Milestone 7 — AI/RAG Mortgage Assistant

| Field | Value |
| --- | --- |
| **Milestone ID** | M7 |
| **Target timeline** | Week 9 (after M6) |
| **Curriculum alignment** | Sessions 25–27 — Prompt engineering, RAG, AI for ops/incident workflows |
| **Primary output** | `ai/mortgage-knowledge-assistant/` with grounded Q&A and prompt library |
| **Previous** | [Milestone 6 — Security Engineering](./m06-security-engineering.md) |
| **Next milestone** | [Milestone 8 — AWS & Data Platform](./m08-aws-data-platform.md) |
| **Estimated effort** | 16–22 hours per team (Week 9) |

---

## Prerequisites & shared references

**From M6:** JWT available if assistant API is protected (recommended for demo).

**Port:** `8001` for assistant ([standards.md](../guides/standards.md)).

**LLM:** use instructor-provided API (Azure OpenAI, OpenAI, etc.)—keys in env only:

```text
LLM_API_BASE=https://...
LLM_API_KEY=<secret>
LLM_MODEL=gpt-4o-mini
EMBEDDING_MODEL=text-embedding-3-small
```

**RAG defaults (document in README):** chunk size **512** tokens, overlap **64**, top-k **5**, similarity threshold **0.7** (tune and record).

---

## Objective

Build a **mortgage knowledge assistant** using **RAG**: controlled policy/guidance documents, chunking and embeddings, vector retrieval, LLM-generated answers with **citations**, handling **insufficient context**, plus a **prompt library** and **human approval** paths for sensitive recommendations. Extend with **ops/incident summarization** patterns from Session 27.

---

## Scope

### In scope (M7)

- Knowledge corpus under `ai/mortgage-knowledge-assistant/knowledge/` (synthetic policies, underwriting/servicing guidance)
- Ingestion: chunk → embed → vector store (FAISS/Chroma/pgvector—team choice)
- API: `POST /api/v1/assistant/ask` with question + optional filters (loan type)
- Citations: source document, section, chunk id
- Prompt templates in `docs/ai/prompt-library.md`
- Human-in-the-loop rules in `docs/ai/governance.md`
- Optional: incident log summarization endpoint for ops persona
- Respect M6 auth if exposed beyond local (recommended)

### Out of scope (M7)

- Autonomous loan approval without human review
- Training/fine-tuning custom models (use provided LLM API)
- Production vector DB HA (document future state)

---

## Concepts applied

| Session | Capstone application |
| --- | --- |
| **25** | Prompt library, responsible AI, underwriting summary prompts |
| **26** | RAG pipeline, citations, hallucination reduction |
| **27** | Approval checkpoints, incident summarization workflow |

---

## Tasks

### Task 7.1 — Knowledge base preparation

**Steps:**

1. Add 5+ markdown/PDF text files: mortgage policy, underwriting guide, servicing FAQ, delinquency playbook, security policy excerpt.
2. **`knowledge/README.md`**: source of truth, update process, no confidential client data.
3. Version corpus (`knowledge/v1/`).

---

### Task 7.2 — Ingestion pipeline

**Steps:**

1. Script or service module: load docs → split chunks (size/overlap documented) → embed → upsert vector store.
2. Store metadata: `docId`, `title`, `section`, `loanType` tags if applicable.
3. Re-run ingestion command documented in service README.

---

### Task 7.3 — Retrieval and generation

**Pipeline:**

```text
Documents → Chunking → Embeddings → Vector Store → Retriever → LLM → Grounded Response
```

**Steps:**

1. Retrieve top-k chunks; optional filter by metadata.
2. Build prompt with context + user question; system prompt requires cite-only-from-context.
3. If similarity below threshold → respond “insufficient context” (no fabrication).
4. Return JSON: `{ answer, citations[], confidence }`.

---

### Task 7.4 — API and integration

**Steps:**

1. FastAPI/Flask service under `ai/mortgage-knowledge-assistant/`.
2. Health check; correlation ID logging.
3. Optional: BFF route from mortgage-service proxy with JWT (document architecture).

---

### Task 7.5 — Prompt library and governance

**Steps:**

1. **`docs/ai/prompt-library.md`**: templates for underwriting summary, delinquency explanation, security policy Q&A.
2. **`docs/ai/governance.md`**: when human underwriter must override; logging of prompts/responses (PII redaction rules).
3. Document hallucination controls tested (Session 26 mini exercise).

---

### Task 7.6 — Ops / incident extension (Session 27)

**Steps:**

1. Add sample incident text file; endpoint or script `summarize-incident` producing structured summary + recommended runbook links.
2. Flag `requiresHumanApproval: true` when confidence low.

---

## API contract (reference)

**POST** `/api/v1/assistant/ask`

Request:

```json
{
  "question": "What happens when a payment is 30 days late?",
  "mortgageExternalId": "MTG-1002",
  "loanType": "CONVENTIONAL"
}
```

Response:

```json
{
  "answer": "After 30 calendar days past due, the loan is marked DELINQUENT...",
  "citations": [
    { "documentId": "delinquency-playbook.md", "section": "Timeline", "chunkId": "c-12" }
  ],
  "confidence": 0.82,
  "requiresHumanApproval": false,
  "correlationId": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
}
```

Insufficient context: `confidence` below threshold, `answer` explains no reliable source, empty `citations`.

**Knowledge files to author (minimum):**

| File | Content |
| --- | --- |
| `knowledge/mortgage-policy-overview.md` | Servicing policy summary |
| `knowledge/underwriting-guidelines.md` | Approval criteria |
| `knowledge/delinquency-playbook.md` | 30-day rule aligned with standards |
| `knowledge/servicing-faq.md` | Agent procedures |

---

## Implementation requirements

- API keys in env only; rate limit public endpoints.
- Citations must map to real chunk IDs present in store.
- Do not send real borrower PII in prompts; use synthetic IDs in examples.

---

## Expected repository changes

| Path | Purpose |
| --- | --- |
| `ai/mortgage-knowledge-assistant/**` | RAG service |
| `ai/.../knowledge/**` | Source docs |
| `docs/ai/prompt-library.md` | Prompts |
| `docs/ai/governance.md` | Human-in-the-loop |

---

## Validation

- [ ] Question answered with ≥1 citation from corpus
- [ ] Off-corpus question returns insufficient context
- [ ] Prompt library has ≥5 templates
- [ ] Governance doc lists ≥3 manual override scenarios
- [ ] Tests for retriever with mock embedder (optional)

---

## Definition of done

```text
☐ Knowledge base prepared (controlled sources)
☐ Documents chunked and embedded
☐ Vector retrieval working
☐ LLM integrated with cite-from-context behavior
☐ Citations returned in API response
☐ Insufficient-context path implemented
☐ Hallucination controls documented and tested
☐ Prompt library created
☐ Human approval scenarios documented
☐ Ops/incident summarization demo available
☐ README documents ingest + ask flow
☐ Merged to develop via reviewed PR(s)
```

---

## Demo scenario

1. Ask: “What is the delinquency contact timeline?” → answer + citation (3 min).
2. Ask unrelated question → insufficient context (2 min).
3. Show prompt library entry for underwriting summary (2 min).
4. Run incident summarization with approval flag (3 min).

---

## Common mistakes

| Mistake | Fix |
| --- | --- |
| LLM answers without retrieval | Enforce RAG pipeline |
| No citation metadata | Store chunk provenance at ingest |
| Whole PDF in prompt | Chunk + top-k only |
| Live borrower data in questions | Synthetic scenarios only |

---

## What comes next

**Milestone 8** expands **AWS**: IAM least privilege, S3/Lambda, Kinesis/DynamoDB, **Glue analytics pipeline**, reconciliation, schema drift.

---

*Capstone — Milestone 7 (Week 9)*
