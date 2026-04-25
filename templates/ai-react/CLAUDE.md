# Agent Instructions

## Stack
- **Frontend:** React 18 + Vite + Vitest + ESLint
- **Port:** 3000

## Commands
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start dev server on port 3000 |
| `npm run build` | Build for production → `dist/` |
| `npm run test` | Run Vitest test suite |
| `npm run lint` | ESLint on `src/` |

## File structure
```
src/
  App.jsx        ← main component
  App.test.jsx   ← tests
  main.jsx       ← entry point
  index.css      ← global styles
```

## Rules — always follow these
1. Never commit to `main` — always `git checkout -b feat/<description>`
2. `npm install` before anything else
3. Before every PR: `npm run lint` → `npm run test` → `npm run build`
4. Open PR with `gh pr create` — never ask the user to do it manually
5. Keep each PR focused on one thing

## Natural language commands
| User says | Action |
|-----------|--------|
| "add a [component] page" | Create component in `src/`, add route if needed |
| "add tests for X" | Add test in `src/X.test.jsx` |
| "prepare a PR" / "open a PR" | lint → test → build → commit → push → `gh pr create` |
| "what's running" | Check port 3000 is up, run `npm run dev` if not |
