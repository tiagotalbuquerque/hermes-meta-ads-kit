# Hermes Meta Ads Kit — Full Spec

**Status:** Hermes adaptation v1.0
**Base project:** [`TheMattBerman/meta-ads-kit`](https://github.com/TheMattBerman/meta-ads-kit)
**Framework:** [Hermes Agent](https://github.com/NousResearch/hermes-agent)

---

## Overview

A Hermes Agent-powered Meta Ads manager that replaces daily Ads Manager sessions with AI-generated briefings and recommendations.

**The promise:** authenticate a Meta ad account → ask Hermes for a daily briefing → get bleeders, winners, fatigue alerts, budget recommendations, copy ideas, upload dry-runs, and Pixel/CAPI diagnostics → approve any spend-affecting actions explicitly.

**Target users:**

- Founders running their own Meta ads
- Small marketing teams without a dedicated media buyer
- Agency operators managing multiple accounts
- Anyone tired of clicking through Ads Manager

---

## System Architecture

```text
┌────────────────────────────────────────────────────────────────────┐
│                   HERMES META ADS KIT                              │
│                                                                    │
│  Hermes Agent                                                      │
│  ├─ skills loader: meta-ads, creative monitor, budget optimizer     │
│  ├─ terminal/file/vision tools for scripts, docs, and creative QA   │
│  ├─ cron for daily briefings                                       │
│  ├─ gateway for Telegram/Discord/Slack/etc. delivery               │
│  └─ memory/session_search/skills for durable learning              │
│                                                                    │
│           ▼                                                        │
│  Repository scripts + skill instructions                           │
│           ▼                                                        │
│  social-cli + direct Graph API calls where needed                  │
│           ▼                                                        │
│  Meta Marketing API                                                │
└────────────────────────────────────────────────────────────────────┘
```

---

## Skills

### Skill 1: `meta-ads`

**Purpose:** daily reporting and ad management recommendations.

Reports:

- Daily check / 5 Daily Questions
- Account overview
- Campaign listing
- Top creatives
- Bleeders
- Winners
- Fatigue check
- Custom reports with breakdowns

Actions, requiring approval:

- Pause/resume ad, ad set, or campaign
- Adjust budget

### Skill 2: `ad-creative-monitor`

**Purpose:** track creative health over time.

Capabilities:

- Day-over-day CTR tracking
- Frequency creep detection
- CPC inflation alerts
- Creative lifespan estimation
- Rotation recommendations

### Skill 3: `budget-optimizer`

**Purpose:** spend efficiency analysis.

Capabilities:

- Campaign/ad set efficiency ranking
- Budget shift recommendations
- Spend pacing checks
- ROI comparison across campaigns where conversion values exist

### Skill 4: `ad-copy-generator`

**Purpose:** generate ad copy matched to specific image creatives.

Capabilities:

- Analyze image creative via Hermes vision tools when available
- Cross-reference account performance data for winning copy patterns
- Generate 3-5 headline variants and 3-5 body variants
- Output `asset_feed_spec`-ready copy
- Apply brand voice from `workspace/brand/voice-profile.md`
- Rotate psychological levers across variants

### Skill 5: `ad-upload`

**Purpose:** push reviewed ads to Meta via Graph API without Ads Manager.

Capabilities:

- Validate copy and image payloads
- Upload images to Meta ad account and return image hashes
- Build `asset_feed_spec` creatives
- Create ads in existing ad sets
- Support dry-run mode before API mutation
- Log creative/ad IDs locally

### Skill 6: `pixel-capi`

**Purpose:** audit and improve Meta Pixel + Conversions API setup.

Capabilities:

- Pixel/CAPI setup audit
- Server-side event tests
- Event Match Quality review
- Platform guidance for Next.js, Shopify, WordPress, Webflow, GHL, ClickFunnels

---

## Data Flow

### Morning Briefing (Automated)

1. Hermes cron triggers a self-contained prompt.
2. Hermes loads relevant skills.
3. Hermes runs `./run.sh daily-check` in the repository.
4. Scripts pull insights via `social-cli`.
5. Hermes analyzes spend pacing, active campaigns, 7-day trends, bleeders, winners, and fatigue signals.
6. Hermes delivers the summary through the configured channel.
7. Hermes waits for user approval before any action that affects spend/delivery.

### On-Demand (Interactive)

1. User asks naturally (`how are my ads?`, `any bleeders?`, etc.).
2. Hermes selects relevant skills/scripts.
3. Hermes runs read-only reports or dry-runs automatically.
4. Hermes interprets results against `ad-config.json` and `workspace/brand/` context.
5. Hermes presents findings with evidence and recommended next actions.
6. If action is requested, Hermes confirms exact scope before execution.

---

## Benchmarks & Thresholds

Default thresholds are configurable in `ad-config.json`:

| Metric | Default | Purpose |
|--------|---------|---------|
| Bleeder CTR | < 1.0% | Flag underperforming ads |
| Max frequency | > 3.5 | Detect creative fatigue |
| Fatigue CTR drop | > 20% over 3 days | Early fatigue warning |
| Spend pace alert | ±15% of planned pace | Over/underspend warning |
| Target CPA | $25.00 | Campaign efficiency target |
| Target ROAS | 3.0x | Return on ad spend target |

---

## Safety Model

### Read-Only by Default

Reporting, analysis, copy drafts, audits, and dry-run validations can run automatically.

### Actions Require Approval

Any action that affects spend or delivery requires explicit user confirmation:

- Pausing/resuming ads, ad sets, or campaigns
- Budget changes
- Uploading/publishing live ads
- Creating/updating live creatives

### Audit Trail

Every approved action should be logged to `workspace/brand/learnings.md` or `memory/YYYY-MM-DD.md` with:

- Timestamp
- What changed
- Why it changed
- Evidence used
- Who approved it

---

## Hermes-Specific Capabilities

- **Skills:** reusable procedural knowledge, installed from `skills/*/SKILL.md`.
- **Cron:** scheduled daily/weekly briefings.
- **Gateway:** delivery and approval flow through messaging platforms.
- **Vision:** creative analysis for image-matched copy.
- **Memory/session search:** durable account learnings and past decision recall, used carefully.
- **Profiles:** separate skill/config homes for agencies or multiple operators.

---

## Roadmap

- [ ] Multi-account agency mode with account selector and per-account benchmark files
- [ ] Better structured JSON output for all reports
- [ ] Automated A/B test detection and analysis
- [ ] Creative performance dashboard generated from report history
- [ ] More robust upload dry-run validator
- [ ] Hermes cron templates and gateway approval message templates
- [ ] Google Ads support when a stable CLI/API abstraction is available
