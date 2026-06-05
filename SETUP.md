# Hermes Meta Ads Kit — Setup Guide

Get the Hermes-powered Meta Ads copilot running in about 10 minutes.

---

## Step 1: Verify Hermes Agent

```bash
hermes --version
hermes doctor
```

If Hermes is not installed:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

---

## Step 2: Install social-cli

`social-cli` is the open-source command-line engine that talks to the Meta Marketing API.

```bash
npm install -g @vishalgojha/social-cli
```

Verify it is installed:

```bash
social --version
```

---

## Step 3: Authenticate With Meta

```bash
social auth login
```

This opens your browser to authorize with Meta. You need:

- A Facebook account with access to the ad account
- Permission to read ad insights
- `ads_management` permission only if you want approved actions such as pause/resume/budget changes

### Advanced: Using a Meta App

If you have a Meta developer app:

```bash
social auth set-app --app-id YOUR_APP_ID --app-secret YOUR_APP_SECRET
social auth login --scopes ads_read,ads_management,read_insights
```

---

## Step 4: Set Your Ad Account

List available ad accounts:

```bash
social marketing accounts
```

Set the default:

```bash
social marketing set-default-account act_YOUR_ACCOUNT_ID
```

Or set it via environment variable:

```bash
export META_AD_ACCOUNT=act_YOUR_ACCOUNT_ID
```

---

## Step 5: Configure Benchmarks

```bash
cp ad-config.example.json ad-config.json
```

Edit `ad-config.json` with your targets:

```json
{
  "account": {
    "id": "act_YOUR_ACCOUNT_ID",
    "name": "Your Brand Name"
  },
  "benchmarks": {
    "target_cpa": 25.00,
    "target_roas": 3.0,
    "max_frequency": 3.5,
    "min_ctr": 1.0,
    "max_cpc": 2.50
  }
}
```

If you do not know your benchmarks yet, keep defaults and let Hermes report against them while you calibrate.

---

## Step 6: Install the Hermes Skills

This repository is a multi-skill pack. Install all included skills into the active Hermes profile:

```bash
chmod +x scripts/install-hermes-skills.sh
scripts/install-hermes-skills.sh
```

Default destination:

```text
${HERMES_HOME:-~/.hermes}/skills/marketing/
```

If a previous copy exists and you deliberately want to replace it:

```bash
scripts/install-hermes-skills.sh --force
```

After installing, start a new Hermes session or use `/reset` in the current session.

---

## Step 7: Test the Scripts Directly

```bash
chmod +x run.sh
./run.sh daily-check
```

You should see the 5 Daily Questions with real ad data from the selected Meta account.

Useful checks:

```bash
./run.sh bleeders --preset last_7d
./run.sh winners --preset last_30d
./run.sh fatigue
./run.sh efficiency
```

---

## Step 8: Run With Hermes

Core monitoring session:

```bash
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer
```

Full pack:

```bash
hermes -s meta-ads -s ad-creative-monitor -s budget-optimizer -s ad-copy-generator -s ad-upload -s pixel-capi
```

Now message Hermes naturally:

- `Daily ads check`
- `Any bleeders?`
- `Which ads should I scale?`
- `Check creative fatigue`
- `Show me performance by age and gender`
- `Generate copy for this creative`
- `Dry-run upload for this ad`

---

## Step 9: Automate Morning Briefings

Check for existing jobs first to avoid duplicate daily briefings:

```bash
hermes cron list
```

Then create a job from Hermes:

```text
Run my Meta ads daily check every morning at 8am and send me the summary. Use the meta-ads, ad-creative-monitor, and budget-optimizer skills. Do not pause, resume, upload, or change budgets; only recommend actions for approval.
```

Hermes can deliver through the configured gateway platform if you create the job from a chat/channel or specify a delivery target.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `hermes: command not found` | Install Hermes Agent or ensure it is on PATH |
| Hermes cannot see the new skills | Run `scripts/install-hermes-skills.sh`, then `/reset` or start a new session |
| `social: command not found` | Run `npm install -g @vishalgojha/social-cli` |
| Authentication fails | Run `social auth login` again and check browser permissions |
| No ad accounts found | Ensure your Facebook user has ad account access |
| No data returned | Check the selected date range and campaign activity |
| Rate limited | Wait a few minutes and retry with fewer/wider queries |
| Upload flow fails | Export `FACEBOOK_ACCESS_TOKEN` and `META_AD_ACCOUNT`; run Graph API verification calls |

### Check social-cli

```bash
social doctor
```

### Check Hermes

```bash
hermes doctor
hermes skills list
```

---

## Permissions Needed

| Permission | Required For |
|-----------|--------------|
| `ads_read` | Reading campaign data and basic account objects |
| `read_insights` | Performance metrics |
| `ads_management` | Pausing/resuming ads, budget changes, uploads |

`ads_read` + `read_insights` are enough for monitoring. Add `ads_management` only if you want Hermes to execute approved actions.
