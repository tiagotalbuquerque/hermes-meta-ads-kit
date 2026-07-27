# Official Meta Ads CLI Local-First Update Plan

**Date:** 2026-04-29  
**Repo:** `/home/matt/clawd/projects/meta-ads-kit`  
**Mode:** local-first only — no public repo push, no live Meta mutations without Matt approval

## Trigger

Meta announced an official Ads CLI for Ads + Commerce. The useful shift: the kit can stop depending primarily on community `social-cli` wrappers and move toward Meta's supported command surface:

```bash
meta ads <resource> <action> [options]
```

Known official capabilities from the launch/docs context:

- Auth via Meta system user access token + ad account ID
- Campaigns / ad sets / ads / creatives CRUD
- Insights queries
- Catalogs, product items, product sets
- Datasets / pixels
- Ad accounts + Facebook pages
- Automation flags: `--no-input`, `--force`
- Output: `table`, `json`, `plain`
- `.env` support
- Consistent exit codes
- Created resources default to `PAUSED`

## Current Architecture Summary

Current repo is a lightweight OpenClaw kit, not a full Node/Python package.

Top-level files:

- `README.md` — product promise, quick start, skill overview
- `SETUP.md` — install/auth instructions for `@vishalgojha/social-cli`
- `SPEC.md` — architecture/spec and safety model
- `run.sh` — command router into skill scripts
- `.env.example` — currently assumes social-cli auth and optional `META_AD_ACCOUNT`
- `ad-config.example.json` — account, benchmarks, alert thresholds, reporting preset
- `clawdbot.json`, `AGENTS.md`, `SOUL.md`, `IDENTITY.md`
- `skills/*/SKILL.md` — six OpenClaw skills

Skills present:

| Skill | Current role | Current dependency posture |
|---|---|---|
| `meta-ads` | Daily checks, reports, winners, bleeders, fatigue | Wraps `social-cli`; references `skills/meta-ads/scripts/meta-ads.sh` |
| `ad-creative-monitor` | Fatigue and creative health | Wraps `social-cli`; references missing `scripts/creative-monitor.sh` |
| `budget-optimizer` | Efficiency, pacing, budget recommendations | Wraps `social-cli`; references missing `scripts/budget-optimizer.sh` |
| `ad-copy-generator` | Copy generation from creative + account patterns | Uses direct Graph API `curl` examples with `FACEBOOK_ACCESS_TOKEN` |
| `ad-upload` | Upload image/copy, create creative/ad | Uses direct Graph API; requires `FACEBOOK_ACCESS_TOKEN`, `META_AD_ACCOUNT` |
| `pixel-capi` | Pixel/CAPI audit/setup/testing | Mostly docs-driven; references scripts/reference docs that are not present locally |

Important local finding: `run.sh` routes to skill script paths, but this checkout currently has no `skills/*/scripts/` directories. The public docs describe an executable workflow, but the local repo is mostly docs/skills plus a router. The official CLI update should use this as a chance to add a real local command layer instead of only changing docs.

## What To Keep vs Replace

### Keep

- The core promise: daily operator read instead of Ads Manager clicking.
- The five-question daily check framework.
- OpenClaw skill layout and brand memory conventions.
- `ad-config.example.json` benchmark/threshold model.
- Approval-first safety model.
- `ad-copy-generator` visual/copy workflow.
- `pixel-capi` strategic skill scope.
- `run.sh` as the human-friendly entrypoint, but update its internals.

### Replace / De-emphasize

- Replace `social-cli` as the primary engine for Meta Ads operations.
- Replace direct Graph API `curl` examples in operational paths with official `meta ads ...` commands where the CLI supports the same operation.
- Stop documenting user OAuth/browser auth as the main production path. Move to system user token + explicit ad account ID.
- Stop pretending missing skill scripts exist. Add local scripts/wrappers or update `run.sh` to fail clearly until implemented.

### Keep as fallback only

- Direct Graph API calls for edge cases not yet covered by official CLI.
- Existing `social-cli` instructions as a temporary legacy fallback during migration, not the recommended path.

## Proposed Local-First Architecture

Add a local adapter layer that all skills call. Do not rewrite every skill directly against raw `meta ads` commands.

