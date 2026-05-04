---
name: symfony-api
description: Symfony 5.4+ / 6.x / 7.x API conventions. Activates when working on controllers, services, entities, repositories, console commands, migrations, or dependency injection in a Symfony backend.
last-verified: 2026-04-16
---

# Symfony (5.4+) — API conventions

Vanilla Symfony + Doctrine ORM + PHP 8.1+. Focused on the mistakes that survive lint because Symfony tolerates both the modern and the legacy style — you have to enforce the modern one.

## Rules

1. **DI is constructor-only.** Bind config values in `services.yaml` under `bind:`; never read `$_ENV` / `getenv()` from a service, never inject `ContainerInterface`.
2. **PHP 8 attributes everywhere.** `#[Route]`, `#[ORM\Entity]`, `#[AsCommand]`, `#[AsSchedule]`. Doctrine annotations (`@ORM\Entity`) are dead weight — a file mixing the two is a bug.
3. **Thin controllers and thin commands.** Controllers and `Command::execute()` handle I/O only; business logic lives in an injected service.
4. **Queries live in repositories.** DQL, `createQueryBuilder`, and custom finders belong in `ServiceEntityRepository` subclasses — never in controllers or services.
5. **Migrations are append-only.** Once a migration has run in any environment, fix mistakes with a new migration — never edit the old file.

## GOOD vs BAD — dependency injection

```php
// BAD — service locator + raw env access
class ReportService {
    public function __construct(private ContainerInterface $container) {}
    public function run(): void {
        $url = $_ENV['REPORT_URL'];
        $http = $this->container->get(HttpClientInterface::class);
    }
}

// GOOD — bound parameter + typed constructor injection
class ReportService {
    public function __construct(
        private readonly string $reportUrl,          // matches services.yaml bind:
        private readonly HttpClientInterface $http,
    ) {}
}
```

```yaml
# config/services.yaml
services:
  _defaults:
    autowire: true
    autoconfigure: true
    bind:
      $reportUrl: '%env(REPORT_URL)%'
```

## GOOD vs BAD — controllers

```php
// BAD — annotation routing, logic in the controller, manual JSON
/** @Route("/api/items", methods={"GET"}) */
public function list(): JsonResponse {
    $items = $this->getDoctrine()->getRepository(Item::class)->findAll();
    return new JsonResponse(array_map(fn($i) => ['id' => $i->getId()], $items));
}

// GOOD — attribute routing, delegation, framework serializer
#[Route('/api/items', methods: ['GET'])]
public function list(ItemService $items): JsonResponse {
    return $this->json($items->findAll());
}
```

## Tooling

- **Migrations**: `php bin/console make:migration`, review the generated SQL (Doctrine can emit unexpected `DROP`/`ALTER`), run against a disposable DB before production.
- **Static analysis**: PHPStan level 6 is the minimum bar for new code. Suppressions with `@phpstan-ignore-*` require a comment explaining *why*.
- **Automated refactors**: `vendor/bin/rector process --dry-run` to preview, `rector process` to apply.
- **Scheduled work**: `#[AsSchedule]` + Symfony Scheduler — don't hand-roll cron bootstrapping.

## Anti-patterns

- ❌ `$_ENV['KEY']` / `getenv('KEY')` inside a service — use `bind:` parameters
- ❌ `ContainerInterface` injection in new services or controllers
- ❌ `@ORM\Entity` annotations — use `#[ORM\Entity]` attributes
- ❌ DQL or `createQueryBuilder` calls outside a repository class
- ❌ Business logic inside `Controller::action()` or `Command::execute()`
- ❌ Editing an already-applied migration in place
- ❌ `shell_exec` / `exec` / `passthru` — use `Symfony\Component\Process\Process`
- ❌ `verify_peer => false` on HTTP clients — fix the certificate, don't disable TLS

## References

- Symfony docs: https://symfony.com/doc/current/index.html
- Doctrine ORM: https://www.doctrine-project.org/projects/orm.html
- PHPStan levels: https://phpstan.org/user-guide/rule-levels
