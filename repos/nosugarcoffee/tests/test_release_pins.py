"""Exercise the release pin module through its interface, with upstreams faked in-process."""

from __future__ import annotations

import importlib.util
import io
import json
import os
import shutil
import sys
import tempfile
import unittest
import urllib.error
from dataclasses import replace
from pathlib import Path
from unittest import mock

REPO = Path(__file__).resolve().parents[1]
_spec = importlib.util.spec_from_file_location(
    "release_pins", REPO / "scripts" / "release_pins.py"
)
assert _spec is not None and _spec.loader is not None
release_pins = importlib.util.module_from_spec(_spec)
sys.modules["release_pins"] = release_pins
_spec.loader.exec_module(release_pins)

FRESH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


class FakeUpstreams:
    def __init__(self, responses: dict[str, object], hashes: dict[str, str]) -> None:
        self.responses = responses
        self.hashes = hashes
        self.prefetched: list[str] = []

    def http_get_json(self, url: str) -> object:
        return self.responses[url]

    def prefetch(self, url: str) -> str:
        self.prefetched.append(url)
        return self.hashes.get(url, FRESH)


def github_latest(repo: str, tag: str, assets: list[str]) -> dict[str, object]:
    return {
        f"https://api.github.com/repos/{repo}/releases/latest": {
            "tag_name": tag,
            "assets": [{"name": name} for name in assets],
        }
    }


class ReleasePinsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.pkgs = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.pkgs, ignore_errors=True)

    def write_pin(self, name: str, doc: dict[str, object]) -> Path:
        path = self.pkgs / name / "pin.json"
        path.parent.mkdir(parents=True)
        path.write_text(json.dumps(doc, indent=2) + "\n")
        return path

    def read_pin(self, name: str) -> dict[str, object]:
        return json.loads((self.pkgs / name / "pin.json").read_text())

    def test_every_real_pin_parses_and_renders_a_url_per_system(self) -> None:
        pin_files = sorted((REPO / "pkgs").glob("*/pin.json"))
        self.assertGreaterEqual(len(pin_files), 7)
        for pin_file in pin_files:
            pin = release_pins.parse_pin(json.loads(pin_file.read_text()), str(pin_file))
            for system in pin.hash:
                self.assertTrue(release_pins.render_url(pin, system).startswith("https://"))
            self.assertEqual(release_pins.dump_pin(pin), pin_file.read_text(), pin_file)

    def test_bumps_version_and_every_arch_hash(self) -> None:
        self.write_pin("clash", {
            "source": {"type": "github", "repo": "o/clash"},
            "version": "2.5.2",
            "url": "https://x/v{version}/Clash_{version}_{arch}.dmg",
            "arch": {"aarch64-darwin": "aarch64", "x86_64-darwin": "x64"},
            "hash": {"aarch64-darwin": "sha256-old1", "x86_64-darwin": "sha256-old2"},
        })
        upstreams = FakeUpstreams(github_latest("o/clash", "v9.9.9", []), {})

        summaries = release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        pin = self.read_pin("clash")
        self.assertEqual(pin["version"], "9.9.9")
        self.assertEqual(pin["hash"], {"aarch64-darwin": FRESH, "x86_64-darwin": FRESH})
        self.assertEqual(pin["arch"], {"aarch64-darwin": "aarch64", "x86_64-darwin": "x64"})
        self.assertEqual(
            sorted(upstreams.prefetched),
            ["https://x/v9.9.9/Clash_9.9.9_aarch64.dmg", "https://x/v9.9.9/Clash_9.9.9_x64.dmg"],
        )
        self.assertEqual(summaries, ["- `clash`: 2.5.2 -> 9.9.9"])

    def test_current_versioned_pin_downloads_nothing(self) -> None:
        path = self.write_pin("obs", {
            "source": {"type": "github", "repo": "o/obs"},
            "version": "32.2.2",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-same"},
        })
        before = path.read_text()
        upstreams = FakeUpstreams(github_latest("o/obs", "32.2.2", []), {})

        summaries = release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        self.assertEqual(summaries, [])
        self.assertEqual(upstreams.prefetched, [])
        self.assertEqual(path.read_text(), before)

    def test_asset_pattern_captures_extra_url_vars(self) -> None:
        self.write_pin("cida", {
            "source": {"type": "github", "repo": "o/cida", "asset": "^Cida-{version}-(?P<build>[0-9]+)[.]dmg$"},
            "version": "1.4.0",
            "vars": {"build": "199"},
            "url": "https://x/v{version}/Cida-{version}-{build}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        upstreams = FakeUpstreams(
            github_latest("o/cida", "v1.4.0", ["Cida-1.4.0-200.dmg", "Cida-1.4.0-200.dmg.sha256"]), {}
        )

        summaries = release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        pin = self.read_pin("cida")
        self.assertEqual(pin["vars"], {"build": "200"})
        self.assertEqual(upstreams.prefetched, ["https://x/v1.4.0/Cida-1.4.0-200.dmg"])
        self.assertEqual(summaries, ["- `cida`: 1.4.0 (build 199) -> 1.4.0 (build 200)"])

    def test_ambiguous_asset_match_fails_without_writing(self) -> None:
        path = self.write_pin("cida", {
            "source": {"type": "github", "repo": "o/cida", "asset": "^Cida-{version}-(?P<build>[0-9]+)[.]dmg$"},
            "version": "1.4.0",
            "vars": {"build": "199"},
            "url": "https://x/{version}-{build}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        before = path.read_text()
        upstreams = FakeUpstreams(github_latest("o/cida", "v1.5.0", ["Cida-1.5.0-1.dmg", "Cida-1.5.0-2.dmg"]), {})

        with self.assertRaises(release_pins.PinError):
            release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)
        self.assertEqual(path.read_text(), before)

    def test_unversioned_url_bumps_only_the_arch_that_changed(self) -> None:
        self.write_pin("ego", {
            "source": {"type": "unversioned-url"},
            "version": "0.5.1.13",
            "url": "https://cdn/{arch}/ego.dmg",
            "arch": {"aarch64-darwin": "arm64", "x86_64-darwin": "x64"},
            "hash": {"aarch64-darwin": "sha256-old", "x86_64-darwin": "sha256-same"},
        })
        upstreams = FakeUpstreams({}, {"https://cdn/x64/ego.dmg": "sha256-same"})

        summaries = release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        pin = self.read_pin("ego")
        self.assertEqual(pin["hash"], {"aarch64-darwin": FRESH, "x86_64-darwin": "sha256-same"})
        self.assertEqual(pin["version"], "0.5.1.13")
        self.assertIn("version label `0.5.1.13` left as is", summaries[0])

    def test_unversioned_url_with_same_bytes_is_current(self) -> None:
        self.write_pin("ego", {
            "source": {"type": "unversioned-url"},
            "version": "1",
            "url": "https://cdn/ego.dmg",
            "hash": {"aarch64-darwin": "sha256-same"},
        })
        upstreams = FakeUpstreams({}, {"https://cdn/ego.dmg": "sha256-same"})

        self.assertEqual(release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch), [])

    def test_jetbrains_source_follows_the_latest_build(self) -> None:
        self.write_pin("air", {
            "source": {"type": "jetbrains", "code": "AIR"},
            "version": "262.579.44",
            "url": "https://dl/Air-{version}-aarch64.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        upstreams = FakeUpstreams(
            {"https://data.services.jetbrains.com/products?code=AIR": [{"releases": [{"build": "262.834.70"}]}]},
            {},
        )

        summaries = release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        self.assertEqual(self.read_pin("air")["version"], "262.834.70")
        self.assertEqual(upstreams.prefetched, ["https://dl/Air-262.834.70-aarch64.dmg"])
        self.assertEqual(summaries, ["- `air`: 262.579.44 -> 262.834.70"])

    def test_unresolved_placeholder_is_rejected(self) -> None:
        pin = release_pins.parse_pin({
            "source": {"type": "unversioned-url"},
            "version": "1",
            "url": "https://x/{build}.dmg",
            "hash": {"aarch64-darwin": "sha256-x"},
        }, "inline")

        with self.assertRaises(release_pins.PinError):
            release_pins.render_url(pin, "aarch64-darwin")

    def test_unknown_source_type_is_rejected(self) -> None:
        with self.assertRaises(release_pins.PinError):
            release_pins.parse_pin({"source": {"type": "gitlab"}, "version": "1", "url": "u", "hash": {}}, "inline")

    def test_step_output_marks_change_and_carries_the_summary(self) -> None:
        output = self.pkgs / "github_output"
        release_pins.write_step_output(["- `a`: 1 -> 2"], output)
        self.assertEqual(output.read_text(), "changed=true\nsummary<<SUMMARY_EOF\n- `a`: 1 -> 2\nSUMMARY_EOF\n")

    def test_one_pin_error_does_not_stop_other_pins(self) -> None:
        self.write_pin("ok", {
            "source": {"type": "github", "repo": "o/ok"},
            "version": "1.0.0",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        broken = self.write_pin("broken", {
            "source": {"type": "github", "repo": "o/broken", "asset": "^Broken-{version}[.]dmg$"},
            "version": "1.0.0",
            "url": "https://x/Broken-{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        before = broken.read_text()
        self.write_pin("later", {
            "source": {"type": "github", "repo": "o/later"},
            "version": "1.0.0",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        upstreams = FakeUpstreams(
            {
                **github_latest("o/ok", "v2.0.0", []),
                **github_latest("o/broken", "v2.0.0", ["Broken_2.0.0_amd64.AppImage"]),
                **github_latest("o/later", "v3.0.0", []),
            },
            {},
        )

        with self.assertRaises(release_pins.PinError) as ctx:
            release_pins.bump_all(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        self.assertIn("`broken`", str(ctx.exception))
        self.assertNotIn("`ok`", str(ctx.exception))
        self.assertNotIn("`later`", str(ctx.exception))
        self.assertEqual(self.read_pin("ok")["version"], "2.0.0")
        self.assertEqual(self.read_pin("later")["version"], "3.0.0")
        self.assertEqual(broken.read_text(), before)

    def test_run_exits_nonzero_after_writing_successful_pins(self) -> None:
        self.write_pin("ok", {
            "source": {"type": "github", "repo": "o/ok"},
            "version": "1.0.0",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        self.write_pin("broken", {
            "source": {"type": "github", "repo": "o/broken", "asset": "^Broken-{version}[.]dmg$"},
            "version": "1.0.0",
            "url": "https://x/Broken-{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        upstreams = FakeUpstreams(
            {
                **github_latest("o/ok", "v2.0.0", []),
                **github_latest("o/broken", "v2.0.0", []),
            },
            {},
        )
        output = self.pkgs / "github_output"

        stderr = io.StringIO()
        with (
            mock.patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}),
            mock.patch.object(sys, "stderr", stderr),
        ):
            code = release_pins.run(self.pkgs, upstreams.http_get_json, upstreams.prefetch)

        self.assertEqual(code, 1)
        self.assertEqual(self.read_pin("ok")["version"], "2.0.0")
        self.assertIn("changed=true", output.read_text())
        self.assertIn("- `ok`: 1.0.0 -> 2.0.0", output.read_text())
        self.assertIn("failed to bump 1 pin(s)", stderr.getvalue())
        self.assertIn("`broken`", stderr.getvalue())

    def test_non_pin_error_does_not_stop_other_pins_or_outputs(self) -> None:
        self.write_pin("ok", {
            "source": {"type": "github", "repo": "o/ok"},
            "version": "1.0.0",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        broken = self.write_pin("broken", {
            "source": {"type": "github", "repo": "o/broken"},
            "version": "1.0.0",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        before = broken.read_text()
        self.write_pin("later", {
            "source": {"type": "github", "repo": "o/later"},
            "version": "1.0.0",
            "url": "https://x/{version}.dmg",
            "hash": {"aarch64-darwin": "sha256-old"},
        })
        responses = {
            **github_latest("o/ok", "v2.0.0", []),
            **github_latest("o/later", "v3.0.0", []),
        }

        def http_get_json(url: str) -> object:
            if "o/broken" in url:
                raise urllib.error.URLError("network down")
            return responses[url]

        output = self.pkgs / "github_output"
        stderr = io.StringIO()
        with (
            mock.patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}),
            mock.patch.object(sys, "stderr", stderr),
        ):
            code = release_pins.run(self.pkgs, http_get_json, FakeUpstreams({}, {}).prefetch)

        self.assertEqual(code, 1)
        self.assertEqual(self.read_pin("ok")["version"], "2.0.0")
        self.assertEqual(self.read_pin("later")["version"], "3.0.0")
        self.assertEqual(broken.read_text(), before)
        self.assertIn("changed=true", output.read_text())
        self.assertIn("- `ok`: 1.0.0 -> 2.0.0", output.read_text())
        self.assertIn("- `later`: 1.0.0 -> 3.0.0", output.read_text())
        self.assertIn("`broken`", stderr.getvalue())
        self.assertIn("network down", stderr.getvalue())

    def test_digup_asset_pattern_matches_hyphen_and_tauri_underscore_dmgs(self) -> None:
        pin = release_pins.parse_pin(json.loads((REPO / "pkgs" / "digup" / "pin.json").read_text()), "digup")

        hyphen = release_pins.latest_release(
            pin,
            FakeUpstreams(github_latest("ARahim3/DigUp", "v0.6.1", ["DigUp-0.6.1.dmg"]), {}).http_get_json,
        )
        self.assertEqual(hyphen.version, "0.6.1")
        self.assertEqual(hyphen.vars.get("file"), "DigUp-0.6.1.dmg")
        self.assertEqual(
            release_pins.render_url(replace(pin, version=hyphen.version, vars=hyphen.vars), "aarch64-darwin"),
            "https://github.com/ARahim3/DigUp/releases/download/v0.6.1/DigUp-0.6.1.dmg",
        )

        tauri = release_pins.latest_release(
            pin,
            FakeUpstreams(
                github_latest(
                    "ARahim3/DigUp",
                    "v0.7.0",
                    [
                        "DigUp_0.7.0_amd64.AppImage",
                        "DigUp_0.7.0_amd64.deb",
                        "DigUp_0.7.0_x64-setup.exe",
                        "DigUp_0.7.0_x64.dmg",
                        "DigUp_0.7.0_aarch64.dmg",
                    ],
                ),
                {},
            ).http_get_json,
        )
        self.assertEqual(tauri.version, "0.7.0")
        self.assertEqual(tauri.vars.get("file"), "DigUp_0.7.0_aarch64.dmg")
        self.assertEqual(
            release_pins.render_url(replace(pin, version=tauri.version, vars=tauri.vars), "aarch64-darwin"),
            "https://github.com/ARahim3/DigUp/releases/download/v0.7.0/DigUp_0.7.0_aarch64.dmg",
        )

    def test_digup_asset_pattern_rejects_non_dmg_assets(self) -> None:
        pin = release_pins.parse_pin(json.loads((REPO / "pkgs" / "digup" / "pin.json").read_text()), "digup")
        upstreams = FakeUpstreams(
            github_latest(
                "ARahim3/DigUp",
                "v0.7.0-beta.1",
                [
                    "DigUp_0.7.0-beta.1_amd64.AppImage",
                    "DigUp_0.7.0-beta.1_amd64.deb",
                    "DigUp_0.7.0-beta.1_x64-setup.exe",
                ],
            ),
            {},
        )

        with self.assertRaises(release_pins.PinError) as ctx:
            release_pins.latest_release(pin, upstreams.http_get_json)
        self.assertIn("expected one asset matching", str(ctx.exception))
        self.assertIn("found 0", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
