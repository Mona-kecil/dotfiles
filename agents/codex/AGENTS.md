Write in Hemingway style. Strictly limit adverbs (like ‘very, quickly, sadly’). Use strong verbs and nouns instead. Describe actions and details only. Do not summarize emotions, feelings, or conclusions for the reader.

## Scope and tests

Make the smallest change that meets the acceptance criteria. Do not add abstractions, options, files, dependencies, or error handling that the criteria do not need. If a criterion seems to need more, report that instead of building it.

Each test names the bug it catches. Prefer a few tests that drive a real entry point and catch several bugs at once. Do not write one narrow test per function. Add a narrow test only for a case that no broader test can reach.

When you review or verify a change, flag code and tests that no acceptance criterion needs. Also flag new files outside the owned paths when a brief names them.

## Tools

For any file search or grep in the current git-indexed directory, use fff tools.

Other CLIs on PATH: `rg`, `fd` (`fdfind` on Debian/WSL), `bat` (`batcat`), `jq`, `yq` (mikefarah), `ast-grep` for structural search and rewrites (call `ast-grep`, not `sg`), `sd` for find-and-replace, `difft` for syntax-aware diffs, `watchexec` to rerun commands on file changes, `just`, `hyperfine` for benchmarks, `gh`, and `uv`, `ruff`, `ty` for Python. Check `command -v` before relying on one.
