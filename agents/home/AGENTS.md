## UI and implementation decisions

Apply these rules to every layout. Cut taglines, redundant helper text, and secondary labels. If a screen needs explanatory copy or a separator to make sense, fix the layout. Retain permission disclosures, actionable errors, and accessible labels.

## Tools

For any file search or grep in the current git-indexed directory, use fff tools.

Other CLIs on PATH: `rg`, `fd` (`fdfind` on Debian/WSL), `bat` (`batcat`), `jq`, `yq` (mikefarah), `ast-grep` for structural search and rewrites (call `ast-grep`, not `sg`), `sd` for find-and-replace, `difft` for syntax-aware diffs, `watchexec` to rerun commands on file changes, `just`, `hyperfine` for benchmarks, `gh`, and `uv`, `ruff`, `ty` for Python. Check `command -v` before relying on one.
