# Week 1 — AI Platform Foundation

**Jul 5 – Jul 11, 2026 · Status: complete**

## Infrastructure
- IAM user `platform-foundation-admin` created (off root), `AdministratorAccess` attached, CLI profile `platform` configured
- AWS Budget `platform-foundation-monthly` — $150/mo cap, email alerts at $50/$150
- GitHub repo live: `github.com/laxmikanth80/ai-platform-foundation`, branch protection on `main` (requires CI to pass, blocks force-push/deletion) + CODEOWNERS

## Python packaging
- `pyproject.toml`, `.pre-commit-config.yaml`, CI workflow (`ci.yml`) all working end-to-end — `uv sync --extra dev`, `pytest`, `ruff check` all pass, pre-commit hook installed and firing on commits

## Terraform — VPC + EKS skeleton
- Wrote the full module-based config: `terraform-aws-modules/vpc/aws` + `.../eks/aws`, 2 AZs, single NAT gateway (cost-optimized), 1x `t3.medium` node group
- `terraform init` / `validate` / `plan` all succeeded — 53 resources ready to create
- **Deliberately not applied yet** — cost-conscious call, since standing it up now would mean ~$135-140/month burning idle until Week 2 actually uses it

## Documentation
- ADR-0001 (why this repo uses ADRs at all) and ADR-0002 (why community Terraform modules over hand-rolled resources, plus the NAT/cost trade-offs) both written and committed
- README Day 1 log captures full day-by-day detail, plus a "concepts covered" section

## Environment fixes along the way
Not part of the curriculum, but real time spent: `git`, `gh`, `uv`, `tfenv`/`terraform`, and Python 3.11 were all stale x86_64 binaries left over on this now-Apple-Silicon Mac — all fixed via native arm64 Homebrew installs. If `bad CPU type in executable` shows up again on this machine, check `file $(which <tool>)` first.

## Concepts covered
- Python packaging vs. linting vs. testing
- pre-commit vs. CI (fast local loop vs. server-side backstop)
- IAM least-privilege vs. `AdministratorAccess` trade-offs on a solo sandbox account
- Why a NAT gateway exists — private-subnet security rationale, outbound-only asymmetric routing
- Community Terraform modules vs. hand-rolled resources — velocity/battle-tested defaults vs. less line-by-line control

## Carried into Week 2
- Actually run `terraform apply` and stand up the live EKS cluster
- Get the CI/CD pipeline deploying a first "hello world" service through it
