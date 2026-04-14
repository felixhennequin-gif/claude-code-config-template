# Symfony API

Backend API built with Symfony 5.4, API Platform, and Doctrine ORM.

## Stack

- **Runtime**: PHP 8.2, Symfony 5.4
- **API**: API Platform 2.7 (JSON-LD), custom controllers
- **ORM**: Doctrine 2.13 (PostgreSQL primary, SQL Server secondary)
- **Auth**: LDAP → JWT (Lexik) + refresh tokens (Gesdinet)
- **Scheduling**: cron/cron-bundle 2.10 — schedules stored in DB
- **Admin**: EasyAdmin 3.5
- **Quality**: PHPStan level 6, Rector (UP_TO_PHP_82)

## Structure

```
src/
  Command/        → Console commands — batch ops, exports, scheduling
  Controller/     → HTTP controllers (API Platform + custom)
  Entity/         → Doctrine ORM entities (PHP 8 attributes)
  Repository/     → Domain-specific query methods
  Service/        → One class per external integration
config/
  packages/       → Bundle YAML configs
  services.yaml   → DI bindings — env vars injected as bound parameters
migrations/
  default/        → Main DB migrations
  crondb/         → Cron bundle migrations
```

## Commands

```bash
composer install
php bin/console doctrine:migrations:migrate --em=default
php bin/console doctrine:migrations:migrate --em=cron
php bin/phpunit
vendor/bin/phpstan analyse
vendor/bin/rector process --dry-run
docker-compose up -d   # PostgreSQL + mailcatcher
```

## Conventions

- Constructor injection only — never `ContainerInterface` or `$_ENV`
- PHP 8 attribute syntax for routes and ORM mapping — no annotations
- Controllers are thin — logic lives in `Service/`
- Bound parameters in `services.yaml` `bind:` — one entry per env var
- PHPStan level 6 must pass before committing to `src/`
- Migrations are append-only — never edit existing files
- Cron schedules live in DB (`CronJob` entity) — not in command classes

## Git workflow

- feature branches: `feat/xxx`, `fix/xxx`
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`
- PHPStan must pass on CI before merge

## Gotchas

- Two entity managers (`default` + `iws`) — never cross-reference entities between them
- Migrations require `--em=default` AND `--em=cron` separately
- `services.yaml` `bind:` keys must match constructor parameter names exactly
- Rector target is `UP_TO_PHP_82` — check `composer.json` requires PHP `^8.2`

## Off-limits

- `.env` — contains real credentials, never modify
- `config/jwt/*.pem` — JWT keypair, never commit
- existing migration files — append-only
- `src/Legacy/` — do not extend legacy patterns (`ContainerInterface`, annotations)

## References

- See `.claude/skills/stacks/symfony-api/` for Symfony-specific conventions
- `config/services.yaml` for the full bound parameters list
- See `CONTRIBUTING.md` for the contribution workflow
