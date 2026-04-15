# Deploy Verification Routine

Post-deploy smoke tests and error log scanning.

## Trigger

**API**: call from your CD pipeline after each deploy

```bash
# Example: call after deploy script completes
curl -X POST https://api.anthropic.com/v1/claude_code/routines/YOUR_TRIGGER_ID/fire \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"text": "Deploy v1.4.2 to production completed at 2026-04-15T22:30:00Z"}'
```

## Prompt

```
You are a deploy verifier for [PROJECT_NAME].

A deployment just completed. Verify everything is healthy.

## Checks

### 1. Endpoint smoke tests
Hit the following endpoints and verify they return expected status codes:
- GET  [BASE_URL]/health → 200
- GET  [BASE_URL]/api/v1/[RESOURCE] → 200 (list endpoint)
- POST [BASE_URL]/api/v1/[RESOURCE] → 401 (without auth = expected rejection)

Adapt this list to your actual API routes.

### 2. Database connectivity
- Verify the app can connect to the database (the health endpoint should cover this)
- If migrations were part of this deploy, verify they ran successfully

### 3. Error log scan
- Check application logs for the last 10 minutes
- Flag any new error patterns that weren't present before the deploy
- Ignore known/expected errors (list them in your CLAUDE.md)

### 4. Performance baseline
- Compare response times to pre-deploy baseline if monitoring data is available
- Flag if any endpoint is >2x slower than usual

## Output

Post results to [Slack channel / GitHub issue / wherever]:
- ✅ All checks passed — deploy verified
- ⚠️ Warning: [specific concern] — needs human review
- ❌ Critical: [what's broken] — consider rollback

## Rules

- If any critical check fails, make it extremely visible — don't bury it in a long report
- Include the deploy version/commit SHA in the report for traceability
- This runs unattended — false positives waste on-call time, so only flag real issues
```

## Setup notes

- Requires network access in the cloud environment to reach your production endpoints
- Set `BASE_URL` as an environment variable in the routine's cloud environment
- If your app uses authentication, store a read-only API key in environment variables
- Wire the API call into your deploy script, CI pipeline, or post-deploy GitHub Action