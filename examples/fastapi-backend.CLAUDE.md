# FastAPI backend

FastAPI backend with SQLAlchemy + Alembic + PostgreSQL.

## Stack

- Python 3.12+, FastAPI, Uvicorn
- SQLAlchemy 2.x (async), Alembic for migrations
- PostgreSQL, Redis (caching)
- Pydantic v2 for validation
- pytest + httpx for testing

## Commands

```bash
# Dev
uvicorn app.main:app --reload --port 8000

# Test
pytest --cov=app --cov-report=term-missing

# Migrations
alembic revision --autogenerate -m "description"
alembic upgrade head

# Lint
ruff check . && ruff format --check .
```

## Conventions

- Async everywhere — all DB calls use `async session`
- Pydantic models for all request/response schemas (no raw dicts)
- Dependency injection via FastAPI's `Depends()`
- Alembic migrations are linear — no branching
- Environment config via pydantic-settings (`app/config.py`)
- No business logic in route handlers — use service layer (`app/services/`)

## Structure

```
app/
├── main.py              # FastAPI app, middleware, startup
├── config.py            # Settings via pydantic-settings
├── models/              # SQLAlchemy models
├── schemas/             # Pydantic request/response models
├── routers/             # Route handlers (thin — delegate to services)
├── services/            # Business logic
├── repositories/        # DB queries (SQLAlchemy)
└── dependencies.py      # Shared FastAPI dependencies
```

## Gotchas

- SQLAlchemy async sessions must use `async with` — never reuse across requests
- `alembic revision --autogenerate` misses some changes (enums, constraints) — always review
- FastAPI's `BackgroundTasks` don't survive worker restarts — use Celery/ARQ for critical jobs
- `response_model` in route decorators filters output — don't rely on it for security, validate in service layer
