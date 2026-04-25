#!/bin/bash
# Usage: ./scripts/init-project.sh <type> <project-name>
# Types: react | node | python | react-node | react-python
set -e

TYPE=${1:-react}
NAME=${2:-my-app}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

echo "==> Initializing $TYPE project: $NAME"

mkdir -p "$NAME"
cd "$NAME"

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

echo ""
echo "==> Project '$NAME' ready!"
echo "    cd $NAME && npm run dev"
