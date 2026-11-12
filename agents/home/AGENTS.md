## UI and implementation decisions

Apply these rules to every layout. Cut taglines, redundant helper text, and secondary labels. If a screen needs explanatory copy or a separator to make sense, fix the layout. Retain permission disclosures, actionable errors, and accessible labels.

## Tools

For any file search or grep in the current git-indexed directory, use fff tools when the session exposes them. Otherwise use `rg` and `fd`.

Installed CLIs differ by host, so run `command -v` before using one, and fall back to what is there: `rg`, `fd` (`fdfind` on Debian/WSL), `bat` (`batcat`), `jq`, `yq` (mikefarah), `ast-grep` for structural search and rewrites (call `ast-grep`, not `sg`), `sd` for find-and-replace, `difft` for syntax-aware diffs, `watchexec` to rerun commands on file changes, `just`, `hyperfine` for benchmarks, `gh`, and `uv`, `ruff`, `ty` for Python.

## Calling the other agent

In a T3 Code session, Claude and Codex call each other through T3's `delegate_task` tool, which may carry an `mcp__t3-code__` prefix. Native subagents can't cross that line: Claude's `Agent` tool rejects `gpt-*` models, and Codex can't run Claude models.

Call `orchestrator_capabilities` first and use only what its catalog lists. Then set `target` from this table:

| Row entry | `providerInstanceId` | `model` | `options` |
| --- | --- | --- | --- |
| `gpt-6.1-sol @high` | `codex` | `gpt-6.1-sol` | `{ "reasoningEffort": "high" }` |
| `opus @high` | `claudeAgent` | `claude-opus-5-5` | `{ "effort": "high" }` |

Other `gpt-*` and Claude models follow the same shape. The two providers use different effort option names, and the full Claude ID only works here; pstack rows and Claude's `Agent` tool use `opus`.

The child sees only your `task` text, so include the goal, context, paths, and the evidence you want back.

Panel rows run one agent per entry. On any other row, take the first entry you can run natively. Delegate only when none qualifies or the user names a model.

Outside T3 Code these tools don't exist. If a model can't be reached, say so instead of switching models.

## pstack model overrides

feature, refactoring: sonnet @high
bug-fix: sonnet @high
perf-issue: gpt-6.1-sol @high
hillclimb: gpt-6.1-sol @high
judgment and prose: opus @high
strongest judgment: gpt-6-astra @high, opus @high
how explorer: sonnet @high
how explainer: opus @high
why investigators: sonnet @high
why synthesizer: opus @high
reflect tooling: sonnet @high
reflect judgment, divergent, synthesizer: opus @high
arena runners: gpt-6.1-sol @high, opus @xhigh
arena cross-judge pool: gpt-6.1-sol @high, opus @xhigh
swarm workers: sonnet @high
architect runners: gpt-6.1-sol @high, opus @xhigh
interrogate reviewers: gpt-6.1-sol @high, opus @xhigh
thermos reviewers: opus @high
no-comments reviewer: sonnet @high

default effort: session
