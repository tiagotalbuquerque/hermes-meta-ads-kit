# Running with Hermes Agent

Hermes runs Meta Ads Kit directly from the local repository. Nothing from this project needs to be copied into a Hermes profile for the scheduled pipeline.

## Setup

```bash
git clone https://github.com/tiagotalbuquerque/hermes-meta-ads-kit.git
cd hermes-meta-ads-kit
cp .env.example .env
chmod 600 .env
```

Set the production variables in `.env`:

```dotenv
META_KIT_MODE=live
ACCESS_TOKEN=...
AD_ACCOUNT_ID=act_...
```

Validate before scheduling:

```bash
./run.sh doctor
./run.sh daily-check
```

A production run is valid only when it reports `mode=live`, the expected account, real data, and no parser errors. A successful exit code alone is insufficient.

## How Hermes initializes the project

Set the Hermes session or cron job `workdir` to the absolute repository root. Hermes then:

1. starts a fresh isolated agent session;
2. injects the repository `AGENTS.md` as project context;
3. runs terminal and file tools from the repository;
4. follows `AGENTS.md` First Run, which reads `SOUL.md`, the README, and the local `skills/` directory;
5. runs `./run.sh`, which loads `.env` from the repository root.

This keeps identity, instructions, credentials, and output local to the project. It does not modify Hermes `SOUL.md`, memory, or profile.

## Optional standalone skills

You may separately copy the directories under `skills/` into a Hermes profile to make individual skills available in normal conversations. This is optional and does not replace or participate in the scheduled pipeline bootstrap above. Do not copy `.env`, `SOUL.md`, `IDENTITY.md`, or `AGENTS.md` into the profile.

## Scheduled run

Create the job from the Hermes profile that should own its schedule and history. The project provides its complete agent context through `workdir`.

```text
schedule: 0 12 * * *
workdir: /absolute/path/to/hermes-meta-ads-kit
skills: []
prompt: Run ./run.sh daily-check. Require mode=live and the expected act_... account. Reject mock, empty, or parser-error output. Report real metrics only. Read-only: do not mutate campaigns, ads, ad sets, or budgets.
```

Leave `enabled_toolsets` unset unless you intentionally maintain a restrictive cron allowlist. Cron sessions do not inherit the current chat, so keep the expected account, live-data gate, and mutation boundary in the prompt.

## Removal

Remove the cron job through Hermes, then delete the local repository if no longer needed. Remove optional standalone skill copies separately if installed.

## OpenClaw

The existing OpenClaw setup remains unchanged; see [SETUP.md](SETUP.md). The Hermes path is additive and does not alter OpenClaw files or behavior.
