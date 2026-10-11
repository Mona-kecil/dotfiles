"""Exercise deployment and MCP updates in disposable homes inside the repo."""

import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import tomllib
import unittest
from unittest.mock import patch

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "scripts"))
import deploy

spec = importlib.util.spec_from_file_location("register_fff", REPO / "scripts/register-fff.py")
registration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(registration)


class SetupTests(unittest.TestCase):
    def setUp(self):
        (REPO / ".checks").mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=REPO / ".checks")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.output = io.StringIO()
        self.capture = contextlib.redirect_stdout(self.output)
        self.capture.__enter__()
        self.addCleanup(self.capture.__exit__, None, None, None)

    def test_dry_run_and_rerun_preserve_host_values_and_backups(self):
        config = self.home / ".codex/config.toml"
        config.parent.mkdir()
        original = '''# Host note
model = "old-model"
[projects."/workspace"]
trust_level = "trusted"
[mcp_servers.other]
command = "/usr/local/bin/other"
args = ["one", "two"]
[desktop]
theme = "dark"
[[hooks]]
command = "echo ready"
'''
        config.write_text(original)
        shell = self.home / ".zshrc"
        shell.write_text("# old shell\n")
        deploy.deploy(self.home)
        self.assertEqual(shell.read_text(), "# old shell\n")
        self.assertEqual(config.read_text(), original)
        self.assertFalse((self.home / ".local").exists())
        deploy.deploy(self.home, apply=True)
        data = tomllib.loads(config.read_text())
        self.assertEqual(data["model"], "gpt-6.1-sol")
        self.assertEqual(data["projects"], {"/workspace": {"trust_level": "trusted"}})
        self.assertEqual(data["mcp_servers"]["other"]["args"], ["one", "two"])
        self.assertEqual(data["desktop"]["theme"], "dark")
        self.assertEqual(data["hooks"], [{"command": "echo ready"}])
        self.assertFalse(config.is_symlink())
        self.assertEqual(config.stat().st_mode & 0o777, 0o600)
        self.assertEqual(os.readlink(shell), str(REPO / "shell/.zshrc"))
        backups = list((self.home / ".local/state/dotfiles/backups").iterdir())
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / ".codex/config.toml").read_text(), original)
        before = config.read_bytes(), config.stat().st_mtime_ns
        deploy.deploy(self.home, apply=True)
        self.assertEqual(before, (config.read_bytes(), config.stat().st_mtime_ns))
        self.assertEqual(backups, list((self.home / ".local/state/dotfiles/backups").iterdir()))

    def test_invalid_config_fails_before_changing_links(self):
        config = self.home / ".codex/config.toml"
        config.parent.mkdir()
        config.write_text("model = [broken\n")
        with self.assertRaises(tomllib.TOMLDecodeError):
            deploy.deploy(self.home, apply=True)
        self.assertFalse((self.home / ".zshenv").exists())
        self.assertFalse((self.home / ".local").exists())

    def test_table_conflict_fails_before_changing_links(self):
        config = self.home / ".codex/config.toml"
        config.parent.mkdir()
        config.write_text('agents = "host-value"\n')
        with self.assertRaises(ValueError):
            deploy.deploy(self.home, apply=True)
        self.assertFalse((self.home / ".zshenv").exists())

    def test_config_symlink_becomes_file_without_editing_its_source(self):
        origin = self.home / "old-config.toml"
        origin.write_text('model = "old-model"\n')
        config = self.home / ".codex/config.toml"
        config.parent.mkdir()
        config.symlink_to(origin)
        deploy.deploy(self.home, apply=True)
        self.assertFalse(config.is_symlink())
        self.assertEqual(origin.read_text(), 'model = "old-model"\n')
        backup = next((self.home / ".local/state/dotfiles/backups").glob("*/.codex/config.toml"))
        self.assertTrue(backup.is_symlink())

    def test_toml_values_survive_serialization(self):
        original = '''text = "emoji: 🐚 and DEL: \\u007f"
offset = 1979-05-27T07:32:00-07:00
local = 1979-05-27T07:32:00
date = 1979-05-27
time = 07:32:00.123
infinity = inf
undefined = nan
mixed = [1, "two", { a = true, nested = { b = [2, 3] } }]
["key.with.dots"]
empty = {}
'''
        values = tomllib.loads(original)
        self.assertTrue(deploy.same(values, tomllib.loads(deploy.dump_toml(values))))

    def test_fff_uses_user_scope_and_absolute_stable_path_then_skips_rerun(self):
        binary = self.home / "fff-mcp"
        binary.write_text("#!/bin/sh\nexit 0\n")
        binary.chmod(0o755)
        claude = self.home / ".claude.json"
        claude.write_text(json.dumps({"mcpServers": {"other": {"command": "/bin/other"},
                                                   "fff": {"command": "/old/fff-mcp"}}}))
        codex = self.home / ".codex/config.toml"
        codex.parent.mkdir()
        codex.write_text('[mcp_servers.fff]\ncommand = "/old/fff-mcp"\n')
        with patch.object(registration.shutil, "which", side_effect=lambda c: f"/client/{c}"), \
                patch.object(registration.subprocess, "run") as run:
            registration.register(self.home, binary)
            run.assert_not_called()
            registration.register(self.home, binary, apply=True)
            self.assertEqual([call.args[0] for call in run.call_args_list], [
                ["/client/claude", "mcp", "remove", "--scope", "user", "fff"],
                ["/client/claude", "mcp", "add", "--transport", "stdio", "--scope", "user", "fff", "--", str(binary)],
                ["/client/codex", "mcp", "remove", "fff"],
                ["/client/codex", "mcp", "add", "fff", "--", str(binary)],
            ])
            self.assertTrue(list((self.home / ".local/state/dotfiles/backups").glob("*/.claude.json")))
            data = json.loads(claude.read_text())
            data["mcpServers"]["fff"] = {"type": "stdio", "command": str(binary), "args": []}
            claude.write_text(json.dumps(data))
            codex.write_text(deploy.dump_toml({"mcp_servers": {"fff": {"command": str(binary)}}}))
            run.reset_mock()
            registration.register(self.home, binary, apply=True)
            run.assert_not_called()
            self.assertIn("other", json.loads(claude.read_text())["mcpServers"])


if __name__ == "__main__":
    unittest.main()
