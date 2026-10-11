# Agent stack inventory: WSL (Ubuntu on Windows)

Captured 2026-10-11 by Claude Opus 5.5 running in T3 Code on WSL2 Ubuntu (x86_64, kernel 6.18.33.2-microsoft-standard-WSL2).
Snapshot files live in [`inventory/wsl/`](wsl/). They are copies of the live config with secrets and machine-only entries removed. Diffs against the MacBook snapshot live in [`inventory/wsl/diffs/`](wsl/diffs/).

## What drives agent behavior

| Piece | Live path | Snapshot | Differs from MacBook |
|---|---|---|---|
| Global Claude instructions | `~/.claude/CLAUDE.md` | none: **file absent** | Yes, missing. [`diffs/claude-CLAUDE.md.diff`](wsl/diffs/claude-CLAUDE.md.diff) |
| Claude settings: pstack plugin and marketplace, `theme: "dark"`, no `promptCacheTtl` | `~/.claude/settings.json` | `claude/settings.json` | Yes. [`diffs/claude-settings.json.diff`](wsl/diffs/claude-settings.json.diff) |
| pstack plugin 1.1.0 from `painhardcore/pstack` (commit `04830a9`), installed for Claude and Codex | `~/.claude/plugins/`, `~/.codex/plugins/cache/pstack/` | none (installed from settings) | Yes: different repo and version (MacBook: `michael-denyer/pstack-claude` 0.9.53) |
| Home git guardrails | `~/AGENTS.md` | none: **file absent** | Yes, missing. [`diffs/home-AGENTS.md.diff`](wsl/diffs/home-AGENTS.md.diff) |
| Codex writing style (Hemingway) | `~/.codex/AGENTS.md` | none: **file absent in WSL** | Yes, missing. [`diffs/codex-AGENTS.md.diff`](wsl/diffs/codex-AGENTS.md.diff). The Windows Codex app has a byte-identical copy at `C:\Users\Mike\.codex\AGENTS.md`, but WSL Codex does not read it. |
| Codex custom agent: `luna-executor` only | `~/.codex/agents/*.toml` | `codex/agents/` | Yes: MacBook has explorer, oracle, verifier, worker. [`diffs/codex-agents-worker-vs-luna-executor.diff`](wsl/diffs/codex-agents-worker-vs-luna-executor.diff) |
| Codex config: pragmatic personality, pstack plugin, `openaiDeveloperDocs` MCP server. No model, no `[agents]` limits | `~/.codex/config.toml` | `codex/config.portable.toml` | Yes. [`diffs/codex-config.portable.toml.diff`](wsl/diffs/codex-config.portable.toml.diff) |
| Codex launcher for T3 | none | none: **absent** | Yes. Not needed for PATH here; see T3 section. [`diffs/bin-codex-t3.diff`](wsl/diffs/bin-codex-t3.diff) |
| T3 settings | `~/.t3/userdata/settings.json` | `t3/settings.json` | MacBook did not copy its own; summary below |
| Login-shell PATH and fnm init | `~/.zprofile` (untracked) | `shell/.zprofile` | Not in MacBook inventory |
| PATH dedupe (`typeset -U path PATH`) | `~/.zshrc.local` (untracked) | none (gitignored `*.local`); that line is its only content | Not in MacBook inventory |
| Cloudflare agent skills: cloudflare, wrangler, durable-objects, workers-best-practices, agents-sdk, sandbox-sdk, web-perf, turnstile-spin, cloudflare-email-service | `~/.config/agents/skills/` | not copied | Not in MacBook inventory |
| claude.ai synced skills | `~/.claude/skills/synced/` | not copied | Same set; syncs with account login |
| Pi agent web-search policy | `~/.pi/agent/AGENTS.md` (from `Mona-kecil/mona-pi-setup`) | not copied | Pi only; not used by Claude, Codex, or T3 |

Not tracked, by design: `~/.codex/auth.json`, `~/.claude/.credentials.json`, `~/.t3/userdata/secrets/`, sessions, memory, caches, and Codex `[projects.*]` trust entries and `[tui]` state.

## T3 settings and how T3 starts providers

