#!/usr/bin/env python3
"""Plan or deploy absolute links and merge the portable Codex base (Python 3.11+)."""

import argparse
import copy
import datetime as dt
import json
import math
import os
from pathlib import Path
import shutil
import tempfile
import tomllib


REPO = Path(__file__).resolve().parents[1]


def read_toml(path):
    return tomllib.loads(path.read_text()) if path.exists() else {}


def merge(current, base):
    result = copy.deepcopy(current)
    for key, value in base.items():
        if key in result and isinstance(result[key], dict) != isinstance(value, dict):
            raise ValueError(f"TOML table/value conflict at {key}")
        result[key] = merge(result.get(key, {}), value) if isinstance(value, dict) else value
    return result


def same(left, right):
    if type(left) is not type(right):
        return False
    if isinstance(left, dict):
        return left.keys() == right.keys() and all(same(left[k], right[k]) for k in left)
    if isinstance(left, list):
        return len(left) == len(right) and all(same(a, b) for a, b in zip(left, right))
    if isinstance(left, float) and math.isnan(left):
        return math.isnan(right)
    return left == right


def quote(text):
    return json.dumps(text, ensure_ascii=False).replace("\x7f", "\\u007f")


def value_toml(value):
    if isinstance(value, str):
        return quote(value)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, (dt.datetime, dt.date, dt.time)):
        return value.isoformat()
    if isinstance(value, list):
        return "[" + ", ".join(value_toml(item) for item in value) + "]"
    if isinstance(value, dict):
        return "{ " + ", ".join(f"{quote(k)} = {value_toml(v)}" for k, v in value.items()) + " }"
    raise TypeError(f"Unsupported TOML value: {type(value).__name__}")


def dump_toml(data):
    lines = ["# Values merged by dotfiles/scripts/deploy.py; original layout is in the backup."]

    def table(values, path=()):
        if path:
            lines.extend(["", "[" + ".".join(quote(k) for k in path) + "]"])
        for key, value in values.items():
            if not isinstance(value, dict):
                lines.append(f"{quote(key)} = {value_toml(value)}")
        for key, value in values.items():
            if isinstance(value, dict):
                table(value, path + (key,))

    table(data)
    text = "\n".join(lines) + "\n"
    if not same(tomllib.loads(text), data):
        raise ValueError("TOML serialization changed a value")
    return text


class Backups:
    def __init__(self, target_home):
        self.home = target_home
        stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
        self.root = target_home / ".local/state/dotfiles/backups" / stamp

    def save(self, path):
        if not os.path.lexists(path):
            return
        destination = self.root / path.relative_to(self.home)
        self.root.mkdir(parents=True, exist_ok=True, mode=0o700)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, destination, follow_symlinks=False)
        print(f"backup {path} -> {destination}")


def write_atomic(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(prefix=".dotfiles-", dir=path.parent)
    try:
        with os.fdopen(handle, "w") as stream:
            stream.write(text)
        os.chmod(temporary, 0o600)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def deploy(target_home, apply=False):
    target_home = target_home.expanduser().absolute()
    sources = [
        (REPO / "shell" / name, target_home / name)
        for name in (".zshenv", ".zprofile", ".zshrc")
    ]
    sources.extend([
        (REPO / "agents/claude/CLAUDE.md", target_home / ".claude/CLAUDE.md"),
        (REPO / "agents/claude/settings.json", target_home / ".claude/settings.json"),
        (REPO / "agents/home/AGENTS.md", target_home / "AGENTS.md"),
        (REPO / "agents/codex/AGENTS.md", target_home / ".codex/AGENTS.md"),
        (REPO / "agents/codex/pstack-models.md", target_home / ".codex/pstack-models.md"),
    ])
    sources.extend((source, target_home / ".codex/agents" / source.name)
                   for source in sorted((REPO / "agents/codex/agents").glob("*.toml")))
    config = target_home / ".codex/config.toml"
    # Parse and serialize before any links change. Never print host config values.
    current = read_toml(config)
    desired = merge(current, read_toml(REPO / "agents/codex/config.base.toml"))
    text = dump_toml(desired)
    for source, destination in sources:
        if not source.is_file() or (destination.is_dir() and not destination.is_symlink()):
            raise ValueError(f"Expected a configuration file: {destination}")
    backups = Backups(target_home)
    for source, destination in sources:
        if destination.is_symlink() and os.readlink(destination) == str(source):
            print(f"keep {destination}")
            continue
        print(f"link {destination} -> {source}")
        if apply:
            backups.save(destination)
            destination.parent.mkdir(parents=True, exist_ok=True)
            if os.path.lexists(destination):
                destination.unlink()
            destination.symlink_to(source)
    if same(current, desired) and not config.is_symlink():
        print(f"keep {config}")
    else:
        print(f"merge {REPO / 'agents/codex/config.base.toml'} -> {config}")
        if apply:
            backups.save(config)
            write_atomic(config, text)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", type=Path, default=Path.home(), help="Target home directory")
    parser.add_argument("--apply", action="store_true", help="Apply the plan; default only prints it")
    args = parser.parse_args()
    deploy(args.home, args.apply)
