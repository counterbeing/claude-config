# Start work on a new ticket

Check that we're on the main/master branch, and that we've pulled the latest.
Use use the Jira MCP server to look up the ticket $ARGUMENT. Check out a new
branch that starts with the ticket number and has a short but descriptive name
in kebab case. Eg. `GLP-1234-my-descriptive-ticket`. Now create a markdown file
with the same name in the local tmp folder like
`./tmp/GLP-1234-my-descriptive-ticket.md`. Create the `tmp` folder and ensure it's git ignored if it doesn't exist. Within that file we'll put the ticket
description for reference as we work.

Clear the context, and then read the ticket description from the markdown file.
Now pause to ask me if you want to start working on the ticket in plan mode, show me the plan file and ask me if you should continue.
