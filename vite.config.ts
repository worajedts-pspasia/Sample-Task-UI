import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import tailwindcss from '@tailwindcss/vite'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const root = path.dirname(fileURLToPath(import.meta.url))
const local = path.resolve(root, 'app/frontend')
const pkg = path.resolve(root, '../shin-med-ui/src')

// vite-plugin-ruby injects its own "@/" -> app/frontend alias (string alias,
// evaluated after these regex rules — first match wins). Everything the app
// still owns locally is enumerated; the catch-all sends the rest (components,
// lib, i18n, hooks, fixtures, api, routes, index.css) to the shin-med-ui
// package source. tsconfig.json paths mirror this order for typechecking.
// New app-local frontend modules must be added to this list.
const appLocal = path.resolve(local)

import fs from 'node:fs'
import type { Plugin } from 'vite'

// Ordering-proof fallback: vite-plugin-ruby injects its own "@/" ->
// app/frontend alias, which rewrites "@/x" to "<rails>/app/frontend/x"
// BEFORE the regex aliases above get a chance on some vite builds. This
// plugin runs after that rewrite: if the aliased app/frontend path does
// not exist but the same path exists in the shin-med-ui package source,
// resolve there instead.
function shinMedUiFallback(): Plugin {
  const exts = ['', '.ts', '.tsx', '.js', '.jsx', '.css', '.json', '/index.ts', '/index.tsx']
  const has = (p: string) => exts.some((e) => fs.existsSync(p + e))
  return {
    name: 'shin-med-ui-fallback',
    async resolveId(source) {
      const m = source.match(/^(.+?)\/app\/frontend\/(.+)$/)
      if (!m) return null
      const rest = m[2]
      const localPath = path.resolve(m[1], 'app/frontend', rest)
      if (has(localPath)) return null
      const pkgPath = path.resolve(pkg, rest)
      // return the resolved FILE, never a directory — the dep-scan build
      // loads what resolveId returns verbatim (probe extensions first: the
      // empty extension would match the directory itself)
      for (const e of exts) if (e && fs.existsSync(pkgPath + e)) return pkgPath + e
      if (fs.existsSync(pkgPath) && fs.statSync(pkgPath).isFile()) return pkgPath
      return null
    },
  }
}

// One copy of every shared runtime lib: the package has its own
// node_modules (it must run Storybook standalone), so without dedupe the
// Rails build would load two @tanstack/react-queries — provider in one,
// hooks in the other. Generated from the package manifest so it can't drift.
const shinDeps = Object.keys(
  JSON.parse(fs.readFileSync(path.resolve(root, '../shin-med-ui/package.json'), 'utf8')).dependencies ?? {},
)

export default defineConfig({
  plugins: [RubyPlugin(), tailwindcss(), shinMedUiFallback()],
  resolve: {
    dedupe: ['react', 'react-dom', ...shinDeps],
    alias: [
      { find: /^@\/App$/, replacement: `${appLocal}/App.tsx` },
      { find: /^@\/i18n$/, replacement: `${pkg}/i18n/index.ts` },
      { find: /^@\/routes$/, replacement: `${pkg}/routes.ts` },
      { find: /^@\/data(\.ts)?$/, replacement: `${appLocal}/data.ts` },
      { find: /^@\/rails\.css$/, replacement: `${appLocal}/rails.css` },
      { find: /^@\/vite-env$/, replacement: `${appLocal}/vite-env.d.ts` },
      { find: /^@\/views\/(Inbox|Lists|ProjectView|Today|Upcoming)$/, replacement: `${appLocal}/views/$1.tsx` },
      { find: /^@\/hotwire\/(.*)$/, replacement: `${appLocal}/hotwire/$1` },
      { find: /^@\//, replacement: `${pkg}/` },
    ],
  },
})
