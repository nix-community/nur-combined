#!/usr/bin/env python3
"""Reject plaintext tokens in the repository's optional SOPS secret file."""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def is_encrypted_secret(content):
    return all(re.search(pattern, content, re.MULTILINE) for pattern in (
        # SOPS deliberately leaves empty strings unencrypted; allow a blank
        # template, but require ciphertext for every nonempty token value.
        r'''^cachix_auth_token:[ \t]*(?:ENC\[AES256_GCM,[^\r\n]+\]|""|'')[ \t]*$''',
        r"^sops:\s*$",
        r"^\s+mac:\s*ENC\[AES256_GCM,[^\r\n]+\]\s*$",
    ))


class RepositorySecretsTests(unittest.TestCase):
    def test_optional_repository_token_is_sops_encrypted(self):
        path = ROOT / "secrets/cachix.yaml"
        if path.exists():
            self.assertTrue(is_encrypted_secret(path.read_text()),
                            "secrets/cachix.yaml must be SOPS encrypted; refusing plaintext")

    def test_guard_rejects_plaintext_and_placeholder(self):
        self.assertFalse(is_encrypted_secret("cachix_auth_token: example-not-a-token\n"))
        self.assertFalse(is_encrypted_secret((ROOT / "secrets/cachix.yaml.example").read_text()))

    def test_guard_accepts_sops_shaped_ciphertext(self):
        self.assertTrue(is_encrypted_secret(
            "cachix_auth_token: ENC[AES256_GCM,data:fixture,tag:fixture,type:str]\n"
            "sops:\n    mac: ENC[AES256_GCM,data:fixture,type:str]\n"
        ))

    def test_guard_accepts_blank_value_only_with_sops_metadata(self):
        self.assertTrue(is_encrypted_secret(
            'cachix_auth_token: ""\nsops:\n    mac: ENC[AES256_GCM,data:fixture,type:str]\n'
        ))
        self.assertFalse(is_encrypted_secret('cachix_auth_token: ""\n'))

    def test_active_sops_config_has_no_template_recipients(self):
        path = ROOT / ".sops.yaml"
        if path.exists():
            self.assertNotIn("REPLACE_WITH", path.read_text(),
                             "Replace example age recipients before using .sops.yaml")


if __name__ == "__main__":
    unittest.main(verbosity=2)
