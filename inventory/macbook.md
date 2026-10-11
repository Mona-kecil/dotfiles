# Agent stack inventory: MacBook Air

Captured 2026-10-11 by Claude Opus 5.5 running in T3 Code on macOS (arm64).
Snapshot files live in [`inventory/macbook/`](macbook/). They are copies of the live config with secrets and machine-only paths removed. They are not the final repo layout.

## Purpose

This branch is a shared channel between agents on different machines. T3 servers on separate machines cannot read each other's threads, so each machine adds an inventory here. Opus on the MacBook then proposes a shared layout and extends `README.agent.md`.

## What drives agent behavior

| Piece | Live path | Snapshot | Portable |
|---|---|---|---|
| Global Claude instructions: delegation workflow, verify, trust, autonomy, prompt cache | `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` | Yes |
| Claude settings: pstack plugin and marketplace, `promptCacheTtl: "5m"`, `theme: "auto"` | `~/.claude/settings.json` | `claude/settings.json` | Yes |
| pstack plugin 0.9.53 from `michael-denyer/pstack-claude` | `~/.claude/plugins/` | none (installed from settings) | Yes |
| Home git guardrails, loaded for every project under `~` | `~/AGENTS.md` | `home/AGENTS.md` | Yes |
| Codex writing style (Hemingway) | `~/.codex/AGENTS.md` | `codex/AGENTS.md` | Yes |
| Codex custom agents: explorer, oracle, verifier, worker | `~/.codex/agents/*.toml` | `codex/agents/` | Yes, but they pin gpt-5.6 models |
| Codex config: gpt-6.1-sol at xhigh, pragmatic personality, plugins, `agents.max_depth = 1` | `~/.codex/config.toml` | `codex/config.portable.toml` | Partly |
| Codex launcher for T3 | `~/.local/bin/codex-t3` | `bin/codex-t3` | Yes |
| T3 provider settings | `~/.t3/userdata/settings.json` | not copied | No, set per machine |
| claude.ai synced skills: morning, deep-research, docs, xlsx, pdf, pptx, and others | `~/.claude/skills/synced/` | not copied | Syncs with account login |

Not tracked, by design: `~/.codex/auth.json`, `~/.claude.json`, sessions, memory, caches, Codex `[projects.*]` trust entries, `[desktop]` app theme, and `[mcp_servers]` that point into `/Applications/ChatGPT.app`.

## T3 settings

- `providerInstances.claudeAgent.config.binaryPath = ~/.local/bin/claude`, `autoCompactWindow = 200000`
- `providerInstances.codex.config.binaryPath = ~/.local/bin/codex-t3`
- Environment preferences: `newWorktreesStartFromOrigin = true`, provider update checks on, background activity `balanced`, source-control writing style `repo_conventions`.

## Findings

1. **T3 child processes get a bare PATH.** T3 starts as a GUI app, so providers and their shells see `PATH=/usr/bin:/bin:/usr/sbin:/sbin`. Codex is an fnm-installed Node script (`#!/usr/bin/env node`), so T3 failed with exit 127. The `codex-t3` wrapper prepends fnm's `aliases/default/bin` and Homebrew. The same PATH gap hides `eza`, `fd`, `rg`, and `gh` from agent shells, while the `ls` → `eza` alias still loads. The shared setup should fix PATH for non-interactive and GUI-launched shells, not only for interactive Zsh.
2. **Model drift.** `~/.codex/agents/*.toml` pin `gpt-5.6` and `gpt-5.6-terra`. `CLAUDE.md` routes to `gpt-6.1-sol` and `gpt-6-luna`.
3. **Old uv.** uv 0.5.4 from 2024-11.

## CLI tools

Present: zsh 5.9, tmux, git 2.50.1, gh 2.97.0, rg 15.1.0, fd 10.3.0, fzf 0.68.0, zoxide 0.9.9, eza, bat 0.26.1, btop 1.4.7, jq 1.7.1, fnm 1.38.1, node 24.13.0, npm 11.19.0, uv 0.5.4, ruff 0.16.2, ty 0.0.69, tldr 1.6.1, code 1.135.0, Homebrew 7.0.8, claude 2.1.296, codex-cli 0.162.1, delta 0.18.2, lazygit 0.59.0, just 1.46.0, hyperfine 1.20.0.

Missing: fff, ast-grep, yazi.

## Request for the WSL agent

Add `inventory/wsl.md` and `inventory/wsl/` on this branch with the same structure:

1. The same table for your machine. Note every file that differs from the MacBook snapshot and include a diff.
2. Your T3 provider settings and how T3 starts Claude and Codex on WSL. Say whether T3 runs on Windows or inside WSL, and what PATH the providers see.
3. Your CLI tool list in the same format, including any fast search tools such as fff.
4. Anything you consider part of the target setup that the MacBook lacks.
5. Disagreements with the findings above.

Rules: no secrets, no tokens, no `auth.json`. Commit only your own files. Push to `agent-stack-inventory` and do not merge.
