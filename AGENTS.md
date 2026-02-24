# Agent Guardrails

These rules apply to all agent-generated code in this workspace unless a deeper `AGENTS.md` overrides them.

## Deterministic CI Gates (Required)

Every code change must pass these gates in this order:

1. `oxfmt --check`
2. `oxlint --deny-warnings`
3. `tsc --noEmit`
4. `vitest run --coverage`

Fail fast on the first failing gate. Do not bypass a failing gate.

## Review And Merge Policy

- Use Graphite for code review.
- No direct merge for agent-generated code without review.
- All required CI gates must be green before merge.

## Graphite Workflow Pattern

- Optimize for small, single-purpose PRs (stacked when related).
- Prefer one coherent commit per PR when possible.
- Split work by dependency boundaries and stack bottom-up.
- Land PRs from the bottom of the stack first.
- Rebase/sync stacks frequently to keep review diffs clean.
- Avoid large, long-lived stacks when smaller independently shippable PRs are possible.

## Observability Requirements

- Use Axiom for operational observability (logs/events).
- Use PostHog for product analytics and feature flags.
- New or changed user-facing flows must include at least one PostHog event.
- New or changed backend critical paths must emit structured logs to Axiom.

## Determinism Rules

- Pin tool versions via lockfiles and CI image.
- Keep all configs in-repo.
- CI checks must be pass/fail (no warn-only for required gates).
- Do not rely on auto-fix in CI.
