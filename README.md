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

### Concepts covered
- **Python packaging** — `pyproject.toml` declares the project (name, Python version, dependencies) so a folder of scripts becomes a real installable project. `uv sync` / `pip install -e .` makes `import platform_foundation` work cleanly anywhere in the repo, with dependencies pinned and reproducible instead of "whatever's installed globally."
- **Linting vs. testing** — linting (`ruff check .`) is static analysis: catches style issues, unused imports, likely bugs, *without running the code*. Testing (`pytest`) actually runs the code and checks behavior. Different jobs, both needed.
- **pre-commit** — wires checks (ruff, formatting, YAML validation, etc.) directly into `git commit`, so they run locally *before* a commit completes. Config lives in `.pre-commit-config.yaml`; one-time setup per repo is `pre-commit install` (wires into `.git/hooks/pre-commit`) — after that, every commit auto-triggers it.
- **pre-commit vs. CI** — pre-commit is the fast local loop; CI (`.github/workflows/ci.yml`) is the server-side backstop that reruns the same checks on GitHub for every push/PR, catching anything that slipped past pre-commit (e.g. a commit made with `--no-verify`, or pushed from a machine without the hooks installed).
- **`uv` workflow** — `uv sync --extra dev` reads `pyproject.toml`, creates a `.venv/`, and installs the project plus its `dev` dependencies, pinned in `uv.lock` for reproducibility. `uv run <command>` runs something inside that venv without manually activating it — e.g. `uv run pytest`, `uv run ruff check .`.
- **Why this exact combination matters:** this is what "production-first mindset" cashes out to in practice for any repo. The pattern (`pyproject.toml` + pre-commit + CI) is identical across all 8 chapters — fluency here means every later chapter is "copy and adjust," not "relearn from scratch."

### Next session
Pick up with the actual Terraform content — VPC + EKS cluster skeleton (Week 1–2 scope per the execution plan).

## Day 2 log — Week 2, GitOps pipeline

### Completed
- Wrote the full CI/CD pipeline ahead of standing up the cluster: ECR repo, a slimmer OIDC/IAM role for GitHub Actions (ECR push only — no EKS access), the hello-world FastAPI app + Dockerfile + tests, the CI build/push workflow, the `k8s/` manifests, and the Argo CD `Application` manifest — all before spending a cent on the cluster itself.
- Ran `terraform apply`: VPC, EKS cluster, node group, ECR, and the IAM/OIDC role all created successfully.
- Installed Argo CD via Helm, verified access via `kubectl port-forward`.
- Applied the Argo CD `Application` manifest — GitOps is now actually live for this project.

### Real problems hit and fixed (all genuine, all worth remembering)
1. **GitHub OIDC provider already existed in this AWS account** (from an earlier, unrelated project) — an account can only have one per URL, since it's account-wide shared infrastructure, not scoped per-repo. Resolved by deleting the old one manually and letting Terraform create a fresh one for this project.
2. **EKS cluster had no public endpoint access by default** — `kubectl` failed with a DNS resolution error (`no such host`) because the module's default left `cluster_endpoint_public_access` off. Fixed by setting it to `true` explicitly (in-place update, no cluster recreation needed).
3. **IAM permissions ≠ Kubernetes RBAC access** — `platform-foundation-admin` had full `AdministratorAccess` in IAM but zero access *inside* the cluster, because EKS access control (access entries) is a completely separate system. `kubectl` failed with "the server has asked for the client to provide credentials" until `enable_cluster_creator_admin_permissions = true` was set.
4. **Argo CD correctly deployed a broken placeholder** — the first sync produced `ImagePullBackOff`, because the manifest still had the literal `CI_IMAGE_TAG` placeholder (CI hadn't run yet). This was actually proof the GitOps reconciliation loop works correctly — it deployed exactly what Git said, faithfully, even though what Git said was wrong.
5. **Branch protection blocked the bot's own auto-commit** — the CI job commits the real image tag back to `main` with `[skip ci]` (to avoid an infinite trigger loop), but branch protection required the `lint-and-test` status check to have passed *for that exact commit* — which `[skip ci]` guarantees never happens. Relaxed branch protection to drop the required status check, since the workflow's own `needs: lint-and-test` dependency already provides that guarantee for the commit that matters.
6. **"Re-run failed jobs" collided with ECR's immutable tags** — since `IMAGE_TAG` is the git SHA, re-running the same failed workflow run tried to re-push to a tag that already existed (the first attempt's Docker push had actually succeeded before failing later at the git-push step). Immutability correctly refused the overwrite. Lesson: for this pipeline, always trigger a fresh commit to recover from a failure — never "re-run failed jobs."

### Concepts covered
- **EKS access entries vs. IAM permissions** — two entirely separate authorization layers. IAM controls what an identity can do to *AWS resources*; EKS access entries control what that same identity can do *inside a specific cluster's Kubernetes API*. Full IAM admin grants nothing inside a cluster on its own.
- **GitOps vs. Argo CD** — GitOps is the pattern (declarative, versioned, pulled, continuously reconciled); Argo CD is one tool that implements it. Flux is the other major one.
- **The "bootstrap problem"** — something has to install the GitOps agent itself, and that one step can't be GitOps (nothing exists yet to do the pulling). Everything after that bootstrap flows through Argo CD.
- **Helm as a Kubernetes package manager** — bundles many related manifests (Argo CD alone is a dozen-plus objects) into one versioned, templated chart.
- **Public vs. private EKS endpoint access** — a real security trade-off, not an oversight: public+unrestricted is simplest for a laptop that changes networks, at the cost of a larger network attack surface (though actual access is still fully gated by IAM + access entries, not network position).

### Next session
Confirm the pod actually reaches `Running` once this commit flows through CI → ECR → Argo CD sync, then move on to Week 2's remaining scope.