**T3 runs in both places.** The desktop app is installed on Windows (`C:\Users\Mike\AppData\Local\Programs\t3code`). It starts the T3 server inside WSL:

```
Windows T3 desktop → wsl.exe → /init → ~/.t3/wsl-runtime/<sha256>/t3 --bootstrap-fd 0
```

The server is a Linux binary. It listens on `0.0.0.0:3773`, labels itself `Monosodiums`, and runs a `cloudflared` tunnel child. Providers are direct children of that server process, not of a shell.

**Claude.** No custom provider instance. `providerInstances.claudeAgent.config.binaryPath = "claude"`, which resolves to `~/.local/bin/claude` (native install, 2.1.296). T3 passes these arguments:

```
claude --output-format stream-json --input-format stream-json --verbose
  --model claude-opus-5-5[1m] --effort high --thinking adaptive --thinking-display summarized
  --permission-mode bypassPermissions --allow-dangerously-skip-permissions --permission-prompt-tool stdio
  --mcp-config '{"mcpServers":{"t3-code":{"type":"http","url":"http://127.0.0.1:3773/mcp","headers":{"Authorization":"Bearer <redacted>"}}}}'
  --allowedTools 'mcp__t3-code__*' --tools default --include-partial-messages
  --add-dir <thread scratch dir> --add-dir ~/.t3/userdata/attachments
  --session-id=<uuid> --settings '{"fastMode":false,"showThinkingSummaries":true}'
```

There is no `autoCompactWindow` override.

**Codex.** No `providerInstances.codex` entry, so T3 uses the built-in default (`binaryPath` `codex`). It resolves to the fnm shim `/run/user/1000/fnm_multishells/<id>/bin/codex` → `@openai/codex` **0.161.0**, installed by npm on 2026-10-07 under Node v24.19.0. **This install is broken.** It lacks the `@openai/codex-linux-x64` optional dependency, so `codex --version` throws `Missing optional dependency @openai/codex-linux-x64`. T3's `probeCodexAppServerProvider` fails with `CodexAppServerProcessExitedError: ... exited with code 1` on every probe today. T3's default model is `codex / gpt-6.1-sol` at `xhigh`, so new threads default to a provider that cannot start.

**Other T3 settings.**
- `defaultModelSelection`: `codex` / `gpt-6.1-sol`, `reasoningEffort: xhigh`, `serviceTier: default`
- `textGenerationModelSelection`: `codex` / `gpt-6-luna`, `reasoningEffort: medium`
- cursor, grok, opencode disabled; device support and agent device access enabled
- Storage cleanup: worktrees after 8 days and on merge, delete, or unchanged; browser artifacts and logs after 7 days
- Environment preferences: `newWorktreesStartFromOrigin = true`, provider update checks on, background activity `balanced`, source-control writing style `repo_conventions`. These match the MacBook.

**PATH the providers see.** It is full, not bare. The `t3` server process has:

```
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
:/run/user/1000/fnm_multishells/599_…/bin:~/.local/share/fnm:~/.local/bin
:… :/usr/games:/usr/local/games:/usr/lib/wsl/lib
:<34 Windows entries under /mnt/c/…> :/snap/bin
```

The Claude provider process has a different PATH, with fnm and `~/.local/bin` first:

```
/run/user/1000/fnm_multishells/664_…/bin:~/.local/share/fnm:~/.local/bin
:/run/user/1000/fnm_multishells/635_…/bin
:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
:/run/user/1000/fnm_multishells/599_…/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib
:<34 Windows entries under /mnt/c/…> :/snap/bin
```

Two fresh fnm multishells (635, then 664) and deduped entries match `~/.zprofile`, then `~/.zshrc`, each running `fnm env` with `typeset -U path PATH` from `~/.zshrc.local`. T3 likely resolves the user's login and interactive zsh environment and passes it to providers. Agent shells see `eza`, `rg`, `fdfind`, `batcat`, `gh`, `node`, and `codex`.

The Windows PATH is appended (WSL `appendWindowsPath` default). Today no Windows `codex`, `claude`, or `node` shadows the Linux ones, because Linux entries come first. A Windows `node` exists at `/mnt/c/Program Files/nodejs/` and would win if fnm init ever failed.

