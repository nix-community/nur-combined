from __future__ import annotations

import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch

from .models import PackageRef, PackageState
from .package_backend import _update_source_with_verification, _verify_source_hash
from .process import CommandError

FLAKE_REF = PackageRef(
    source_kind="flake",
    attrset="packages.x86_64-linux",
    attr="xberg",
    attr_path="packages.x86_64-linux.xberg",
    file_path=Path("pkgs/xberg/default.nix"),
)
FILE_REF = PackageRef(
    source_kind="file",
    attrset="bibata",
    attr="modern.cursors.gruvbox-dark",
    attr_path="bibata.modern.cursors.gruvbox-dark",
    file_path=Path("pkgs/bibata/default.nix"),
)
MISMATCH = (
    "error: hash mismatch in fixed-output derivation '/nix/store/abc-source.drv':\n"
    "         specified: sha256-6/+iYdy3zWlJzovAixxr3GLQNGwxJ7aZV8XPCO9m9lU=\n"
    "             got:    sha256-Ry1SdFObIAHVS5rxe/NmeU4JRYEzemQ5l9hWZ7Eb+YQ=\n"
)


def _state(src_hash: str | None) -> PackageState:
    return PackageState(version="3.5.0", version_mode="stable", src_hash=src_hash)


def _completed(
    returncode: int, stderr: str = "", stdout: str = ""
) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess([], returncode, stdout, stderr)


class VerifySourceHashTests(unittest.TestCase):
    def test_source_without_fixed_output_hash_is_not_fetched(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state(None)),
            patch("updater.package_backend.run") as run,
        ):
            self.assertIsNone(_verify_source_hash(FLAKE_REF, timeout="1m"))
            run.assert_not_called()

    def test_flake_source_is_fetched_through_the_flake(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-x")),
            patch("updater.package_backend.run", return_value=_completed(0)) as run,
        ):
            self.assertIsNone(_verify_source_hash(FLAKE_REF, timeout="1m"))
            self.assertEqual(
                run.call_args.args[0],
                ["nix", "build", "--no-link", ".#packages.x86_64-linux.xberg.src"],
            )

    def test_classic_package_set_source_is_fetched_through_default_nix(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-x")),
            patch("updater.package_backend.run", return_value=_completed(0)) as run,
        ):
            _verify_source_hash(FILE_REF, timeout="1m")
            self.assertEqual(
                run.call_args.args[0],
                [
                    "nix-build",
                    "-f",
                    "default.nix",
                    "-A",
                    "bibata.modern.cursors.gruvbox-dark.src",
                    "--no-out-link",
                ],
            )

    def test_hash_mismatch_is_reported(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-x")),
            patch("updater.package_backend.run", return_value=_completed(1, stderr=MISMATCH)),
        ):
            reason = _verify_source_hash(FLAKE_REF, timeout="1m")
        self.assertEqual(
            reason, "error: hash mismatch in fixed-output derivation '/nix/store/abc-source.drv':"
        )

    def test_fetch_failure_without_hash_mismatch_is_reported(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-x")),
            patch(
                "updater.package_backend.run",
                return_value=_completed(
                    1, stderr="warning: talking to the daemon\nerror: unable to download\n"
                ),
            ),
        ):
            self.assertEqual(
                _verify_source_hash(FLAKE_REF, timeout="1m"), "error: unable to download"
            )

    def test_fetch_failure_without_error_line_is_reported(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-x")),
            patch("updater.package_backend.run", return_value=_completed(1, stdout="failed\n")),
        ):
            self.assertEqual(_verify_source_hash(FLAKE_REF, timeout="1m"), "failed")


class UpdateSourceWithVerificationTests(unittest.TestCase):
    def test_unchanged_source_is_not_fetched(self) -> None:
        before = _state("sha256-old")
        with (
            patch("updater.package_backend.read_state", return_value=before),
            patch("updater.package_backend._verify_source_hash") as verify,
            patch("updater.package_backend._run_nix_update") as update,
        ):
            self.assertIsNone(
                _update_source_with_verification(FLAKE_REF, before, "stable", timeout="1m")
            )
            verify.assert_not_called()
            update.assert_not_called()

    def test_verified_source_is_left_alone(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-new")),
            patch("updater.package_backend._verify_source_hash", return_value=None),
            patch("updater.package_backend._run_nix_update") as update,
        ):
            self.assertIsNone(
                _update_source_with_verification(
                    FLAKE_REF, _state("sha256-old"), "stable", timeout="1m"
                )
            )
            update.assert_not_called()

    def test_moved_reference_is_rewritten_once(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-new")),
            patch(
                "updater.package_backend._verify_source_hash",
                side_effect=[MISMATCH, None],
            ) as verify,
            patch("updater.package_backend._run_nix_update") as update,
        ):
            self.assertIsNone(
                _update_source_with_verification(
                    FLAKE_REF, _state("sha256-old"), "stable", timeout="1m"
                )
            )
            update.assert_called_once_with(FLAKE_REF, "stable", timeout="1m")
            self.assertEqual(verify.call_count, 2)

    def test_persistent_mismatch_is_rejected(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-new")),
            patch("updater.package_backend._verify_source_hash", return_value=MISMATCH) as verify,
            patch("updater.package_backend._run_nix_update") as update,
        ):
            reason = _update_source_with_verification(
                FLAKE_REF, _state("sha256-old"), "stable", timeout="1m"
            )
            self.assertTrue(reason.startswith("source hash verification failed: "))
            update.assert_called_once_with(FLAKE_REF, "stable", timeout="1m")
            self.assertEqual(verify.call_count, 2)

    def test_failure_other_than_a_mismatch_is_not_retried(self) -> None:
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-new")),
            patch(
                "updater.package_backend._verify_source_hash",
                return_value="error: unable to download",
            ),
            patch("updater.package_backend._run_nix_update") as update,
        ):
            self.assertEqual(
                _update_source_with_verification(
                    FLAKE_REF, _state("sha256-old"), "skip", timeout="1m"
                ),
                "error: unable to download",
            )
            update.assert_not_called()

    def test_failed_reupdate_is_reported(self) -> None:
        error = CommandError(["nix", "run"], _completed(1, stderr="error: nix-update failed"))
        with (
            patch("updater.package_backend.read_state", return_value=_state("sha256-new")),
            patch("updater.package_backend._verify_source_hash", return_value=MISMATCH),
            patch("updater.package_backend._run_nix_update", side_effect=error),
        ):
            reason = _update_source_with_verification(
                FLAKE_REF, _state("sha256-old"), "stable", timeout="1m"
            )
        self.assertTrue(reason.startswith("source hash verification failed and re-update failed: "))


if __name__ == "__main__":
    unittest.main()
