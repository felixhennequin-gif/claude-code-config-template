---
name: symfony-api
description: Symfony 5.4+ / 6.x / 7.x API conventions. Activates when working on controllers, services, entities, repositories, console commands, migrations, or dependency injection in a Symfony backend.
---

# Symfony (5.4+) — API conventions

Applies to any vanilla Symfony project using Doctrine ORM and PHP 8.1+.

## 1. Dependency injection — constructor only, no service locator

All dependencies are injected via the constructor. Never pull services from
`ContainerInterface` inside a service or controller. Config values come from
bound parameters declared in `config/services.yaml` under `bind:` — never
read `$_ENV` or `getenv()` inside services.

```php
// BAD — service locator + direct env access
class ReportService
{
    public function __construct(private ContainerInterface $container) {}

    public function run(): void
    {
        $url = $_ENV['REPORT_URL']; // don't
        $client = $this->container->get(HttpClientInterface::class);
    }
}

// GOOD — bound parameter + typed constructor injection
class ReportService
{
    public function __construct(
        private readonly string $reportUrl, // matches $reportUrl in services.yaml bind:
        private readonly HttpClientInterface $httpClient,
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

Anti-pattern: `ContainerInterface` in new code.

## 2. Controllers — attributes, constructor injection, thin handlers

Use PHP 8 `#[Route]` attributes. Inject services through the action signature
or the controller constructor. Controllers stay thin — delegate logic to services.

```php
// BAD — annotation syntax, logic in controller, manual JSON build
/**
 * @Route("/api/items", methods={"GET"})
 */
public function list(): JsonResponse
{
    $items = $this->getDoctrine()->getRepository(Item::class)->findAll();
    $data = [];
    foreach ($items as $item) {
        $data[] = ['id' => $item->getId(), 'name' => $item->getName()];
    }
    return new JsonResponse($data);
}

// GOOD — attribute routing, action injection, delegation
#[Route('/api/items', methods: ['GET'])]
public function list(ItemService $items): JsonResponse
{
    return $this->json($items->findAll());
}
```

Never mix annotation and attribute routing in the same project — attributes only.
For ORM mapping, use PHP 8 attributes (`#[ORM\Entity]`, `#[ORM\Column]`), not
Doctrine annotations (`@ORM\Entity`).

## 3. Entities and repositories

Repositories extend `ServiceEntityRepository` and are auto-wired by type.
Custom queries live in the repository, not the service or controller.

```php
// BAD — DQL in a controller
$em->createQuery('SELECT i FROM App\Entity\Item i WHERE i.active = true')
   ->getResult();

// GOOD — named finder in the repository
class ItemRepository extends ServiceEntityRepository
{
    public function findActive(): array
    {
        return $this->createQueryBuilder('i')
            ->where('i.active = true')
            ->getQuery()
            ->getResult();
    }
}
```

Never use entity manager's `getRepository()` service-locator style in new code —
inject the repository directly.

## 4. Console commands

Use `#[AsCommand]` attribute. Commands are thin wrappers over services —
the command handles input/output, a service does the work.

```php
// BAD — business logic in execute()
#[AsCommand(name: 'app:sync')]
class SyncCommand extends Command
{
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        // 80 lines of fetch + transform + persist
    }
}

// GOOD — delegate to a service
#[AsCommand(name: 'app:sync', description: 'Sync remote catalog')]
class SyncCommand extends Command
{
    public function __construct(private readonly CatalogSyncer $syncer)
    {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $count = $this->syncer->sync();
        $output->writeln("Synced {$count} items");
        return Command::SUCCESS;
    }
}
```

For scheduled work, use the built-in [Symfony Scheduler](https://symfony.com/doc/current/scheduler.html)
component (`#[AsSchedule]`) — don't reinvent cron bootstrapping.

## 5. Migrations

- Generate: `php bin/console make:migration` after mapping changes
- Review the generated SQL before committing — Doctrine can emit unexpected `DROP` / `ALTER` statements
- Never edit a migration that has already been applied anywhere
- Run migrations against a disposable test database before production

```bash
php bin/console doctrine:migrations:migrate --no-interaction
```

Migrations are append-only: a mistake in an applied migration gets fixed by a
new migration, not by editing the old one.

## 6. Static analysis

PHPStan level 6 — minimum bar for new code. Run before every commit to `src/`:

```bash
vendor/bin/phpstan analyse
```

Rector for automated refactors and PHP version upgrades:

```bash
vendor/bin/rector process --dry-run  # preview changes
vendor/bin/rector process            # apply
```

New code must pass PHPStan level 6 without `@phpstan-ignore-*` comments.
Every suppression added must have a comment explaining why.

## Anti-patterns

- ❌ `$_ENV['KEY']` / `getenv('KEY')` in services — use `bind:` bound parameters
- ❌ `ContainerInterface` injection in new services or controllers
- ❌ Doctrine annotation syntax (`@ORM\Entity`) — use PHP 8 attributes
- ❌ DQL or QueryBuilder calls outside repository classes
- ❌ Business logic inside `Controller::action()` or `Command::execute()`
- ❌ Editing migrations that are already applied anywhere
- ❌ `shell_exec` / `exec` / `passthru` in new code — use `Symfony\Component\Process\Process`
- ❌ `verify_peer => false` on HTTP clients — fix the cert, don't disable TLS verification
