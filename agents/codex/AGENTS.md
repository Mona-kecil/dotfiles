Write in Hemingway style. Strictly limit adverbs (like ‘very, quickly, sadly’). Use strong verbs and nouns instead. Describe actions and details only. Do not summarize emotions, feelings, or conclusions for the reader.

## Scope and tests

Make the smallest change that meets the acceptance criteria. Do not add abstractions, options, files, dependencies, or error handling that the criteria do not need. If a criterion seems to need more, report that instead of building it.

Each test names the bug it catches. Prefer a few tests that drive a real entry point and catch several bugs at once. Do not write one narrow test per function. Add a narrow test only for a case that no broader test can reach.

When you review or verify a change, flag code and tests that no acceptance criterion needs. Also flag new files outside the owned paths when a brief names them.

## Tools

For any file search or grep in the current git-indexed directory, use fff tools.

Other CLIs on PATH: `rg`, `fd` (`fdfind` on Debian/WSL), `bat` (`batcat`), `jq`, `yq` (mikefarah), `ast-grep` for structural search and rewrites (call `ast-grep`, not `sg`), `sd` for find-and-replace, `difft` for syntax-aware diffs, `watchexec` to rerun commands on file changes, `just`, `hyperfine` for benchmarks, `gh`, and `uv`, `ruff`, `ty` for Python. Check `command -v` before relying on one.

## Discord pings

When the user asks for Discord notifications while stepping away from long tasks, read the global webhook URL from `~/.codex/discord-webhook.url`. Use it across projects without asking the user to paste it again. If the user supplies a different webhook for a task, use that webhook for the task. Send short pings only for real blockers or decisions that need their input.

Mention the user with `<@871768827250217052>` and include `allowed_mentions: {"users": ["871768827250217052"]}` in the payload. The webhook is one-way; the user replies in the T3 thread.

Keep the webhook URL in the global config file; do not copy it into memory, repository files, or logs. Never send secrets to Discord or ask the user to paste API keys there. Ask them to put keys in `.env.local` instead.

## pstack model routing

Replace Astra assignments with GPT-6.1-Sol at xhigh. Keep Luna for comparisons and light tasks. Do not spawn GPT-6-Sol or Astra. These rows mirror `/Users/monakecil/.codex/pstack-models.md`.

feature, refactoring: gpt-6.1-sol @xhigh
bug-fix: gpt-6.1-sol @xhigh
perf-issue: gpt-6.1-sol @xhigh
hillclimb: gpt-6.1-sol @xhigh
judgment and prose: gpt-6.1-sol @xhigh
strongest judgment: gpt-6.1-sol @xhigh
how explorer: gpt-6.1-sol @xhigh
how explainer: gpt-6.1-sol @xhigh
why investigators: gpt-6.1-sol @xhigh
why synthesizer: gpt-6.1-sol @xhigh
reflect tooling: gpt-6.1-sol @xhigh
reflect judgment, divergent, synthesizer: gpt-6.1-sol @xhigh
arena runners: gpt-6.1-sol @xhigh, gpt-6-luna @high
arena cross-judge pool: gpt-6.1-sol @xhigh, gpt-6-luna @high
swarm workers: gpt-6.1-sol @xhigh
architect runners: gpt-6.1-sol @xhigh, gpt-6-luna @high
interrogate reviewers: gpt-6.1-sol @xhigh, gpt-6-luna @high

default effort: session
