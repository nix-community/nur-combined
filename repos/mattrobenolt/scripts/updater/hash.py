"""Hash helpers for package update scripts."""

import base64


def hex_to_sri(hex_hash: str, algo: str = "sha256") -> str:
    hash_bytes = bytes.fromhex(hex_hash)
    return f"{algo}-{base64.b64encode(hash_bytes).decode('ascii')}"
