Apply the ai-base template to the current repository.

Use this when working in an existing repo that doesn't have the ai-dev-workflow setup yet.

1. Run `bash scripts/apply-base.sh` (path relative to _Workflow root, adjust if needed)
2. Verify `npm run dev` is configured and works
3. Create branch: `git checkout -b setup/ai-workflow`
4. Run `/prepare-pr` to commit and open a PR
