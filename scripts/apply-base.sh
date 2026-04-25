#!/bin/bash
# Usage: ./scripts/apply-base.sh
# Run from root of an existing repo to add devcontainer, CI, and scripts
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

echo "==> Applying ai-base to current repo"

# Copy devcontainer (never overwrite if already exists)
if [ ! -d ".devcontainer" ]; then
  cp -r "$TEMPLATES_DIR/ai-base/.devcontainer" .
  echo "    + .devcontainer/"
else
  echo "    ~ .devcontainer/ already exists, skipping"
fi

# Copy CI workflow
mkdir -p .github/workflows
if [ ! -f ".github/workflows/ci.yml" ]; then
  cp "$TEMPLATES_DIR/ai-base/.github/workflows/ci.yml" .github/workflows/ci.yml
  echo "    + .github/workflows/ci.yml"
else
  echo "    ~ .github/workflows/ci.yml already exists, skipping"
fi

# Merge scripts into existing package.json if present
if [ -f "package.json" ]; then
  echo "    ~ package.json found — ensure dev/build/test/lint scripts exist"
  echo "      (manual merge may be needed if scripts conflict)"
else
  cp "$TEMPLATES_DIR/ai-base/package.json" .
  echo "    + package.json"
fi

# Copy README only if none exists
if [ ! -f "README.md" ]; then
  cp "$TEMPLATES_DIR/ai-base/README.md" .
  echo "    + README.md"
fi

echo ""
echo "==> ai-base applied. Next:"
echo "    git checkout -b setup/ai-workflow"
echo "    npm install && npm run dev"
