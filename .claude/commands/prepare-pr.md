Prepare and open a pull request for the current branch.

Arguments: $ARGUMENTS (optional PR title)

1. Confirm we are NOT on main/master — if we are, ask the user what branch name to use
2. Run `npm install`
3. Run `npm run lint` — fix any errors before continuing
4. Run `npm run test` — fix any failures before continuing
5. Run `npm run build` if a build script exists
6. Run `git add -A && git commit -m "<title or auto-generated summary>"`
7. Run `git push -u origin <branch>`
8. Run `gh pr create --title "<title>" --body "<summary of changes>"`
9. Report the PR URL to the user
