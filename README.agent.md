# Set up the agent stack on a host

This guide works on macOS, Linux (Arch, Debian, Ubuntu), and WSL. It records the choices this repo makes and the traps that broke earlier setups. Use your own knowledge for package names and install commands. A repo-only task stops before it installs or deploys anything.

## Follow these rules on every host

- Inspect the host before you change it: OS, architecture, `$SHELL`, existing shell files, agent configs, and T3 provider paths. Present a plan, then apply it.
- Install only the tools this guide names. Use official packages, upstream installers, or upstream release assets for the detected architecture.
- Back up each file you replace under `~/.local/state/dotfiles/backups/<UTC timestamp>/`.
- Keep credentials, account files, and machine paths out of Git. Host-only shell settings go in `~/.zshrc.local`.
- Skip steps that are already done. Never append duplicate shell initialization.

## Install the base CLIs

Install Zsh, git, gh, rg, fd, fzf, zoxide, eza, bat, jq, unzip, just, hyperfine, ast-grep, sd, difftastic, watchexec, and Mike Farah's yq. On Linux, put tools that the distro lacks in `~/.local/bin` from upstream release assets.

Three tools have names that differ by host:

- Debian and Ubuntu name fd `fdfind` and bat `batcat`. Keep those names. `AGENTS.md` tells agents to fall back to them.
- Debian's `sg` is a group-switch command. Call `ast-grep`, and leave `/usr/bin/sg` alone.
- A Python program is also named `yq`. Check that `yq --version` names `mikefarah/yq`.

## Deploy the shell and agent links

`scripts/deploy.py` prints its plan. `scripts/deploy.py --apply` makes these absolute symlinks and backs up whatever it replaces:

- `~/.zshenv`, `~/.zprofile`, and `~/.zshrc` point to `shell/`.
- `~/.claude/settings.json` points to `agents/claude/settings.json`.
- `~/AGENTS.md` and `~/.codex/AGENTS.md` both point to `agents/home/AGENTS.md`. Codex reads `~/AGENTS.md` only when the project root is `~`, so it needs its own link.
- Each folder in `agents/skills/` is linked into `~/.agents/skills/`, `~/.claude/skills/`, and `~/.codex/skills/`. The script skips a skill path that something else already owns.

The script merges `agents/codex/config.base.toml` into `~/.codex/config.toml` instead of linking it. The merge keeps every host value that the base does not set, such as project trust, MCP servers, and host plugins. It writes a regular file with mode 0600. A run with nothing to change leaves the file untouched.

The script needs Python 3.11 or later. If the system Python is older, run it with `uv run --no-project --python 3.13 scripts/deploy.py`.

`.zshenv` owns PATH. It puts `~/.local/bin`, `~/.cargo/bin`, fnm's default Node, and both Homebrew prefixes first. `.zprofile` sources it again because macOS `path_helper` reorders PATH at login. `.zshrc` removes every alias defined before it, then loads `~/.zshrc.local` so a host can add its own.

## Install Node and Python

Install fnm with `--skip-shell --install-dir "$HOME/.local/bin"` on Linux, or from Homebrew on macOS. Use `FNM_DIR=~/.local/share/fnm`, then run `fnm install --lts` and `fnm default lts-latest`. No agent CLI needs this Node. It is for projects.

Install uv with `UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1`. Then run `uv python install 3.13`, `uv tool install ruff`, and `uv tool install ty`. Do not create global `python` or `python3` links.

## Install Claude Code

Use the native installer at `https://claude.ai/install.sh`. It puts the binary at `~/.local/bin/claude`.

The settings link selects pstack from `michael-denyer/pstack-claude` and turns off auto memory. It also loads `AGENTS.md` beside each `CLAUDE.md`. After you sign in, `/plugin` lists pstack. If it does not, run `/plugin marketplace add michael-denyer/pstack-claude` and then `/plugin install pstack@pstack-claude`.

Claude Code writes plugin and theme changes through the settings symlink into this repo. Review those writes before you commit. If Claude Code replaces the symlink with a regular file, the next `scripts/deploy.py` run reports it.

## Install Codex

Use the official standalone installer at `https://chatgpt.com/codex/install.sh` with `CODEX_INSTALL_DIR="$HOME/.local/bin"`. Read the installer before you run it, and back up the existing `codex` and `codex-code-mode-host` commands first. If `command -v codex` points to an npm or Homebrew install, pick one owner for updates before you continue.

Install the complete package. A host that had only the `codex` binary started Codex in T3, but every tool call failed because `codex-code-mode-host` was missing. The package lives under `~/.codex/packages/standalone/` and keeps `bin/codex`, `bin/codex-code-mode-host`, and `codex-resources/` together.

The config base registers pstack from `michael-denyer/pstack-claude`. If `codex plugin list --json` still shows an older pstack source, such as `pstack-for-codex@pstack-for-codex-local` or `pstack@pstack`, remove that plugin and its marketplace with `codex plugin remove` and `codex plugin marketplace remove`. Then trust pstack's `SessionStart` hook through `/hooks`.

The pstack model rows live in `agents/home/AGENTS.md`, so Claude and Codex share one list. The pstack session hook stays on because no `pstack-models.md` sheet says `session hook: off`.

## Register fff

Install `fff-mcp` from `dmtrKovalenko/fff` into `~/.local/bin`, or with `brew install dmtrKovalenko/fff/fff-mcp` on macOS. Run `scripts/register-fff.py` to see the plan, then add `--apply`. It registers the absolute path at user scope for Claude and Codex. Pass `--binary <path>` for a custom install. If an add fails, restore that client's config from the printed backup and run it again.

## Wire T3 Code

Set `providerInstances.<id>.config.binaryPath` in `~/.t3/userdata/settings.json` to the absolute path of each native binary, such as `/home/<user>/.local/bin/codex`. Do not use `~`, a bare command name, or a versioned release directory. The macOS app launches providers with the bare PATH `/usr/bin:/bin:/usr/sbin:/sbin` through `/bin/sh`, which never reads Zsh files.

Before you save a path, test it under that PATH:

```sh
env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin "$HOME/.local/bin/codex" app-server --help
```

On WSL, the Windows app starts a Linux T3 server, so all agent config lives in the Linux home. Windows paths such as `C:\Users\<user>\.codex` do not configure Linux providers.

After a `binaryPath` change, quit T3 Code completely and reopen it. Running sessions keep the old path.

## Verify the setup

1. Run `scripts/deploy.py --apply` twice. The second run changes nothing.
2. Run `python3 -m unittest discover -s tests`. The tests use disposable homes under `.checks/`.
3. Run `zsh -n` on each file in `shell/`. `zsh -ic 'alias; echo $PATH'` prints no aliases, no errors, and no repeated PATH entries.
4. `hyperfine --warmup 5 'zsh -i -c exit'` stays under 50 ms.
5. Start a fresh T3 session for Claude and for Codex. In each one, run a shell command and an fff search. A version string does not prove that tool calls work.
6. Before you commit, scan the diff for credentials and run `git diff --check`. Run `git pull --rebase` before you push to `main`.

Report what you verified separately from what you assumed.
