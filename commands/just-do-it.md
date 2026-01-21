Work through the plan file and progress file provided.

Plan: $ARGUMENTS

## Instructions

1. **Read the plan file (PLAN.md if not specified** to understand all features/tasks
2. **Read the progress file in ./tmp/progress.md** (create it if it doesn't exist) to see what's been done
3. **Select the highest-priority incomplete task** - use your judgment on priority, not just list order
4. **Implement that single task:**
   - Make the necessary code changes
   - Run pnpm install to make sure the dependencies are up to date
   - Make sure the build runs using .bin/b
   - Ensure types pass (`pnpm typecheck`)
   - Ensure tests pass (`pnpm test`)
5. **Update the plan file** to mark the task as complete
6. **Append to the progress file** with a note about what was done (for the next person/session)
7. **Git commit** the changes with a descriptive message

**ONLY WORK ON A SINGLE TASK PER RUN.**

When the entire plan is complete (all tasks done), output:
<promise>COMPLETE</promise>