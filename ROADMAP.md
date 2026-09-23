# Roadmap and handover

**Start here if you are picking this project up in a new session.** This file says what is done, what is pending (with exact steps), why decisions were made, and what to build next. `CLAUDE.md` explains how the repo is wired; this file explains the plan.

Last updated: 2026-09-23 (end of setup session).

---

## 1. The goal in one paragraph

Build a small passive income from the owner's expertise in debugging production errors (Kubernetes, cloud load balancers, proxies, job schedulers). Free blog posts bring search traffic and email signups. The paid products come later: an ebook (~$29) and then a bundle (~$99). The blog itself earns $0 directly; its job is to bring buyers to the paid products.

```
Free post ──▶ search traffic ──▶ email signup ──▶ ebook $29 ──▶ bundle $99
 (live)        (weeks–months)    (launch list)    (month 2–3)    (month 3+)
```

Realistic expectation (from market research, see section 6): month 1 earns $0. A niche technical book like this typically sells 100–500 copies in year 1 (~$3K–15K) and keeps selling after that.

---

## 2. Current status (as of 2026-09-23)

| Piece | Status | Where / how |
|---|---|---|
| Lab repo | ✅ Live | https://github.com/Pushkar-Agnihotri/debug5xx-lab (MIT) |
| Blog repo | ✅ Live | https://github.com/Pushkar-Agnihotri/debug5xx |
| Site | ✅ Live | https://debug5xx.pages.dev (Cloudflare Pages, free, auto-deploy on push to `main`) |
| Post #1 | ✅ Published | https://debug5xx.pages.dev/blog/intermittent-502-load-balancer-keep-alive-timeout/ |
| Email launch list | ✅ Wired | Buttondown user `pushkar` (free tier, 100 subscribers). Form in `src/components/Subscribe.astro` |
| Google Search Console | ✅ Verified | URL-prefix property, HTML meta tag in `BaseHead.astro`. Sitemaps submitted (showed "Couldn't fetch" on day 1, which is normal for new sites; the files return 200 to Googlebot) |
| Google indexing request | ❌ Pending | Hit "Quota exceeded" on day 1. Retry (see 3.1) |
| Bing Webmaster | ✅ Imported from Google | Sitemap submission in Bing still pending (see 3.1) |
| IndexNow | ✅ 3 URLs submitted (202) | `scripts/indexnow.sh` |
| Sharing (HN, Reddit, Stack Overflow) | ❌ Not started | See 3.2 |
| dev.to cross-post | ❌ Draft ready, not posted | `~/personal/drafts/devto-keepalive-502.md` (outside the repo). Post ~1 week after launch |
| Post #2, #3 | ❌ Not started | See section 4 |
| Ebook, bundle | ❌ Not started | See section 5 |

---

## 3. Pending work for post #1 (do these first)

### 3.1 Indexing (owner does it in the browser; ~5 minutes)

1. **Google:** Search Console → URL inspection → paste
   `https://debug5xx.pages.dev/blog/intermittent-502-load-balancer-keep-alive-timeout/` → **Request indexing**.
   If it says "Quota exceeded", try the next day. New properties get a tiny quota.
2. **Bing:** Bing Webmaster Tools → Sitemaps → submit `https://debug5xx.pages.dev/sitemap-index.xml`. Optionally URL Submission → paste the post URL.
3. **Check after 2–3 days:** Search Console → Sitemaps should show "Success". Pages → the post should be "Indexed". If not, check with URL inspection → "Test live URL".

### 3.2 Sharing (Claude drafts, owner posts from their own accounts)

Nothing is drafted yet. Research-backed rules for each channel:

| Channel | How | Rules that matter |
|---|---|---|
| **Hacker News** | Normal submission (NOT Show HN; Show HN is for things people can run, not blog posts). Use the post's plain title, submit the pages.dev URL | Weekdays 06–12 UTC have less competition. Stay available ~2–3 hours to answer comments. Never ask for upvotes. A repost after a few days is allowed if it gets no traction |
| **Reddit** r/node, r/devops (maybe r/kubernetes, r/FastAPI) | Text post: TL;DR plus the key finding, link at the end | Read each subreddit's self-promotion rules first. Some route blog links to a weekly thread. Disclose it's your post |
| **Stack Overflow** | Answer 2–3 **existing** questions about ALB/nginx 502 + keepAliveTimeout, uvicorn keep-alive, "upstream prematurely closed connection" | The full answer must be in the body; the link is extra. Disclose that you wrote the post. Link-only answers get deleted |
| **Lab repo** | Already has topics (load-balancer, nginx, 502, keep-alive, aws-alb, gcp, sre) | Could later be added to awesome-lists (awesome-sre, awesome-nginx) via PR |

Suggested HN title: `Random 502s behind your load balancer? Check your keep-alive timeout`

