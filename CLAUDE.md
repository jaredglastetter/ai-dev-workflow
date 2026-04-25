# AI Dev Workflow — Agent Instructions

You are working inside the `ai-dev-workflow` template system. Read this file fully before doing anything.

## Natural Language Commands

When the user says any of the following, translate it directly to the corresponding script — do not ask for clarification, just run it.

| User says | Run |
|-----------|-----|
| "create a react app called X" | `bash scripts/init-project.sh react X` |
| "create a node app called X" | `bash scripts/init-project.sh node X` |
| "create a python app called X" | `bash scripts/init-project.sh python X` |
| "create a react+node app called X" | `bash scripts/init-project.sh react-node X` |
| "create a react+python app called X" | `bash scripts/init-project.sh react-python X` |
| "apply base to this repo" | `bash scripts/apply-base.sh` |
| "add react" | `cp -r templates/ai-react frontend/` |
| "add node" | `cp -r templates/ai-node backend/` |
| "add python" | `cp -r templates/ai-python api/` |
| "prepare a PR" / "open a PR" | `bash scripts/prepare-pr.sh` |
| "set up this codespace" | `bash scripts/setup-codespace.sh` |

After running `init-project.sh`, the script handles git and GitHub automatically. Always:
1. Tell the user the GitHub URL that was printed
2. Tell them to open the new repo in its own Codespace (not this one)
3. Note: projects are created in `~/projects/<name>` — never inside the ai-dev-workflow repo

## Rules (always follow these)

- Never commit to `main` or `master` — always create a branch first
- Always run `npm install` before lint/test/build
- Always run lint → test → build before opening a PR
- Always use `gh pr create` to open PRs, never ask the user to do it manually
- Keep changes small and focused

## Stack Reference

| Template | Port | Start command |
|----------|------|---------------|
| ai-react | 3000 | `npm run dev` |
| ai-node | 4000 | `npm run dev` |
| ai-python | 8000 | `npm run dev` |
| ai-react-node | 3000 + 4000 | `npm run dev` (runs both) |
| ai-react-python | 3000 + 8000 | `npm run dev` (runs both) |

## Full documentation

See `AI_WORKFLOW.md` for complete skill reference, deploy setup, and execution rules.
