import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from updater.manifest import _latest_tangled_release, update_release_asset_manifest


class TangledManifestTests(unittest.TestCase):
    def update(self, manifest_data, published_assets, fetched_hashes):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest = root / "release.json"
            manifest.write_text(json.dumps(manifest_data))
            with (
                patch("updater.manifest.ROOT", root),
                patch("updater.manifest.version_is_older", return_value=False),
                patch(
                    "updater.manifest._latest_tangled_release",
                    return_value=("2.0.6", "a" * 40, published_assets),
                ),
                patch(
                    "updater.manifest._prefetch_tangled_release_hashes",
                    return_value=("sha256-new-source", fetched_hashes),
                ) as prefetch,
            ):
                result = update_release_asset_manifest(manifest)
                calls = prefetch.call_args
            return result, json.loads(manifest.read_text()), calls

    def manifest(self):
        return {
            "version": "2.0.5",
            "sourceHash": "sha256-old-source",
            "updater": {"type": "tangled-tag-artifacts", "did": "did:plc:test", "repo": "bibata"},
        }

    def test_source_only_release_does_not_require_uploaded_artifacts(self):
        html = b'<a href="/test.invalid/bibata/tags/2.0.6">2.0.6</a>'
        with patch("updater.manifest.urllib.request.urlopen") as urlopen:
            urlopen.return_value.__enter__.return_value.read.return_value = html
            self.assertIsNone(_latest_tangled_release("did:plc:test", "bibata"))
            self.assertEqual(
                _latest_tangled_release("did:plc:test", "bibata", require_artifacts=False),
                ("2.0.6", "", []),
            )

    def test_source_only_manifest_prefetches_no_artifacts(self):
        result, updated, call = self.update(self.manifest(), [], {})
        self.assertEqual(result.status, "updated")
        self.assertEqual(updated["version"], "2.0.6")
        self.assertEqual(updated["sourceHash"], "sha256-new-source")
        self.assertNotIn("tagHash", updated)
        self.assertNotIn("hashes", updated)
        self.assertEqual(call.args[-1], [])

    def test_artifact_manifest_keeps_its_hashes(self):
        manifest = self.manifest() | {"tagHash": "b" * 40, "hashes": {"Bibata": "sha256-old"}}
        result, updated, call = self.update(manifest, ["Bibata.zip"], {"Bibata": "sha256-new"})
        self.assertEqual(result.status, "updated")
        self.assertEqual(updated["tagHash"], "a" * 40)
        self.assertEqual(updated["hashes"], {"Bibata": "sha256-new"})
        self.assertEqual(call.args[-1], ["Bibata.zip"])

    def test_artifact_manifest_still_rejects_missing_artifacts(self):
        manifest = self.manifest() | {"hashes": {"Bibata": "sha256-old"}}
        result, updated, call = self.update(manifest, [], {})
        self.assertEqual(result.status, "failed")
        self.assertEqual(updated, manifest)
        self.assertIsNone(call)


if __name__ == "__main__":
    unittest.main()
