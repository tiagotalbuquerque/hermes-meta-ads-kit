---
name: meta-ads
description: "Meta Ads management and reporting — daily checks, campaign performance, creative fatigue, bleeders, winners. Uses a local adapter over Meta Ads CLI in mock/read-only/live-approved modes."
metadata:
  openclaw:
    emoji: "📣"
    user-invocable: true
    requires:
      tools: ["bash"]
      env: []
---

# Meta Ads — Your AI Ad Manager

Stop clicking through Ads Manager. This skill uses `./run.sh` + `./scripts/meta-kit.sh` to give you the five things that actually matter about your Meta campaigns — in plain text, every day.

The thesis: 90% of ad management is pattern recognition. Spend trending up or down. CTR declining (creative fatigue). CPA spiking (audience exhaustion). Winners emerging. Losers bleeding.

This skill spots the patterns. You make the calls.

Read `workspace/brand/` per the _vibe-system protocol

Follow all output formatting rules from the _vibe-system output format

---

## Brand Memory Integration

**Reads:** `stack.md`, `creative-kit.md`, `audience.md`, `learnings.md` (all optional)

| File | What it provides | How it shapes output |
|------|-----------------|---------------------|
| `workspace/brand/stack.md` | Stored ad account ID, target CPA/ROAS | Auto-fills account, benchmarks performance against targets |
| `workspace/brand/creative-kit.md` | Brand creative guidelines, assets | Context for creative recommendations |
| `workspace/brand/audience.md` | Target audience profiles | Interprets audience performance data |
| `workspace/brand/learnings.md` | Past performance patterns | Spots recurring issues — "this happened last month too" |

### Writes

| File | What it contains |
|------|-----------------|
| `workspace/brand/stack.md` | Stores ad account ID on first use |
| `workspace/brand/learnings.md` | Appends performance findings, fatigue patterns, winning creative traits |

---

## Setup (One Time)

### 1. Configure local adapter mode

```bash
cp .env.example .env
META_KIT_MODE=mock ./scripts/meta-kit.sh doctor
```

### 2. Set account/token in `.env` for non-mock runs

Use official Ads CLI variables: `ACCESS_TOKEN`, `AD_ACCOUNT_ID`, and optionally `BUSINESS_ID`. The kit still accepts `META_AD_ACCOUNT` / `META_SYSTEM_USER_ACCESS_TOKEN` aliases for backwards compatibility. Keep secrets out of git.

---

## Reports

### The 5 Daily Questions ← Start Here

The core of the system. Five questions that replace 20 minutes of Ads Manager clicking:

1. **Am I on track?** — Today's spend vs expectations
2. **What's running?** — Active campaigns at a glance
3. **How's performance?** — 7-day metrics by campaign
4. **Who's winning/losing?** — Ad-level performance sorted
5. **Any fatigue?** — CTR trends, frequency, CPC movement

```
Tell me: "Daily ads check"
Or: "Run the 5 questions on my ads"
Or: "How are my Meta ads doing?"
```

Script: `./run.sh daily-check`

### Overview

Account-level summary with campaign breakdown.

```
Tell me: "Meta ads overview for last 30 days"
```

Script: `./run.sh overview --preset last_30d`

### Campaigns

List campaigns, optionally filtered by status.

```
Tell me: "Show me active campaigns"
```

Script: `./run.sh campaigns --status ACTIVE`

### Top Creatives

Ad-level performance ranked by results.

```
Tell me: "What are my best performing ads?"
```

Script: `./run.sh winners --preset last_7d`

### Bleeders 🩸

Ads with high spend but poor performance — candidates for pause. Flags ads with CTR < 1% or frequency > 3.5.

```
Tell me: "Any ads bleeding money?"
Or: "Find underperforming ads"
```

Script: `./run.sh bleeders --preset last_7d`

### Winners 🏆

Top performing ads by CTR and efficiency. These are your scale candidates.

