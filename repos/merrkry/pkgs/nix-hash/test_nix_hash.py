"""Exercise hash tasks against real Nix builds with cached stale outputs."""

import base64
import hashlib
import json
import os
import subprocess
import sys
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory


def sri(content: str) -> str:
    return (
        "sha256-" + base64.b64encode(hashlib.sha256(content.encode()).digest()).decode()
    )


@unittest.skipUnless(
    "NIX_HASH_TEST_BASH" in os.environ,
    "Run with nix run .#test-nix-hash",
)
class HashTasksTest(unittest.TestCase):
    def test_cached_dependency_and_hash_file_updates(self) -> None:
        with TemporaryDirectory(prefix="nix-hash-test-") as directory:
            root = Path(directory)
            (root / "nix").mkdir()
            (root / "nix/hash-targets.toml").write_text(
                '[example]\ninstallable = ".#example.pnpmDeps"\nfile = "package.nix"\n'
                '[bundle]\ninstallable = ".#bundle"\nfile = "hash.txt"\n'
                '[remote]\ninstallable = "nixpkgs#hello"\nfile = "hash.txt"\n'
            )
            (root / "content.txt").write_text("old")
            (root / "hash.txt").write_text(sri("old") + "\n")
            bash = json.dumps(os.environ["NIX_HASH_TEST_BASH"])
            system = os.environ["NIX_HASH_TEST_SYSTEM"]
            (root / "flake.nix").write_text(
                f"""{{
                  outputs = {{ ... }}: {{
                    packages.{system} = import ./package.nix {{
                      bash = builtins.appendContext {bash} {{
                        {bash} = {{ path = true; }};
                      }};
                      system = "{system}";
                    }};
                  }};
                }}"""
            )
            package = root / "package.nix"
            package.write_text(
                """{ bash, system }: let
                  mkDerivation = attrs: builtins.derivation attrs // {
                    inherit (attrs) src;
                    overrideAttrs = f: mkDerivation (attrs // f attrs);
                  };
                  dependency = hash: mkDerivation {
                    inherit system;
                    name = "NAME";
                    src = ./content.txt;
                    builder = "${bash}/bin/bash";
                    args = [ "-e" "-c" ''
                      test "$content" != broken
                      printf '%s' "$content" > "$out"
                    '' ];
                    outputHash = hash;
                    outputHashMode = "flat";
                    outputHashAlgo = "sha256";
                    content = builtins.readFile ./content.txt;
                  };
                in rec {
                  example = {
                    name = "hash-task-example-1";
                    src = ./.;
                    pnpmDeps = dependency "HASH";
                  };
                  bundle = dependency (
                    builtins.replaceStrings [ "\\n" ] [ "" ]
                      (builtins.readFile ./hash.txt)
                  );
                }
                """.replace("NAME", root.name).replace("HASH", sri("old"))
            )
            script = os.environ["NIX_HASH_TEST_SCRIPT"]

            def command(*args: str, success: bool = True) -> str:
                result = subprocess.run(
                    args,
                    cwd=root,
                    capture_output=True,
                    text=True,
                    timeout=120,
                    check=False,
                )
                output = result.stdout + result.stderr
                self.assertEqual(result.returncode == 0, success, output)
                return output

            def task(*args: str, success: bool = True) -> str:
                return command(sys.executable, script, *args, success=success)

            task("check", "example", "bundle")
            original = package.read_bytes(), (root / "hash.txt").read_bytes()
            (root / "content.txt").write_text("new")
            command("nix", "build", "--no-link", ".#example.pnpmDeps", ".#bundle")
            self.assertIn(
                "hash mismatch", task("check", "example", "bundle", success=False)
            )
            self.assertEqual(
                original, (package.read_bytes(), (root / "hash.txt").read_bytes())
            )
            task("update", "example")
            self.assertIn(sri("new"), package.read_text())
            self.assertEqual((root / "hash.txt").read_text(), sri("old") + "\n")
            task("check", "example")
            self.assertIn("hash mismatch", task("check", "bundle", success=False))
            task("update", "bundle")
            self.assertEqual((root / "hash.txt").read_text(), sri("new") + "\n")
            task("check", "example", "bundle")

            updated = package.read_bytes(), (root / "hash.txt").read_bytes()
            (root / "content.txt").write_text("broken")
            task("update", "example", success=False)
            self.assertEqual(
                updated, (package.read_bytes(), (root / "hash.txt").read_bytes())
            )
            self.assertIn("Unknown packages", task("update", "missing", success=False))
            self.assertIn(".#<attribute>", task("update", "remote", success=False))


if __name__ == "__main__":
    unittest.main()
