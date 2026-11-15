#!/usr/bin/env python3
"""Offline tests for the ScopeBuddy entry point that keeps Steam's overlay away
from the script's own helpers (no Nix, no network)."""
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXPRESSION = ROOT / "pkgs/scopebuddy/default.nix"


def entry_script():
    """The entry point exactly as installPhase writes it (heredoc, Nix-unescaped)."""
    text = EXPRESSION.read_text()
    body = text.split("cat > $out/bin/scopebuddy <<EOF\n", 1)[1].split("\n    EOF\n", 1)[0]
    lines = [line[4:] if line.startswith("    ") else line for line in body.splitlines()]
    script = "\n".join(lines) + "\n"
    # Undo the Nix ('' -> ${) and heredoc (\$ -> $) escaping.
    return script.replace("\\''${", "${").replace("\\$", "$")


class ScopeBuddyEntryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        target = self.root / "out/libexec/scopebuddy/scopebuddy"
        target.parent.mkdir(parents=True)
        target.write_text('#!/bin/sh\n'
                          'echo "SCRIPT_LD_PRELOAD=${LD_PRELOAD-unset}"\n'
                          'echo "SCRIPT_SAVED=${SCB_LD_PRELOAD-unset}"\n'
                          'echo "ARGS=$*"\n')
        target.chmod(0o755)
        script = entry_script()
        self.assertTrue(script.startswith("#!${busybox-sandbox-shell}/bin/busybox sh\n"), script)
        # Run the entry logic with the test's shell and the fake script.
        script = re.sub(r"^#!.*\n", "#!/bin/sh\n", script)
        script = script.replace("$out/", f"{self.root}/out/")
        self.entry = self.root / "scopebuddy"
        self.entry.write_text(script)
        self.entry.chmod(0o755)

    def run_entry(self, extra_env, *args):
        env = {k: v for k, v in os.environ.items() if k not in ("LD_PRELOAD", "SCB_LD_PRELOAD")}
        env.update(extra_env)
        return subprocess.run([str(self.entry), *args], env=env, text=True,
                              capture_output=True, check=True).stdout

    def test_steam_overlay_is_moved_out_of_the_scripts_environment(self):
        out = self.run_entry({"LD_PRELOAD": "/steam/gameoverlayrenderer.so"}, "--", "game", "-x")
        self.assertIn("SCRIPT_LD_PRELOAD=unset", out)
        self.assertIn("SCRIPT_SAVED=/steam/gameoverlayrenderer.so", out)
        self.assertIn("ARGS=-- game -x", out)

    def test_without_preload_nothing_is_invented(self):
        out = self.run_entry({}, "--", "game")
        self.assertIn("SCRIPT_LD_PRELOAD=unset", out)
        self.assertIn("SCRIPT_SAVED=unset", out)

    def test_empty_preload_is_preserved_as_set(self):
        out = self.run_entry({"LD_PRELOAD": ""}, "--", "game")
        self.assertIn("SCRIPT_LD_PRELOAD=unset", out)
        self.assertIn("SCRIPT_SAVED=", out)
        self.assertNotIn("SCRIPT_SAVED=unset", out)


class ScopeBuddyPackagePolicyTests(unittest.TestCase):
    def test_entry_point_is_statically_linked_and_overlay_returns_only_to_the_game(self):
        text = EXPRESSION.read_text()
        # The loader ignores LD_PRELOAD only for static executables.
        self.assertIn("#!${busybox-sandbox-shell}/bin/busybox sh", text)
        # Both launch paths hand the saved overlay back to the game command.
        self.assertIn("'LD_PRELOAD_REAL=$LD_PRELOAD' 'LD_PRELOAD_REAL=$SCB_LD_PRELOAD'", text)
        self.assertIn('export LD_PRELOAD="$SCB_LD_PRELOAD"; fi # Launch %command% without gamescope', text)
        self.assertIn("ln -s scopebuddy $out/bin/scb", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
