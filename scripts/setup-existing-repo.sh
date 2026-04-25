#!/bin/bash
# Usage: bash scripts/setup-existing-repo.sh <owner/repo>
# Clones an existing repo, applies ai-base, creates a PR.
# Claude then analyzes the repo and writes CLAUDE.md before the PR is opened.
set -e

REPO=${1}
if [ -z "$REPO" ]; then
  echo "Usage: bash scripts/setup-existing-repo.sh <owner/repo>"
  echo "Example: bash scripts/setup-existing-repo.sh jaredglastetter/my-app"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects}"
REPO_NAME="${REPO##*/}"
PROJECT_PATH="$PROJECTS_DIR/$REPO_NAME"
BRANCH="setup/ai-workflow"

echo ""
echo "======================================"
echo " Setting up existing repo: $REPO"
echo "======================================"
echo ""

# ── Clone ─────────────────────────────────────────────────────────────────────
if [ -d "$PROJECT_PATH" ]; then
  echo "==> $PROJECT_PATH already exists — pulling latest"
  git -C "$PROJECT_PATH" pull
else
  echo "==> Cloning $REPO → $PROJECT_PATH"
  gh repo clone "$REPO" "$PROJECT_PATH"
fi

cd "$PROJECT_PATH"

# ── Branch ────────────────────────────────────────────────────────────────────
CURRENT=$(git branch --show-current)
if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
  echo "==> Creating branch: $BRANCH"
  git checkout -b "$BRANCH"
else
  echo "==> Already on branch: $CURRENT"
fi

# ── DevContainer ──────────────────────────────────────────────────────────────
echo ""
echo "==> Adding devcontainer"
if [ ! -d ".devcontainer" ]; then
  cp -r "$TEMPLATES_DIR/ai-base/.devcontainer" .
  echo "    + .devcontainer/"
else
  echo "    ~ .devcontainer/ already exists — skipping"
fi

# ── CI workflows ──────────────────────────────────────────────────────────────
echo ""
echo "==> Adding GitHub Actions"
mkdir -p .github/workflows
for workflow in ci.yml deploy.yml; do
  if [ ! -f ".github/workflows/$workflow" ]; then
    cp "$TEMPLATES_DIR/ai-base/.github/workflows/$workflow" ".github/workflows/$workflow"
    echo "    + .github/workflows/$workflow"
  else
    echo "    ~ $workflow already exists — skipping"
  fi
done

# ── Scripts ───────────────────────────────────────────────────────────────────
echo ""
echo "==> Adding scripts"
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

# ── .env.example ──────────────────────────────────────────────────────────────
echo ""
echo "==> Checking .env"
if [ -f ".env" ] && [ ! -f ".env.example" ]; then
  grep -v '^#' .env | grep '=' | sed 's/=.*/=/' > .env.example
  echo "    + .env.example created (keys only, values stripped)"
fi
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
  echo ".env" >> .gitignore
  echo "    + .env added to .gitignore"
fi

# ── Check package.json scripts ────────────────────────────────────────────────
echo ""
echo "==> Checking package.json scripts"
if [ -f "package.json" ]; then
  for script in dev build test lint; do
    if grep -q "\"$script\"" package.json; then
      echo "    ✓ $script"
    else
      echo "    ~ missing: $script"
    fi
  done
else
  echo "    ~ No package.json found"
fi

# ── Copy secrets ──────────────────────────────────────────────────────────────
echo ""
echo "==> Copying secrets to repo"
GITHUB_OWNER=$(gh api user --jq .login)
REPO_FULL="$GITHUB_OWNER/$REPO_NAME"
REPO_ID=$(gh api "repos/$REPO_FULL" --jq .id 2>/dev/null || echo "")

grant_codespaces_secret() {
  local KEY=$1
  if [ -n "$REPO_ID" ] && gh api "user/codespaces/secrets/$KEY" &>/dev/null; then
    gh api --method PUT "user/codespaces/secrets/$KEY/repositories/$REPO_ID" 2>/dev/null && \
      echo "    ✓ $KEY → Codespaces" || true
  fi
}

copy_secret() {
  local KEY=$1
  local VAL=${!KEY}
  if [ -n "$VAL" ]; then
    gh secret set "$KEY" --body "$VAL" --repo "$REPO_FULL" 2>/dev/null && \
      echo "    ✓ $KEY → Actions" || true
  fi
}

grant_codespaces_secret GH_PAT
grant_codespaces_secret VERCEL_TOKEN
grant_codespaces_secret ANTHROPIC_API_KEY

copy_secret VERCEL_TOKEN
copy_secret VERCEL_ORG_ID
copy_secret VERCEL_PROJECT_ID
copy_secret RENDER_DEPLOY_HOOK_URL

# ── Done — Claude writes CLAUDE.md next ───────────────────────────────────────
echo ""
echo "======================================"
echo " Repo prepared at: $PROJECT_PATH"
echo "======================================"
echo ""
echo " NEXT: Claude will now analyze this repo and write CLAUDE.md"
echo " Then run: bash scripts/prepare-pr.sh \"setup: add ai-dev-workflow\""
echo ""
echo "READY_FOR_CLAUDE_ANALYSIS:$PROJECT_PATH"
