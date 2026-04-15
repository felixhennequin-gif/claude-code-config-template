# Go REST API

Go API with Chi router, sqlc for queries, and PostgreSQL.

## Stack

- Go 1.22+, Chi v5 router
- sqlc for type-safe SQL queries
- PostgreSQL, pgx driver
- golang-migrate for migrations
- Air for hot reload

## Commands

```bash
# Dev
air                                    # Hot reload (requires .air.toml)

# Test
go test ./... -v -cover

# Migrations
migrate -path db/migrations -database "$DATABASE_URL" up
migrate create -ext sql -dir db/migrations -seq <name>

# Lint
golangci-lint run ./...

# Build
go build -o bin/api ./cmd/api
```

## Conventions

- Standard Go project layout: `cmd/`, `internal/`, `pkg/`
- All SQL in `.sql` files, generated via `sqlc generate` — no string SQL in Go code
- Errors wrap with `fmt.Errorf("context: %w", err)` — never swallow errors
- Context passed as first parameter to every function that does I/O
- Config via environment variables, parsed at startup into a typed struct
- No global state — dependencies injected via constructor functions
- HTTP handlers take `(w http.ResponseWriter, r *http.Request)` — no custom signatures

## Structure

```
cmd/api/           → main.go (entrypoint, DI wiring)
internal/
├── handler/       → HTTP handlers (thin — validate, call service, respond)
├── service/       → Business logic
├── repository/    → DB queries (sqlc-generated + custom)
├── middleware/    → Auth, logging, recovery, CORS
└── model/         → Domain types
db/
├── migrations/    → SQL migration files (up/down)
├── queries/       → sqlc .sql files
└── sqlc.yaml      → sqlc config
```

## Gotchas

- `sqlc generate` must be re-run after any `.sql` file change — it's not automatic
- Chi's `URLParam()` returns empty string (not error) for missing params — always validate
- `pgx` pool connections must be released — use `defer rows.Close()` on every query
- `context.Background()` in handlers masks cancellation — always use `r.Context()`
- `air` doesn't watch `.sql` files by default — add them to `.air.toml`
