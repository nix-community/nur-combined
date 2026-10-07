import io
import json
import os
import subprocess
import sys
import unittest
from http.client import IncompleteRead
from unittest.mock import patch
from urllib.error import HTTPError

from updaters.__main__ import main


def release(tag, *, prerelease=False, draft=False):
    return {"tagName": tag, "isPrerelease": prerelease, "isDraft": draft}


def page(releases, *, cursor=None):
    data = {
        "data": {
            "repository": {
                "releases": {
                    "nodes": releases,
                    "pageInfo": {
                        "hasNextPage": cursor is not None,
                        "endCursor": cursor,
                    },
                }
            }
        }
    }
    return io.BytesIO(json.dumps(data).encode())


class TruncatedResponse(io.BytesIO):
    def read(self, *args):
        raise IncompleteRead(super().read(*args), 100)


class ReleaseUpdaterTests(unittest.TestCase):
    def setUp(self):
        environment = patch.dict(os.environ, {"GITHUB_TOKEN": "test-token"}, clear=True)
        environment.start()
        self.addCleanup(environment.stop)
        self.request = patch("updaters.http.urlopen").start()
        self.run = patch("updaters.__main__.subprocess.run").start()
        patch("updaters.http.time.sleep").start()
        self.addCleanup(patch.stopall)

    def invoke(self, *extra):
        arguments = [
            "updaters",
            "--owner",
            "openai",
            "--repo",
            "codex",
            "--attribute",
            "codex-bin",
            "--tag-pattern",
            r"rust-v(\d+\.\d+\.\d+)",
            *extra,
        ]
        with patch.object(sys, "argv", arguments):
            main()

    def test_stable_version_is_highest_across_pages_not_most_recent(self):
        self.request.side_effect = [
            page(
                [
                    release("rust-v0.9.1"),
                    release("rust-v0.11.0", prerelease=True),
                    release("rust-v0.12.0", draft=True),
                    release("unrelated-v9.0.0"),
                ],
                cursor="next",
            ),
            page([release("rust-v0.10.0"), release("rust-v0.9.9")]),
        ]
        self.invoke()
        self.run.assert_called_once_with(
            ["nix-update", "codex-bin", "--version=0.10.0"], check=True
        )
        requests = [
            json.loads(call.args[0].data) for call in self.request.call_args_list
        ]
        self.assertEqual(
            [request["variables"]["cursor"] for request in requests], [None, "next"]
        )
        # Verify the actual request excludes the large metadata that caused CI failures.
        self.assertNotIn("assets", requests[0]["query"])
        self.assertNotIn("description", requests[0]["query"])

    def test_nightly_version_and_desktop_arguments_reach_nix_update(self):
        self.request.return_value = page(
            [
                release("v0.0.46-nightly.20261006.9", prerelease=True),
                release("v0.0.46-nightly.20261006.10", prerelease=True),
                release("v0.0.47-nightly.20261007.1"),
                release("v0.0.47"),
            ]
        )
        arguments = [
            "updaters",
            "--owner",
            "pingdotgg",
            "--repo",
            "t3code",
            "--attribute",
            "t3code-bin",
            "--tag-pattern",
            r"v(\d+\.\d+\.\d+-nightly\.\d{8}\.\d+)",
            "--prerelease",
            "--",
            "--override-filename=pkgs/t3code-bin/sources.nix",
            "--subpackage=desktop",
        ]
        with (
            patch.dict(os.environ, {"UPDATE_NIX_ATTR_PATH": "t3code-nightly-bin"}),
            patch.object(sys, "argv", arguments),
        ):
            main()
        self.run.assert_called_once_with(
            [
                "nix-update",
                "t3code-nightly-bin",
                "--version=0.0.46-nightly.20261006.10",
                "--override-filename=pkgs/t3code-bin/sources.nix",
                "--subpackage=desktop",
            ],
            check=True,
        )

    def test_incomplete_response_is_retried_before_updating(self):
        self.request.side_effect = [
            TruncatedResponse(b"partial"),
            page([release("rust-v0.10.0")]),
        ]
        self.invoke()
        self.assertEqual(self.request.call_count, 2)
        self.run.assert_called_once()

    def test_transport_failure_stops_after_bounded_retries(self):
        self.request.side_effect = lambda *_args, **_kwargs: TruncatedResponse(
            b"partial"
        )
        with self.assertRaises(IncompleteRead):
            self.invoke()
        self.assertEqual(self.request.call_count, 3)
        self.run.assert_not_called()

    def test_invalid_release_results_never_start_nix_update(self):
        cases = {
            "No matching releases": {
                "data": {
                    "repository": {
                        "releases": {
                            "nodes": [release("rust-v0.10.0", prerelease=True)],
                            "pageInfo": {"hasNextPage": False, "endCursor": None},
                        }
                    }
                }
            },
            "GitHub query failed": {"errors": [{"message": "Resource not accessible"}]},
            "GitHub repository not found": {"data": {"repository": None}},
            "invalid release cursor": {
                "data": {
                    "repository": {
                        "releases": {
                            "nodes": [release("rust-v0.10.0")],
                            "pageInfo": {"hasNextPage": True, "endCursor": None},
                        }
                    }
                }
            },
        }
        for reason, result in cases.items():
            with self.subTest(reason=reason):
                self.request.return_value = io.BytesIO(json.dumps(result).encode())
                with self.assertRaisesRegex(ValueError, reason):
                    self.invoke()
                self.run.assert_not_called()

    def test_authorization_failure_is_not_retried(self):
        error = HTTPError(
            "https://api.github.com/graphql", 401, "Unauthorized", {}, None
        )
        self.addCleanup(error.close)
        self.request.side_effect = error
        with self.assertRaises(HTTPError):
            self.invoke()
        self.assertEqual(self.request.call_count, 1)
        self.run.assert_not_called()

    def test_nix_update_failure_is_reported(self):
        self.request.return_value = page([release("rust-v0.10.0")])
        self.run.side_effect = subprocess.CalledProcessError(1, "nix-update")
        with self.assertRaises(subprocess.CalledProcessError):
            self.invoke()


if __name__ == "__main__":
    unittest.main()
