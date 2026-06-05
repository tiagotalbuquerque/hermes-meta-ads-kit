---
name: budget-optimizer
description: "Analyze spend efficiency across campaigns and adsets. Recommends budget shifts from underperformers to winners."
version: 1.0.0-hermes.1
author: TheMattBerman + Hermes adaptation
license: MIT
metadata:
  hermes:
    emoji: "💰"
    tags: ["meta-ads", "budget", "paid-media", "optimization"]
    homepage: https://github.com/tiagotalbuquerque/hermes-meta-ads-kit
    user_invocable: true
    requires:
      commands: ["social", "jq"]
      env: []
prerequisites:
  commands: ["social", "jq"]
  environment_variables: []
---

# Budget Optimizer — Put Money Where It Works

Most ad accounts have the same problem: budget spread evenly across campaigns when performance isn't even close to even. This skill finds where your money works hardest and recommends shifts.

---

## Hermes Execution Notes

When loaded by Hermes, run `./run.sh efficiency`, `./run.sh recommend`, or `./run.sh pacing` from the repository root, or run `scripts/budget-optimizer.sh` by absolute path from the installed skill directory. Do not assume `./scripts/...` resolves unless your current working directory is this skill directory.

This skill requires `social-cli` and `jq`. Budget changes are never performed by this skill directly; recommendations require explicit user approval before any separate mutating command.

---


## Reports

### Efficiency Analysis
Rank campaigns/adsets by cost efficiency (CPA, ROAS, or CPC depending on objectives).

```
Tell me: "Where's my money working best?"
Or: "Analyze spend efficiency"
```

### Budget Shift Recommendations
Compare performance across campaigns, recommend moving budget from losers to winners.

```
Tell me: "How should I shift my budget?"
Or: "Optimize my ad spend"
```

### Spend Pacing
Check if campaigns are on pace for their daily/lifetime budgets.

```
Tell me: "Am I overspending or underspending?"
Or: "Check spend pacing"
```

---

## Scripts

```bash
# Efficiency ranking
./scripts/budget-optimizer.sh efficiency [--account act_123] [--preset last_7d]

# Budget recommendations
./scripts/budget-optimizer.sh recommend [--account act_123]

# Spend pacing check
./scripts/budget-optimizer.sh pacing [--account act_123]
```

---

## Invocation

1. Pull campaign and adset level insights
2. Calculate efficiency metrics (CPA, ROAS, CPC relative to spend)
3. Compare against benchmarks in `ad-config.json`
4. Identify top and bottom performers
5. Calculate recommended budget shifts (% based)
6. Present recommendations with clear reasoning
7. **Never adjust budget without explicit approval**
8. Log decisions to `workspace/brand/learnings.md`

---

## Safety

Budget changes are **high-risk actions**. This skill:
- Always shows current vs. recommended budget
- Explains the reasoning (data-backed)
- Waits for explicit "yes" before executing
- Logs every budget change for audit trail