```text
OpenClaw skills
   ↓
run.sh
   ↓
scripts/meta-kit.sh              # public local entrypoint / dispatcher
   ↓
scripts/lib/meta-cli.sh          # official CLI wrapper + guards
scripts/lib/config.sh            # env loading, account selection, output defaults
scripts/lib/safety.sh            # read-only/mutation approval checks
scripts/lib/mock.sh              # fake mode fixtures
   ↓
Official Meta Ads CLI
   ↓
Meta Marketing API
```

Recommended local files to add in implementation phase:

```text
scripts/
  meta-kit.sh
  meta-audit.sh
  meta-mutate.sh
  lib/
    config.sh
    meta-cli.sh
    safety.sh
    mock.sh
  fixtures/
    campaigns.list.json
    adsets.list.json
    ads.list.json
    insights.last_7d.json
local/
  .gitkeep
  outputs/.gitkeep
  dry-runs/.gitkeep
```

`.gitignore` should protect local-only state:

```gitignore
.env
.env.*.local
local/
*.token
*.secrets
```

## Install / Auth / Config Strategy

### Installation

First implementation step should verify Meta's official package/install command from docs before locking it into README. Avoid guessing package names in public docs.

Local-only install options:

1. Prefer project-local dev dependency if Meta publishes an npm package.
2. Otherwise use the official global install method from Meta docs.
3. Add a `scripts/meta-kit.sh doctor` command that checks:
   - `meta` binary exists
   - `meta ads --help` works
   - required env vars are present
   - current mode is `mock`, `read-only`, or `live-approved`

### Environment variables

Update `.env.example` locally first:

```bash
# Official Meta Ads CLI auth
META_SYSTEM_USER_ACCESS_TOKEN=
META_AD_ACCOUNT=act_123456789
META_BUSINESS_ID=
META_APP_ID=
META_APP_SECRET=

# Kit behavior
META_KIT_MODE=mock              # mock | read-only | live-approved
META_KIT_OUTPUT=json            # json | table | plain
META_KIT_DEFAULT_PRESET=last_7d
META_KIT_REQUIRE_APPROVAL=true
META_KIT_FORCE_PAUSED=true
META_KIT_DRY_RUN_DIR=local/dry-runs
```

Notes:

- Use a Meta system user token, not Matt's personal session token.
- Use least-privilege tokens for normal read-only work: `ads_read`, `read_insights`.
- Keep `ads_management` token separate and only load it for explicitly approved mutation sessions.
- Maintain account/client separation with separate env files, e.g. `.env.fitnessgm.local`, `.env.emerald.local`, never committed.

### Config separation

Keep `ad-config.json` for marketing thresholds, not secrets. Add optional account/client routing config without credentials:

```json
{
  "account": {
    "id": "act_123456789",
    "name": "My Brand",
    "env_file": ".env.mybrand.local"
  },
  "cli": {
    "output": "json",
    "default_mode": "read-only"
  }
}
```

## Read-Only Audit Commands First

Before any mutating work, build and test read-only flows only.

Candidate commands to map after confirming exact command reference:

```bash
# Doctor / help
meta ads --help
meta ads campaigns --help

# Account visibility
meta ads ad-accounts list --output json --no-input
meta ads pages list --output json --no-input

# Core reports
meta ads campaigns list --account "$META_AD_ACCOUNT" --output json --no-input
meta ads adsets list --account "$META_AD_ACCOUNT" --output json --no-input
meta ads ads list --account "$META_AD_ACCOUNT" --output json --no-input
meta ads insights get --account "$META_AD_ACCOUNT" --level campaign --date-preset last_7d --output json --no-input
meta ads insights get --account "$META_AD_ACCOUNT" --level ad --date-preset last_7d --output json --no-input

# Tracking/catalog read-only
meta ads datasets list --account "$META_AD_ACCOUNT" --output json --no-input
meta ads pixels list --account "$META_AD_ACCOUNT" --output json --no-input
meta ads catalogs list --account "$META_AD_ACCOUNT" --output json --no-input
```

If exact resource/action names differ, implementation should create a mapping table in `scripts/lib/meta-cli.sh` and keep skills stable.

## Safe Mutation Guardrails

Hard rules:

