# Symfony API

Backend API built with Symfony and Doctrine ORM.

## Stack

- **Runtime**: PHP 8.1+, Symfony 5.4+ (also works on 6.x / 7.x)
- **ORM**: Doctrine ORM + Doctrine Migrations
- **API**: controllers with PHP 8 `#[Route]` attributes (swap in API Platform if you use it)
- **Auth**: replace with your provider — JWT, OAuth2, session, etc.
- **Scheduling**: Symfony Scheduler (`#[AsSchedule]`) or system cron
- **Quality**: PHPStan level 6+, Rector

## Structure

```
src/
  Command/        → Console commands (#[AsCommand])
  Controller/     → HTTP controllers, one action per endpoint
  Entity/         → Doctrine entities (PHP 8 attributes)
  Repository/     → Query methods, extends ServiceEntityRepository
  Service/        → Business logic, one class per concern
config/
  packages/       → Bundle configs
  services.yaml   → DI bindings, env vars via bind:
migrations/       → Doctrine migrations (append-only)
```

## Commands

```bash
composer install
php bin/console doctrine:migrations:migrate --no-interaction
php bin/phpunit
vendor/bin/phpstan analyse
vendor/bin/rector process --dry-run
```

## Conventions

- Constructor injection only — never `ContainerInterface` or direct `$_ENV` reads
- PHP 8 attributes for routes and ORM mapping — no annotations
- Controllers stay thin — business logic lives in `Service/`, queries in `Repository/`
- Env vars injected as bound parameters in `services.yaml` under `bind:`
- PHPStan level 6 must pass before committing to `src/`
- Migrations are append-only — a mistake is fixed by a new migration, never an edit
- New code must pass `vendor/bin/phpstan analyse` without suppression comments

## Git workflow

- Feature branches: `feat/xxx`, `fix/xxx`, `docs/xxx`
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`
- PHPStan must pass on CI before merge

## Gotchas

- `services.yaml` `bind:` keys must match constructor parameter names exactly (`$apiUrl` ↔ `$apiUrl`)
- Doctrine generates migrations by diffing mapping metadata — review the SQL, it can emit unexpected `DROP` / `ALTER` statements
- `php bin/console cache:clear` in `prod` requires the target `var/cache/prod/` to be writable
- Rector may rewrite code aggressively — always run `--dry-run` first and commit its changes in a separate commit

## Off-limits

- `.env` — production credentials, never commit real values
- `config/secrets/` — secrets vault, never commit decrypted values
- Applied migration files — append-only

## References

- See `.claude/skills/stacks/symfony-api/` for Symfony-specific conventions
- `config/services.yaml` for bound parameter examples
- See `CONTRIBUTING.md` for the contribution workflow
