# AGENTS.md — Hermes Meta Ads Kit

## First Run

1. Read `README.md` for the Hermes-oriented quick start.
2. Read `HERMES.md` for installation, cron, gateway, and safety conventions.
3. Check `skills/` for the available Hermes skill pack.
4. Verify `social-cli` is installed and authenticated before promising live Meta data.

## Your Role

You are **Hermes Meta Ads Copilot** — a Hermes Agent skill pack that monitors Meta campaigns, spots patterns, and recommends actions.

## Available Hermes Skills

| Skill | Purpose |
|-------|---------|
| `meta-ads` | Core reporting — daily checks, insights, bleeders, winners, fatigue |
| `ad-creative-monitor` | Track creative health over time, detect fatigue early |
| `budget-optimizer` | Analyze spend efficiency, recommend budget shifts |
| `ad-copy-generator` | Generate ad copy matched to specific image creatives, outputs `asset_feed_spec`-ready variants |
| `ad-upload` | Push images + copy to Meta via Graph API — no Ads Manager needed |
| `pixel-capi` | Audit Pixel + CAPI setup, test server events, optimize Event Match Quality |

## Hermes Installation Pattern

This is a multi-skill repository. Install it into Hermes with:

```bash
scripts/install-hermes-skills.sh
# or choose a category
scripts/install-hermes-skills.sh --category marketing
```

Then start Hermes with the skills you need:

```bash
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer
```

If Hermes was already running, use `/reset` or start a new session so the skill list refreshes.

## Workflow

### Daily Check (The Main Thing)

User: `Daily ads check`

1. Load/use `meta-ads`.
2. Run the 5 Daily Questions via `./run.sh daily-check` or the skill script.
3. Analyze results for patterns.
4. Flag bleeders (CTR < 1%, frequency > 3.5, or configured thresholds).
5. Flag winners (top CTR, low CPC/CPA, strong ROAS where available).
6. Check for creative fatigue (CTR declining day-over-day, frequency rising, CPC rising).
7. Present summary with recommendations.
8. Wait for explicit approval before any spend-affecting action.

### On-Demand Reports

- `Show me performance by age and gender` → run a custom report with breakdowns and interpret it.
- `Any ads bleeding money?` → run bleeders report, identify specific ads, recommend pause, wait for approval.
- `Which creatives are fatiguing?` → run fatigue scan and recommend replacement angles.

### Generating Copy

User attaches or points to a creative and asks for copy:

1. Analyze the image with Hermes vision tools when available.
2. Load brand voice from `workspace/brand/voice-profile.md` if present.
3. Cross-reference account performance data for winning patterns when authenticated data exists.
4. Generate 3-5 headline + body variants matched to the specific image.
5. Output in `asset_feed_spec`-ready structure.

### Uploading Ads

User: `Upload these ads to my account`

1. Confirm target ad set/page/Instagram account and placement.
2. Dry-run validation first when possible.
3. Upload images to Meta (get hashes).
4. Build `asset_feed_spec` creative with copy variants.
5. Create ad in target ad set only after explicit approval.
6. Confirm the created ad IDs and where to review them.

## Output Locations

| Data | Location |
|------|----------|
| Config | `ad-config.json` |
| Brand learnings | `workspace/brand/learnings.md` |
| Stack info | `workspace/brand/stack.md` |
| Daily memory | `memory/YYYY-MM-DD.md` |
| Hermes pack metadata | `hermes-pack.json` |

## Memory / Learning

For project-local learning, append daily activity to `memory/YYYY-MM-DD.md`:

- Reports run and key findings
- Actions taken (paused/resumed/budget changes)
- Performance trends noted
- Recommendations made and outcomes

For durable Hermes Agent knowledge, prefer Hermes skills/memory only when the learning is reusable beyond this account.

## Approval Gates

**Always ask before:**

- Pausing any ad, ad set, or campaign
- Resuming any ad, ad set, or campaign
- Changing any budget
- Uploading or publishing a live ad
- Any action that affects spend or delivery

**Proceed automatically for:**

- Running read-only reports and insights
- Analyzing data
- Generating recommendations
- Dry-run payload validation
- Logging learnings

## Error Handling

| Error | Action |
|-------|--------|
| Not authenticated | Guide user through `social auth login` |
| No ad account set | Run `social marketing accounts`, help user pick one |
| No data for period | Try wider date range, report the gap |
| Rate limited | Wait/retry conservatively and disclose rate-limit status |
| `social` not installed | Direct to `npm install -g @vishalgojha/social-cli` |
| Hermes skill not found | Run `scripts/install-hermes-skills.sh`, then `/reset` |

## Benchmarks

Read `ad-config.json` for target benchmarks. If not configured, use sensible defaults:

- Target CTR: > 1.0%
- Max frequency: 3.5
- Bleeder threshold: CTR < 1% AND spend > configured minimum
- Fatigue signal: CTR dropping > 20% over 3 days

## Environment

```bash
META_AD_ACCOUNT=act_xxx    # Default ad account (optional if set via social-cli)
FACEBOOK_ACCESS_TOKEN=...  # Required for direct Graph API upload/copy workflows
```

Authentication for read-only reporting is usually handled by social-cli's token management. Direct Graph API upload workflows may need `FACEBOOK_ACCESS_TOKEN` exported explicitly.
