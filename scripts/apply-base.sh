#!/bin/bash
# Usage: bash apply-base.sh
# Run from the root of an existing repo to add devcontainer, CI, and Claude setup.
# Safe to run — never overwrites existing files.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
BRANCH="setup/ai-workflow"

echo ""
echo "======================================"
echo " Applying ai-base to existing repo"
echo "======================================"
echo ""

# ── Branch ───────────────────────────────────────────────────────────────────
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "==> Creating branch: $BRANCH"
  git checkout -b "$BRANCH"
else
  echo "==> Already on branch: $CURRENT_BRANCH"
fi

# ── DevContainer ─────────────────────────────────────────────────────────────
echo ""
echo "==> DevContainer"
if [ ! -d ".devcontainer" ]; then
  cp -r "$TEMPLATES_DIR/ai-base/.devcontainer" .
  echo "    + .devcontainer/"
else
  echo "    ~ .devcontainer/ already exists — skipping"
fi

# ── CI workflow ───────────────────────────────────────────────────────────────
echo ""
echo "==> GitHub Actions"
mkdir -p .github/workflows
if [ ! -f ".github/workflows/ci.yml" ]; then
  cp "$TEMPLATES_DIR/ai-base/.github/workflows/ci.yml" .github/workflows/ci.yml
  echo "    + .github/workflows/ci.yml"
else
  echo "    ~ ci.yml already exists — skipping"
fi
if [ ! -f ".github/workflows/deploy.yml" ]; then
  cp "$TEMPLATES_DIR/ai-base/.github/workflows/deploy.yml" .github/workflows/deploy.yml
  echo "    + .github/workflows/deploy.yml"
else
  echo "    ~ deploy.yml already exists — skipping"
fi

# ── Scripts ───────────────────────────────────────────────────────────────────
echo ""
echo "==> Setup scripts"
mkdir -p scripts
for script in setup-codespace.sh prepare-pr.sh; do
  if [ ! -f "scripts/$script" ]; then
    cp "$SCRIPT_DIR/$script" "scripts/$script"
    chmod +x "scripts/$script"
    echo "    + scripts/$script"
  else
    echo "    ~ scripts/$script already exists — skipping"
  fi
done

# ── package.json scripts ──────────────────────────────────────────────────────
echo ""
echo "==> Checking package.json scripts"
if [ ! -f "package.json" ]; then
  cp "$TEMPLATES_DIR/ai-base/package.json" .
  echo "    + package.json (base)"
else
  # Check for missing standard scripts and warn
  for script in dev build test lint; do
    if ! grep -q "\"$script\"" package.json; then
      echo "    ~ Missing script: $script — add it to package.json manually"
    else
      echo "    ✓ $script script exists"
    fi
  done
fi

# ── .env.example ─────────────────────────────────────────────────────────────
echo ""
echo "==> Checking .env setup"
if [ -f ".env" ] && [ ! -f ".env.example" ]; then
  echo "    Found .env but no .env.example"
  echo "    Creating .env.example with keys (values stripped)..."
  grep -v '^#' .env | grep '=' | sed 's/=.*/=/' > .env.example
  echo "    + .env.example (keys only — safe to commit)"
  # Ensure .env is gitignored
  if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo ".env" >> .gitignore
    echo "    + .env added to .gitignore"
  fi
elif [ ! -f ".env.example" ]; then
  echo "    ~ No .env or .env.example found — create .env.example if your project needs env vars"
else
  echo "    ✓ .env.example exists"
fi

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────
echo ""
echo "==> CLAUDE.md"
if [ ! -f "CLAUDE.md" ]; then
  cat > CLAUDE.md << 'EOF'
# Agent Instructions

## Rules — always follow these
1. Never commit to `main` or `master` — always `git checkout -b feat/<description>`
2. `npm install` before anything else
3. Before every PR: lint → test → build (if applicable)
4. Open PR with `gh pr create` — never ask the user to do it manually
5. Never commit `.env` — only `.env.example`

## Commands
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run test` | Run tests |
| `npm run lint` | Lint code |

## Natural language commands
| User says | Action |
|-----------|--------|
| "prepare a PR" / "open a PR" | lint → test → build → commit → push → `gh pr create` |

## Stack
<!-- TODO: describe your stack here so the agent understands the project -->
EOF
  echo "    + CLAUDE.md (fill in Stack section)"
else
  echo "    ~ CLAUDE.md already exists — skipping"
fi

# ── .gitignore ────────────────────────────────────────────────────────────────
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
  echo ".env" >> .gitignore
  echo ""
  echo "==> Added .env to .gitignore"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "======================================"
echo " Done! Next steps:"
echo "======================================"
echo ""
echo "  1. Fill in CLAUDE.md → Stack section"
echo "  2. Add your .env vars as Codespaces secrets for this repo:"
echo "     github.com/settings/codespaces → New secret → select this repo"
echo "  3. Verify npm run dev works"
echo "  4. Run: bash scripts/prepare-pr.sh \"setup: add ai-dev-workflow\""
echo ""
