#!/usr/bin/env python3
"""Patch the verified Linux x86-64 Packet Tracer 9.0.1 startup login branch."""

import hashlib
from pathlib import Path
import sys

# From the official CiscoPacketTracer_901_Ubuntu_64bit.deb AppImage.
EXPECTED_SHA256 = "3e871b6463798076e4c26adfc2bb4820b9a7822b18bf1cdb33d949048fd3a9db"
OFFSET = 0x42E9A4E
ORIGINAL = bytes.fromhex("0f 85 0e 0f 00 00")
# oldMain: jne 0x42ea962 -> jmp 0x42ea962; retain the six-byte instruction span.
# This skips construction/execution of CNetspaceLogin, then uses the existing
# CAppWindow::setLoginState path (esi = 2) and continues into QApplication::exec.
PATCHED = bytes.fromhex("e9 0f 0f 00 00 90")


def patch(path):
    binary = path.read_bytes()
    actual = hashlib.sha256(binary).hexdigest()
    if actual != EXPECTED_SHA256:
        raise ValueError(f"Unsupported PacketTracer binary SHA-256: {actual}")
    if binary[OFFSET:OFFSET + len(ORIGINAL)] != ORIGINAL:
        raise ValueError("PacketTracer login branch does not match the verified instructions")
    path.write_bytes(binary[:OFFSET] + PATCHED + binary[OFFSET + len(ORIGINAL):])
    print(f"Patched Packet Tracer 9.0.1 login branch at file offset {OFFSET:#x}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} /path/to/PacketTracer")
    try:
        patch(Path(sys.argv[1]))
    except (OSError, ValueError) as error:
        sys.exit(str(error))
