#!/bin/bash
set -e

echo "==> Setting up AI Dev Environment"

# Install Node deps if package.json exists
if [ -f "package.json" ]; then
  echo "==> Installing Node dependencies"
  npm install
fi

# Install Python deps if requirements.txt exists
if [ -f "requirements.txt" ]; then
  echo "==> Installing Python dependencies"
  pip install -r requirements.txt
fi

# Install Playwright browsers if used
if grep -q "playwright" package.json 2>/dev/null; then
  echo "==> Installing Playwright browsers"
  npx playwright install --with-deps
fi

echo "==> Setup complete. Run: npm run dev"
