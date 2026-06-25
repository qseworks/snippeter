# Snippeter — Landing Site

A polished, single-page marketing site for **Snippeter**, a fast, local-first
manager for code snippets and AI prompts. Built with **Next.js 14 (App Router)**,
**TypeScript** and **Tailwind CSS**. Fully static — no backend, no external image
or CDN assets (the product mock and logo are drawn with inline SVG/CSS).

## Stack

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- `next/font` for the Inter typeface

## Local development

This repo intentionally ships without `node_modules`. Install dependencies, then
run the dev server:

```bash
npm install
npm run dev
```

Open <http://localhost:3000>.

### Other scripts

```bash
npm run build   # production build (next build)
npm run start   # serve the production build
npm run lint    # next lint
```

## Project structure

```
landing/
├─ app/
│  ├─ globals.css        # Tailwind layers + theme/base styles
│  ├─ icon.svg           # favicon (the </> logo mark)
│  ├─ layout.tsx         # Inter font, metadata, OpenGraph, theme-color
│  └─ page.tsx           # composes all sections
├─ components/
│  ├─ Nav.tsx
│  ├─ Hero.tsx
│  ├─ LogoMark.tsx
│  ├─ FeatureGrid.tsx
│  ├─ IntegrationsStrip.tsx
│  ├─ CodeToImageShowcase.tsx
│  ├─ Pricing.tsx
│  ├─ Faq.tsx
│  ├─ Footer.tsx
│  └─ CtaButton.tsx
├─ next.config.mjs
├─ postcss.config.mjs
├─ tailwind.config.ts    # brand colors extended as a palette
├─ tsconfig.json
└─ package.json
```

## "Open Snippeter" links

The primary CTAs (`Open Snippeter`) currently point to `#` as a placeholder.
They are meant to launch the **deployed web app**. Search for `href="#"` and the
accompanying comments (e.g. in `components/Nav.tsx` and `components/Hero.tsx`),
then replace `#` with the production URL — for example
`https://app.snippeter.app` — once the web app is live.

## Deploy to Vercel

This site lives in the `landing/` subdirectory of a larger monorepo, so the
**root directory must be set to `landing`** in Vercel.

1. Push this repository to GitHub/GitLab/Bitbucket.
2. In the [Vercel dashboard](https://vercel.com/new), click **Add New → Project**
   and import the repository.
3. In **Configure Project**, set **Root Directory** to `landing`.
   (Click *Edit* next to Root Directory and select the `landing` folder.)
4. Vercel auto-detects **Next.js**. Leave the defaults:
   - **Framework Preset:** Next.js
   - **Build Command:** `next build`
   - **Output Directory:** `.next` (auto)
   - **Install Command:** `npm install` (auto)
5. Click **Deploy**.

### Deploy via the Vercel CLI (alternative)

```bash
npm i -g vercel
cd landing
vercel            # follow prompts; confirm the root is this directory
vercel --prod     # promote to production
```

## Design tokens

The brand palette is defined in `tailwind.config.ts`:

| Token              | Hex       | Tailwind class            |
| ------------------ | --------- | ------------------------- |
| Accent green       | `#16B378` | `accent` / `accent-green` |
| Teal               | `#12A594` | `accent-teal`             |
| Background         | `#0F1115` | `bg`                      |
| Surface            | `#161A21` | `surface`                 |
| Elevated surface   | `#1C212B` | `surface-elevated`        |
| Hairline border    | `#262B36` | `hairline`                |
| Text               | `#E6E9EF` | `ink`                     |
| Muted text         | `#8A93A2` | `muted`                   |

## Accessibility & performance notes

- Semantic landmarks (`header`, `main`, `nav`, `footer`), a skip-to-content link,
  and visible `focus-visible` rings throughout.
- `prefers-reduced-motion` disables animations and smooth scrolling.
- No third-party scripts, fonts self-hosted via `next/font`, all imagery is
  inline SVG/CSS — so the page is light and renders without network assets.

---

© 2026 Snippeter.
