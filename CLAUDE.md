# CLAUDE.md: debug5xx blog

Read this first. It explains what this repo is, how it is wired, and the rules for changing it.

**Plan, status and pending work:** see [ROADMAP.md](ROADMAP.md) (what's done, what's next, why).

## What and why

- **What:** a static blog at https://debug5xx.pages.dev about production errors where the logs look clean but users see 5xx (502s, 504s, timeouts).
- **Why:** the long-term plan is free posts → an email launch list → a paid ebook of incident write-ups (and later a bundle of Claude Code debugging skills). Posts are the free top of that funnel; every post should earn search traffic and email signups.
- **Companion repo:** https://github.com/Pushkar-Agnihotri/debug5xx-lab. Every post has a runnable lab there. Numbers in posts come from those labs.

## How it is wired

```
src/content/blog/*.md ──git push main──▶ GitHub (Pushkar-Agnihotri/debug5xx)
                                           │ Cloudflare Pages Git integration
                                           ▼
                          Cloudflare builds: npm run build → dist/
                                           ▼
                          https://debug5xx.pages.dev  (free *.pages.dev, no custom domain yet)
```

| Piece | Where | Notes |
|---|---|---|
| Framework | Astro (blog template, trimmed) | Static HTML, no client JS. Node version pinned in `.node-version` (24); Astro needs >= 22.12. |
| Hosting | Cloudflare Pages project `debug5xx` | Auto-deploys every push to `main`, usually live in ~1 minute. Build command `npm run build`, output `dist`, preset Astro. Created via the legacy "Pages" flow, not Workers (Workers would give an ugly `*.workers.dev` URL). |
| Site settings | `src/consts.ts` | Title, author, GitHub user, lab repo URL, Buttondown user. Change things here, not in components. |
| Site URL | `astro.config.mjs` (`site`) and `public/robots.txt` | Both say `https://debug5xx.pages.dev`. If a custom domain is bought, change both, then add the domain in Cloudflare and redirect the old address. |
| Email list | `src/components/Subscribe.astro` → Buttondown user `pushkar` | A **launch list**, not a newsletter: one email per new post or ebook. No schedule is promised. Free tier: 100 subscribers. |
| Google Search Console | `<meta name="google-site-verification">` in `src/components/BaseHead.astro` | **Do not remove it**: Google un-verifies the site. Property type is URL prefix (a Domain property needs DNS, which pages.dev doesn't allow). Sitemaps submitted: `sitemap-index.xml`, `sitemap-0.xml`. |
| Bing | Imported from Google Search Console | ChatGPT search and Copilot use Bing's index, so Bing matters. |
| IndexNow | `public/<key>.txt` + `.indexnow-key` + `scripts/indexnow.sh` | Instantly notifies Bing and others of new URLs. The key file must stay published. |
| SEO per post | `src/layouts/BlogPost.astro` | Emits `<title>` from `seoTitle` (falls back to `title`), meta description, canonical URL, Open Graph, and TechArticle JSON-LD. |
| Sitemap / RSS | `@astrojs/sitemap`, `src/pages/rss.xml.js` | Generated on build. |

## Writing a new post

1. Build and verify the lab first in `debug5xx-lab` (`run.sh bug` shows the error, `run.sh fix` shows 0 errors).
2. Add `src/content/blog/<slug>.md`. The slug is the URL, so use the searched phrase (e.g. `intermittent-502-load-balancer-keep-alive-timeout`), no dates.
3. Frontmatter:
   ```yaml
   title: "Human headline shown on the page"
   seoTitle: "≤60 chars, exact search phrase first"   # optional
   description: "≤155 chars: symptom + cause + fix"
   pubDate: YYYY-MM-DD
   updatedDate: YYYY-MM-DD   # set when facts change
   ```
4. Structure that works: TL;DR first → symptom with the **exact error strings** → why it happens (diagram in `public/images/`, with descriptive alt text) → a defaults table → reproduce it (link the lab, paste real output) → the fix per language → a checklist → one-line "what I'd tell my younger self".
5. Style:
   - Simple enough for a fresher.
   - First person, short paragraphs.
   - Every claim gets a number or a source.
   - No AI-sounding filler ("delve", "landscape", "not only X but Y", em-dash chains).
   - No sales pitch in the body. The layout adds the subscribe box.
6. Verify every version-specific fact by running it. Example from post #1: the claim "Node 26 defaults keepAliveTimeout to 65s" was **false** (26.10 still ships 5s; the change is only merged upstream in nodejs/node#62782). Node 24 also has `keepAliveTimeoutBuffer` = 1000 ms.
7. Run `npm run build`, then `scripts/anonymize-check.sh`, then push.
8. After it is live: `scripts/indexnow.sh /blog/<slug>/`, then Search Console → URL inspection → Request indexing (a new property has a small daily quota; retry the next day if "Quota exceeded").
9. About a week later, cross-post to dev.to / Hashnode with `canonical_url` pointing to the pages.dev URL (drafts are kept outside this repo in `~/personal/drafts`). Submit to Hacker News as a normal post, not Show HN.

## Hard rules

- **Anonymize everything.** No employer, customer or internal service names, no IPs, no internal hostnames, no real incident numbers. Reproduce everything in the lab instead. `scripts/anonymize-check.sh` scans tracked files against a **private** pattern list at `~/personal/.anonymize-patterns`, which is kept outside the repo because the list itself would reveal what is being hidden. Never commit that list, and never paste its contents into this repo.
- **Personal identity only.** The repo-local git config uses the personal Gmail. The global git config on this machine belongs to a different account, so never rely on it and never change it.
- **GitHub auth.** The personal `gh` login lives only in `GH_CONFIG_DIR=~/.config/gh-personal` (file storage, not the macOS keychain). The machine's default `gh` must stay on the other account: never run `gh auth login` / `gh auth switch` without `GH_CONFIG_DIR`, and after any personal `gh` action check that `gh api user` still returns the default account. `git push` works through a repo-local `credential.helper` that reads the personal token, so plain `git push` is enough.
- **Keep it simple.** No new frameworks, trackers or client-side JS without a reason. Fast static pages rank better.

## Commands

```bash
npm install
npm run dev                     # http://localhost:4321
npm run build                   # output in dist/
scripts/anonymize-check.sh      # must print "clean" before any push
scripts/indexnow.sh /blog/<slug>/
```
