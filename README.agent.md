# Agent stack setup

Run this spec on macOS, Debian/Ubuntu, or WSL. Inspect the host and adapt each step. Commands below describe host setup; a repo-only task must stop before installation or deployment.

## 1. Detect the host

Read `uname -s`, `uname -m`, the Linux release file, `$SHELL`, and installed command paths. Detect WSL through `WSL_DISTRO_NAME` or `/proc/sys/kernel/osrelease`. Use `/bin/ls` and `/usr/bin/grep` during inspection so host shell overrides cannot change the command.

Inspect existing shell files, fnm state, agent configs, T3 provider paths, and `inventory/`. Treat inventory files as evidence from a named host, not deployable config. Present a plan with the host, install sources, links, backups, and checks before applying it.

Operating principles:

- Inspect before changing a host. Install only the tools in this spec.
- Back up each replaced file in a UTC timestamped directory. Keep backups on the host, outside Git.
- Use upstream installers, upstream release assets, or official package repositories. Check architecture and available package candidates before installation.
- Skip satisfied steps. Replace owned settings; preserve unrelated host settings. Never append duplicate shell initialization.
- Keep credentials, private keys, account files, and machine paths out of Git. Do not print account config values into reports.
- Deploy tracked config with absolute symlinks. Merge the Codex base into a regular host file.
- Validate behavior and report versions, command paths, changed links, backup paths, skipped steps, and gaps.

Keep this repo public. Local overrides belong in `~/.zshrc.local`. Authentication and T3 provider settings stay on each host.

## 2. Base CLIs

Install Zsh, git, gh, rg, fd, fzf, zoxide, eza, bat, jq, unzip, just, hyperfine, ast-grep, sd, difftastic, watchexec, and Mike Farah's yq. Install `curl` and CA certificates as installer prerequisites. Resolve executables with `command -v` after each install.

Package names and executable names:

