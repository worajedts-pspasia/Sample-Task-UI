# AGENTS.md — Sample Tasks UI (Rails app) repository rules

These rules apply to every task in this repository. They exist so that the app, the
Storybook spec, and the verification tooling stay in lockstep.

## What this project is

A functional task-manager app (Sample Tasks UI): Rails 8.1 + SQLite + vite_rails + React 19 +
Tailwind v4 + shadcn/ui. Hybrid UI: React+shadcn owns the task canvas (views under
`app/frontend/views`), Hotwire (ERB + Turbo + Stimulus) owns forms/settings pages.

The design system (components, tokens, i18n, fixtures, Storybook, the clinic spec)
lives in the sibling package **../shin-med-ui**, consumed via `"shin-med-ui":
"file:../shin-med-ui"` and the `@/` fallback alias in `vite.config.ts` (local
`app/frontend` first, package source second; `tsconfig.json` paths mirror it).
The sibling folder must exist for this app to build.
API v1 lives under `/api/v1` (documented at `/api/docs` via `doc/openapi.yaml`).
Every button/input must actually work — no dead UI. The app is localized (en/th/ja):
SPA strings in `../shin-med-ui/src/i18n/*.json` (i18next), Rails strings in `config/locales/*.yml`.
When adding a string, add it to all three locale files.

The repo's sibling `../shin-med-ui` vendors the **full shadcn/ui registry set**
(new-york-v4) in `src/components/ui/` as the shared base library. Keep it
complete: install new registry items via the CLI there rather than pruning
unused ones. Every vendored primitive has a colocated `<name>.stories.tsx`
(spec rule applies to `ui/*` too: stories are new files; the vendored `.tsx`
itself is never edited).

## Source of truth (in order)

1. **Design tokens** — `../shin-med-ui/src/index.css`, the `@theme` block. The palette lives
   there and nowhere else. Mirrors that must stay in sync:
   `../shin-med-ui/src/design-tokens.json` (Storybook + tooling) and the glyph hexes in
   `../shin-med-ui/src/components/things/icons.tsx` + list/tag colors in `app/frontend/data.ts` (app sample data; clinic fixtures live in `../shin-med-ui/src/fixtures/`).
   `npm run verify:spec` from `../shin-med-ui` cross-checks (Rails checks hit localhost:3000) the JSON mirror against the CSS.
2. **Component spec** — Storybook (`.storybook/`, stories colocated as `*.stories.tsx`).
   Every component in `components/things/` must have a story showing its states.
3. **Sample data** — `app/frontend/data.ts` (app sample data; clinic fixtures live in `../shin-med-ui/src/fixtures/`). Realistic Things-style content; edit freely,
   never invent UI strings the spec doesn't define.

## Hard rules

- **Never hardcode a hex color in a className.** Add or use a `things-*` token utility
  (`bg-things-blue`, `text-things-ink`, …). New color → add the token in `@theme` **and**
  `design-tokens.json` in the same change.
- **Don't edit `../shin-med-ui/src/components/ui/*`** — those are vendored shadcn primitives,
  re-installed via the CLI. Themed behavior belongs in `components/things/*`.
- **Adding a component**: `npx shadcn@latest add <name>` (needs `components.json`, already
  configured). Build Things-flavored wrappers in `components/things/`, import only tokens,
  add a story, and extend `tools/verify-spec.mjs` if the component adds a checkable
  invariant (color, size, shape).
- TypeScript must pass: `npx tsc --noEmit -p tsconfig.json`.
- Fonts: system stack only (`-apple-system…`, set in `@theme`). No webfonts.

## Commands

```bash
bin/rails db:prepare db:seed  # SQLite schema + demo data
bin/rails server              # Rails on :3000
bin/vite dev                  # Vite dev server + HMR on :3036 (run alongside Rails)
npm run storybook             # Storybook spec on :6006
npm run verify:spec           # spec ↔ implementation compliance (needs Rails + Storybook up)
bundle exec rspec spec/requests  # API request specs (23 examples)
npx tsc --noEmit              # typecheck
```

`verify:spec` flags: `--app <url>`, `--storybook <url>`, `--skip-storybook`.
It must be green before any commit that touches tokens, `components/things/*`,
views, or the tools.

## Layout map

```
app/frontend/
  index.css            # @theme tokens (source of truth) + shadcn theme
  design-tokens.json   # mirror of tokens for Storybook/tooling
  data.ts              # sample projects/areas/tags/tasks
  App.tsx              # shell, pathname router, dialogs
  views/               # one file per Things view (Today, Upcoming, …)
  components/ui/       # shadcn primitives (do not edit)
  components/things/   # design-system components + their *.stories.tsx
  components/clinic/   # clinic/medical app components (composed from ui/* + things/clinic tokens), spec: merge-clinic-ui/
.storybook/            # main.ts (strips vite-plugin-ruby), preview.tsx
tools/verify-spec.mjs  # Playwright compliance checks
```

Rails side: `PagesController#app` mounts the SPA (spa layout); Sessions/Settings/Tags are
Hotwire (hotwire layout, `entrypoints/hotwire.js`); `Api::V1::*` serves JSON (api layout
conventions in `Api::BaseController`). Routing contract: `/api/v1/*` JSON ·
`/login /settings /tags /projects/:id/edit` Hotwire · everything else → SPA.
Auth: session + `Authorization: Token <api_token>` (shown in Settings → Account).
CSRF: SPA retries once via `GET /api/v1/csrf` when a token goes stale.
When an API endpoint changes, update `doc/openapi.yaml` in the same commit.
