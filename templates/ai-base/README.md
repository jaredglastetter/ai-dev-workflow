# Project Name

## Setup

### GitHub Codespaces (Recommended)

1. Click **Code → Codespaces → Create codespace on main**
2. Wait for the environment to build (~2 min)
3. Run: `npm run dev`
4. Open the forwarded port preview in your browser

### Local Setup

```bash
git clone <repo-url>
cd <repo>
npm install
npm run dev
```

## Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start all services |
| `npm run build` | Build for production |
| `npm run test` | Run test suite |
| `npm run lint` | Lint all code |

## AI Agent Rules

All AI agents working in this repo **must** follow these rules:

1. **Always create a branch** — never commit directly to `main`
   ```bash
   git checkout -b feat/<description>
   ```

2. **Always run lint, test, and build** before opening a PR
   ```bash
   npm install
   npm run lint
   npm run test
   npm run build
   ```

3. **Always open a PR** with a clear summary of changes

4. **Never break existing functionality** — run full CI suite before merging

5. **Keep changes small and focused** — one PR per feature/fix

## Stack

- See individual service READMEs for stack details
- All services are accessible via forwarded ports in Codespaces
