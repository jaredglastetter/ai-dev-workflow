Create a new app using the ai-dev-workflow template system.

Arguments: $ARGUMENTS (format: "<type> <name>", e.g. "react my-app" or "react-node my-fullstack-app")

Parse the arguments to extract type and name, then:

1. Run: `bash scripts/init-project.sh <type> <name>`
2. Run: `cd <name> && gh repo create <name> --public --source=. --push`
3. Report the GitHub URL to the user
4. Tell them to open it in Codespaces: go to github.com/<username>/<name> → Code → Codespaces → New

Valid types: react, node, python, react-node, react-python
