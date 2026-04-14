---
name: ci-cd-pipeline
description: CI/CD pipeline patterns — GitHub Actions and GitLab CI. Loads when editing .github/workflows/, .gitlab-ci.yml, or when auditing/debugging a pipeline.
---

# CI/CD Pipeline — Skill

## When to load this skill

Load this file when you need to:
- Create or modify a GitHub Actions workflow (`.github/workflows/`)
- Create or modify a GitLab CI pipeline (`.gitlab-ci.yml`)
- Audit an existing pipeline
- Debug a failing CI job

---

## Core principles

**Build once, deploy many**: build the artifact once in CI, then promote it across environments without rebuilding.

```
BAD   build-staging → image:staging  /  build-prod → image:prod
GOOD  build → image:$SHA  →  deploy-staging (same image)  →  deploy-prod (same image)
```

**Idempotence**: same commit = same result. Always.
- `npm ci` (not `npm install`)
- Pinned Docker images (`node:20.11.0-alpine3.19`, not `node:lts`)
- Actions pinned by SHA (not by tag)

**Feedback < 10 min**: run lint + unit tests + security scan in parallel, fail fast.

**Separate build from deploy**: two distinct jobs, two distinct responsibilities.

---

## GitHub Actions — patterns

### Recommended base structure

```yaml
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:

permissions:
  contents: read          # least privilege by default

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4
      - uses: actions/setup-node@1a4442cacd436585916779262731145c7197628    # v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: actions/setup-node@1a4442cacd436585916779262731145c7197628
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test

  build:
    needs: [lint, test]   # blocked until both succeed
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - run: docker build -t my-app:${{ github.sha }} .
      - uses: actions/upload-artifact@65c4c4a1ddee5b72f698fdd19549f0f0fb45cf08  # v4
        with:
          name: image-digest
          path: digest.txt
```

### Passing an artifact between jobs

```yaml
build:
  steps:
    - run: npm run build
    - uses: actions/upload-artifact@65c4c4a1ddee5b72f698fdd19549f0f0fb45cf08
      with:
        name: dist
        path: dist/

deploy:
  needs: build
  steps:
    - uses: actions/download-artifact@fa0a91b85d4f404e444306234b4d8a0d48344ab1  # v4
      with:
        name: dist
```

### OIDC — no static secrets (AWS example)

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
      aws-region: eu-west-1
      # No AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY stored
```

### Secrets scoped per environment

```yaml
deploy-staging:
  environment: staging        # staging-env secrets only
  steps:
    - run: ./deploy.sh

deploy-prod:
  environment: production     # production-env secrets only
  needs: deploy-staging
  steps:
    - run: ./deploy.sh
```

---

## GitLab CI — patterns

### Recommended base structure

```yaml
stages:
  - lint
  - test
  - build
  - deploy

default:
  image: node:20.11.0-alpine3.19   # pinned version, never :lts

lint:
  stage: lint
  script:
    - npm ci
    - npm run lint
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

test:
  stage: test
  script:
    - npm ci
    - npm test
  artifacts:
    reports:
      junit: junit.xml
    when: always

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy-staging:
  stage: deploy
  environment: staging
  script: ./deploy.sh staging $CI_COMMIT_SHA
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy-prod:
  stage: deploy
  environment: production
  script: ./deploy.sh prod $CI_COMMIT_SHA
  when: manual                    # Continuous Delivery: human approval gate
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### DAG with needs (max parallelism)

```yaml
# Without needs: sequential per stage
# With needs: explicit dependency graph

build-api:
  needs: []             # starts immediately

build-frontend:
  needs: []             # starts in parallel with build-api

test-api:
  needs: [build-api]    # waits only for build-api

test-frontend:
  needs: [build-frontend]

deploy:
  needs: [test-api, test-frontend]
```

---

## Security checklist

Before approving a CI/CD workflow:

- [ ] GitHub Actions pinned by SHA (not `@v4`, not `@main`)
- [ ] Docker images pinned to an explicit version (not `:latest`, not `:lts`)
- [ ] Minimum permissions declared (`permissions: contents: read`)
- [ ] OIDC used where possible (no long-lived API keys stored as secrets)
- [ ] Secrets scoped per environment (staging != prod)
- [ ] No `echo $SECRET` and no secrets printed in scripts
- [ ] `npm ci` (not `npm install`)
- [ ] Rollback documented or tested

---

## Anti-patterns to flag

If you see any of these in an existing workflow, flag them:

- `@latest` or `@main` on an action → replace with a SHA
- Rebuilding the image per environment → build once
- Production secrets used in the build job → scope per environment
- Pipeline > 30 min without parallelization → propose a DAG
- No `needs` → fully sequential, wasted wall-clock time
- `npm install` instead of `npm ci` → not reproducible
