# progress-bar

A long-duration visual timer (up to ~24h). The progress bar is the primary
indicator — numerical readouts are secondary and hidden behind a chevron.
Intended to be dropped into a static-site-generated personal blog as a
self-contained client-side page.

## Stack

- **SvelteKit** (minimal template) with **Svelte 5 runes** (`$state`,
  `$derived`, `$effect`)
- **TypeScript**
- **Tailwind CSS v4** via `@tailwindcss/vite` (no `tailwind.config`, just
  `@import "tailwindcss";` in `src/app.css`)
- **`@sveltejs/adapter-static`** — builds to a fully static bundle in `build/`.
  `src/routes/+layout.ts` sets `prerender = true` and `ssr = false` (pure CSR).
  If hosting under a subpath, set `kit.paths.base` in `svelte.config.js`.

## Structure

The entire app lives in `src/routes/+page.svelte` — single file, no components,
no stores. State is local runes.

Key state:
- `hh`, `mm`, `ss` — duration inputs (default 1h)
- `startedAt`, `now`, `paused`, `elapsedBeforePause` — timer state, ticked by
  a 250ms `setInterval` inside `$effect` while running
- `showDetails` — toggles the collapsible details block (countdown +
  hh:mm:ss inputs)
- `selectedPreset` — derived via `$effect` from (hh, mm, ss) matching a preset;
  drives the highlighted pill

Presets: 30m / 1h / 3h / 6h / 8h.

## UI design intent

- Chevron-collapsed state shows ONLY: progress bar, Start/Pause+Reset buttons,
  preset pills. No title, no numerical timers.
- The **selected preset pill is highlighted** so the user can tell what total
  duration the bar represents when the details are hidden. This is load-bearing
  — do not remove.
- Expanding the chevron reveals: large HH:MM:SS countdown, elapsed/total +
  percentage line, and three numeric inputs for precise duration.
- Editing the inputs to a value that doesn't match any preset clears the
  highlight (handled by the `$effect` that syncs `selectedPreset`).

## Known TODOs (mobile polish — not yet applied)

Noted during design review, deferred:
- Add `flex-wrap` to the preset pill row; at ~375px width the 5 pills are
  borderline tight.
- Expanded hh:mm:ss inputs (`w-20` × 3 + colons) are close to overflowing the
  card on narrow screens. Options: shrink to `w-16` on mobile, or reduce card
  padding from `p-8` to `p-6` on small screens.
- Swap `min-h-screen` → `min-h-dvh` to avoid iOS Safari URL-bar miscalc.
- Add `inputmode="numeric"` to the hh/mm/ss `<input>`s so iOS shows the
  numeric keypad.

## Dev / build

```
npm run dev          # local dev server
npm run build        # emits static site to build/
npm run preview      # smoke-test the built output
npx svelte-check     # type check
```

## Working style notes for Claude

- User is a senior engineer who reviews diffs directly — keep responses terse,
  skip trailing summaries of code changes.
- Prefer editing `+page.svelte` in place over splitting into components unless
  the file gets unwieldy.
- When proposing UI tweaks, describe them first and wait for confirmation
  rather than immediately applying (see the mobile TODOs above as an example).
