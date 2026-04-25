# Agent Instructions

## Stack
- **Backend:** Node.js + Express + dotenv + CORS
- **Port:** 4000

## Commands
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start server with `--watch` on port 4000 |
| `npm start` | Start without watch (production) |
| `npm run test` | Run Node built-in test runner |
| `npm run lint` | ESLint on `src/` |

## File structure
```
src/
  index.js    ← Express app entry
.env          ← environment variables (never commit)
.env.example  ← template for env vars
```

## Adding routes
Add new routes in `src/index.js` or create `src/routes/` and import them. Always add a health check pattern:
```js
app.get('/api/health', (_req, res) => res.json({ status: 'ok' }))
```

## Rules — always follow these
1. Never commit to `main` — always `git checkout -b feat/<description>`
2. Never commit `.env` — only `.env.example`
3. `npm install` before anything else
4. Before every PR: `npm run lint` → `npm run test`
5. Open PR with `gh pr create` — never ask the user to do it manually

## Natural language commands
| User says | Action |
|-----------|--------|
| "add a [name] endpoint" | Add route to `src/index.js` or new file in `src/routes/` |
| "add middleware for X" | Add to `src/index.js` before routes |
| "add an env variable" | Add to `.env.example` + document usage in code |
| "prepare a PR" / "open a PR" | lint → test → commit → push → `gh pr create` |
