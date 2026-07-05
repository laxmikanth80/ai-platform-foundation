# ADR 0001: Record architecture decisions

## Status
Accepted

## Context
This project (and every chapter after it) needs a lightweight, durable record of *why* a
technical choice was made — not just what was built. Decisions made under time pressure are
easy to forget the reasoning behind; a senior interview asks for the reasoning, not the tool list.

## Decision
Use Architecture Decision Records (ADRs), one per significant decision, numbered sequentially,
stored in `docs/adr/`. Each ADR follows this shape: Status, Context, Decision, Consequences.

Write the ADR at the time the decision is made, not retroactively — if it's hard to write, the
decision probably isn't settled yet.

## Consequences
- Every non-trivial tool/architecture choice in this repo gets an ADR before or immediately after
  implementation.
- The handbook chapter for this project is compiled from these ADRs plus the README and
  lessons-learned notes — not authored separately from scratch.
