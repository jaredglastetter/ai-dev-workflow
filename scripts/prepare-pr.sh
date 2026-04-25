#!/bin/bash
# Usage: ./scripts/prepare-pr.sh "PR title" "PR body"
# Runs install/lint/test/build, commits, pushes, opens PR
set -e

TITLE=${1:-"chore: apply ai-dev-workflow"}
BODY=${2:-"Applied ai-dev-workflow setup. Adds devcontainer, CI, and unified dev scripts."}
BRANCH=${3:-"setup/ai-workflow"}

echo "==> Preparing PR: $TITLE"

# Ensure on a branch (not main)
CURRENT=$(git branch --show-current)
if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
  echo "==> Creating branch: $BRANCH"
  git checkout -b "$BRANCH"
fi

echo "==> Installing dependencies"
npm install

echo "==> Linting"
npm run lint

echo "==> Testing"
npm run test

echo "==> Building (if applicable)"
npm run build 2>/dev/null || true

echo "==> Committing changes"
git add -A
git commit -m "$TITLE" --allow-empty

echo "==> Pushing branch"
git push -u origin "$(git branch --show-current)"

echo "==> Opening PR"
gh pr create \
  --title "$TITLE" \
  --body "$BODY" \
  --base main 2>/dev/null || \
gh pr create \
  --title "$TITLE" \
  --body "$BODY" \
  --base master

echo "==> PR created."
