from __future__ import annotations

import io
import unittest
import urllib.error
from unittest.mock import patch

from .manifest import latest_github_release_tag


class GitHubReleaseTests(unittest.TestCase):
    def fetch(self):
        response = io.BytesIO(b'{"tag_name": "v0.73.0"}')
        with patch("updater.manifest.urllib.request.urlopen", return_value=response) as urlopen:
            self.assertEqual(latest_github_release_tag("steipete", "CodexBar"), "v0.73.0")
        request = urlopen.call_args.args[0]
        self.assertEqual(
            request.full_url, "https://api.github.com/repos/steipete/CodexBar/releases/latest"
        )
        self.assertEqual(request.get_header("Accept"), "application/vnd.github+json")
        self.assertEqual(urlopen.call_args.kwargs["timeout"], 30)
        return request

    def test_github_token(self):
        with patch.dict("os.environ", {"GITHUB_TOKEN": "workflow-token"}, clear=True):
            self.assertEqual(self.fetch().get_header("Authorization"), "Bearer workflow-token")

    def test_gh_token_takes_precedence(self):
        with patch.dict(
            "os.environ", {"GH_TOKEN": "cli-token", "GITHUB_TOKEN": "workflow-token"}, clear=True
        ):
            self.assertEqual(self.fetch().get_header("Authorization"), "Bearer cli-token")

    def test_without_token(self):
        with patch.dict("os.environ", {}, clear=True):
            self.assertIsNone(self.fetch().get_header("Authorization"))

    def test_http_failure_is_visible_without_verbose_logging(self):
        error = urllib.error.HTTPError("https://api.github.com", 403, "Forbidden", {}, None)
        with (
            patch("updater.manifest.urllib.request.urlopen", side_effect=error),
            self.assertLogs("updater.manifest", level="WARNING") as logs,
        ):
            self.assertIsNone(latest_github_release_tag("steipete", "CodexBar"))
        self.assertIn("HTTP Error 403", logs.output[0])


if __name__ == "__main__":
    unittest.main()
