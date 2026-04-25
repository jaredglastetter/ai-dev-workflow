# AI Dev Workflow

Persistent memory for AI agents. This file defines the `ai-dev-workflow` skill and all execution rules.

---

## Skill: ai-dev-workflow

A reusable skill for creating and managing AI-assisted development projects entirely from a phone or remote environment.

---

## Commands

### 1. `init project <type>`

Creates a new project from a template.

**Types:** `react` | `node` | `python` | `react-node` | `react-python`

```bash
./scripts/init-project.sh react my-app
./scripts/init-project.sh react-node my-fullstack-app
```

**What it does:**
- Copies template files (devcontainer, CI, source)
- Renames project to match `<name>`
- Runs `npm install`
- Initializes git on `main`

---

### 2. `apply base`

Applies `ai-base` to an existing repository non-destructively.

```bash
./scripts/apply-base.sh
```

**What it does:**
- Adds `.devcontainer/` if missing
- Adds `.github/workflows/ci.yml` if missing
- Adds `package.json` scripts if missing
- Never overwrites existing files

---

### 3. `add react`

Merges the `ai-react` template into the current repo (as `frontend/`).

```bash
cp -r templates/ai-react frontend/
```

---

### 4. `add node`

Merges the `ai-node` template into the current repo (as `backend/`).

```bash
cp -r templates/ai-node backend/
```

---

### 5. `add python`

Merges the `ai-python` template into the current repo (as `api/`).

```bash
cp -r templates/ai-python api/
```

---

### 6. `prepare PR`

Runs the full pre-PR pipeline and opens a PR.

```bash
./scripts/prepare-pr.sh "feat: description" "PR body text" "branch-name"
```

**What it does:**
1. Creates branch if on `main`/`master`
2. `npm install`
3. `npm run lint`
4. `npm run test`
5. `npm run build` (if applicable)
6. `git add -A && git commit`
7. `git push -u origin <branch>`
8. `gh pr create`

---

## Execution Rules

All AI agents must follow these rules without exception:

| Rule | Details |
|------|---------|
| **Always branch** | Never commit to `main` or `master`. Branch: `feat/<desc>` or `setup/<desc>` |
| **Always install** | Run `npm install` before any other command |
| **Always lint** | Run `npm run lint` — fix errors before PR |
| **Always test** | Run `npm run test` — fix failures before PR |
| **Always build** | Run `npm run build` if a build script exists |
| **Always PR** | Use `gh pr create` with title + body summary |
| **Never break** | Do not modify unrelated files. Verify existing tests still pass |

---

## Deployment

### Frontend → Vercel

Each React template includes `vercel.json`. To connect:

1. Go to [vercel.com](https://vercel.com) → Import project from GitHub
2. Vercel auto-detects `vercel.json` and deploys on every push
3. Every PR gets a **preview URL** (commented on the PR automatically by CI)
4. Merge to `main` → production deploy

**Required GitHub secrets:**

| Secret | Where to get it |
|--------|----------------|
| `VERCEL_TOKEN` | vercel.com → Settings → Tokens |
| `VERCEL_ORG_ID` | Printed by `setup-codespace.sh` after linking |
| `VERCEL_PROJECT_ID` | Printed by `setup-codespace.sh` after linking |

`setup-codespace.sh` runs `vercel link --yes` automatically when `VERCEL_TOKEN` is set as a Codespaces secret — no dashboard clicking required for Vercel.

### Backend → Render

Each Node/Python template includes `render.yaml`. To connect:

1. Go to [render.com](https://render.com) → New → Blueprint
2. Point at your GitHub repo — Render reads `render.yaml` and creates the service
3. On the Render service page → Settings → Deploy Hook → copy the URL
4. Add it as GitHub secret: `RENDER_DEPLOY_HOOK_URL`
5. Every push to `main` triggers a Render redeploy via CI

> Render has no CLI for service creation — this one dashboard click is unavoidable.

### Combined stacks (react-node, react-python)

After deploying the Render service, update `vercel.json` in your project:

```json
"destination": "https://YOUR-ACTUAL-RENDER-URL/api/$1"
```

This makes Vercel proxy `/api/*` calls to Render — no CORS issues.

---

## Codespace Setup

Run once per new Codespace (auto-runs via `postCreateCommand`):

```bash
bash scripts/setup-codespace.sh
```

**What it does:**
- Authenticates GitHub CLI (uses `GITHUB_TOKEN` automatically in Codespaces)
- Sets git user name/email from your GitHub profile
- Runs `npm install` and `pip install`
- Copies `.env.example` → `.env` for all services
- Prints live preview URLs for all forwarded ports

---

## Template Structure

```
templates/
├── ai-base/               # Shared: devcontainer, CI, scripts, README
│   ├── .devcontainer/
│   │   ├── devcontainer.json
│   │   └── setup.sh
│   ├── .github/workflows/ci.yml
│   ├── package.json
│   └── README.md
├── ai-react/              # Vite + React + Vitest + ESLint + vercel.json
├── ai-node/               # Express + dotenv + CORS + ESLint + render.yaml
├── ai-python/             # FastAPI + pytest + ruff + render.yaml
├── ai-react-node/         # Combined (npm workspaces) + vercel.json + render.yaml
└── ai-react-python/       # Combined (frontend workspace + api/) + vercel.json + render.yaml

scripts/
├── init-project.sh        # Create new project
├── apply-base.sh          # Apply base to existing repo
├── prepare-pr.sh          # Run CI checks + open PR
└── setup-codespace.sh     # One-time Codespace setup (auth, install, .env)
```

---

## DevContainer

All templates share a single devcontainer definition:

- **Base:** `mcr.microsoft.com/devcontainers/universal:2`
- **Node:** LTS
- **Python:** 3.11
- **GitHub CLI:** latest
- **Forwarded ports:** 3000 (frontend), 4000 (node API), 8000 (python API)
- **Post-create:** auto-installs `npm` and `pip` dependencies

Open in Codespaces → all services start with `npm run dev`.

---

## Port Map

| Port | Service |
|------|---------|
| 3000 | React frontend (Vite) |
| 4000 | Node/Express API |
| 8000 | Python/FastAPI API |

---

## CI Pipeline (`.github/workflows/ci.yml`)

Runs on every PR to `main`/`master`:

1. `npm install`
2. `npm run lint`
3. `npm run test`
4. `npm run build` (skipped if no build config detected)

---

## Existing Repo Checklist

When applying to an existing repo:

- [ ] `git checkout -b setup/ai-workflow`
- [ ] Run `./scripts/apply-base.sh`
- [ ] Verify `npm run dev` works
- [ ] Run `./scripts/prepare-pr.sh "setup: add ai-dev-workflow"`

---

## Primary Goal

This system enables a **fully remote, phone-first development workflow**:

- Everything runs in GitHub Codespaces
- No local machine required
- AI agents can create, test, and ship features autonomously
- All commands are deterministic and scriptable