### 3.3 Cross-posting (~1 week after launch)

- dev.to: paste `~/personal/drafts/devto-keepalive-502.md` (frontmatter already has `canonical_url` pointing to the pages.dev URL and `published: false`). Set the AI-disclosure option honestly (the post was written with AI assistance and verified by hand).
- Hashnode: import, set "Are you republishing?" to the original URL.
- Medium: optional, only via "Import a story" (keeps the canonical link).

Why wait a week: Google should index the original first, or the dev.to copy may outrank it.

---

## 4. Post pipeline (what to write next)

Same process for every post:

1. Build the lab from scratch in `debug5xx-lab` (see its CLAUDE.md for conventions). Run `bug` and `fix`, keep the real output.
2. Write the post from the lab's numbers only (structure and style in `CLAUDE.md` → "Writing a new post").
3. Verify every version-specific fact by running it.
4. `npm run build`, `scripts/anonymize-check.sh` in both repos, push.
5. `scripts/indexnow.sh /blog/<slug>/`, then request indexing in Search Console.
6. Share (3.2) and cross-post a week later (3.3).
7. Add the lab to the table in `debug5xx-lab/README.md` and `debug5xx-lab/CLAUDE.md`.

### Ranked queue

Ranked by how many engineers hit the problem and search for it, not by how interesting it is.

