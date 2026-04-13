# ai-config-template

Template d'architecture IA pour projets Node.js/React/PostgreSQL.

Basé sur l'analyse de ~55 repos open-source (Supabase, Bitwarden, Vercel, Anthropic, Cloudflare, OpenAI) — voir [la recherche complète](https://github.com/felixhennequin-gif/ai-config-template/blob/main/RESEARCH.md).

## Pourquoi

Claude Code lit automatiquement les fichiers `CLAUDE.md` et `.claude/` au démarrage de chaque session. Sans ça, tu perds 15 minutes à re-contextualiser. Avec, Claude connaît ta stack, tes conventions, tes commandes, et tes pièges dès le premier message.

## Ce que contient ce template

```
.
├── CLAUDE.md                         # Contexte projet (le seul fichier obligatoire)
├── CLAUDE.local.md                   # Overrides perso (gitignored)
├── .claude/
│   ├── settings.json                 # Hooks déterministes (block main, auto-lint)
│   ├── settings.local.json           # Overrides perso (gitignored)
│   ├── agents/
│   │   ├── reviewer.md               # Review de code automatisée
│   │   └── security-auditor.md       # Audit sécurité ciblé
│   ├── commands/
│   │   ├── deploy.md                 # /deploy — workflow de déploiement
│   │   ├── audit.md                  # /audit — audit qualité complet
│   │   └── test.md                   # /test — lance les tests + coverage
│   ├── skills/
│   │   ├── prisma-patterns/SKILL.md  # Conventions Prisma 7
│   │   ├── express-api/SKILL.md      # Patterns Express 5
│   │   └── react-frontend/SKILL.md   # Patterns React 19 + Tailwind v4
│   ├── hooks/
│   │   └── lint-on-edit.sh           # Auto-lint après chaque édition
│   └── rules/
│       └── test-files.md             # Règles spécifiques aux fichiers de test
├── examples/
│   ├── ecume.CLAUDE.md               # Exemple adapté à Écume (cocktail-app)
│   └── lecabanon.CLAUDE.md           # Exemple adapté à LeCabanon
└── RESEARCH.md                       # Données brutes de la recherche
```

## Installation

### Pour un nouveau projet

```bash
# Clone le template
git clone https://github.com/felixhennequin-gif/ai-config-template.git /tmp/ai-template

# Copie dans ton projet
cp /tmp/ai-template/CLAUDE.md ton-projet/CLAUDE.md
cp -r /tmp/ai-template/.claude ton-projet/.claude
cp /tmp/ai-template/CLAUDE.local.md ton-projet/CLAUDE.local.md

# Ajoute au .gitignore
echo "CLAUDE.local.md" >> ton-projet/.gitignore
echo ".claude/settings.local.json" >> ton-projet/.gitignore

# Édite CLAUDE.md avec les infos de ton projet
```

### Pour Écume ou LeCabanon

```bash
cp examples/ecume.CLAUDE.md cocktail-app/CLAUDE.md
cp -r .claude cocktail-app/.claude

cp examples/lecabanon.CLAUDE.md LeCabanon/CLAUDE.md
cp -r .claude LeCabanon/.claude
```

Puis adapte les commandes et la structure dans chaque CLAUDE.md.

## Config globale (optionnel)

Crée `~/.claude/CLAUDE.md` pour tes préférences cross-projets :

```markdown
# Préférences globales
- Toujours lancer les tests avant de commit
- Préférer la simplicité — pas de sur-ingénierie
- Conventional commits obligatoires
- Pas de console.log en prod
- Code en anglais, commentaires en français si pertinent
```

Max 15 lignes. Tout ce qui est spécifique au projet va dans le CLAUDE.md projet.

## Principes

1. **Max ~80 lignes pour le CLAUDE.md projet.** Au-delà, Claude ignore des parties.
2. **Ne duplique pas ce qu'un linter fait.** Utilise un hook à la place.
3. **Pointe vers les docs, ne copie pas.** `Voir TESTING.md` > 50 lignes sur comment tester.
4. **Les commandes build/test/lint sont le minimum vital.**
5. **Les skills sont le meilleur ROI.** Un skill Prisma bien écrit est réutilisé automatiquement.
6. **Les hooks sont gratuits en tokens.** Block main, auto-format — c'est déterministe.

## Crédits

Recherche basée sur l'analyse de : Supabase (supabase-js), Bitwarden (server, android, ai-plugins), Vercel (next-devtools-mcp, agent-skills), Anthropic (claude-code-action), Cloudflare (6 skills officiels), OpenAI (openai-agents-python), et ~45 autres projets open-source.

## Licence

MIT
