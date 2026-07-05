# Lessons learned — Ch.1 AI Platform Foundation

Add an entry each time something surprises you, breaks, or takes longer than expected. One entry per lesson, not a diary.

## Template
- **What happened:**
- **Why:**
- **What I'd do differently:**

## 2026-07-05 — Half my CLI tools were silently x86_64-only
- **What happened:** `git`, `gh`, `uv`, and `terraform` (via `tfenv`) all failed with `bad CPU type in executable` the first time each was used in this project.
- **Why:** this Mac is Apple Silicon (arm64), but these tools were installed a while back via the old Intel Homebrew (`/usr/local`), which still has PATH priority in some cases (e.g. `~/.local/bin/uv` shadowing the correct one). Nothing had exercised them recently enough to notice.
- **What I'd do differently:** on any "new to me" machine, run `file $(which git gh uv terraform aws)` once up front before relying on them mid-task — cheaper than discovering it one broken command at a time. See README Day 1 log for the full fix table.
