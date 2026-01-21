# Review SonarQube issues for this project

Review and fix SonarQube issues for the audit-logs-service project.

## Project Configuration

- **Project Key**: `snap-mobile_audit-logs-service_6a2fbb20-ace9-413f-a5a8-9d5a24a83016`
- **Dashboard**: https://sonarqube.snap.app/dashboard?id=snap-mobile_audit-logs-service_6a2fbb20-ace9-413f-a5a8-9d5a24a83016

## Workflow

### 1. Get current PR number
First, determine the PR number if reviewing PR-specific issues:
```bash
gh pr view --json number -q .number
```

### 2. Query SonarQube issues
Use the MCP tool to fetch OPEN issues only. For PR-specific issues:
```
mcp__sonarqube__search_sonar_issues_in_projects with:
- projects: ["snap-mobile_audit-logs-service_6a2fbb20-ace9-413f-a5a8-9d5a24a83016"]
- pullRequestId: "<PR_NUMBER>"
- ps: 100 (page size)
```

For main branch issues, omit the pullRequestId parameter.

**Important**: When processing the response, only extract these fields from each issue to reduce context:
- `key` (for accepting/changing status)
- `rule` (e.g., "typescript:S6644")
- `component` (file path - extract just the path after the project key)
- `message` (the issue description)
- `textRange.startLine` (line number)
- `status` (filter to OPEN only)

Ignore closed issues entirely. Example jq filter to trim the response:
```bash
# For processing locally or in scripts
echo '$RESPONSE' | jq '[.issues[] | select(.status == "OPEN") | {key, rule, file: (.component | split(":")[1]), line: .textRange.startLine, message}]'
```

### 3. Filter and categorize
Categorize OPEN issues by:

**Quick Wins (fix immediately):**
- S2933: Fields should be readonly
- S6606: Use nullish coalescing `??` instead of `||`
- S6644: Unnecessary conditional expression for default assignment (use `??`)
- S7019: Use exec form for Dockerfile CMD/HEALTHCHECK
- S7020: Split long Dockerfile lines

**Requires Analysis:**
- S3776: Cognitive complexity (refactor functions)
- S2004: Nested functions (may be intentional)
- S6534: Promise handling

**False Positives (accept via MCP):**
- S6698: Hardcoded secrets in docker-compose.yml or local dev configs

### 4. Fix issues
Work through issues by category, starting with quick wins. Common fixes:

**Readonly fields:**
```typescript
// Before
constructor(private client: RedisClient) {}
// After
constructor(private readonly client: RedisClient) {}
```

**Nullish coalescing:**
```typescript
// Before (when empty string should be falsy)
const value = input || "default";
// After (only null/undefined)
const value = input ?? "default";

// If empty string SHOULD trigger default, use ternary:
const value = input ? input : "default";
```

**Dockerfile exec form:**
```dockerfile
# Before
HEALTHCHECK CMD wget --spider http://localhost/health
# After
HEALTHCHECK CMD ["sh", "-c", "wget --spider http://localhost/health"]
```

### 5. Accept false positives
Use MCP to mark false positives as accepted:
```
mcp__sonarqube__change_sonar_issue_status with:
- key: "<ISSUE_KEY>"
- status: ["accept"]
```

### 6. Generated files
If issues appear in generated code, ensure `sonar-project.properties` excludes them:
```properties
sonar.exclusions=\
  **/node_modules/**,\
  **/dist/**,\
  **/libs/database/src/generated/**,\
  **/libs/protos/src/generated/**
```

## Output
After fixing issues:
1. Run `pnpm build` to verify no build errors
2. Run `pnpm test` to verify tests pass
3. Commit changes with message: "fix(sonar): address SonarQube issues"
4. Push and wait for SonarQube to re-analyze
