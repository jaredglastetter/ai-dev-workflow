#!/bin/bash
# One-time Codespace setup. Run once after a new Codespace opens.
# Safe to re-run — all steps are idempotent.
set -e

echo ""
echo "======================================"
echo " AI Dev Workflow — Codespace Setup"
echo "======================================"
echo ""

# ── GitHub CLI auth ─────────────────────────────────────────────────────────
echo "==> Checking GitHub CLI auth"
if gh auth status &>/dev/null; then
  echo "    ✓ Already authenticated as $(gh api user --jq .login)"
else
  if [ -n "$GITHUB_TOKEN" ]; then
    # Codespaces provides this automatically
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    echo "    ✓ Authenticated via GITHUB_TOKEN"
  else
    echo "    Paste a GitHub personal access token (needs repo + workflow scopes):"
    echo "    Generate one at: https://github.com/settings/tokens/new"
    gh auth login --hostname github.com --git-protocol https --web 2>/dev/null || \
    read -rsp "    Token: " token && echo "$token" | gh auth login --with-token
    echo "    ✓ Authenticated"
  fi
fi

# ── Git config ───────────────────────────────────────────────────────────────
echo ""
echo "==> Checking git config"
if [ -z "$(git config --global user.email)" ]; then
  GH_EMAIL=$(gh api user --jq '.email // empty' 2>/dev/null || true)
  GH_NAME=$(gh api user --jq '.name // .login' 2>/dev/null || true)
  if [ -n "$GH_EMAIL" ]; then
    git config --global user.email "$GH_EMAIL"
    git config --global user.name "$GH_NAME"
    echo "    ✓ Set from GitHub: $GH_NAME <$GH_EMAIL>"
  else
    echo "    No public email on GitHub. Set manually:"
    echo "    git config --global user.email \"you@example.com\""
    echo "    git config --global user.name \"Your Name\""
  fi
else
  echo "    ✓ Already set: $(git config --global user.name) <$(git config --global user.email)>"
fi
git config --global push.autoSetupRemote true

# ── Node dependencies ────────────────────────────────────────────────────────
echo ""
echo "==> Installing Node dependencies"
if [ -f "package.json" ]; then
  npm install
  echo "    ✓ npm install complete"
else
  echo "    ~ No package.json found, skipping"
fi

# ── Python dependencies ──────────────────────────────────────────────────────
echo ""
echo "==> Installing Python dependencies"
if [ -f "requirements.txt" ]; then
  pip install -r requirements.txt -q
  echo "    ✓ pip install complete"
elif [ -f "api/requirements.txt" ]; then
  pip install -r api/requirements.txt -q
  echo "    ✓ pip install (api/) complete"
else
  echo "    ~ No requirements.txt found, skipping"
fi

# ── Copy .env files ──────────────────────────────────────────────────────────
echo ""
echo "==> Setting up .env files"
for example in $(find . -name ".env.example" -not -path "*/node_modules/*"); do
  target="${example%.example}"
  if [ ! -f "$target" ]; then
    cp "$example" "$target"
    echo "    + $target (copied from $example)"
  else
    echo "    ~ $target already exists"
  fi
done

# ── Playwright (if present) ──────────────────────────────────────────────────
if grep -q "\"playwright\"" package.json 2>/dev/null; then
  echo ""
  echo "==> Installing Playwright browsers"
  npx playwright install --with-deps chromium
  echo "    ✓ Playwright ready"
fi

# ── Vercel setup ─────────────────────────────────────────────────────────────
echo ""
echo "==> Checking Vercel"
if [ ! -f "vercel.json" ]; then
  echo "    ~ No vercel.json found, skipping"
elif [ -z "$VERCEL_TOKEN" ]; then
  echo "    ~ VERCEL_TOKEN not set — skipping auto-link"
  echo "      To enable: add VERCEL_TOKEN to Codespaces secrets"
  echo "      Get token: https://vercel.com/account/tokens"
else
  # Install Vercel CLI if needed
  if ! command -v vercel &>/dev/null; then
    npm install -g vercel -q
  fi

  if [ -f ".vercel/project.json" ]; then
    echo "    ✓ Already linked to Vercel project"
  else
    echo "    Linking to Vercel..."

    # Derive org/project name from git remote or directory name
    REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")

    # vercel link --yes requires scope; pull org from token
    VERCEL_ORG=$(vercel teams ls --token "$VERCEL_TOKEN" 2>/dev/null | awk 'NR==2{print $1}' || true)

    if [ -n "$VERCEL_ORG" ]; then
      vercel link --yes --token "$VERCEL_TOKEN" --scope "$VERCEL_ORG" 2>/dev/null && \
        echo "    ✓ Linked to Vercel (org: $VERCEL_ORG)" || \
        echo "    ~ vercel link failed — run manually: vercel link"
    else
      # Personal account (no team)
      vercel link --yes --token "$VERCEL_TOKEN" 2>/dev/null && \
        echo "    ✓ Linked to Vercel (personal account)" || \
        echo "    ~ vercel link failed — run manually: vercel link"
    fi

    # Pull env vars from Vercel into .env.local
    if [ -f ".vercel/project.json" ]; then
      vercel env pull .env.local --token "$VERCEL_TOKEN" --yes 2>/dev/null && \
        echo "    ✓ Pulled Vercel env → .env.local" || true
    fi
  fi

  # Store project/org IDs as env hints for CI
  if [ -f ".vercel/project.json" ]; then
    VERCEL_PROJECT_ID=$(jq -r '.projectId' .vercel/project.json 2>/dev/null || true)
    VERCEL_ORG_ID=$(jq -r '.orgId' .vercel/project.json 2>/dev/null || true)
    echo ""
    echo "    Add these as GitHub repo secrets for CI deploys:"
    echo "      VERCEL_TOKEN       = (already have)"
    echo "      VERCEL_PROJECT_ID  = $VERCEL_PROJECT_ID"
    echo "      VERCEL_ORG_ID      = $VERCEL_ORG_ID"
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "======================================"
echo " Setup complete!"
echo "======================================"
echo ""
echo " Available commands:"
echo "   npm run dev      — start all services"
echo "   npm run test     — run tests"
echo "   npm run lint     — lint code"
echo "   npm run build    — build for production"
echo ""
if [ -n "$CODESPACE_NAME" ]; then
  echo " Codespace ports (live preview):"
  echo "   Frontend : https://$CODESPACE_NAME-3000.app.github.dev"
  echo "   Node API : https://$CODESPACE_NAME-4000.app.github.dev"
  echo "   Python   : https://$CODESPACE_NAME-8000.app.github.dev"
  echo ""
fi
echo " Run: npm run dev"
echo ""
