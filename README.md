# ReachInbox Onebox — Feature-Rich Email Aggregator (Starter)

This repository is a **ready-to-run scaffold** that implements the core flows requested in the assignment:

- **Real-time IMAP (IDLE)** sync for multiple accounts
- **Elasticsearch** indexing + search with folder/account filters
- **AI categorization** via **Gemini** JSON mode
- **Slack + webhook** triggers for `Interested`
- Minimal **frontend** to list/search emails
- **RAG** hooks using **Qdrant** for suggested replies

> Fill `.env` from `.env.sample`, run Docker, and start the server.


## 1) Quick Start

```bash
# 1) Clone and install
npm install

# 2) Start persistence
docker-compose up -d

# 3) Configure env
cp .env.sample .env
# edit IMAP1_*, IMAP2_*, GEMINI_API_KEY, SLACK_WEBHOOK_URL, WEBHOOK_SITE_URL

# 4) Dev run
npm run dev
# open: http://localhost:3000/web/index.html (serve statically via reverse proxy or use any static server)
```

> The server exposes:
> - `GET /api/accounts`
> - `GET /api/emails`
> - `GET /api/emails/search?q=...&account=...&folder=...`
> - `POST /api/emails/:id/suggest-reply` (requires Qdrant+Gemini configured)


## 2) Architecture

- `src/imap/imapService.ts` — Connects two IMAP accounts, fetches last 30 days, then listens in **IDLE** for new mail. Emits `newMail` events.
- `src/search/elasticsearchService.ts` — Ensures index mapping, indexes emails, updates `aiCategory`, and supports search/filter.
- `src/ai/classifier.ts` — Calls **Gemini** in JSON mode to label: Interested, Meeting Booked, Not Interested, Spam, Out of Office.
- `src/integrations/notify.ts` — Sends Slack and generic webhook when category is **Interested**.
- `src/ai/rag.ts` + `src/ai/embeddings.ts` — Qdrant collection bootstrap, upsert of KB chunks, vector search. Used by `suggest-reply` route.
- `src/index.ts` — Composition root: starts API, IMAP connections, wires indexing → categorize → notify pipeline.

## 3) Notes & Assumptions

- **Security**: Use app passwords or OAuth for IMAP in production.
- **IDLE stability**: Reconnect logic included; production should add jitter/backoff.
- **Gemini JSON mode**: Make sure your key has access; endpoints are configurable.
- **Embedding vector size**: Adjust Qdrant `size` to match your chosen embedding model.
- **Frontend**: Minimal HTML included for demo; replace with real UI when you reach point 5.
- **Static hosting**: Serve `web/` via nginx or `vite preview` for local tests.

## 4) Demo Flow (for your 5-min video)

1. Show Docker running ES+Qdrant.
2. Start server → accounts load → `newMail` gets indexed.
3. `GET /api/emails` shows recent emails; `search` filters.
4. Trigger an inbound "Interested" email → show Slack ping + webhook.site capture.
5. Use `suggest-reply` with a seeded KB in Qdrant to generate a concise, context-grounded reply.

## 5) Credits & References

- IMAP IDLE with `node-imap`
- Elasticsearch Node client `@elastic/elasticsearch`
- Qdrant Vector DB
- Google Gemini API (classification + embeddings)

This code is intentionally concise and ready to extend for production-readiness.


## AI Setup
Set GEMINI_API_KEY in .env. Use the following endpoints:
GEMINI_GENERATE_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent
GEMINI_EMBED_URL=https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent

RAG is file based. Add lines to data/kb.txt and restart the API to re-embed.
