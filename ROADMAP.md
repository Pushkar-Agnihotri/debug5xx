# Roadmap

What's done, what's left, and in what order. Update this file when a step is finished.

Goal: free posts that bring search traffic and email signups, then an ebook, then a paid skills bundle.

## Done (2026-09-23)

- [x] Lab repo [debug5xx-lab](https://github.com/Pushkar-Agnihotri/debug5xx-lab): keep-alive 502 lab (Node, Python, Go behind nginx). `./run.sh bug` gives 3-7% 502s, `./run.sh fix` gives 0%.
- [x] Post #1 live: https://debug5xx.pages.dev/blog/intermittent-502-load-balancer-keep-alive-timeout/
- [x] Hosting: Cloudflare Pages (free), auto-deploys on every push to `main`
- [x] Email launch list: Buttondown `pushkar` (free tier). One email per new post or book launch, no schedule.
- [x] Google Search Console: verified (HTML tag in `BaseHead.astro`), both sitemaps submitted
- [x] Bing Webmaster: imported from Search Console
- [x] IndexNow: key file in `public/`, first 3 URLs submitted (202 Accepted)

## Next (post #1)

- [ ] Bing Webmaster: submit `https://debug5xx.pages.dev/sitemap-index.xml` under Sitemaps
- [ ] Google Search Console: URL inspection, then Request indexing for the post (daily quota was hit on day 1)
- [ ] Share: Hacker News as a normal submission (not Show HN), r/node and r/devops (read each subreddit's rules first), 2-3 Stack Overflow answers to existing questions with the full answer in the body and a disclosed link
- [ ] About 1 week after launch: cross-post to dev.to with `canonical_url` pointing back here (draft kept outside the repo), then Hashnode with its original-URL setting

## Posts 2 and 3

Same flow each time: build a lab from scratch, run it, write the post from the lab's own numbers, run the anonymization check, publish, submit to IndexNow, share.

- [ ] Post #2: 502s on every deploy (preStop and load balancer connection draining race). Biggest audience.
- [ ] Post #3: "HTTP 200, half a body" (proxy truncates large responses) or "128KB argv limit breaks workflow steps"
- [ ] After 3 posts: compare views and signups. The winning topic sets the ebook title and focus.

## Ebook

- [ ] Write the book (working title: "When Every Log Says 200"), about 15-19 chapters, each backed by a lab
- [ ] Publish on Leanpub while in progress, then Amazon KDP when complete. Price about $29.
- [ ] Email the launch list on launch day

## Paid bundle

- [ ] Around month 3: $99 bundle on Gumroad with the ebook, generic Claude Code debugging skills and the lab scripts

## Optional

- [ ] Own domain (about $10/year). If added, redirect `debug5xx.pages.dev` and update `site` in `astro.config.mjs`, `public/robots.txt`, and Search Console.

## Rules that always apply

- Anonymize everything: no company, product, service or customer names, no IPs or internal hostnames, no numbers from real incidents. Every number comes from a lab run.
- Commits and pushes use the personal GitHub account and personal email only. The laptop's default `gh` must stay the work account.