1. No live changes without explicit Matt approval.
2. Default mode is `mock` or `read-only`, never live mutation.
3. Any campaign/adset/ad creation must be `PAUSED` only.
4. Budget changes, status changes, creates, updates, deletes are blocked unless all approval gates pass.
5. Deletes should remain unsupported in v1 local integration.
6. Use dry-run files for every proposed mutation.
7. Use env separation: read-only token and management token should not be the same default secret.
8. Use `--no-input` for automation; only use `--force` inside an approved mutation wrapper.
9. Log every approved mutation request + response under `local/outputs/` and `workspace/brand/learnings.md` when present.

### Wrapper behavior

`meta-cli.sh` should classify commands:

- Read-only: `list`, `get`, `insights`, `preview`, `help`, `doctor`
- Mutating: `create`, `update`, `delete`, `pause`, `resume`, `set-budget`, any command with `--force`

For mutating commands, wrapper requires:

```bash
META_KIT_MODE=live-approved
META_KIT_APPROVAL_ID=<human-provided approval token/string>
META_KIT_REQUIRE_APPROVAL=true
```

For creation commands, wrapper enforces or injects:

```bash
--status PAUSED
```

If status is anything other than `PAUSED`, fail before calling Meta.

### Dry-run format

Every proposed mutation should generate a file before execution:

```text
local/dry-runs/2026-04-29T193600-create-ad.json
```

Include:

- timestamp
- account ID
- resource/action
- exact CLI command to be run
- sanitized payload
- expected risk
- approval requirement
- rollback/undo note where applicable

## Skill Updates Needed

### `skills/meta-ads/SKILL.md`

- Change engine from `social-cli` to official Meta Ads CLI adapter.
- Update setup to system user token + `META_AD_ACCOUNT`.
- Replace script references with `./run.sh daily-check`, backed by `scripts/meta-kit.sh`.
- Require JSON output for agent interpretation.
- Keep output sections and decision logic.

### `skills/ad-creative-monitor/SKILL.md`

- Replace social-cli script examples with official insights read-only calls via adapter.
- Store daily snapshots in `local/outputs/creative-health/` or `workspace/brand/learnings.md`.
- Clarify fatigue detection is read-only.

### `skills/budget-optimizer/SKILL.md`

- Use official insights/adset/campaign reads.
- Keep budget recommendations as recommendations only.
- Add explicit: budget mutations require dry-run + Matt approval + `live-approved` mode.

### `skills/ad-upload/SKILL.md`

- Move from direct Graph API-first to official CLI-first where supported:
  - image/creative upload
  - creative creation
  - ad creation
- Keep Graph API fallback notes only for missing CLI features.
- Enforce PAUSED-only ad creation.
- Require local validation and dry-run artifact before any create.

### `skills/ad-copy-generator/SKILL.md`

- Replace top-performer Graph API examples with adapter/official CLI insights commands.
- Keep creative/copy generation logic unchanged.
- Output should include both human copy and machine payload candidate for `ad-upload` dry run.

### `skills/pixel-capi/SKILL.md`

- Use official CLI for datasets/pixels read-only inventory where possible.
- Keep CAPI event testing separate and approval-gated because test events can still hit Meta systems.

### Top-level docs

Local branch only until tested:

- `README.md`: mention official Meta Ads CLI as new preferred engine.
- `SETUP.md`: new official CLI install/auth flow.
- `SPEC.md`: update architecture diagram from `social-cli` to official CLI adapter.
- `.env.example`: add official env vars and local safety mode.
- `run.sh`: route to actual local adapter scripts.

## Test Plan

### Phase 0 — Static/local only

- `bash -n run.sh scripts/*.sh scripts/lib/*.sh`
- `shellcheck` if available
- Validate `.env.example` has no secrets
- Validate `.gitignore` excludes `local/` and `.env.*.local`

### Phase 1 — Fake/mock mode

Set:

```bash
META_KIT_MODE=mock
```

Use fixtures only:

```bash
./run.sh daily-check
./run.sh overview --preset last_7d
./run.sh campaigns
./run.sh bleeders
./run.sh winners
./run.sh fatigue
./run.sh efficiency
./run.sh pacing
```

Expected:

- No Meta CLI invocation.
- Deterministic output from fixtures.
- Skills can still produce executive reads, winners, bleeders, fatigue, and budget recommendations.
- Mutation commands create dry-run files and fail before live execution.