| # | Topic | Lab idea | Why this rank |
|---|---|---|---|
| **2** | **502/503 on every deploy**: pods are killed while the load balancer still sends them traffic (preStop hook and termination grace period shorter than the load balancer's connection draining time) | kind cluster or compose: nginx upstream + app with rolling restarts. `bug` = no preStop sleep; `fix` = preStop sleep longer than the drain time plus a grace period longer than preStop. Count errors during restarts | Almost every Kubernetes team behind a cloud load balancer hits it. "502 during rolling update" is heavily searched |
| 3 | **Retries that create duplicate rows**: a client retries a non-idempotent POST after a stale pooled connection dies | App with a counter, a client with retries on, force stale connections. `fix` = retry only on connect errors, or idempotency keys | Universal backend problem; data corruption is scary |
| 4 | **HTTP 200 with half a body**: a proxy sends `Connection: close` upstream and large responses get truncated while the status stays 200 | Proxy with close mode vs keep-alive mode in front of a slow, large-response backend; count truncated bodies | Most shareable title; smaller search audience |
| 5 | **Cloud NAT port exhaustion**: outbound connections time out at peak, and the obvious "allocation failed" metric stays at 0 | Hard to fully reproduce locally; could simulate with a conntrack/port-limited NAT container | "The metric lies" hook |
| 6 | **The invisible 504**: a CDN's origin timeout is shorter than a slow backend query, so the 504 never appears in origin logs | Proxy with a 5s timeout in front of an app that sometimes takes 8s | Good hook, moderate reach |
| 7 | **128KB argument limit breaks workflow steps**: the Linux per-argument limit (MAX_ARG_STRLEN) kills container steps that pass large payloads as args ("argument list too long", exit with an empty log) | Container that runs a command with an argument over 128KB, then with gzip+base64 | Great curiosity factor for HN; niche |
| 8+ | Spot/preemptible nodes killing job exit handlers; workflow controller throttling at scale; Kafka consumers that look healthy but process nothing; Elasticsearch drowning in tiny shards | Deeper, smaller audience; better as ebook chapters | |

After 3 posts, compare Search Console clicks, dev.to views and Buttondown signups. The winning topic sets the ebook's title and focus.

---

## 5. Paid products (not started)

### 5.1 Ebook

- **Working title:** "When Every Log Says 200: production incidents on Kubernetes and the cloud". Alternative if the load balancer posts win: "Hidden 5xx".
- **Where:** Leanpub first, **while the book is still being written** (readers can buy early chapters, so this is the fastest first dollar, around month 2). Then Amazon KDP once it's complete (Amazon is the biggest channel for technical books). Both marketplaces bring their own buyers, which Gumroad does not.
- **Price:** ~$29.
- **Draft outline** (each chapter backed by a lab, all anonymized):
  1. The request path lies: keep-alive 502s, deploy-time 502s, the invisible CDN 504, proxy truncation
  2. The network runs out: NAT port exhaustion, retry storms and duplicate writes
  3. Spot nodes and the status that never arrived: preempted jobs, exit handlers, forensics after the evidence is gone
  4. Workflow engines at scale: lost cron ticks, controller throttling, the 128KB argument limit
  5. State, data and config: truncated secrets, stale ORM caches, Kafka commit mistakes, Elasticsearch shards
  6. Observability that misleads: alerts that lie, lossy logs, absence of a log line proves nothing
  7. Appendix: runbooks and checklists; running AI agents safely (read-only) on production
- **Launch:** email the Buttondown list once, on launch day.

### 5.2 Bundle (~month 3)

- **$99 on Gumroad:** the ebook, generic Claude Code debugging skills (load balancer log decoding, HTTP client connection-failure diagnosis, evidence-first debugging method), and the lab scripts.
- The skills must be rewritten generically. No hostnames, internal tools or company-specific steps.

---

## 6. Why these decisions (research summary)

Research done on 2026-09-23 (several web research passes):

- **Why a book and not selling skills or MCP servers directly:** the most-installed Claude skills and MCP servers are free and vendor-made. The median paid skill listing earns under $50/month. What does sell is production incident playbooks with tools bundled in. Verified Gumroad sales counts: a $249 backend incident playbook had 135 sales and a $99 production engineering library had 121.
- **Why lab-backed incident stories:** generic runbooks are free everywhere (one open repo has 400+). Real incidents with proof are rare. AI is also eroding information-only products, so hands-on labs and real debugging stories are the defensible part.
- **Why not Udemy, a paid newsletter, or GCP cost content:** Udemy pays about $3.70 per sale. A paid newsletter is weekly work, not passive. Cloud cost content is saturated with free vendor blogs.
- **Why "debug5xx":** keyword-in-domain barely affects ranking. The name is short, memorable and uses a term engineers search.
- **Why Cloudflare Pages via the legacy Pages flow:** free, fast, and the Workers flow would give a long `*.workers.dev` URL.
- **Why a launch list, not a newsletter:** the owner can't commit to a schedule. Email still drives a large share of product sales, so collect emails and send only on launches.
- **Why start with keep-alive 502s:** biggest searched audience among the story candidates, easiest to reproduce, and proxy-agnostic (hits AWS ALB, GCP, nginx and Envoy users alike). HAProxy was ruled out as the lab proxy because it is under 0.1% of public web servers.
- **Distribution:** no LinkedIn (owner's choice). Search, Hacker News, Reddit, Stack Overflow and dev.to instead.
- **SEO reality:** new domains usually take months to rank. Exact-error-string searches can rank in weeks. No one can guarantee #1.

---

## 7. Gotchas already hit (don't repeat them)

- **Two GitHub accounts on one laptop.** A keychain-based `gh auth login` for the personal account overwrote the shared default token, so the machine's default `gh` silently acted as the personal account. Fixed by storing the personal token in `~/.config/gh-personal/hosts.yml` (file storage) and switching the default back. See `CLAUDE.md` → Hard rules.
- **Search Console on day 1:** "Couldn't fetch" on sitemaps and "Quota exceeded" on Request indexing are both normal for a brand-new property. Verify with curl as Googlebot and retry the next day.
- **Races don't reproduce on localhost:** the network is too fast. Add `tc netem` latency (see the lab's `latency` service).
- **Node `keepAliveTimeoutBuffer`:** Node 24 closes idle sockets about 1s after `keepAliveTimeout`.
- **Don't trust research claims about versions:** the "Node 26 = 65s default" claim was wrong. Run it and check.

---

## 8. Accounts and services (no secrets here)

| Service | Account | Used for |
|---|---|---|
| GitHub | `Pushkar-Agnihotri` (personal Gmail) | Both repos |
| Cloudflare | personal Gmail | Pages project `debug5xx` |
| Buttondown | `pushkar` | Launch list |
| Google Search Console | personal Gmail | URL-prefix property `https://debug5xx.pages.dev/` |
| Bing Webmaster | signed in with Google | Imported property |

Paid so far: $0.

---

## 9. Metrics to watch (monthly)

- Search Console → Performance: impressions, clicks, and **which queries** bring impressions. Rewrite headings to match real queries.
- Bing Webmaster → Search Performance and AI Performance (citations in Copilot).
- Buttondown subscriber count.
- dev.to views and reactions per post.
- GitHub stars on the lab repo.

---

## 10. How to resume in a new session

Tell Claude something like: *"Continue the debug5xx project. Read `~/personal/blog/ROADMAP.md` and `CLAUDE.md` first."* Then pick the first unchecked item:

- [ ] 3.1 Google Request indexing + Bing sitemap (owner, browser)
- [ ] 3.2 Draft HN, Reddit and Stack Overflow posts (Claude drafts, owner posts)
- [ ] 3.3 dev.to and Hashnode cross-post (~2026-09-30)
- [ ] 4 Post #2: 502s on every deploy
- [ ] 4 Post #3
- [ ] 4 Compare metrics, pick the ebook focus
- [ ] 5.1 Leanpub page with the first chapters (early sales)
- [ ] 5.1 Finish the ebook, publish on Amazon KDP, email the list
- [ ] 5.2 $99 bundle
- [ ] Optional: custom domain (about $10/year); update `astro.config.mjs`, `public/robots.txt`, Search Console, redirect pages.dev

Update this file (status table and checkboxes) at the end of every session.
