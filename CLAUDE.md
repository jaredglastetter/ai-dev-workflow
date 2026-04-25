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
| "set up \<repo\> for ai workflow" / "apply workflow to \<repo\>" | Run full setup — see **Existing Repo Setup** below |
| "add react" | `cp -r templates/ai-react frontend/` |
| "add node" | `cp -r templates/ai-node backend/` |
| "add python" | `cp -r templates/ai-python api/` |
| "prepare a PR" / "open a PR" | `bash scripts/prepare-pr.sh` |
| "set up this codespace" | `bash scripts/setup-codespace.sh` |

After running `init-project.sh`, the script handles git and GitHub automatically. Always:
1. Tell the user the GitHub URL that was printed
2. Tell them to open the new repo in its own Codespace (not this one)
3. Note: projects are created in `~/projects/<name>` — never inside the ai-dev-workflow repo

## Existing Repo Setup

When the user says "set up X for ai workflow" or "apply workflow to X":

1. Extract the repo name/owner from what the user said (e.g. `jaredglastetter/my-app`)
2. Run: `bash scripts/setup-existing-repo.sh <owner/repo>`
3. `cd` into the project path printed at the end (`READY_FOR_CLAUDE_ANALYSIS:<path>`)
4. **Analyze the repo** — read `package.json`, source files, folder structure, existing README
5. **Write a `CLAUDE.md`** tailored to this specific project including:
   - Actual stack (what frameworks, languages, tools are used)
   - Actual commands from `package.json` scripts
   - Actual file structure
   - Any missing `dev/build/test/lint` scripts that need to be added
   - The standard agent rules
6. If any standard scripts (`dev`, `build`, `test`, `lint`) are missing from `package.json`, add them
7. Run: `bash scripts/prepare-pr.sh "setup: add ai-dev-workflow"`
8. Report the PR URL to the user

Do not ask the user to fill anything in — figure it out from the code.

---

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
