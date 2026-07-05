# Ch.1 — AI Platform Foundation

**Weeks 1–3 · Jul 5 – Jul 25, 2026**

Bootstrap the base platform repo, CI, and IaC conventions every later chapter reuses.

## What is it, and why does it exist?
_(fill in after architecture review)_

## How do we build and operate it in production?
- Architecture diagram: `docs/architecture.md`
- Tech stack: Python (uv or poetry), Terraform, GitHub Actions, AWS (EKS)
- ADRs: `docs/adr/`
- Folder structure: see below

## How do I defend it in a senior interview?
- Interview questions: `docs/interview-cheatsheet.md`
- Resume points: _(fill in after this chapter ships)_

## Week 1 checklist
- [x] AWS sub-account + IAM user (not root) created — `platform-foundation-admin`, `platform` CLI profile
- [x] AWS Budget + billing alarm set ($50 / $150 thresholds) — `platform-foundation-monthly`, $150/mo cap
- [x] GitHub repo pushed, branch protection + CODEOWNERS added — github.com/laxmikanth80/ai-platform-foundation
- [ ] Terraform: VPC + EKS cluster skeleton (`terraform/`) — files scaffolded, actual module content is next
- [x] Python packaging + pre-commit + linting working (`pyproject.toml`, `.pre-commit-config.yaml`) — `uv sync`, `pytest`, `ruff check` all passing, pre-commit hook installed

## Folder structure

```
.
├── docs/
│   ├── adr/                  # architecture decision records
│   ├── architecture.md
│   ├── lessons-learned.md
│   └── interview-cheatsheet.md
├── .github/workflows/        # CI
├── terraform/                # VPC, EKS skeleton
├── src/platform_foundation/  # application code
├── tests/
├── pyproject.toml
├── .pre-commit-config.yaml
└── .gitignore
```

## Day 1 log — 2026-07-05

### Completed
- **AWS:** created IAM user `platform-foundation-admin` (not root), attached `AdministratorAccess`, configured a CLI profile named `platform`. Verified with `aws sts get-caller-identity --profile platform`.
- **AWS:** created a $150/month cost budget (`platform-foundation-monthly`) with email alerts at 33% (~$50) and 100% ($150), so GPU spend in later chapters can't run away unnoticed.
- **GitHub:** repo created and pushed — [github.com/laxmikanth80/ai-platform-foundation](https://github.com/laxmikanth80/ai-platform-foundation). Branch protection added on `main`: requires the `lint-and-test` CI check to pass before merging, blocks force-push and branch deletion. CODEOWNERS added (`@laxmikanth80` as default owner).
- **Python packaging:** fixed a scaffold bug (`pre-commit` was missing from the `dev` extras in `pyproject.toml` even though `.pre-commit-config.yaml` existed). After the fix: `uv sync --extra dev` installs cleanly, `pre-commit install` wired into `.git/hooks/`, `pytest` and `ruff check` both pass.

### Decisions worth remembering
- **`AdministratorAccess` over hand-scoped least-privilege IAM** for this IAM user — this is a personal, single-user sandbox account, so there's no other principal to protect against; the real safety net here is the Budget alarm, not a fine-grained policy. Would not make this same call on a shared or production AWS account — there, least privilege is non-negotiable.
- **Branch protection with admins not locked out** — as the only contributor, the rule requires CI to pass and blocks force-push/deletion, but doesn't prevent the owner (you) from pushing directly if genuinely needed. Trade-off: convenience for a solo repo vs. the stricter "no one bypasses, ever" rule you'd want with a team.
- **`terraform/` intentionally left as an empty skeleton** — actual VPC/EKS module content is Week 2 scope per the execution plan, not something to rush into Day 1 just because the folder exists.

### Environment issues found and fixed
This machine is Apple Silicon (arm64), but several CLI tools were still x86_64-only binaries left over from before — every one of them failed the same way: `bad CPU type in executable`. Fixed by installing native arm64 versions via Homebrew at `/opt/homebrew` (which already has PATH priority over the old `/usr/local` install location):

| Tool | Root cause | Fix |
|---|---|---|
| `git` | `/usr/local/bin/git` was x86_64-only | `brew install git` → resolves to `/opt/homebrew/bin/git` (2.55.0) |
| `gh` | Same, plus an expired auth token | `brew install gh`, then fresh `gh auth login --web` |
| `uv` | Two broken copies — Homebrew's *and* a standalone one at `~/.local/bin/uv` shadowing it (that directory is first in PATH) | `brew install uv`, then symlinked `~/.local/bin/uv`/`uvx` to the working Homebrew binaries |
| `terraform` (via `tfenv`) | Two layers deep — `tfenv` itself was from the old Intel Homebrew, and its checksum step depended on `ggrep` (GNU grep), also x86_64-only | `brew install tfenv grep`, then `tfenv install 1.9.8` |
| Python | pyenv only had 3.10.14; `pyproject.toml` requires ≥3.11 | `pyenv install 3.11.15`, then `pyenv local 3.11.15` in this repo |

**Takeaway for future sessions:** if a command ever fails with `bad CPU type in executable` on this machine again, it's almost certainly another leftover x86_64 binary from `/usr/local`. Diagnose with `file $(which <tool>)`, fix with `brew install <tool>` (arm64 Homebrew already wins the PATH race).

### Reference artifacts
- AWS account: `668639472905` · IAM user: `platform-foundation-admin` · CLI profile: `platform`
- Budget: `platform-foundation-monthly` ($150/mo, alerts to laxmikanth80@gmail.com at $50/$150)
- GitHub repo: https://github.com/laxmikanth80/ai-platform-foundation

### Next session
Pick up with the actual Terraform content — VPC + EKS cluster skeleton (Week 1–2 scope per the execution plan).
