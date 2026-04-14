---
name: ci-cd-pipeline
description: CI/CD pipeline patterns — GitHub Actions and GitLab CI. Loads when editing .github/workflows/, .gitlab-ci.yml, or when auditing/debugging a pipeline.
---

# CI/CD Pipeline — Skill

## Quand charger ce skill

Charge ce fichier quand tu dois :
- Créer ou modifier un workflow GitHub Actions (`.github/workflows/`)
- Créer ou modifier un pipeline GitLab CI (`.gitlab-ci.yml`)
- Auditer un pipeline existant
- Déboguer un job CI qui échoue

---

## Principes fondamentaux

**Build once, deploy many** : construire l'artefact une seule fois en CI, le promouvoir sans le reconstruire.

```
BAD   build-staging → image:staging  /  build-prod → image:prod
GOOD  build → image:$SHA  →  deploy-staging (même image)  →  deploy-prod (même image)
```

**Idempotence** : même commit = même résultat. Toujours.
- `npm ci` (pas `npm install`)
- Images Docker versionnées (`node:20.11.0-alpine3.19` pas `node:lts`)
- Actions épinglées par SHA (pas par tag)

**Feedback < 10 min** : lint + tests unitaires + scan sécurité en parallèle, fail fast.

**Séparation build / deploy** : deux jobs distincts, deux responsabilités distinctes.

---

## GitHub Actions — patterns

### Structure de base recommandée

```yaml
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:

permissions:
  contents: read          # moindre privilège par défaut

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
    needs: [lint, test]   # bloqué jusqu'à succès des deux
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - run: docker build -t my-app:${{ github.sha }} .
      - uses: actions/upload-artifact@65c4c4a1ddee5b72f698fdd19549f0f0fb45cf08  # v4
        with:
          name: image-digest
          path: digest.txt
```

### Passer un artefact entre jobs

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

### OIDC — pas de secrets statiques (AWS example)

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
      aws-region: eu-west-1
      # Pas de AWS_ACCESS_KEY_ID ni AWS_SECRET_ACCESS_KEY stockés
```

### Secrets scopés par environnement

```yaml
deploy-staging:
  environment: staging        # secrets de l'env staging uniquement
  steps:
    - run: ./deploy.sh

deploy-prod:
  environment: production     # secrets de l'env production uniquement
  needs: deploy-staging
  steps:
    - run: ./deploy.sh
```

---

## GitLab CI — patterns

### Structure de base recommandée

```yaml
stages:
  - lint
  - test
  - build
  - deploy

default:
  image: node:20.11.0-alpine3.19   # version fixée, jamais :lts

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
  when: manual                    # Continuous Delivery : humain valide
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### DAG avec needs (parallélisme max)

```yaml
# Sans needs : séquentiel par stage
# Avec needs : graphe de dépendances explicite

build-api:
  needs: []             # démarre immédiatement

build-frontend:
  needs: []             # démarre en parallèle avec build-api

test-api:
  needs: [build-api]    # attend uniquement build-api

test-frontend:
  needs: [build-frontend]

deploy:
  needs: [test-api, test-frontend]
```

---

## Checklist sécurité

Avant de valider un workflow CI/CD :

- [ ] Actions GitHub épinglées par SHA (pas `@v4`, pas `@main`)
- [ ] Images Docker versionnées (pas `:latest`, pas `:lts`)
- [ ] Permissions minimales déclarées (`permissions: contents: read`)
- [ ] OIDC utilisé si possible (pas de clés API stockées comme secrets)
- [ ] Secrets différents par environnement (staging != prod)
- [ ] Pas de `echo $SECRET` ni de secret dans les scripts
- [ ] `npm ci` (pas `npm install`)
- [ ] Rollback documenté ou testé

---

## Anti-patterns à signaler

Si tu vois ça dans un workflow existant, flag-le :

- `@latest` ou `@main` sur une action → remplacer par SHA
- Reconstruction de l'image par environnement → build once
- Secrets prod utilisés dès le job de build → scoper par env
- Pipeline > 30 min sans parallélisation → proposer DAG
- Pas de `needs` → tout séquentiel, pertes de temps inutiles
- `npm install` au lieu de `npm ci` → non reproductible