```
Tell me: "Which ads should I scale?"
Or: "Show me the winners"
```

Script: `./run.sh winners --preset last_7d`

### Fatigue Check 😴

Daily breakdown to spot creative fatigue — CTR declining day-over-day, frequency climbing, CPC rising.

```
Tell me: "Any creative fatigue?"
Or: "Check for ad fatigue"
```

Script: `./run.sh fatigue`

### Custom

Full control. Specify level, fields, breakdowns.

```
Tell me: "Show me ad performance broken down by age and gender"
```

Script: `meta --output json --no-input ads insights get --breakdown age --breakdown gender --fields spend,impressions,ctr,cpc` once read-only CLI auth is configured.

---

## Date Presets

- `today` — Today only
- `yesterday` — Yesterday only
- `last_7d` — Last 7 days (default for most reports)
- `last_30d` — Last 30 days
- `last_90d` — Last 90 days

---

## Actions (Use With Care)

Beyond reporting, official Ads CLI can create/update/delete resources. In this kit, mutating actions are blocked unless they go through dry-run + explicit approval.

### Prepare an ad create dry run
```bash
META_KIT_MODE=mock ./scripts/meta-kit.sh create-ad --payload examples/create-ad.json --dry-run
```

**Safety:** All mutating actions are high-risk and require confirmation. The skill should ALWAYS present findings and recommendations first, write a dry-run artifact for proposed changes, then ask for explicit approval before any live action.

---

## The AI Ad Manager Workflow

This is the system from the newsletter. Here's how it works in practice:

**Morning (automated via cron):**
1. Run daily-check
2. Flag bleeders (CTR < 1%, frequency > 3.5, CPA > threshold)
3. Flag winners (top CTR, low CPC, scaling headroom)
4. Send summary to Telegram/Slack

**You (2 minutes over coffee):**
1. Read the summary
2. Approve/reject recommendations
3. Ask follow-up questions if needed

**The AI (on approval):**
1. Generates exact dry-run artifacts for confirmed changes
2. Requires `META_KIT_MODE=live-approved` + `META_KIT_APPROVAL_ID` before live mutation
3. Keeps new creates PAUSED-only
4. Logs decisions to learnings.md

---

## Invocation

When the user asks about Meta ads, Facebook ads, Instagram ads, or campaign performance:

1. Check `workspace/brand/stack.md` for stored ad account ID
2. Check `AD_ACCOUNT_ID` / `META_AD_ACCOUNT` env vars
3. If neither, run `./scripts/meta-kit.sh doctor`; after auth, `meta ads adaccount list` can list accounts
4. Run the appropriate `./run.sh` report
5. Interpret results in context of brand goals (from stack.md/learnings.md)
6. For bleeders/winners, present clear recommendations with reasoning
7. **Never take action without explicit user approval**
8. Log findings to `workspace/brand/learnings.md`

### The 5 Daily Questions (Detailed)

When running daily-check, frame the output around these questions:

1. **"Am I on track?"** — Compare today's spend rate to daily budget. If pacing high or low, flag it.
2. **"What's running?"** — List active campaigns with status. Flag any that should be off.
3. **"How's the last 7 days?"** — Campaign-level metrics. Compare to previous 7 if available.
4. **"Who's winning and who's losing?"** — Ad-level sort. Top 3 winners, bottom 3 losers with specific metrics.
5. **"Any fatigue signals?"** — Frequency trends, CTR day-over-day, CPC movement. Concrete numbers, not vibes.

---

## Next Up

- **`/ga4-report`** — See what Meta traffic actually does on your site. Pair with ads data to find true ROAS.
- **`/gsc-report`** — Cross-reference paid vs organic. Are you paying for traffic you'd get free?
- **`/creative`** — Generate new ad creatives when fatigue hits. Feed winning patterns into new concepts.
- **`/direct-response-copy`** — Write ad copy based on what's actually converting.
