# Hermes Meta Ads Kit

A Hermes Agent skill pack for managing Meta Ads from the terminal/chat: daily checks, bleeders, winners, fatigue detection, budget recommendations, ad copy generation, ad upload, and Pixel/CAPI audits.

Forked and adapted from [`TheMattBerman/meta-ads-kit`](https://github.com/TheMattBerman/meta-ads-kit). This fork replaces OpenClaw-specific setup with Hermes Agent skills, installation scripts, cron/gateway usage, and Hermes-oriented documentation.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hermes Agent](https://img.shields.io/badge/Built%20for-Hermes%20Agent-7c3aed)](https://github.com/NousResearch/hermes-agent)

---

**Monitor → Detect Fatigue → Find Winners → Shift Budget → Generate Copy → Upload to Meta → Audit Pixel/CAPI → Repeat**

This kit automates the Meta Ads management loop:

- **Morning briefing** — spend pacing, active campaigns, 7-day trends
- **Find bleeders** — ads with high spend + weak CTR/CPA/frequency signals
- **Spot winners** — top performers ready to scale
- **Detect fatigue** — CTR declining, frequency climbing, CPC rising
- **Generate copy** — Hermes writes ad copy matched to actual image creatives
- **Upload to Meta** — push reviewed ads through Graph API
- **Pixel + CAPI audit** — audit tracking, test server-side events, optimize Event Match Quality
- **Take action** — pause, resume, adjust budgets, or publish ads only after explicit approval

---

## Quick Start

```bash
git clone https://github.com/tiagotalbuquerque/hermes-meta-ads-kit.git
cd hermes-meta-ads-kit

# Install social-cli, the Meta Marketing API wrapper used by the scripts
npm install -g @vishalgojha/social-cli

# Authenticate with Meta
social auth login

# Set your default ad account
social marketing accounts
social marketing set-default-account act_YOUR_ACCOUNT_ID

# Copy local config
cp .env.example .env
cp ad-config.example.json ad-config.json

# Install this multi-skill pack into Hermes
chmod +x scripts/install-hermes-skills.sh
scripts/install-hermes-skills.sh
```

Start Hermes with the core ads skills:

```bash
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer
```

Or load the full pack:

```bash
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer -s ad-copy-generator -s ad-upload -s pixel-capi
```

Then ask:

```text
Daily ads check
```

See [`SETUP.md`](SETUP.md) for detailed setup and [`HERMES.md`](HERMES.md) for Hermes-specific installation, cron, gateway, and safety notes.

---

## The 5 Daily Questions

The core of the system. Five questions that replace Ads Manager clicking:

| # | Question | What It Tells You |
|---|----------|-------------------|
| 1 | Am I on track? | Today's spend vs. pacing expectations |
| 2 | What's running? | Active campaigns at a glance |
| 3 | How's performance? | 7-day metrics by campaign |
| 4 | Who's winning/losing? | Ad-level performance sorted |
| 5 | Any fatigue? | CTR trends, frequency, CPC movement |

Run directly:

```bash
./run.sh daily-check
```

Run through Hermes:

```bash
hermes -s meta-ads -q "In this repo, run a daily Meta ads check and summarize the 5 daily questions. Do not take any spend-affecting action."
```

---

## Skills

| Skill | What It Does |
|-------|-------------|
| `meta-ads` | Core reporting — daily checks, campaign insights, bleeders, winners, fatigue detection |
| `ad-creative-monitor` | Tracks creative performance over time and flags fatigue before it kills ROAS |
| `budget-optimizer` | Analyzes spend efficiency and recommends budget shifts between campaigns/ad sets |
| `ad-copy-generator` | Generates image-matched Meta ad copy and `asset_feed_spec`-ready variants |
| `ad-upload` | Uploads images/copy to Meta via Graph API after review and approval |
| `pixel-capi` | Audits Meta Pixel + Conversions API setup, tests server events, and improves EMQ |

Each skill can run standalone or as part of the daily routine.

### Install the Skill Pack

This repository contains multiple Hermes skills, so use the included installer instead of installing only a root `SKILL.md`:

```bash
scripts/install-hermes-skills.sh
```

Destination:

```text
${HERMES_HOME:-~/.hermes}/skills/marketing/<skill-name>/
```

After installing into a running Hermes session, use `/reset` or start a new session so the skills appear in the loaded skill list.

---

## The Full Loop

```text
Monitor (meta-ads) → Detect fatigue (ad-creative-monitor) → Shift budget (budget-optimizer)
    → Generate new copy (ad-copy-generator) → Upload to Meta (ad-upload) → Monitor again

Pixel + CAPI (pixel-capi) runs alongside: audit tracking, test server events, optimize EMQ
```

No Ads Manager required for analysis; live actions still require explicit human approval.

---

## Running With Hermes Agent

Hermes is the orchestration layer for this fork.

```bash
# Install Hermes if needed
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# Verify Hermes
hermes doctor

# Start with this skill pack
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer
```

Ask naturally:

- `How are my ads doing?`
- `Any bleeders I should pause?`
- `Which ads should I scale?`
- `Check for creative fatigue`
- `Show me performance by age and gender`
- `Write copy for this image`
- `Dry-run upload for these ads`

Hermes handles orchestration, tool use, data interpretation, memory/skills, gateway delivery, and cron scheduling.

### Automate Morning Briefings

Before creating a recurring job, check existing jobs to avoid duplicates:

```bash
hermes cron list
```

Then create a daily briefing from Hermes:

```text
Run my Meta ads daily check every morning at 8am and send me the summary. Do not pause, resume, upload, or change budgets; only recommend actions for approval.
```

Hermes can deliver the briefing through configured gateway platforms such as Telegram, Discord, Slack, WhatsApp, Signal, Matrix, or email.

---

## Configuration

Edit `ad-config.json` to set benchmarks:

```json
{
  "account": {
    "id": "act_123456789",
    "name": "My Brand"
  },
  "benchmarks": {
    "target_cpa": 25.00,
    "target_roas": 3.0,
    "max_frequency": 3.5,
    "min_ctr": 1.0,
    "max_cpc": 2.50
  },
  "alerts": {
    "bleeder_ctr_threshold": 1.0,
    "bleeder_frequency_threshold": 3.5,
    "fatigue_ctr_drop_pct": 20,
    "spend_pace_alert_pct": 15
  },
  "reporting": {
    "default_preset": "last_7d",
    "timezone": "America/Sao_Paulo"
  }
}
```

You can also keep account/brand context under `workspace/brand/`:

```text
workspace/brand/stack.md
workspace/brand/voice-profile.md
workspace/brand/audience.md
workspace/brand/learnings.md
```

---

## Safety Model

Read-only operations can run without extra confirmation:

- Reports and insights
- Fatigue checks
- Budget recommendations
- Copy drafts
- Dry-run payload validation
- Pixel/CAPI audits that do not mutate production settings

Actions that affect spend or delivery require explicit approval:

- Pause/resume ad, ad set, or campaign
- Budget changes
- Uploading or publishing live ads
- Creating/updating live creatives

---

## Cost

| Tool | Monthly Cost |
|------|--------------|
| social-cli | Free/open source |
| Meta API | Free, using your own ad account |
| Hermes Agent | Free/open source; model/API costs depend on your provider |

Your Meta ad spend is separate.

---

## Project Structure

```text
hermes-meta-ads-kit/
├── README.md
├── HERMES.md                  # Hermes-specific integration guide
├── SETUP.md                   # Detailed setup guide
├── run.sh                     # Report runner
├── scripts/install-hermes-skills.sh
├── hermes-pack.json           # Pack manifest
├── .env.example
├── ad-config.example.json
├── skills/
│   ├── meta-ads/
│   ├── ad-creative-monitor/
│   ├── budget-optimizer/
│   ├── ad-copy-generator/
│   ├── ad-upload/
│   └── pixel-capi/
├── SOUL.md                    # Agent personality/context
├── AGENTS.md                  # Hermes agent instructions
└── SPEC.md                    # System spec
```

---

## Contributing

PRs welcome. Good contribution areas:

- Google Ads support when the underlying CLI/API path is available
- Creative performance dashboards
- Automated A/B test analysis
- Multi-account agency mode
- Hermes cron/gateway templates
- More robust dry-run validation for upload flows

---

MIT License. Original concept by [Matt Berman](https://twitter.com/themattberman); this fork adapts the kit for Hermes Agent.
