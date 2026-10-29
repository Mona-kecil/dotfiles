## UI and implementation decisions

Apply these rules to every layout. Cut taglines, redundant helper text, and secondary labels. If a screen needs explanatory copy or a separator to make sense, fix the layout. Retain permission disclosures, actionable errors, and accessible labels.

## Tools

For any file search or grep in the current git-indexed directory, use fff tools.

Other CLIs on PATH: `rg`, `fd` (`fdfind` on Debian/WSL), `bat` (`batcat`), `jq`, `yq` (mikefarah), `ast-grep` for structural search and rewrites (call `ast-grep`, not `sg`), `sd` for find-and-replace, `difft` for syntax-aware diffs, `watchexec` to rerun commands on file changes, `just`, `hyperfine` for benchmarks, `gh`, and `uv`, `ruff`, `ty` for Python. Check `command -v` before relying on one.

## pstack model overrides

feature, refactoring: gpt-6.1-sol @high
bug-fix: gpt-6.1-sol @high
perf-issue: gpt-6.1-sol @high
hillclimb: gpt-6.1-sol @high
judgment and prose: gpt-6.1-sol @high
strongest judgment: gpt-6.1-sol @high, gpt-6-astra @high
how explorer: gpt-6.1-sol @high
how explainer: gpt-6.1-sol @high
why investigators: gpt-6.1-sol @high
why synthesizer: gpt-6.1-sol @high
reflect tooling: gpt-6.1-sol @high
reflect judgment, divergent, synthesizer: gpt-6.1-sol @high
arena runners: gpt-6.1-sol @high, gpt-6-luna @xhigh
arena cross-judge pool: gpt-6.1-sol @high, gpt-6-luna @xhigh
swarm workers: gpt-6.1-sol @high
architect runners: gpt-6.1-sol @high, gpt-6-luna @xhigh
interrogate reviewers: gpt-6.1-sol @high, gpt-6-luna @xhigh

default effort: session
