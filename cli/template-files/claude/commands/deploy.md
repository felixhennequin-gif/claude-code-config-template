# Deploy workflow
# Usage: /deploy

Run the full deployment pipeline for this project.

## Steps

1. **Pre-checks**
   - Confirm the current branch is the project's release branch (typically `main`, `master`, or `dev` — check `CLAUDE.md` or `README.md` for the project's convention)
   - `git status --porcelain` — if the working tree is dirty, stop and ask
   - Confirm the remote is up to date (`git fetch && git status -sb`)

2. **Tests**
   - Inspect `package.json`, `Makefile`, `pyproject.toml`, or `go.mod` to find the test command, then run it from the correct directory.
   - If any test fails, stop and report

3. **Build**
   - Inspect `package.json` (or the equivalent for the project's language) to find the build script and the frontend/backend directory, then run the build.
   - Verify the build output directory exists and is non-empty

4. **Deploy**
   - Check if a deploy script exists at common locations (`scripts/deploy.sh`, `deploy.sh`, `Makefile` `deploy` target, `justfile` `deploy` recipe) and run it if found.
   - Otherwise, follow the project's documented deployment path —
     typically one of:
     - SSH to the server, pull latest, install deps, run migrations,
       then restart the process manager
     - Push to a branch/tag that triggers a CI/CD pipeline
     - Push a container image to the registry and restart the service
   - Never hardcode the target host or credentials in this file — put
     them in the project's deploy script or an environment-scoped config

5. **Verify**
   - Hit the app's health endpoint and report the HTTP status code — e.g. `curl -s -o /dev/null -w "%{http_code}" https://your-app/health`
   - Check the process manager status and report the output (`pm2 list` / `systemctl status …` / `docker ps` — whichever this project uses)
   - Report the last 50 log lines (`pm2 logs --lines 50` / `journalctl -n 50` / `docker logs --tail 50 <container>`)
   - If any error appears in the log output, stop and report it

Report each step's result. Stop at the first failure.