## Findings

1. **Codex is down in T3 on WSL.** See above. Fix: `npm install -g @openai/codex@latest` under fnm's default Node, then confirm `codex --version` and a T3 Codex thread.
2. **This machine lacks the instructions that make the MacBook Opus behave the way the user likes.** There is no `~/.claude/CLAUDE.md`, no `~/AGENTS.md`, and no WSL `~/.codex/AGENTS.md`. Only pstack and T3 defaults shape behavior here.
3. **Three different pstack sources.** WSL Claude and Codex use `painhardcore/pstack` 1.1.0. MacBook Claude uses `michael-denyer/pstack-claude` 0.9.53, and MacBook Codex uses `Aqua-123/pstack-for-codex`. The shared setup needs one choice per tool.
4. **Model drift here too.** `luna-executor.toml` pins `gpt-5.6-luna`. The Windows Codex app config pins `gpt-5.5` at `medium`. T3 defaults use `gpt-6.1-sol` and `gpt-6-luna`.
5. **Login-shell setup is untracked.** `~/.zprofile` and `~/.zshrc.local` hold the PATH and fnm init that make non-interactive login shells work (Pi services, T3 providers). Neither is in the repo.
6. **fnm multishell dirs pile up.** Every shell start adds a symlink under `/run/user/1000/fnm_multishells/` (9 today), and provider PATHs embed three of them. They point at `aliases/default`, so they work until WSL restarts. `~/.local/share/fnm/aliases/default/bin` is the stable path, as the MacBook `codex-t3` wrapper already uses.
7. **`tldr` is tealdeer here**, not the npm `tldr` that `README.agent.md` specifies.

## CLI tools

Present: zsh 5.9, tmux 3.4, git 2.43.0, gh 2.97.0, rg 14.1.0, fdfind 9.0.0 (as `fdfind`; no `fd`), fzf 0.44.1, zoxide 0.9.3, eza 0.18.2, bat 0.24.0 (as `batcat`; no `bat`), btop 1.3.0, jq 1.7, unzip 6.00, fnm 1.39.0, node 24.19.0, npm 11.17.0, pnpm 11.10.0, uv 0.11.8, ruff 0.16.1, ty 0.0.69, tldr (tealdeer 1.9.0), code 1.133.0 (Windows VS Code via WSL), claude 2.1.296, codex-cli 0.161.0 (**broken**), pi 0.84.4, kimi 1.41.0.

Missing: fff, ast-grep, yazi, delta, lazygit, just, hyperfine, Homebrew (not expected on WSL).

Older than the MacBook: git, rg, fzf, zoxide, bat, btop come from Ubuntu 24.04 apt.

## What the target setup should include that the MacBook lacks

- A tracked `zsh/.zprofile` with PATH and `fnm env`, plus `typeset -U path PATH`. Login shells need it on every host.
- The `openaiDeveloperDocs` MCP server in Codex config.
- pstack 1.1.0, if `painhardcore/pstack` is the chosen source. It is newer than 0.9.53.
- The Cloudflare skill set in `~/.config/agents/skills/`, if Cloudflare work is part of the shared workflow.
- A WSL-specific rule: T3 runs on Windows but its server and providers run in WSL. All agent config belongs in the Linux home, not `C:\Users\Mike`.

## Disagreements with the MacBook findings

1. **Bare PATH (finding 1) is macOS-specific.** On WSL, T3 starts its server through `wsl.exe` and gives providers the login-shell PATH, so no wrapper is needed. I agree the shared fix belongs in login-shell config (`.zprofile`) rather than interactive `.zshrc`. Keep `codex-t3` as a macOS-only shim, or point `binaryPath` at `~/.local/share/fnm/aliases/default/bin/codex` on both hosts.
2. **Model drift (finding 2):** agreed, and it is worse across three Codex configs (MacBook, WSL, Windows app).
3. **Old uv (finding 3):** agreed. WSL has 0.11.8.
4. **Missing tools:** fff, ast-grep, and yazi are missing here too. delta, lazygit, just, and hyperfine are MacBook-only. `README.agent.md` lists none of them, so the shared layout should decide whether they belong.
