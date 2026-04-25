# Agent Instructions

## Stack
- **Frontend:** React 18 + Vite — `frontend/` — port 3000
- **Backend:** Python + FastAPI — `api/` — port 8000
- Frontend proxies `/api/*` → backend automatically (configured in `vite.config.js`)

## Commands (run from root)
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start frontend + FastAPI together |
| `npm run build` | Build frontend → `frontend/dist/` |
| `npm run test` | Run frontend tests + pytest |
| `npm run lint` | Lint frontend (ESLint) + api (ruff) |

## File structure
```
frontend/
  src/
    App.jsx       ← main component
    main.jsx      ← entry point
api/
  main.py         ← FastAPI app
  test_main.py    ← pytest tests
  requirements.txt
package.json      ← root scripts
```

## How frontend calls backend
Just call `/api/...` from the frontend — Vite proxies to FastAPI:
```js
fetch('/api/health').then(r => r.json())
```

## Rules — always follow these
1. Never commit to `main` — always `git checkout -b feat/<description>`
2. Never commit `.env` files — only `.env.example`
3. Run `npm install` from root + `pip install -r api/requirements.txt` when needed
4. Add new Python packages to `api/requirements.txt` immediately
5. Before every PR: `npm run lint` → `npm run test` → `npm run build`
6. Open PR with `gh pr create` — never ask the user to do it manually

## Natural language commands
| User says | Action |
|-----------|--------|
| "add a [name] page" | Add component in `frontend/src/`, call `/api/` if needed |
| "add a [name] endpoint" | Add route in `api/main.py`, add test in `api/test_main.py` |
| "add a Python dependency" | `pip install X`, add to `api/requirements.txt` |
| "prepare a PR" / "open a PR" | lint → test → build → commit → push → `gh pr create` |
| "what's running" | Frontend on :3000, FastAPI on :8000 — run `npm run dev` from root |
