#!/usr/bin/env python3
"""Pack an unpacked Chromium extension directory into a CRX3 file.

Layout: "Cr24" | u32le(3) | u32le(header_len) | CrxFileHeader | zip payload.
The CRX is self-signed with a committed throwaway RSA key so Chromium's
`external_crx` installer (used by home-manager's programs.chromium.extensions
crxPath) accepts it and the extension ID stays stable across rebuilds.

Signature input (chromium components/crx_file/crx_verifier.cc):
  "CRX3 SignedData" || \\x00 || u32le(len(signed_header_data))
  || signed_header_data || zip_payload
signed_header_data = SignedData{ bytes crx_id = 1 }  (protobuf, hand-rolled)
crx_id = SHA256(SPKI DER of the key)[:16]
extension ID = each nibble of crx_id mapped 0..15 -> a..p
"""

import argparse
import hashlib
import io
import json
import struct
import sys
import zipfile
from pathlib import Path

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding


def varint(n: int) -> bytes:
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        if n:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)


def field(number: int, payload: bytes) -> bytes:
    """Length-delimited protobuf field."""
    return varint(number << 3 | 2) + varint(len(payload)) + payload


def deterministic_zip(root: Path) -> bytes:
    """Zip the extension dir deterministically (sorted, fixed mtime)."""
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for path in sorted(root.rglob("*")):
            if not path.is_file():
                continue
            info = zipfile.ZipInfo(path.relative_to(root).as_posix(), date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            zf.writestr(info, path.read_bytes())
    return buf.getvalue()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("src_dir", type=Path, help="unpacked extension directory (manifest.json at root)")
    ap.add_argument("key", type=Path, help="PEM RSA private key (committed throwaway)")
    ap.add_argument("out", type=Path, help="output .crx path")
    ap.add_argument("--expect-id", help="fail if the derived extension ID differs")
    ap.add_argument("--expect-version", help="fail if manifest.json version differs")
    args = ap.parse_args()

    manifest = json.loads((args.src_dir / "manifest.json").read_text())
    version = manifest["version"]
    if args.expect_version and version != args.expect_version:
        sys.exit(
            f"manifest version {version} != expected {args.expect_version} — "
            "bump browserRelayExtension.version in pkgs/oh-my-pi/default.nix"
        )

    key = serialization.load_pem_private_key(args.key.read_bytes(), password=None)
    pub_der = key.public_key().public_bytes(
        serialization.Encoding.DER, serialization.PublicFormat.SubjectPublicKeyInfo
    )
    crx_id = hashlib.sha256(pub_der).digest()[:16]
    ext_id = "".join(chr(ord("a") + n) for byte in crx_id for n in (byte >> 4, byte & 0xF))
    if args.expect_id and ext_id != args.expect_id:
        sys.exit(
            f"extension id {ext_id} != expected {args.expect_id} — "
            "key changed, update extensionId in pkgs/oh-my-pi/default.nix"
        )

    zip_payload = deterministic_zip(args.src_dir)

    signed_header_data = field(1, crx_id)  # SignedData{ crx_id }
    to_sign = (
        b"CRX3 SignedData\x00"
        + struct.pack("<I", len(signed_header_data))
        + signed_header_data
        + zip_payload
    )
    signature = key.sign(to_sign, padding.PKCS1v15(), hashes.SHA256())
    # Round-trip verify so a bad key/format fails the build, not the browser.
    key.public_key().verify(signature, to_sign, padding.PKCS1v15(), hashes.SHA256())

    proof = field(1, pub_der) + field(2, signature)  # AsymmetricKeyProof
    header = field(2, proof) + field(10000, signed_header_data)  # CrxFileHeader
    args.out.write_bytes(b"Cr24" + struct.pack("<II", 3, len(header)) + header + zip_payload)
    print(f"packed {args.src_dir} -> {args.out} (id {ext_id}, version {version})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
