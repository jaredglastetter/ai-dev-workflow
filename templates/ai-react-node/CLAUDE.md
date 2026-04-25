# Agent Instructions

## Stack
- **Frontend:** React 18 + Vite — `frontend/` — port 3000
- **Backend:** Node.js + Express — `backend/` — port 4000
- Frontend proxies `/api/*` → backend automatically (configured in `vite.config.js`)

## Commands (run from root)
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start frontend + backend together |
| `npm run build` | Build frontend → `frontend/dist/` |
| `npm run test` | Run all tests (both workspaces) |
| `npm run lint` | Lint all code (both workspaces) |

## File structure
```
frontend/
  src/
    App.jsx       ← main component
    main.jsx      ← entry point
backend/
  src/
    index.js      ← Express app
package.json      ← root (npm workspaces)
```

## How frontend calls backend
The Vite dev proxy handles this — just call `/api/...` from the frontend:
```js
fetch('/api/health').then(r => r.json())
```
No need for absolute URLs or CORS config in development.

## Rules — always follow these
1. Never commit to `main` — always `git checkout -b feat/<description>`
2. Never commit `.env` files — only `.env.example`
3. Run `npm install` from root (installs all workspaces)
4. Before every PR: `npm run lint` → `npm run test` → `npm run build`
5. Open PR with `gh pr create` — never ask the user to do it manually
6. Keep frontend and backend changes in the same PR when they're related

## Natural language commands
| User says | Action |
|-----------|--------|
| "add a [name] page" | Add component in `frontend/src/`, fetch from `/api/` if needed |
| "add a [name] endpoint" | Add route in `backend/src/index.js` |
| "add a new feature" | Implement frontend + backend together, single PR |
| "prepare a PR" / "open a PR" | lint → test → build → commit → push → `gh pr create` |
| "what's running" | Frontend on :3000, backend on :4000 — run `npm run dev` from root |
