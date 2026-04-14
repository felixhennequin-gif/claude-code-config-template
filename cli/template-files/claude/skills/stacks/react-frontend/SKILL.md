---
name: react-frontend
description: React 19 + Vite + Tailwind v4 frontend conventions. Activates when working on components, pages, hooks, state management, or styling.
---

# React 19 + Vite + Tailwind v4 — Frontend conventions

## Structure

```
frontend/src/
├── pages/           # Page components (one per route)
├── components/      # ui/ primitives + [feature]/ folders
├── hooks/           # Custom hooks
├── services/        # API calls (fetch wrapper)
├── contexts/        # React contexts (auth, theme)
└── styles/          # Global CSS, Tailwind variables
```

## Components

- **One component per file.** No multi-export unless sub-components are colocated.
- **Max ~200 lines per component.** Beyond that, extract sub-components or hooks.
- **Destructure props** in the signature, with default values.
- **No business logic in components.** Extract to a hook or a service.

```jsx
// GOOD
function ItemCard({ item, onFavorite, isFavorited = false }) { /* ... */ }

// BAD — unstructured props, component doing too much
function ItemCard(props) {
  const [data, setData] = useState(null);
  useEffect(() => { fetch(`/api/items/${props.id}`); }, []);
}
```

## Hooks

- Prefix with `use`. One hook = one responsibility.
- Prefer returning a named object over an array (except simple two-value hooks like useState) — makes destructuring self-documenting. This is a team preference, not a framework rule.

## State management

- **React Context** for low-frequency state (theme, auth, locale). Context re-renders every consumer on every change — fine when changes are rare.
- **Zustand** (or similar) for high-frequency shared state that updates often. Selectors avoid the Context re-render problem.
- **Local state by default.** Lift only when necessary.

## React 19

- **`use()`** — unwrap promises and contexts conditionally. Replaces most `useEffect` + `useState` fetch patterns.
- **`useActionState`** — wire forms to async actions, track pending/error state without manual `useState`.
- **`useFormStatus`** — read parent form's pending state from a child submit button, no prop drilling.
- **Server Components awareness** — even in a client-heavy Vite app, know the `"use client"` boundary. Eases any later migration to Next.js or React Router framework mode.
- **React Compiler / React Forget** — when enabled, it auto-memoizes and you can skip manual `useMemo`/`useCallback`. Check if the project has it enabled (look for `babel-plugin-react-compiler` or the `reactCompiler` Vite plugin). If it's NOT enabled, use `useMemo`/`useCallback` where the profiler shows a real need — don't add them preemptively, but don't ignore measurable perf issues either.

## Tailwind v4

- Use the design system's CSS variables — no hardcoded values.
- Utility classes inline in JSX. `cn()` / `clsx()` for conditionals.
- Dark mode via `class` strategy. Mobile-first responsive.

## Forms & API

- React Hook Form + Zod resolver; share the Zod schema between frontend and backend when possible.
- Centralized `fetch` wrapper in `services/api.js` — no direct `fetch` inside components.
- Every call exposes loading + error states.

## Accessibility (minimum)

- `aria-label` on icon-only buttons, focus trapping in modals, sufficient contrast, keyboard nav.

## Anti-patterns

- ❌ `useEffect` to derive state — use `useMemo` or compute during render
- ❌ Props drilling deeper than 3 levels — use a Context or store
- ❌ `index` as key in dynamic lists
- ❌ Components over 200 lines without extraction
- ❌ `any` in TypeScript / JSDoc
