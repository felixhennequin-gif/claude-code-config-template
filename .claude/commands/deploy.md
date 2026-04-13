# Deploy workflow
# Usage: /deploy

Run the full deployment pipeline for this project.

## Steps

1. **Pre-checks**
   - Confirm we are on `main` or `dev`
   - `git status --porcelain` — if the working tree is dirty, stop and ask
   - Confirm the remote is up to date (`git fetch && git status -sb`)

2. **Tests**
   - `cd backend && npm test`
   - If any test fails, stop and report

3. **Build**
   - `cd frontend && npm run build`
   - Verify `frontend/dist/` exists and is non-empty

4. **Deploy**
   - Prefer a repo-local script: if `./scripts/deploy.sh` exists, run it
   - Otherwise, follow the project's documented deployment path —
     typically one of:
     - SSH to the server, `git pull && npm ci && npx prisma migrate deploy`,
       then restart the process manager
     - Push to a branch/tag that triggers a CI/CD pipeline
     - Push a container image to the registry and restart the service
   - Never hardcode the target host or credentials in this file — put
     them in `./scripts/deploy.sh` or an environment-scoped config

5. **Verify**
   - Hit the app's health endpoint (e.g. `GET /health`)
   - Check the process manager status (`pm2 list`, `systemctl status …`,
     `docker ps`, etc. — whichever this project uses)
   - Tail the logs for 30 seconds and confirm no errors

Report each step's result. Stop at the first failure.
