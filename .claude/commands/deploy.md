# Deploy workflow
# Usage: /deploy

Run the full deployment pipeline for this project.

## Steps

1. **Pre-checks**
   - Confirm we're on `main` or `dev` branch
   - Check for uncommitted changes: `git status --porcelain`
   - If dirty working tree, stop and ask

2. **Tests**
   - Run `cd backend && npm test`
   - If any test fails, stop and report

3. **Build**
   - Run `cd frontend && npm run build`
   - Verify `frontend/dist/` exists and is non-empty

4. **Deploy to server**
   - Run `./scripts/deploy.sh` if it exists
   - Otherwise: `ssh debian@192.168.1.85 "cd /path/to/project && git pull && npm install && npx prisma migrate deploy && pm2 restart all"`

5. **Verify**
   - Check PM2 status: `pm2 list`
   - Confirm the process is online and not erroring

Report each step's result. Stop at first failure.
