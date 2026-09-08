import base64
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import update


class UpdateTests(unittest.TestCase):
    def setUp(self):
        directory = self.enterContext(tempfile.TemporaryDirectory())
        self.source = Path(directory) / "source.json"
        self.original = '{"version": "1.0"}\n'
        self.source.write_text(self.original)
        self.indexes = {}
        self.downloads = {}
        self.expected = {"version": "2.0"}
        base_url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/"
        for system, architecture in [("aarch64-linux", "arm64"), ("x86_64-linux", "amd64")]:
            payload = f"fixture package for {architecture}".encode()
            digest = hashlib.sha256(payload).digest()
            filename = f"pool/main/c/chatgpt/chatgpt_2.0_{architecture}.deb"
            index_url = f"{base_url}dists/stable/main/binary-{architecture}/Packages"
            self.indexes[index_url] = (
                "Package: chatgpt\n"
                f"Architecture: {architecture}\n"
                "Version: 2.0\n"
                f"Filename: {filename}\n"
                f"SHA256: {digest.hex()}\n"
                f"Size: {len(payload)}\n"
            )
            self.downloads[base_url + filename] = payload
            self.expected[system] = {
                "hash": "sha256-" + base64.b64encode(digest).decode(),
                "url": base_url + filename,
            }

        def fetch_index(command, *, text):
            self.assertTrue(text)
            return self.indexes[command[-1]]

        def download(command, *, stdout, check):
            self.assertTrue(check)
            stdout.write(self.downloads[command[-1]])

        self.enterContext(patch.object(update, "Path")).return_value.with_name.return_value = self.source
        self.fetch_index = self.enterContext(
            patch.object(update.subprocess, "check_output", side_effect=fetch_index)
        )
        self.download = self.enterContext(
            patch.object(update.subprocess, "run", side_effect=download)
        )
        self.enterContext(patch("builtins.print"))

    def test_updates_both_architectures(self):
        update.main()

        self.assertEqual(
            self.source.read_text(),
            json.dumps(self.expected, indent=2, sort_keys=True) + "\n",
        )
        self.assertEqual(
            [args.args[0][-1] for args in self.fetch_index.call_args_list],
            list(self.indexes),
        )
        self.assertEqual(
            [args.args[0][-1] for args in self.download.call_args_list],
            list(self.downloads),
        )

    def test_current_pin_does_not_download_or_write(self):
        original = json.dumps(self.expected)
        self.source.write_text(original)
        with patch.object(Path, "write_text") as write:
            update.main()
        self.assertEqual(self.fetch_index.call_count, 2)
        self.download.assert_not_called()
        write.assert_not_called()
        self.assertEqual(self.source.read_text(), original)

    def test_mismatched_architecture_versions_do_not_write(self):
        index_url = next(url for url in self.indexes if "binary-amd64" in url)
        self.indexes[index_url] = self.indexes[index_url].replace("2.0", "2.1")
        url = self.expected["x86_64-linux"]["url"]
        self.downloads[url.replace("2.0", "2.1")] = self.downloads.pop(url)
        with patch.object(Path, "write_text") as write:
            with self.assertRaisesRegex(RuntimeError, "Architecture versions differ"):
                update.main()
        write.assert_not_called()
        self.assertEqual(self.source.read_text(), self.original)

    def test_checksum_or_size_mismatch_does_not_write(self):
        # Fail the second download to check that a valid first archive is not committed early.
        url = self.expected["x86_64-linux"]["url"]
        payload = self.downloads[url]
        for failure in ("checksum", "size"):
            with self.subTest(failure=failure):
                self.downloads[url] = b"x" * len(payload) if failure == "checksum" else payload
                index_url = next(url for url in self.indexes if "binary-amd64" in url)
                original_index = self.indexes[index_url]
                if failure == "size":
                    self.indexes[index_url] = original_index.replace(
                        f"Size: {len(payload)}", f"Size: {len(payload) + 1}"
                    )
                with patch.object(Path, "write_text") as write:
                    with self.assertRaisesRegex(RuntimeError, "Download does not match repository metadata"):
                        update.main()
                write.assert_not_called()
                self.assertEqual(self.source.read_text(), self.original)
                self.indexes[index_url] = original_index

    def test_downgrade_does_not_write(self):
        original = '{"version": "10.0"}\n'
        self.source.write_text(original)
        with patch.object(Path, "write_text") as write:
            with self.assertRaisesRegex(RuntimeError, "Refusing to downgrade ChatGPT"):
                update.main()
        write.assert_not_called()
        self.assertEqual(self.source.read_text(), original)

    def test_ambiguous_index_and_malicious_filenames_are_rejected(self):
        index_url = next(iter(self.indexes))
        original_index = self.indexes[index_url]
        filename = "pool/main/c/chatgpt/chatgpt_2.0_arm64.deb"
        cases = [
            (original_index + "\n" + original_index, "Expected one ChatGPT package"),
            ("", "Expected one ChatGPT package"),
            (original_index.replace(filename, "../../outside.deb"), "Unexpected package filename"),
            (original_index.replace(filename, "https://evil.invalid/package.deb"), "Unexpected package filename"),
        ]
        for index, error in cases:
            with self.subTest(index=index):
                self.indexes[index_url] = index
                with patch.object(Path, "write_text") as write:
                    with self.assertRaisesRegex(RuntimeError, error):
                        update.main()
                self.download.assert_not_called()
                write.assert_not_called()
                self.assertEqual(self.source.read_text(), self.original)


if __name__ == "__main__":
    unittest.main()