### Phase 2 — CLI present, no credentials

```bash
./scripts/meta-kit.sh doctor
```

Expected:

- Detect `meta` binary.
- Report missing env vars clearly.
- Do not call account endpoints without token/account.

### Phase 3 — Real read-only command later

Only after Matt provides/approves a read-only system user token:

```bash
META_KIT_MODE=read-only \
./scripts/meta-kit.sh campaigns --account "$META_AD_ACCOUNT" --output json
```

or exact equivalent after command-reference confirmation.

Expected:

- Successful JSON output.
- No account changes.
- Response saved under `local/outputs/read-only/` with secrets redacted.

### Phase 4 — Dry-run mutation only

Use fake payload and mock mode:

```bash
META_KIT_MODE=mock ./scripts/meta-kit.sh create-ad --payload examples/create-ad.json --dry-run
```

Expected:

- Writes dry-run artifact.
- Shows exact command that would run.
- Refuses non-PAUSED status.
- Does not call Meta.

### Phase 5 — Approved PAUSED create later

Only after separate explicit Matt approval for one exact command/payload:

- Use management token only for that session.
- Use `META_KIT_MODE=live-approved`.
- Require `META_KIT_APPROVAL_ID`.
- Create only as `PAUSED`.
- Save request/response.

## Phased Implementation Checklist

### Phase 1 — Local planning + adapter skeleton

- [ ] Confirm official install command/package from Meta docs.
- [ ] Add `.gitignore` entries for `local/`, `.env.*.local`, tokens/secrets.
- [ ] Add `scripts/lib/config.sh` env loader.
- [ ] Add `scripts/lib/safety.sh` classifier/guards.
- [ ] Add `scripts/lib/mock.sh` fixture loader.
- [ ] Add `scripts/lib/meta-cli.sh` wrapper.
- [ ] Add `scripts/meta-kit.sh` dispatcher.
- [ ] Add mock fixtures for campaigns/adsets/ads/insights.
- [ ] Update `run.sh` to call the adapter instead of missing skill scripts.

### Phase 2 — Read-only reporting parity

- [ ] Implement `daily-check` from official CLI/fixtures.
- [ ] Implement `overview`.
- [ ] Implement `campaigns`.
- [ ] Implement `top-creatives` / `winners`.
- [ ] Implement `bleeders`.
- [ ] Implement `fatigue-check`.
- [ ] Implement `efficiency` / `pacing` reads.
- [ ] Save sanitized JSON snapshots under `local/outputs/read-only/`.

### Phase 3 — Skill/doc local updates

- [ ] Update `skills/meta-ads/SKILL.md`.
- [ ] Update `skills/ad-creative-monitor/SKILL.md`.
- [ ] Update `skills/budget-optimizer/SKILL.md`.
- [ ] Update `skills/ad-copy-generator/SKILL.md`.
- [ ] Update `skills/ad-upload/SKILL.md`.
- [ ] Update `skills/pixel-capi/SKILL.md`.
- [ ] Update `SETUP.md`, `SPEC.md`, `README.md` locally.

### Phase 4 — Dry-run mutation wrappers

- [ ] Implement mutation command classifier.
- [ ] Implement dry-run artifact writer.
- [ ] Implement PAUSED-only enforcement.
- [ ] Implement exact-command approval display.
- [ ] Add tests that non-PAUSED creates fail locally.
- [ ] Add tests that `--force` is blocked outside `live-approved`.

### Phase 5 — Real read-only validation

- [ ] Matt creates/provides least-privilege system user token.
- [ ] Run `doctor`.
- [ ] Run one account/campaign list command.
- [ ] Run one campaign-level insights command.
- [ ] Compare output with Ads Manager manually.
- [ ] Fix command mappings.

### Phase 6 — Local review before public repo

- [ ] `git diff` review locally.
- [ ] Confirm no secrets in files.
- [ ] Confirm no live mutation command was run.
- [ ] Matt decides whether to open a branch/PR to public repo.

## Recommendation

Do not do a docs-only update. The repo currently promises executable scripts that are absent in this checkout. The right local-first move is to add a real adapter/wrapper layer around Meta's official CLI, get mock mode and read-only parity working first, then update the skills/docs to describe the new official engine.

The public repo should only be touched after local mock + one real read-only command pass cleanly.
