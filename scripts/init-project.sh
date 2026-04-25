#!/bin/bash
# Usage: ./scripts/init-project.sh <type> <project-name>
# Types: react | node | python | react-node | react-python
set -e

TYPE=${1:-react}
NAME=${2:-my-app}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

# Always create projects outside the workflow repo, in ~/projects/
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects}"
mkdir -p "$PROJECTS_DIR"
PROJECT_PATH="$PROJECTS_DIR/$NAME"

echo "==> Initializing $TYPE project: $NAME"
echo "    Location: $PROJECT_PATH"

if [ -d "$PROJECT_PATH" ]; then
  echo "ERROR: $PROJECT_PATH already exists. Choose a different name."
  exit 1
fi

mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"

# Apply base
cp -r "$TEMPLATES_DIR/ai-base/." .

case "$TYPE" in
  react)
    cp -r "$TEMPLATES_DIR/ai-react/." .
    sed -i "s/\"name\": \"ai-react\"/\"name\": \"$NAME\"/" package.json
    ;;
  node)
    cp -r "$TEMPLATES_DIR/ai-node/." .
    sed -i "s/\"name\": \"ai-node\"/\"name\": \"$NAME\"/" package.json
    ;;
  python)
    cp -r "$TEMPLATES_DIR/ai-python/." .
    sed -i "s/\"name\": \"ai-python\"/\"name\": \"$NAME\"/" package.json
    ;;
  react-node)
    cp -r "$TEMPLATES_DIR/ai-react-node/." .
    mkdir -p frontend backend
    cp -r "$TEMPLATES_DIR/ai-react/." frontend/
    cp -r "$TEMPLATES_DIR/ai-node/." backend/
    sed -i "s/\"name\": \"ai-react-node\"/\"name\": \"$NAME\"/" package.json
    ;;
  react-python)
    cp -r "$TEMPLATES_DIR/ai-react-python/." .
    mkdir -p frontend api
    cp -r "$TEMPLATES_DIR/ai-react/." frontend/
    cp -r "$TEMPLATES_DIR/ai-python/." api/
    sed -i "s/\"name\": \"ai-react-python\"/\"name\": \"$NAME\"/" package.json
    ;;
  *)
    echo "Unknown type: $TYPE. Use: react | node | python | react-node | react-python"
    exit 1
    ;;
esac

git init
git checkout -b main
npm install

# ── Create GitHub repo and push ───────────────────────────────────────────────
echo ""
echo "==> Creating GitHub repo: $NAME"
gh repo create "$NAME" --public --source=. --push
GITHUB_OWNER=$(gh api user --jq .login)
REPO_FULL="$GITHUB_OWNER/$NAME"

# ── Grant Codespaces secret access to new repo ───────────────────────────────
echo ""
echo "==> Granting Codespaces secret access"
REPO_ID=$(gh api "repos/$REPO_FULL" --jq .id)

grant_codespaces_secret() {
  local KEY=$1
  # Check if secret exists for this user first
  if gh api "user/codespaces/secrets/$KEY" &>/dev/null; then
    gh api --method PUT "user/codespaces/secrets/$KEY/repositories/$REPO_ID" && \
      echo "    ✓ $KEY → added to Codespaces access" || \
      echo "    ~ $KEY → could not grant access (may need manual add)"
  else
    echo "    ~ $KEY not found in Codespaces secrets, skipping"
  fi
}

grant_codespaces_secret GH_PAT
grant_codespaces_secret VERCEL_TOKEN
grant_codespaces_secret ANTHROPIC_API_KEY

# ── Copy secrets to new repo Actions ─────────────────────────────────────────
echo ""
echo "==> Copying secrets to $REPO_FULL Actions"

copy_secret() {
  local KEY=$1
  local VAL=${!KEY}
  if [ -n "$VAL" ]; then
    gh secret set "$KEY" --body "$VAL" --repo "$REPO_FULL"
    echo "    ✓ $KEY"
  else
    echo "    ~ $KEY not set in environment, skipping"
  fi
}

copy_secret VERCEL_TOKEN
copy_secret VERCEL_ORG_ID
copy_secret VERCEL_PROJECT_ID
copy_secret RENDER_DEPLOY_HOOK_URL
copy_secret ANTHROPIC_API_KEY

echo ""
echo "======================================"
echo " Project '$NAME' ready!"
echo "======================================"
echo ""
echo "  GitHub : https://github.com/$REPO_FULL"
echo "  Codespaces: github.com/$REPO_FULL → Code → Codespaces → New"
echo ""
echo "  Or run locally: npm run dev"
