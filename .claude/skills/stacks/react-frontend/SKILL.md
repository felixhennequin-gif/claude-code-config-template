---
name: react-frontend
description: React 19 + Vite + Tailwind v4 frontend conventions. Activates when working on components, pages, hooks, state management, or styling.
allowed-tools: Read, Grep, Glob
---

# React 19 + Vite + Tailwind v4 — Frontend conventions

## Structure

```
frontend/src/
├── pages/           # Page components (one per route)
├── components/      # Reusable components
│   ├── ui/          # Primitives (Button, Input, Modal, Avatar)
│   └── [feature]/   # Feature-scoped components (user/, post/, ...)
├── hooks/           # Custom hooks
├── services/        # API calls (fetch wrapper)
├── contexts/        # React contexts (auth, theme)
├── i18n/            # Translations
├── utils/           # Pure helpers
└── styles/          # Global CSS, Tailwind variables
```

## Components

- **One component per file.** No multi-export unless sub-components are colocated.
- **Max ~200 lines per component.** Beyond that, extract sub-components or hooks.
- **Destructure props** in the signature, with default values.
- **No business logic in components.** Extract to a hook or a service.

```jsx
// GOOD
function ItemCard({ item, onFavorite, isFavorited = false }) {
  // ...
}

// BAD — unstructured props, component doing too much
function ItemCard(props) {
  const [data, setData] = useState(null);
  useEffect(() => { fetch(`/api/items/${props.id}`)/* ... */; }, []);
  // 300 lines...
}
```

## Hooks

- Prefix with `use`: `useItems`, `useAuth`, `useDebounce`.
- One hook = one responsibility. `useItems` handles fetch + cache + error — not `useItemsAndAuthAndTheme`.
- Return a named object, not an array (except for simple two-value hooks like `useState`).

## State management

- **React Context** for lightweight global state (auth, theme, i18n).
- **No Redux / Zustand** unless global state becomes complex (> 5 contexts).
- **Local state by default.** Lift only when necessary.

## Tailwind v4

- Use the design system's CSS variables — no hardcoded values.
- Utility classes inline in JSX. No per-component CSS files.
- `cn()` or `clsx()` for conditional classes.
- Dark mode via the `class` strategy (not `media`).
- Responsive: mobile-first (`sm:`, `md:`, `lg:`).

## Forms

- React Hook Form + Zod resolver.
- Share the Zod schema between frontend and backend when possible.
- Inline feedback on fields — no global alerts.

## API calls

- A centralized `fetch` wrapper in `services/api.js` handles JWT tokens automatically.
- No direct `fetch` inside components — always go through a hook or a service.
- Every call exposes loading + error states.

## Accessibility (minimum)

- `aria-label` on icon-only buttons.
- Focus trapping inside modals.
- Sufficient contrast (check dark mode too).
- Keyboard navigation on interactive elements.

## Anti-patterns

- ❌ `useEffect` to derive state — use `useMemo` or compute during render
- ❌ Props drilling deeper than 3 levels — use a Context
- ❌ `index` as key in dynamic lists
- ❌ Unused hook imports (dead code)
- ❌ Components over 200 lines without extraction
- ❌ `any` in TypeScript / JSDoc
