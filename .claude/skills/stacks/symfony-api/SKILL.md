---
name: symfony-api
description: Symfony 5.4+ API conventions. Activates when working on controllers, services, entities, repositories, console commands, migrations, or dependency injection in a Symfony backend.
---

# Symfony 5.4+ — API conventions

## 1. Dependency injection — constructor only, never ContainerInterface

All dependencies injected via constructor. Config values injected as bound
parameters from `services.yaml` `bind:` section — never access `$_ENV` or
`getenv()` directly.

```php
// BAD — accesses env directly, legacy pattern
class CmdbService
{
    public function __construct(private ContainerInterface $container) {}

    public function connect(): void
    {
        $url = $_ENV['CMDB_URL']; // never do this
    }
}

// GOOD — bound parameter injected by name, matches services.yaml bind:
class CmdbService
{
    public function __construct(
        private readonly string $cmdbUrl,  // matches $cmdbUrl in bind:
        private readonly HttpClientInterface $httpClient,
    ) {}
}
```

Anti-pattern: `ContainerInterface` in new code — existing uses are legacy
tech debt, do not extend the pattern.

## 2. Controllers — attributes, constructor injection, thin handlers

Use PHP 8 `#[Route]` attributes. Inject services through constructor.
Controllers stay thin — delegate logic to services.

```php
// BAD — annotation syntax, service locator, logic in controller
/**
 * @Route("/api/servers", methods={"GET"})
 */
public function list(): JsonResponse
{
    $service = $this->container->get(ServerService::class);
    $servers = $service->findAll();
    // ... 40 lines of transformation logic
}

// GOOD — attribute routing, constructor injection, thin handler
#[Route('/api/servers', methods: ['GET'])]
public function list(ServerService $serverService): JsonResponse
{
    return $this->json($serverService->findAll());
}
```

Never use `ContainerInterface` in new controllers.
Never add Doctrine annotations — PHP 8 attribute syntax only (`#[ORM\Entity]`,
`#[ORM\Column]`, etc.).

## 3. Multi-entity manager — never cross managers

Some projects run two entity managers (e.g. `primary` for the main database
and `secondary` for a legacy or external one). When they do, never reference
entities from one EM in queries of the other, and always specify the EM
explicitly for migrations and schema operations.

```php
// BAD — implicit EM, will use wrong connection
$this->entityManager->getRepository(SecondaryEntity::class)->findAll();

// GOOD — inject the correct EM explicitly
public function __construct(
    #[Autowire(service: 'doctrine.orm.primary_entity_manager')]
    private readonly EntityManagerInterface $em,
    #[Autowire(service: 'doctrine.orm.secondary_entity_manager')]
    private readonly EntityManagerInterface $secondaryEm,
) {}
```

Migration commands:
```bash
# Always run both — they manage separate schema sets
php bin/console doctrine:migrations:migrate --em=primary
php bin/console doctrine:migrations:migrate --em=secondary
```

Never edit existing migration files — migrations are append-only.
Never push migrations without running them against a test DB first.

## 4. Console commands and cron jobs

Cron schedule lives in the DB (`CronJob` entity), not hardcoded in the
command class. Edit schedules via admin UI or API, not in code.

```php
// BAD — hardcoded schedule in command
#[AsCronTask('0 * * * *')]
class SyncServersCommand extends Command { ... }

// GOOD — schedule managed via DB, command has no schedule annotation
#[AsCommand(name: 'app:sync-servers')]
class SyncServersCommand extends Command
{
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        // logic only — schedule is in CronJob entity
    }
}
```

## 5. Migrations

- Generate: `php bin/console make:migration` (primary EM) or
  `php bin/console doctrine:migrations:diff --em=secondary`
- Never edit existing migration files
- Review generated SQL before committing — Doctrine may emit unexpected DROPs
- Run against test DB before production

## 6. Static analysis

PHPStan level 6 — run before every commit to `src/`:
```bash
vendor/bin/phpstan analyse
```

Rector for PHP 8.2+ modernization:
```bash
vendor/bin/rector process --dry-run  # preview
vendor/bin/rector process            # apply
```

New code must pass PHPStan level 6 without suppression comments.
Never add `@phpstan-ignore` without a documented reason.

## Anti-patterns

- ❌ `$_ENV['KEY']` or `getenv('KEY')` — use bound parameters from `services.yaml`
- ❌ `ContainerInterface` in new services or controllers
- ❌ Doctrine annotation syntax (`@ORM\Entity`) — use PHP 8 attributes
- ❌ Cross-EM entity references — `primary` and `secondary` are isolated
- ❌ Hardcoded cron schedules in command classes
- ❌ Editing existing migration files
- ❌ `shell_exec` or `exec` in new code
- ❌ `verify_peer=false` in new HTTP clients — legacy `LegacyHttpClient` does this, don't replicate