| Tool | macOS Homebrew package → executable | Debian/Ubuntu/WSL source → executable | Primary source |
| --- | --- | --- | --- |
| Zsh | system Zsh, or `zsh` → `zsh` | apt `zsh` → `zsh` | [Zsh](https://zsh.sourceforge.io/) |
| git | `git` → `git` | apt `git` → `git` | [git](https://git-scm.com/downloads) |
| gh | `gh` → `gh` | apt `gh` → `gh`; use the upstream apt repo if needed | [gh Linux install](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) |
| rg | `ripgrep` → `rg` | apt `ripgrep` → `rg` | [ripgrep](https://github.com/BurntSushi/ripgrep#installation) |
| fd | `fd` → `fd` | apt `fd-find` → `fdfind` | [fd](https://github.com/sharkdp/fd#installation) |
| fzf | `fzf` → `fzf` | apt `fzf` → `fzf` | [fzf](https://github.com/junegunn/fzf#installation) |
| zoxide | `zoxide` → `zoxide` | upstream installer → `zoxide`; upstream flags old distro builds | [zoxide](https://github.com/ajeetdsouza/zoxide#installation) |
| eza | `eza` → `eza` | apt `eza` when available, otherwise the repo listed upstream or a release binary → `eza` | [eza install](https://github.com/eza-community/eza/blob/main/INSTALL.md) |
| bat | `bat` → `bat` | apt `bat` → `batcat` | [bat](https://github.com/sharkdp/bat#installation) |
| jq | `jq` → `jq` | apt `jq` → `jq` | [jq](https://jqlang.org/download/) |
| unzip | `unzip` → `unzip` | apt `unzip` → `unzip` | [Debian unzip](https://packages.debian.org/stable/unzip) |
| just | `just` → `just` | apt `just` if a candidate exists; otherwise upstream release / crate `just` → `just` | [just](https://github.com/casey/just#installation) |
| hyperfine | `hyperfine` → `hyperfine` | apt `hyperfine` or upstream release / crate `hyperfine` → `hyperfine` | [hyperfine](https://github.com/sharkdp/hyperfine#installation) |
| ast-grep | `ast-grep` → `ast-grep`, `sg` | upstream release / crate `ast-grep` → `ast-grep`, `sg`; invoke `ast-grep` | [ast-grep](https://ast-grep.github.io/guide/quick-start.html) |
| sd | `sd` → `sd` | apt `sd` if a candidate exists; otherwise upstream release / crate `sd` → `sd` | [sd](https://github.com/chmln/sd#installation) |
| difftastic | `difftastic` → `difft` | upstream release / crate `difftastic` → `difft` | [difftastic](https://difftastic.wilfred.me.uk/installation.html) |
| watchexec | `watchexec` → `watchexec` | upstream release / crate `watchexec-cli` → `watchexec` | [watchexec](https://github.com/watchexec/watchexec#installation) |
| yq | `yq` → `yq` | Mike Farah release asset `yq_linux_amd64` or `yq_linux_arm64` → `yq` | [Mike Farah yq](https://github.com/mikefarah/yq#install) |

On macOS, install missing formulae from this set:

```sh
brew install git gh ripgrep fd fzf zoxide eza bat jq unzip fnm \
  just hyperfine ast-grep sd difftastic watchexec yq
```

Use the [Homebrew installer](https://brew.sh/) if the host lacks Homebrew. Do not append `brew shellenv` to the shell files; the tracked PATH already covers both Mac prefixes.

On Debian/Ubuntu and WSL, inspect `apt-cache policy` before selecting packages:

```sh
sudo apt update
sudo apt install zsh git ripgrep fd-find fzf bat jq unzip curl ca-certificates
```

Use [gh's signed apt repository](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) when the distro lacks a suitable candidate. Install remaining tools from available official distro packages or their upstream release assets into `~/.local/bin`. Select assets for the detected architecture, verify published checksums when available, and record release tags. Prefer prebuilt assets; use `cargo install --locked <crate>` only when a Rust toolchain already exists. Do not add a toolchain as an unstated dependency.

For zoxide on Linux, use the [upstream installer](https://github.com/ajeetdsouza/zoxide/blob/main/install.sh), with `--bin-dir "$HOME/.local/bin"`. For eza, follow [its current package instructions](https://github.com/eza-community/eza/blob/main/INSTALL.md) or use a release binary. Package availability varies by distro version; do not assume every row is an apt package.

Debian's `sg` is a group-switch command. Call `ast-grep`, and leave `/usr/bin/sg` intact. Keep `fdfind` and `batcat` under their distro names. Configure consumers to call those names. Verify `yq --version` identifies `mikefarah/yq`; the Python program named yq is a different tool.

## 3. Shell and PATH

Deploy these links to absolute repo paths:

- `~/.zshenv` → `shell/.zshenv`
- `~/.zprofile` → `shell/.zprofile`
- `~/.zshrc` → `shell/.zshrc`

`.zshenv` uses `typeset -U path` and shell builtins. It adds `~/.local/bin`, `~/.cargo/bin`, `${FNM_DIR:-$HOME/.local/share/fnm}/aliases/default/bin`, `/opt/homebrew/bin`, `/opt/homebrew/sbin`, `/usr/local/bin`, and `/usr/local/sbin`. It exports a shared default `FNM_DIR` of `~/.local/share/fnm`. It emits no output and starts no subprocesses. An existing `FNM_DIR` takes precedence.

[Zsh reads `.zshenv` for every shell and `.zprofile` after the system login profile](https://zsh.sourceforge.io/Doc/Release/Files.html). macOS `/etc/zprofile` invokes `/usr/libexec/path_helper`, which can move system paths to the front. The repo `.zprofile` sources `.zshenv` again to restore the order and remove duplicates.

`.zshrc` initializes completion and history, then fnm, fzf, and zoxide. It removes Zsh's built-in command shorthands. It loads `~/.zshrc.local` when present. No prompt framework is needed.

Completion builds `~/.zcompdump` on first start and uses the cache on later starts. After adding completion directories, remove the dump and start a shell to rebuild it. With `ZDOTDIR` set, completion and history files live there, which keeps validation writes inside a disposable directory.

The fzf file widget uses `bat` or `batcat` for its preview. File listing and directory selection use `fd` or `fdfind`. Preview flags belong in `FZF_CTRL_T_OPTS`, since history selection is not a file list. [fzf's shell integration](https://github.com/junegunn/fzf#setting-up-shell-integration) supports `fzf --zsh` from 0.48 onward. Older packages load their packaged `key-bindings.zsh` and `completion.zsh`; the tracked file checks Linux and both Homebrew locations. Bindings load only with a TTY and ZLE, so `zsh -ic` under an agent does not produce line-editor errors.

Run `python3 scripts/deploy.py` to inspect the deployment plan, then `python3 scripts/deploy.py --apply` during an authorized host setup. It handles shell and agent links together. The helper requires Python 3.11+; if the system Python is older, defer applying it until the uv step and use `uv run --no-project --python 3.13 scripts/deploy.py --apply`.

## 4. Node and Python

### Node

Use [fnm's official installation instructions](https://github.com/Schniz/fnm#installation). Homebrew supplies `fnm` on macOS. On Linux, put the executable on the shared PATH without letting the installer edit shell config:

```sh
curl -fsSL https://fnm.vercel.app/install -o fnm-install.sh
bash fnm-install.sh --skip-shell --install-dir "$HOME/.local/bin"
```

Set `FNM_DIR` to `~/.local/share/fnm` unless the host has an explicit override. Install LTS and make the version fnm installed the default:

```sh
export FNM_DIR="${FNM_DIR:-$HOME/.local/share/fnm}"
fnm install --lts
fnm default lts-latest
```

`fnm install --lts` records the installed version under `lts-latest`; `fnm default lts-latest` points the default directory at that version. Verify the default directory contains `node` and `npm`. Interactive initialization is `fnm env --use-on-cd --shell zsh --log-level quiet`; non-interactive shells use the default directory without creating a multishell.

Claude Code, Codex, and fff-mcp use native binaries. None of them requires fnm-managed Node.

### Python

Use the [official uv installer](https://docs.astral.sh/uv/getting-started/installation/) and [installer options](https://docs.astral.sh/uv/reference/installer/):

```sh
curl -LsSf https://astral.sh/uv/install.sh -o uv-install.sh
UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh uv-install.sh
UV_NO_MODIFY_PATH=1 uv self update
uv python install 3.13
uv tool install ruff
uv tool install ty
```

Run `uv tool upgrade ruff` and `uv tool upgrade ty` when installed versions need updates. Use `uv run` for project Python. Do not create global `python` or `python3` links. The system Python remains available for system tasks. Sources: [uv tools](https://docs.astral.sh/uv/guides/tools/) and [ty installation](https://docs.astral.sh/ty/installation/).

## 5. Agent stack

### Claude Code

Use [Claude Code's native installer](https://code.claude.com/docs/en/setup):

```sh
curl -fsSL https://claude.ai/install.sh -o claude-install.sh
bash claude-install.sh
```

The stable launch path is `~/.local/bin/claude`. Skip a fresh install if a working native installation already exists; use its supported update command when needed.

Link `agents/claude/CLAUDE.md` to `~/.claude/CLAUDE.md` and `agents/claude/settings.json` to `~/.claude/settings.json`. Instructions copy the MacBook snapshot and add the final fff Tools section. Settings copy the snapshot's pstack marketplace, enabled plugin, theme, and cache TTL.

On a fresh host, deploy settings, sign in to Claude Code, and let the configured marketplace and enabled plugin install. Verify `/plugin` shows pstack. If installation did not complete, use these [pstack upstream commands](https://github.com/michael-denyer/pstack-claude#installation) in Claude Code:

```text
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

Inspect the marketplace and installed plugin before rerunning those commands. Start a new session after installation. The [Claude plugin reference](https://code.claude.com/docs/en/plugins-reference) documents user scope and plugin lifecycle. The copied `promptCacheTtl` setting comes from the snapshot; confirm support on the installed Claude release rather than claiming fresh-host validation here.

### Codex

Use an [official native release](https://github.com/openai/codex#installing-and-running-codex) at a stable `~/.local/bin/codex` path. This path works on all target Unix hosts and avoids fnm's npm launcher. The official Mac alternative is `brew install --cask codex`, exposing a stable Homebrew `bin/codex` link. Choose one owner for updates.

For the direct release route, skip installation when the intended native binary is present. For an install or update, select a release tag and architecture, then back up any existing destination before replacing it:

```sh
case "$(uname -s):$(uname -m)" in
  Darwin:arm64) target=aarch64-apple-darwin ;;
  Darwin:x86_64) target=x86_64-apple-darwin ;;
  Linux:aarch64|Linux:arm64) target=aarch64-unknown-linux-musl ;;
  Linux:x86_64) target=x86_64-unknown-linux-musl ;;
  *) echo 'Unsupported Codex target' >&2; exit 1 ;;
esac
release_tag=$(curl -fsSL https://api.github.com/repos/openai/codex/releases/latest | jq -er .tag_name)
staging_dir=$(mktemp -d)
curl -fL "https://github.com/openai/codex/releases/download/$release_tag/codex-$target.tar.gz" \
  -o "$staging_dir/codex.tar.gz"
tar -xzf "$staging_dir/codex.tar.gz" -C "$staging_dir"
mkdir -p "$HOME/.local/bin"
install -m 755 "$staging_dir/codex-$target" "$HOME/.local/bin/codex"
```

Record the release tag, verify upstream digests/attestation when available, and remove the staging directory after validation. Direct native installs do not acquire npm updates; repeat the release procedure for updates, keeping the destination path unchanged. Do not point T3 at a versioned app-server-daemon release directory. The inventory launcher is a legacy workaround for an npm installation; the target setup replaces it with the native binary. [Official OpenAI documentation](https://learn.chatgpt.com/docs/codex/cli) covers CLI use and authentication.

Link `agents/codex/AGENTS.md` to `~/.codex/AGENTS.md`. Link each `agents/codex/agents/*.toml` file to the matching `~/.codex/agents/` path. Worker and oracle use `gpt-6.1-sol`; explorer and verifier use `gpt-6-luna`. Every role uses `xhigh`. These are the requested model IDs; verify account availability on the host.

Merge `agents/codex/config.base.toml` into `~/.codex/config.toml` with `scripts/deploy.py`. Do not symlink the live config. The helper recursively replaces base-owned values and preserves all other parsed values, including project trust, MCP servers, desktop state, and host plugins. It validates TOML before changing links, keeps the original file in a timestamped backup, and writes a regular file with mode 0600. A satisfied rerun leaves the file untouched. A changed merge regenerates TOML layout and removes comments; the backup retains the original text.

The base keeps the snapshot's [pstack-for-codex marketplace and plugin](https://github.com/Aqua-123/pstack-for-codex). Its upstream catalog declares `pstack-for-codex-local` and the plugin `pstack-for-codex`. It differs from the Claude pstack repo. Inspect `codex plugin list --json` after deployment; if absent, use the upstream install commands:

```sh
codex plugin marketplace add Aqua-123/pstack-for-codex
codex plugin add pstack-for-codex@pstack-for-codex-local
```

Skip satisfied registrations and start a fresh session after installation. [Codex config reference](https://learn.chatgpt.com/docs/config-file/config-reference) documents config and plugin keys. The snapshot's `openai-bundled`, `openai-primary-runtime`, and `openai-curated` plugin entries remain host-managed. Public docs do not establish that those exact groups are desktop-only. They are omitted from the portable base, and the merge preserves existing entries. Do not fabricate platform labels.

### Home instructions

Link `agents/home/AGENTS.md` to `~/AGENTS.md`. It copies the snapshot's Git staging guardrails. `scripts/deploy.py` creates all eleven config links and merges the Codex base. Backups live under `~/.local/state/dotfiles/backups/<UTC timestamp>/`. Review its printed plan before host deployment.

## 6. fff

Install the native MCP server from [dmtrKovalenko/fff](https://github.com/dmtrKovalenko/fff). The upstream installer puts it in `~/.local/bin/fff-mcp` without a Node dependency:

```sh
curl -fsSL https://raw.githubusercontent.com/dmtrKovalenko/fff/main/install-mcp.sh -o fff-install.sh
FFF_MCP_INSTALL_DIR="$HOME/.local/bin" bash fff-install.sh
```

On macOS, the official project tap is another native route: `brew install dmtrKovalenko/fff/fff-mcp`. Pick one installation owner; skip a satisfied install. Inspect the downloaded script before execution and use its release checksums. It prints registration suggestions; the helper below performs registration.

Resolve the installed server to its absolute stable command path. Keep a Homebrew `bin` link rather than resolving it into a versioned package directory. Register at user scope with these commands:

```sh
claude mcp add --transport stdio --scope user fff -- "$HOME/.local/bin/fff-mcp"
codex mcp add fff -- "$HOME/.local/bin/fff-mcp"
```

Sources: [Claude MCP syntax and scopes](https://code.claude.com/docs/en/mcp) and [Codex MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli). Claude user servers live in `~/.claude.json`; Codex user servers live in `~/.codex/config.toml`. These are host files and remain untracked.

Use `python3 scripts/register-fff.py` to inspect the plan and add `--apply` for host setup. Pass `--binary /absolute/stable/path/fff-mcp` for a custom install. The helper compares only the named user registration. It skips matching entries, backs up files before changes, removes stale fff entries at the same scope, and adds the absolute path through each client's CLI. It leaves other registrations intact. Use default config locations for this deployment; remove conflicting config-directory overrides before applying.

Both instruction files end with the required Tools section. Verify the new session connects fff and exposes its search tools in a Git working tree. Registration alone is not a connection test.

## 7. T3 wiring

Use [T3 Code's official install instructions](https://github.com/pingdotgg/t3code#desktop-app):

- macOS: `brew install --cask t3-code`, or the matching signed release from [T3 releases](https://github.com/pingdotgg/t3code/releases).
- Native Debian/Ubuntu desktop: download the matching `.deb` release, then run `sudo apt install ./T3-Code-<release>.deb`. A headless host needs a separate GUI host; do not infer that a desktop app can run there.
- WSL: **TODO**. The upstream Windows app has `winget install T3Tools.T3Code`. `inventory/wsl.md` reports a Windows app launching a Linux T3 server through `wsl.exe`, with providers and agent config in the Linux home. It also reports a broken npm Codex installation and a full provider PATH. Treat those as remote host observations. Verify the chosen native installation, Linux absolute provider paths, restart behavior, and a fresh T3 session on that host before completing wiring. Do not copy Mac launch assumptions to Windows.

On the MacBook, T3 is a GUI app with launchd PATH `/usr/bin:/bin:/usr/sbin:/sbin`. The recorded provider launch shape is:

```sh
/bin/sh -c 'exec "$@"' t3-agent /absolute/provider/binary app-server ...
```

`/bin/sh` does not load Zsh startup files. Fixing `.zshenv` helps Zsh commands but cannot supply Node to an npm provider launcher. Native provider binaries solve that boundary.

Set `providerInstances.<id>.config.binaryPath` in `~/.t3/userdata/settings.json` to the installed absolute path. Use `/Users/<user>/.local/bin/claude` and `/Users/<user>/.local/bin/codex` for the native installer route, or an absolute Homebrew Codex path if that route owns it. Do not write `~`, an executable name, shell expansion, or a versioned release path into `binaryPath`.

Test both configured paths under the bare PATH before saving them:

```sh
env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  /bin/sh -c 'exec "$@"' t3-agent "$HOME/.local/bin/claude" --version
env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  /bin/sh -c 'exec "$@"' t3-agent "$HOME/.local/bin/codex" --version
```

Also run the configured Codex path with `app-server --help` under that PATH, then verify a provider session in T3. Existing T3 sessions retain the path read at startup. **Fully quit T3 Code and reopen it after a binaryPath change.** Then start fresh provider sessions. The Mac PATH, settings key, launch form, and session behavior are host evidence from `inventory/macbook.md` and the task brief; they are not claimed as cross-platform upstream guarantees.

## 8. Validation

Do not mark host setup complete until installed paths, versions, links, and provider sessions pass. Run deployment twice and confirm the second pass changes nothing. Preserve outputs and label failed or untested checks.

For repo-only validation, create a temporary `ZDOTDIR` under the ignored `.checks/` directory and link the three shell files into it. Keep the real HOME for command discovery. Redirect `XDG_RUNTIME_DIR`, `XDG_CACHE_HOME`, and `XDG_STATE_HOME` into `.checks/` during interactive checks so fnm writes no state outside the repo.

Run these checks:

1. `zsh -n` on each file in `shell/`.
2. Under `env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin ZDOTDIR="$T"`, use `zsh -c` to resolve `brew rg fd gh jq fnm node npm uv claude just hyperfine` on macOS. On Linux, check `fdfind` and `batcat`, and omit macOS-only brew. Node must resolve through the fnm default directory in this check.
3. `zsh -lc 'echo $PATH'` with the same environment must put Homebrew before `/usr/bin` on macOS and contain no repeated entries.
4. `zsh -ic 'alias; echo ---; echo $PATH'` must print no command shorthands and no stderr. PATH must contain no repeated entries. An fnm multishell belongs in the interactive session. Also check fzf Ctrl-T bindings and preview in a TTY.
5. Use `hyperfine --warmup 5 --runs 30 'zsh -i -c exit'` with that `ZDOTDIR`. Cached interactive startup should be below 50 ms. Report the first completion-cache build separately.
6. Parse every `agents/**/*.toml` with Python `tomllib`, and parse `agents/claude/settings.json` with `python3 -m json.tool`. Run `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`. The helper tests use disposable homes under `.checks/`; MCP execution is mocked.
7. Scan the repo excluding `.git` and `inventory/` for retired tools, editor sections, and shell shorthand declarations. Explain the `unalias` call that removes Zsh defaults and any instruction text preserved from a snapshot. No retired config should remain outside inventory.
8. Scan every tracked and untracked text file excluding `.git` for credential patterns. Review every match; do not commit private account data. Historical inventory descriptions and instructions can mention credential handling without containing credentials.
9. Check `git diff --check`, staged paths, and the pushed commit SHA. Stage explicit owned paths only. Run `git pull --rebase` before pushing this shared branch, preserve incoming inventory, and do not merge.

On a deployed host, also check `fnm current`, `node --version`, `npm --version`, `uv --version`, `uv python list`, `ruff --version`, `ty --version`, and each declared CLI. Confirm `yq --version`, `ast-grep --version`, `difft --version`, `watchexec --version`, native agent startup under bare PATH, pstack loading, fff connection, and fresh T3 provider sessions.

Report verified facts apart from assumptions. Repo validation does not prove fresh-host installation, account model access, plugin availability, WSL integration, or GUI provider sessions.
