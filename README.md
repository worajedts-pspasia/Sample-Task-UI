# Sample Tasks UI — the Rails app

A working task-manager app: real buttons, real persistence, localized
(en/th/ja). React owns the task canvas; Hotwire (ERB + Turbo + Stimulus) owns
the forms and settings; one Rails API serves both.

**The UI component library lives in the sibling repo [`../shin-med-ui`](../shin-med-ui)**
— this app consumes it as a package. **That folder must exist next to this one
or nothing builds.**

## Stack

- Rails 8.1 + SQLite (zero-config dev DB)
- vite_rails 5 (Vite 8) + TypeScript
- React 19 — views in `app/frontend/views`, mounted through `app/frontend/entrypoints`
- Hotwire: Turbo + Stimulus for form/settings pages
- Tailwind v4 — tokens and utilities come from shin-med-ui's `theme.css`
- API v1 under `/api/v1`, docs at `/api/docs`

## First run

```bash
bundle install
npm install            # installs ../shin-med-ui via file: and your direct deps
bin/rails db:prepare
bin/dev                # Rails :3000 + Vite :3036
```

Sign in with the demo account: `demo@things.local` / `things3`.
(Requires an rbenv Ruby; if bundle complains, `PATH="$HOME/.rbenv/shims:$PATH"`.)

| Port | What |
|---|---|
| 3000 | Rails app |
| 3036 | Vite dev server (used by Rails) |
| 6006 | shin-med-ui Storybook — run `npm run storybook` **in ../shin-med-ui** |

## How this app consumes shin-med-ui

- `package.json` → `"shin-med-ui": "file:../shin-med-ui"`; only deps the app
  code imports directly are declared here (npm doesn't hoist the package's).
- `vite.config.ts` → regex aliases for the app-local `app/frontend` modules,
  everything else `@/…` falls through to the package source; shared runtime
  libs are deduped (list generated from the package manifest); a fallback
  resolver catches ids the vite-ruby alias already rewrote.
- `tsconfig.json` → `paths` mirror that order for typechecking.
- `app/frontend/rails.css` → this app's Tailwind root: inlines the package's
  `theme.css` and `@source`s the package tree + this app's ERB.
- `AGENTS.md` → repository rules; the spec/verification now live in the
  package repo (`npm run verify:spec` there; its Rails checks still hit
  localhost:3000, so run both servers).

## Layout

```
app/frontend/     entrypoints, views (React), hotwire controllers, data.ts
app/views/        ERB (forms, settings, sessions) — utility classes welcome
config/vite.json  vite_rails wiring
doc/              openapi.yaml (API contract)
```
