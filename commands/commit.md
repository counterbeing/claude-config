# Commit

Do a git commit. If the branch name starts with a pattern such as "GLP-1234" that is our ticket number, and we will take that exact ticket number to start our commit message. It should be separted by a dash and be all uppercase.

Then write a short description, and then in the body of the commit please capture the intent of the changes made, while including high level specifics.

Keep commit titles to 72 characters or less.

Do not credit claude in the commit message.

For example:

```shell
git commit << 'EOF'
GLP-1234 Built a new feature

- Change 1
- Change 2
- Change 3
EOF
```

Additional context if added: $ARGUMENTS