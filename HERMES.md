# HERMES.md — Hermes Agent Integration

This repository is a Hermes Agent adaptation of `TheMattBerman/meta-ads-kit`.

It is intentionally a **multi-skill pack**: each subdirectory under `skills/` is a normal Hermes `SKILL.md` directory, with scripts/references preserved beside the skill.

## What Changed From the Original

- Replaced OpenClaw-specific metadata and docs with Hermes Agent conventions.
- Added `hermes-pack.json` as a simple manifest for humans/tools.
- Added `scripts/install-hermes-skills.sh` to install the full skill pack into the active Hermes profile.
- Updated agent instructions in `AGENTS.md` for Hermes tool use, `/reset`, cron, gateway, and approval gates.
- Expanded the docs for Hermes CLI usage, gateway delivery, and cron scheduling.

## Prerequisites

```bash
# Hermes Agent
hermes --version

# Meta API wrapper used by the report scripts
npm install -g @vishalgojha/social-cli
social auth login
social marketing accounts
social marketing set-default-account act_YOUR_ACCOUNT_ID
```

Optional for upload/copy workflows:

```bash
export FACEBOOK_ACCESS_TOKEN="..."
export META_AD_ACCOUNT="act_123456789"
```

## Install the Skills Into Hermes

From the repository root:

```bash
chmod +x scripts/install-hermes-skills.sh
scripts/install-hermes-skills.sh
```

Default destination:

```text
${HERMES_HOME:-~/.hermes}/skills/marketing/<skill-name>/
```

Useful variants:

```bash
# Install into a different category
scripts/install-hermes-skills.sh --category marketing

# Replace existing copies deliberately
scripts/install-hermes-skills.sh --force

# Install into another Hermes profile/home
HERMES_HOME=~/.hermes/profiles/ads/.hermes scripts/install-hermes-skills.sh
```

After installation, start a new Hermes session or run `/reset` in an existing one so the skill list refreshes.

## Run With Hermes

Load just the skills needed for a daily check:

```bash
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer
```

Load the full pack:

```bash
hermes \
  -s meta-ads \
  -s ad-creative-monitor \
  -s budget-optimizer \
  -s ad-copy-generator \
  -s ad-upload \
  -s pixel-capi
```

Then ask naturally:

- `Daily ads check`
- `Any bleeders I should pause?`
- `Which ads should I scale?`
- `Check for creative fatigue`
- `Show performance by age and gender`
- `Generate copy for this creative`
- `Dry-run upload for these ads`

## Run Scripts Directly

The scripts still work outside Hermes for verification/debugging:

```bash
./run.sh daily-check
./run.sh bleeders --preset last_7d
./run.sh winners --preset last_30d
./run.sh fatigue
./run.sh efficiency
./run.sh recommend
```

## Automate With Hermes Cron

Inside Hermes:

```text
Run my Meta ads daily check every morning at 8am and send me the summary.
```

Or via CLI:

```bash
hermes cron create "0 8 * * *"
```

Use a self-contained prompt such as:

```text
Load/use the meta-ads, ad-creative-monitor, and budget-optimizer skills. In /path/to/hermes-meta-ads-kit, run ./run.sh daily-check using the configured Meta account. Summarize spend pacing, active campaigns, bleeders, winners, fatigue signals, and recommended next actions. Do not pause, resume, upload, or change budgets; only recommend actions for user approval.
```

## Delivery Through Hermes Gateway

Hermes can send scheduled summaries through any configured gateway platform (Telegram, Discord, Slack, WhatsApp, Signal, Matrix, email, etc.). Configure the gateway normally:

```bash
hermes gateway setup
hermes gateway status
```

Then create the cron job from the target chat/thread or set the cron delivery target explicitly.

## Safety Rules

Read-only operations can run without approval:

- Reports
- Insights
- Fatigue checks
- Budget recommendations
- Dry-run payload validation

Spend/delivery-affecting operations require explicit approval:

- Pause/resume ad, ad set, or campaign
- Budget changes
- Uploading/publishing live ads
- Creating or updating live creatives

## Troubleshooting

| Symptom | Fix |
|---|---|
| Hermes cannot see the skills | Run `scripts/install-hermes-skills.sh`, then `/reset` or start a new session |
| `social: command not found` | `npm install -g @vishalgojha/social-cli` |
| No ad accounts | Confirm the Meta user has access, then run `social auth login` again |
| No data for period | Try `--preset last_30d` or verify campaigns were active |
| Upload/copy Graph API fails | Export `FACEBOOK_ACCESS_TOKEN` and `META_AD_ACCOUNT`; verify with `/me` and `/me/adaccounts` Graph calls |
| Cron duplicates | Run `hermes cron list` before adding a new recurring briefing |

## Repo Layout

```text
hermes-meta-ads-kit/
├── AGENTS.md
├── HERMES.md
├── README.md
├── SETUP.md
├── SPEC.md
├── hermes-pack.json
├── scripts/install-hermes-skills.sh
├── run.sh
└── skills/
    ├── meta-ads/
    ├── ad-creative-monitor/
    ├── budget-optimizer/
    ├── ad-copy-generator/
    ├── ad-upload/
    └── pixel-capi/
```
