# Meta Official Ads AI Connectors / Ads CLI Research

**Date:** 2026-04-30  
**Purpose:** Ground the local adapter migration in the available Meta launch material before live syntax is locked in.

## Sources checked

- Meta developer launch URL found in search: `https://developers.facebook.com/blog/post/2026/04/29/introducing-ads-cli/`
  - Status from local fetch/curl: returns Meta generic 400/error page in this environment.
  - Result: confirms the URL exists in search, but full content was not retrievable here.
- Meta business news URL from secondary source: `https://www.facebook.com/business/news/meta-ads-ai-connectors`
  - Status from local fetch/curl: returns Meta generic 400/error page in this environment.
  - Result: official source exists, but full content was not retrievable here.
- Secondary article quoting/pointing to Meta source: `https://www.thekeyword.co/news/meta-ads-ai-connectors`
  - Fetch succeeded.

## Confirmed from official docs

Official docs became accessible via the path:

`https://developers.facebook.com/documentation/ads-commerce/ads-ai-connectors/ads-cli/ads-cli-overview`

Key facts from the official docs:

- Updated Apr 29, 2026.
- Install package: `pip install meta-ads`.
- Requirements: Python 3.12+, virtual environment setup, `pip` and `uv` package managers.
- Run commands with `uv run meta` after setup, or activate the virtualenv and use `meta` directly.
- Verified locally without credentials: `uvx --python 3.12 --from meta-ads meta --help`, `meta ads --help`, `meta ads campaign list --help`, and `meta ads insights get --help` all resolve from the official PyPI package.
- Authentication uses a **Meta system user access token**.
- Official env vars:
  - `ACCESS_TOKEN`
  - `AD_ACCOUNT_ID`
  - `BUSINESS_ID` for catalog/dataset commands.
- Configuration precedence:
  1. command-line flags, e.g. `--ad-account-id`
  2. environment variables
  3. project `.env`
  4. user config in `~/.config/meta/`
- Global options must be placed before the ads subcommand: `meta [global options] ads <resource> <action> [options]`.
- Supported output formats: `table`, `json`, `plain`.
- Automation flags: `--no-input`, `--force`.
- Command pattern: `meta ads <resource> <action> [options]`.
- Official examples:
  - `meta ads campaign list`
  - `meta ads creative create --name "My Ad" --page-id <PAGE_ID> --image ./banner.jpg`
  - `meta ads adaccount list`
  - `meta ads page list`
  - `meta ads insights get --fields spend,impressions,ctr,cpc`
- Created campaigns default to `--status PAUSED` unless otherwise provided.

Official command resources use singular names:

| Resource | Actions |
|---|---|
| `adaccount` | `list`, `get`, `current` |
| `page` | `list`, `get` |
| `campaign` | `list`, `create`, `get`, `update`, `delete` |
| `adset` | `list`, `create`, `get`, `update`, `delete` |
| `ad` | `list`, `create`, `get`, `update`, `delete` |
| `creative` | `list`, `create`, `get`, `update`, `delete` |
| `insights` | `get` |
| `dataset` | `list`, `create`, `get`, `connect`, `disconnect`, `assign-user` |
| `catalog` | `list`, `create`, `get`, `update`, `delete` |
| `product-feed` | product feed operations |
| `product-item` | product item operations |
| `product-set` | product set operations |

Insights notes:

- Default range: `last_30d`.
- Presets: `today`, `yesterday`, `last_3d`, `last_7d`, `last_14d`, `last_30d`, `last_90d`, `this_month`, `last_month`.
- `--time-increment`: `all_days`, `daily`, `weekly`, `monthly`.
- Filters: `--campaign-id`, `--adset-id`, `--ad-id`.
- Common fields: `spend`, `impressions`, `reach`, `clicks`, `ctr`, `cpc`, `cpm`, `frequency`, `conversions`, `cost_per_conversion`, `purchase_roas`.

## Secondary launch coverage

The accessible coverage says:

- Meta introduced **Meta Ads AI Connectors** for eligible advertisers globally.
- The connectors include both:
  - an **Ads MCP server**
  - an **Ads CLI**
- Both are described as available in open beta.
- They connect Meta ad accounts to AI tools such as Claude/ChatGPT and other MCP-compatible agents.
- The MCP path is described as using a standard Meta login flow with **no developer credentials, API setup, or coding required**.
- Reported capabilities include campaign reporting/analysis, campaign/ad set/ad creation and editing, budgets, targeting, creative setups, catalog/product data management, and signal diagnostics.

## Implications for this kit

The original plan's system-user-token assumption was correct for **Ads CLI** specifically. The accessible secondary article's “standard login/no API setup” language appears to describe the **MCP connector** path, not the CLI path.

Use this posture:

1. **Ads CLI auth:** system user token via `ACCESS_TOKEN`.
2. **Account config:** `AD_ACCOUNT_ID`, with optional `BUSINESS_ID` for catalog/dataset commands.
3. **Command mappings:** singular resources (`campaign`, `adset`, `ad`, `creative`, `adaccount`, `page`, `dataset`, `catalog`).
4. **Adapter design remains correct:** central command mapping keeps the kit stable if Meta changes syntax.
5. **Safety model remains mandatory:** read-only/mock first, dry-run artifacts, no live mutation without Matt approval, PAUSED-only creates.

## Still unresolved

- Need to install the package locally and confirm `meta --help` / `meta ads --help` output exactly.
- Need real read-only token/account validation later, with Matt approval.

Until those are verified, the local adapter should treat live command mappings as placeholders and mock/read-only-local behavior as the only proven path.
