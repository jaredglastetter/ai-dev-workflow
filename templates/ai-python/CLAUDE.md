# Agent Instructions

## Stack
- **Backend:** Python + FastAPI + uvicorn + pytest
- **Port:** 8000

## Commands
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start FastAPI with hot reload on port 8000 |
| `npm run test` | Run pytest |
| `npm run lint` | ruff check |

## File structure
```
main.py         ← FastAPI app
test_main.py    ← pytest tests
requirements.txt
.env            ← environment variables (never commit)
.env.example    ← template for env vars
```

## Adding routes
Add to `main.py`. Always include a response model and follow existing patterns:
```python
@app.get("/your-route")
def your_route():
    return {"key": "value"}
```

## Rules — always follow these
1. Never commit to `main` — always `git checkout -b feat/<description>`
2. Never commit `.env` — only `.env.example`
3. `pip install -r requirements.txt` if adding new packages
4. Add new packages to `requirements.txt` immediately
5. Before every PR: `npm run lint` → `npm run test`
6. Open PR with `gh pr create` — never ask the user to do it manually

## Natural language commands
| User says | Action |
|-----------|--------|
| "add a [name] endpoint" | Add route to `main.py`, add test to `test_main.py` |
| "add a dependency" | `pip install X`, add to `requirements.txt` |
| "prepare a PR" / "open a PR" | lint → test → commit → push → `gh pr create` |
