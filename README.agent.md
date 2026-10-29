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
| unzip | system `/usr/bin/unzip` → `unzip` | apt `unzip` → `unzip` | [Debian unzip](https://packages.debian.org/stable/unzip) |
| just | `just` → `just` | apt `just` if a candidate exists; otherwise upstream release / crate `just` → `just` | [just](https://github.com/casey/just#installation) |
| hyperfine | `hyperfine` → `hyperfine` | apt `hyperfine` or upstream release / crate `hyperfine` → `hyperfine` | [hyperfine](https://github.com/sharkdp/hyperfine#installation) |
| ast-grep | `ast-grep` → `ast-grep`, `sg` | upstream release / crate `ast-grep` → `ast-grep`, `sg`; invoke `ast-grep` | [ast-grep](https://ast-grep.github.io/guide/quick-start.html) |
| sd | `sd` → `sd` | apt `sd` if a candidate exists; otherwise upstream release / crate `sd` → `sd` | [sd](https://github.com/chmln/sd#installation) |
| difftastic | `difftastic` → `difft` | upstream release / crate `difftastic` → `difft` | [difftastic](https://difftastic.wilfred.me.uk/installation.html) |
| watchexec | `watchexec` → `watchexec` | upstream release / crate `watchexec-cli` → `watchexec` | [watchexec](https://github.com/watchexec/watchexec#installation) |
| yq | `yq` → `yq` | Mike Farah release asset `yq_linux_amd64` or `yq_linux_arm64` → `yq` | [Mike Farah yq](https://github.com/mikefarah/yq#install) |

On macOS, install missing formulae from this set:

```sh
brew install git gh ripgrep fd fzf zoxide eza bat jq fnm \
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

`.zshrc` initializes completion and history, then fnm, fzf, and zoxide. It first removes every alias defined before it, including Zsh and system defaults, so no host alias such as `ls` → `eza` survives. It loads `~/.zshrc.local` afterwards, so a host can opt back into its own aliases there. No prompt framework is needed.

Completion builds `~/.zcompdump` on first start and reuses it while its mtime is less than 24 hours old. A Zsh glob qualifier checks age without a subprocess; the `zsh/files` builtin removes an expired dump so `compinit` rescans and rewrites it even when the completion-file count has not changed. Cached starts use `compinit -C`. After adding completion directories, remove the dump to rebuild before the daily refresh. With `ZDOTDIR` set, completion and history files live there, which keeps validation writes inside a disposable directory. Sources: [Zsh completion initialization](https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Use-of-compinit), [glob qualifiers](https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers), and [Zsh file builtins](https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002ffiles-Module).

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

Link `agents/claude/CLAUDE.md` to `~/.claude/CLAUDE.md` and `agents/claude/settings.json` to `~/.claude/settings.json`. Instructions copy the live owner-approved `~/.claude/CLAUDE.md`: T3 and Codex CLI delegation, with Sol at `high` and Luna at `xhigh`. Shared UI and tool rules live in `~/AGENTS.md`. By default Claude loads `AGENTS.md` only for projects without their own `CLAUDE.md`, and it reads this option only from user, `--settings`, or managed settings. Settings select `michael-denyer/pstack-claude`, the shared pstack source for Claude Code and Codex, disable auto memory, load `AGENTS.md` files beside `CLAUDE.md` through `pluginConfigs."agents-md@builtin".options.instructionFiles = "claude-md-and-agents-md"`, and run the impeccable hooks when `~/.claude/skills/impeccable` is installed. They leave `promptCacheTtl` unset, so Claude picks the TTL: 1 hour on a subscription within its usage limits, 5 minutes on an API key or cloud provider.

Claude Code may rewrite `~/.claude/settings.json` after plugin or theme changes. Writes through the symlink land in the repo working tree; review them before committing. If Claude replaces the link with a regular file, a second `scripts/deploy.py` run reports the link that needs restoration. Its dry run leaves the file intact.

On a fresh host, deploy settings, sign in to Claude Code, and let the configured marketplace and enabled plugin install. Verify `/plugin` shows pstack. If installation did not complete, use these [pstack upstream commands](https://github.com/michael-denyer/pstack-claude#install) in Claude Code:

```text
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

Inspect the marketplace and installed plugin before rerunning those commands. On an existing WSL Claude host, inspect `/plugin` before migration; if the old plugin is `pstack@pstack`, uninstall that entry from the Installed tab and remove its marketplace with `/plugin marketplace remove pstack` before adding the shared source. Back up user settings and review any repo changes from these writes. The [Claude plugin lifecycle](https://code.claude.com/docs/en/discover-plugins#manage-installed-plugins) documents those actions. Start a new session after installation. The [Claude plugin reference](https://code.claude.com/docs/en/plugins-reference) documents user scope and plugin lifecycle.

### Codex

Use the [official standalone installer](https://learn.chatgpt.com/docs/codex/cli#getting-started) at a stable `~/.local/bin/codex` path. It installs the complete native package, including `codex-code-mode-host` and runtime resources, without fnm's npm launcher. The official Mac alternative is `brew install --cask codex`. Choose one owner for updates.

Skip installation only when the intended complete package is present. A working `codex --version` does not prove that tools can run. Installing only the `codex-<target>.tar.gz` binary left this Mac without `codex-code-mode-host`; T3 started Codex but every tool call failed after restart. For an install or update, inspect the installer, select a release tag, and back up both visible commands before replacing them:

Before this block, check `command -v codex`. It must be absent or point to `~/.local/bin/codex`. If it points to an npm or Homebrew install, keep that manager as the update owner or remove its Codex package before choosing standalone. Resolve that conflict before deploying shell symlinks; the standalone installer can rewrite a profile when it detects another manager.

```sh
release_tag=$(curl -fsSL https://api.github.com/repos/openai/codex/releases/latest | jq -er .tag_name)
staging_dir=$(mktemp -d)
curl -fsSL https://chatgpt.com/codex/install.sh -o "$staging_dir/install.sh"
# Read the downloaded installer before running the remaining commands.
backup_dir="$HOME/.local/state/dotfiles/backups/$(date -u +%Y%m%dT%H%M%SZ)/.local/bin"
for command_name in codex codex-code-mode-host; do
  if [ -e "$HOME/.local/bin/$command_name" ] || [ -L "$HOME/.local/bin/$command_name" ]; then
    mkdir -p "$backup_dir"
    cp -pL "$HOME/.local/bin/$command_name" "$backup_dir/$command_name"
  fi
done
if [ -L "$HOME/.codex/packages/standalone/current" ]; then
  mkdir -p "$backup_dir"
  cp -pP "$HOME/.codex/packages/standalone/current" "$backup_dir/standalone-current"
fi
mkdir -p "$HOME/.local/bin"
PATH="$HOME/.local/bin:$PATH" CODEX_INSTALL_DIR="$HOME/.local/bin" \
  CODEX_NON_INTERACTIVE=1 CODEX_RELEASE="$release_tag" sh "$staging_dir/install.sh"
```

Record the release tag and remove the staging directory after validation. The reviewed installer detects architecture, verifies release checksums, keeps the package layout under `~/.codex/packages/standalone/`, and selects it through stable command symlinks. With no conflicting manager and `~/.local/bin` on PATH, its PATH setup leaves shell files untouched. Keep the package's binaries and resources together; if downloading assets by hand, use the complete `codex-package-<target>.tar.gz` archive and preserve its layout. Use the same installer for updates and restart provider sessions afterwards. Do not point T3 at a versioned app-server-daemon release directory. The inventory launcher is a legacy workaround for an npm installation; the target setup replaces it with the native package.

Link `agents/home/AGENTS.md` to `~/.codex/AGENTS.md` too, because Codex reads `~/AGENTS.md` only when the project root is `~`. Link `agents/codex/pstack-models.md` to `~/.codex/pstack-models.md`; pstack's session hook reads only its `session hook` line, so the role rows (Sol at `high`, Luna at `xhigh`, Astra at `high` for strongest judgment) do not reach Codex sessions. Codex runs plugin hooks only after they are trusted: after installing pstack, trust its `SessionStart` hook and confirm the app-server `hooks/list` reports `trustStatus` as `trusted`. The base uses Sol at `high`. These are the requested model IDs; verify account availability on the host.

Merge `agents/codex/config.base.toml` into `~/.codex/config.toml` with `scripts/deploy.py`. Do not symlink the live config. The helper recursively replaces base-owned values and preserves all other parsed values, including project trust, MCP servers, desktop state, and host plugins. It validates TOML before changing links, keeps the original file in a timestamped backup, and writes a regular file with mode 0600. A satisfied rerun leaves the file untouched. A changed merge regenerates TOML layout and removes comments; the backup retains the original text.

The base selects [michael-denyer/pstack-claude](https://github.com/michael-denyer/pstack-claude#install) for both tools. Its [Codex catalog](https://github.com/michael-denyer/pstack-claude/blob/main/.agents/plugins/marketplace.json) and [Claude catalog](https://github.com/michael-denyer/pstack-claude/blob/main/.claude-plugin/marketplace.json) name the marketplace `pstack-claude` and plugin `pstack`. The upstream Codex commands are:

```sh
codex plugin marketplace add michael-denyer/pstack-claude
codex plugin add pstack@pstack-claude
```

These commands record `[marketplaces.pstack-claude]` with `source_type = "git"` and `source = "https://github.com/michael-denyer/pstack-claude.git"`, and `[plugins."pstack@pstack-claude"]` with `enabled = true`. The exact serialization follows Codex's [GitHub source parser](https://github.com/openai/codex/blob/main/codex-rs/core-plugins/src/marketplace_add/source.rs), [marketplace writer](https://github.com/openai/codex/blob/main/codex-rs/config/src/marketplace_edit.rs), and [plugin writer](https://github.com/openai/codex/blob/main/codex-rs/config/src/plugin_edit.rs). Those values are in the base; repo validation does not install the marketplace or plugin.

#### Migrate existing pstack installs

The merge preserves unrelated host entries, including the old pstack source. On an authorized host setup, inspect `codex plugin list --json` and `codex plugin marketplace list --json` before removing anything. Back up `~/.codex/config.toml`. Check `codex plugin remove --help` and `codex plugin marketplace remove --help` on that host; the [current CLI reference](https://learn.chatgpt.com/docs/cli/reference#codex-plugin) documents both commands, and the Mac CLI help confirms them.

For the Mac snapshot's `Aqua-123/pstack-for-codex` entries:

```sh
codex plugin remove pstack-for-codex@pstack-for-codex-local
codex plugin marketplace remove pstack-for-codex-local
```

For the WSL snapshot's `painhardcore/pstack` entries:

```sh
codex plugin remove pstack@pstack
codex plugin marketplace remove pstack
```

Run only the commands whose plugin and marketplace names match the inspected host. If that Codex release lacks removal commands, edit the backed-up user config: remove `[plugins."pstack-for-codex@pstack-for-codex-local"]` and `[marketplaces.pstack-for-codex-local]` on Mac, or `[plugins."pstack@pstack"]` and `[marketplaces.pstack]` on WSL, including their contents. Preserve other tables, especially MCP entries. A manual config edit stops loading the old plugin but leaves its cache on disk. Removing a plugin leaves its `[hooks.state]` trust entries; delete those too. Then add the shared source and plugin with the upstream commands above; inspect both lists again and start a fresh session.

Skip satisfied registrations and start a fresh session after installation. [Codex config reference](https://learn.chatgpt.com/docs/config-file/config-reference) documents config and plugin keys. The snapshot's `openai-bundled`, `openai-primary-runtime`, and `openai-curated` plugin entries remain host-managed. Public docs do not establish that those exact groups are desktop-only. They are omitted from the portable base, and the merge preserves existing entries. Do not fabricate platform labels.

The base also carries the WSL host's `[mcp_servers.openaiDeveloperDocs]` URL, `https://developers.openai.com/mcp` ([OpenAI Docs MCP](https://developers.openai.com/learn/docs-mcp)). This named HTTP server coexists with the `mcp_servers.fff` stdio entry written by `codex mcp add`; deployment preserves that entry. The merge test covers fff, the legacy Mac pstack entries, and the new base together.

### Home instructions

Link `agents/home/AGENTS.md` to `~/AGENTS.md`. It holds the shared UI rules and the CLI tool list for every agent. `scripts/deploy.py` creates all eight config links and merges the Codex base. Backups live under `~/.local/state/dotfiles/backups/<UTC timestamp>/`. Review its printed plan before host deployment.

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

Use `python3 scripts/register-fff.py` to inspect the plan and add `--apply` for host setup. Pass `--binary /absolute/stable/path/fff-mcp` for a custom install. The helper compares only the named user registration. It skips matching entries, backs up files before changes, removes stale fff entries at the same scope, and adds the absolute path through each client's CLI. Remove-then-add is not atomic: if an add fails, the stale entry is already gone. Restore that client's config from the printed backup path, fix the cause, and rerun. It leaves other registrations intact. Use default config locations for this deployment; remove conflicting config-directory overrides before applying.

Both instruction files end with the required Tools section. Verify the new session connects fff and exposes its search tools in a Git working tree. Registration alone is not a connection test.

## 7. T3 wiring

Use [T3 Code's official install instructions](https://github.com/pingdotgg/t3code#desktop-app):

- macOS: `brew install --cask t3-code`, or the matching signed release from [T3 releases](https://github.com/pingdotgg/t3code/releases).
- Native Debian/Ubuntu desktop: download the matching `.deb` release, then run `sudo apt install ./T3-Code-<release>.deb`. A headless host needs a separate GUI host; do not infer that a desktop app can run there.
- WSL: install the Windows desktop app with the upstream `winget install T3Tools.T3Code` command. The recorded launch is Windows T3 desktop → `wsl.exe` → Linux T3 server inside WSL. Providers are children of that Linux server. They receive the user's login-shell PATH, which includes fnm and local Linux executables; this is the host evidence in [`inventory/wsl.md`](inventory/wsl.md), not the Mac bare-PATH case. The inventory infers the exact shell-resolution mechanism from fnm multishell paths; it does not trace that implementation.

All WSL agent config belongs in the Linux home: `~/.claude/`, `~/.codex/`, `~/AGENTS.md`, and the Linux T3 server's `~/.t3/userdata/settings.json`. Windows paths such as `C:\Users\<user>\.codex` do not configure Linux providers. Use the native `~/.local/bin/codex` and an absolute Linux `binaryPath`, such as `/home/<user>/.local/bin/codex`, so provider startup does not depend on fnm or shell initialization. Use `/home/<user>/.local/bin/claude` for the native Claude provider. The inventory's missing npm optional dependency is history; the owner reports that the WSL npm Codex installation has been repaired. This spec still selects a stable native binary.

WSL appends Windows PATH entries by default through `appendWindowsPath`. A Windows `node` under `/mnt/c` could win if fnm initialization fails and no Linux Node precedes it. The tracked PATH puts Linux executable paths and fnm's stable default directory first. A host owner can choose `/etc/wsl.conf` with `[interop]` and `appendWindowsPath=false` to omit Windows PATH entries ([Microsoft WSL config](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#interop-settings)). This is an optional host-level choice; the spec does not apply it.

On the MacBook, T3 is a GUI app with launchd PATH `/usr/bin:/bin:/usr/sbin:/sbin`. The recorded provider launch shape is:

```sh
/bin/sh -c 'exec "$@"' t3-agent /absolute/provider/binary app-server ...
```

`/bin/sh` does not load Zsh startup files. Fixing `.zshenv` helps Zsh commands but cannot supply Node to an npm provider launcher. Native provider binaries solve that boundary.

Set `providerInstances.<id>.config.binaryPath` in `~/.t3/userdata/settings.json` to the installed absolute path. Use `/Users/<user>/.local/bin/claude` and `/Users/<user>/.local/bin/codex` for the native installer route, or an absolute Homebrew Codex path if that route owns it. Do not write `~`, an executable name, shell expansion, or a versioned release path into `binaryPath`.

Test both configured paths under the bare PATH before saving them (use the Linux home paths on WSL):

```sh
env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  /bin/sh -c 'exec "$@"' t3-agent "$HOME/.local/bin/claude" --version
env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  /bin/sh -c 'exec "$@"' t3-agent "$HOME/.local/bin/codex" --version
```

Also run the configured Codex path with `app-server --help` under that PATH, then verify a provider session in T3. Existing T3 sessions retain the path read at startup. **Fully quit T3 Code and reopen it after a binaryPath change, including the Windows desktop app used with WSL.** Then start fresh provider sessions. The Mac PATH, settings key, launch form, and session behavior are host evidence from `inventory/macbook.md` and the task brief; they are not claimed as cross-platform upstream guarantees.

On macOS, also run `~/.local/bin/codex-code-mode-host --help` under the bare PATH. On every host, verify the selected standalone package contains `bin/codex`, `bin/codex-code-mode-host`, `codex-package.json`, `codex-path/`, and `codex-resources/`. In the fresh T3 Codex session, execute a shell command and an fff search. Version and help output alone cannot catch a missing tool runner.

WSL host checks remain unverified in this repo-only pass:

- Resolve the configured absolute Linux binaries; check their versions and Codex `app-server --help` under a bare PATH.
- After a full quit and restart of the Windows app, start fresh Claude and Codex T3 sessions against the Linux server.
- Inspect provider PATHs in those sessions for Linux precedence and duplicates, and resolve Node through fnm's default directory.
- Confirm Linux-home instructions and agent roles load, the shared pstack plugin loads, and both Docs and fff MCP servers connect.

## 8. Validation

Do not mark host setup complete until installed paths, versions, links, and provider sessions pass. Run deployment twice and confirm the second pass changes nothing. Preserve outputs and label failed or untested checks.

For repo-only validation, create a temporary `ZDOTDIR` under the ignored `.checks/` directory and link the three shell files into it. Keep the real HOME for command discovery. Redirect `XDG_RUNTIME_DIR`, `XDG_CACHE_HOME`, and `XDG_STATE_HOME` into `.checks/` during interactive checks so fnm writes no state outside the repo.

Run these checks:

1. `zsh -n` on each file in `shell/`.
2. Under `env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin ZDOTDIR="$T"`, use `zsh -c` to resolve `brew rg fd gh jq fnm node npm uv claude just hyperfine` on macOS. On Linux, check `fdfind` and `batcat`, and omit macOS-only brew. Node must resolve through the fnm default directory in this check.
3. `zsh -lc 'echo $PATH'` with the same environment must put Homebrew before `/usr/bin` on macOS and contain no repeated entries.
4. `zsh -ic 'alias; echo ---; echo $PATH'` must print no command shorthands and no stderr. PATH must contain no repeated entries. An fnm multishell belongs in the interactive session. Also check fzf Ctrl-T bindings and preview in a TTY.
5. Use `hyperfine --warmup 5 --runs 30 'zsh -i -c exit'` with that `ZDOTDIR`. Cached interactive startup should be below 50 ms. Report the first completion-cache build separately. Set the dump mtime to more than 24 hours ago with `touch -t`, start a shell, and confirm it rewrites the dump. Start another shell and confirm the fresh dump keeps its mtime.
6. Use Python 3.11+ for this step; `tomllib` does not exist in older releases such as macOS's `/usr/bin/python3` 3.9. Set `py=python3` if `python3 -c 'import tomllib'` succeeds, otherwise `py='uv run --no-project --python 3.13 python'`. Parse every `agents/**/*.toml` with `tomllib`, parse `agents/claude/settings.json` with `$py -m json.tool`, and run `PYTHONDONTWRITEBYTECODE=1 $py -m unittest discover -s tests -v`. The helper tests use disposable homes under `.checks/`; MCP execution is mocked.
7. Scan the repo excluding `.git` and `inventory/` for retired tools, editor sections, and shell shorthand declarations. Explain the `unalias` call that removes Zsh defaults and any instruction text preserved from a snapshot. No retired config should remain outside inventory.
8. Scan every tracked and untracked text file excluding `.git` for credential patterns. Review every match; do not commit private account data. Historical inventory descriptions and instructions can mention credential handling without containing credentials.
9. Check `git diff --check`, staged paths, and the pushed commit SHA. Stage explicit owned paths only. Run `git pull --rebase` before pushing this shared branch, preserve incoming inventory, and do not merge.

On a deployed host, also check `fnm current`, `node --version`, `npm --version`, `uv --version`, `uv python list`, `ruff --version`, `ty --version`, and each declared CLI. Confirm `yq --version`, `ast-grep --version`, `difft --version`, `watchexec --version`, native agent startup under bare PATH, pstack loading, fff connection, and fresh T3 provider sessions.

Report verified facts apart from assumptions. Repo validation does not prove fresh-host installation, account model access, plugin availability, WSL integration, or GUI provider sessions.
