---
name: react-frontend
description: Conventions React 19 + Vite + Tailwind v4. Active quand on travaille sur les composants, pages, hooks, state management, ou styling frontend.
allowed-tools: Read, Grep, Glob
---

# React 19 + Vite + Tailwind v4 — Conventions frontend

## Structure

```
frontend/src/
├── pages/           # Composants page (1 par route)
├── components/      # Composants réutilisables
│   ├── ui/          # Primitives (Button, Input, Modal, Avatar)
│   └── [feature]/   # Composants par feature (recipe/, artisan/)
├── hooks/           # Custom hooks
├── services/        # Appels API (fetch wrapper)
├── contexts/        # React contexts (auth, theme)
├── i18n/            # Traductions
├── utils/           # Helpers purs
└── styles/          # CSS global, variables Tailwind
```

## Composants

- **Un composant = un fichier.** Pas de multi-export sauf pour les sous-composants colocalisés.
- **Max ~200 lignes par composant.** Au-delà, extraire en sous-composants ou hooks.
- **Props destructurées** dans la signature, avec valeurs par défaut.
- **Pas de logique métier dans les composants.** Extraire dans un hook ou un service.

```jsx
// BON
function RecipeCard({ recipe, onFavorite, isFavorited = false }) {
  // ...
}

// MAUVAIS — props non destructurées, composant trop gros
function RecipeCard(props) {
  const [data, setData] = useState(null);
  useEffect(() => { fetch(`/api/recipes/${props.id}`)... }, []);
  // 300 lignes...
}
```

## Hooks

- Prefixer `use` : `useRecipes`, `useAuth`, `useDebounce`.
- Un hook = une responsabilité. `useRecipes` fait le fetch + cache + error. Pas `useRecipesAndAuthAndTheme`.
- Retourner un objet nommé, pas un tableau (sauf pour les hooks simples à 2 valeurs comme `useState`).

## State management

- **React Context** pour le state global léger (auth, theme, i18n).
- **Pas de Redux/Zustand** sauf si le state global devient complexe (> 5 contextes).
- **State local** par défaut. Remonter seulement quand nécessaire.

## Tailwind v4

- Utiliser les CSS variables du design system (pas de valeurs hardcodées).
- Classes utilitaires directement dans le JSX. Pas de fichiers CSS par composant.
- `cn()` ou `clsx()` pour les classes conditionnelles.
- Dark mode via `class` strategy (pas `media`).
- Responsive : mobile-first (`sm:`, `md:`, `lg:`).

## Formulaires

- React Hook Form + Zod resolver.
- Un schéma Zod partagé entre front et back quand possible.
- Feedback inline sur les champs (pas d'alert globale).

## API calls

- Wrapper `fetch` centralisé dans `services/api.js` avec gestion auto des tokens JWT.
- Pas de `fetch` direct dans les composants — toujours via un hook ou un service.
- Loading + error states sur chaque appel.

## Accessibilité (minimum)

- `aria-label` sur les boutons icon-only.
- Focus trapping dans les modals.
- Contraste suffisant (vérifier dark mode aussi).
- Navigation clavier sur les éléments interactifs.

## Anti-patterns

- ❌ `useEffect` pour dériver du state — utiliser `useMemo` ou calculer dans le render
- ❌ Props drilling > 3 niveaux — utiliser un Context
- ❌ `index` comme key dans les listes dynamiques
- ❌ Imports de hooks inutilisés (dead code)
- ❌ Composant > 200 lignes sans extraction
- ❌ `any` dans le TypeScript/JSDoc
