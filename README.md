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
- [ ] AWS sub-account + IAM user (not root) created
- [ ] AWS Budget + billing alarm set ($50 / $150 thresholds)
- [ ] GitHub repo pushed, branch protection + CODEOWNERS added
- [ ] Terraform: VPC + EKS cluster skeleton (`terraform/`)
- [ ] Python packaging + pre-commit + linting working (`pyproject.toml`, `.pre-commit-config.yaml`)

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
