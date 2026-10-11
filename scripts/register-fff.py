#!/usr/bin/env python3
"""Plan or register fff by stable absolute path at user scope (Python 3.11+)."""

import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess

from deploy import Backups, read_toml


def matches(entry, binary):
    return (isinstance(entry, dict) and entry.get("command") == str(binary)
            and entry.get("type", "stdio") == "stdio" and not entry.get("args", [])
            and entry.get("enabled", True))


def register(target_home, binary, apply=False):
    target_home = target_home.expanduser().absolute()
    # Retain stable symlink paths rather than resolving a package's version folder.
    binary = binary.expanduser().absolute()
    if not binary.is_file() or not os.access(binary, os.X_OK):
        raise ValueError(f"fff binary is not executable: {binary}")
    claude_config = target_home / ".claude.json"
    codex_config = target_home / ".codex/config.toml"
    claude_data = json.loads(claude_config.read_text()) if claude_config.exists() else {}
    codex_data = read_toml(codex_config)
    plans = []
    for client, config, entry in [
        ("claude", claude_config, claude_data.get("mcpServers", {}).get("fff")),
        ("codex", codex_config, codex_data.get("mcp_servers", {}).get("fff")),
    ]:
        if matches(entry, binary):
            print(f"keep {client} user fff: {binary}")
            continue
        executable = shutil.which(client)
        if executable is None:
            raise ValueError(f"Client is not on PATH: {client}")
        commands = []
        if entry is not None:
            remove = [executable, "mcp", "remove"]
            if client == "claude":
                remove += ["--scope", "user"]
            commands.append(remove + ["fff"])
        add = [executable, "mcp", "add"]
        if client == "claude":
            add += ["--transport", "stdio", "--scope", "user"]
        commands.append(add + ["fff", "--", str(binary)])
        plans.append((config, commands))
    backups = Backups(target_home)
    environment = dict(os.environ, HOME=str(target_home), CODEX_HOME=str(target_home / ".codex"))
    for config, commands in plans:
        if apply:
            backups.save(config)
        for command in commands:
            print(shlex.join(command))
            if apply:
                subprocess.run(command, check=True, env=environment)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", type=Path, default=Path.home(), help="Target home directory")
    parser.add_argument("--binary", type=Path, help="Stable fff-mcp path; default searches PATH")
    parser.add_argument("--apply", action="store_true", help="Apply the plan; default only prints it")
    args = parser.parse_args()
    found = args.binary or shutil.which("fff-mcp")
    if found is None:
        parser.error("Install fff-mcp first or pass --binary")
    register(args.home, Path(found), args.apply)
