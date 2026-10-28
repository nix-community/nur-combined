#!/usr/bin/env python3
"""Skip the startup login dialog in the supplied Linux i386 Packet Tracer 6.3."""

import hashlib
from pathlib import Path
import sys

EXPECTED_SHA256 = "09b2752c12323a5d19fb5a9d960f8e8f0c43881e1665c27080faf8b38fdc6106"
# ELF virtual address 0x0813097c, mapped at file offset VA - 0x08048000.
OFFSET = 0xE897C
ORIGINAL = bytes.fromhex("0f 84 0d 05 00 00")
# oldMain: je 0x08130e8f -> jmp 0x08130e8f; nop. The target is the existing
# continuation after the complete CNetspaceLogin construction/exec/destruction
# block. No login object or authentication token is manufactured.
PATCHED = bytes.fromhex("e9 0e 05 00 00 90")


def patch(path):
    binary = path.read_bytes()
    actual = hashlib.sha256(binary).hexdigest()
    if actual != EXPECTED_SHA256:
        raise ValueError(f"Unsupported PacketTracer6 binary SHA-256: {actual}")
    if binary[OFFSET:OFFSET + len(ORIGINAL)] != ORIGINAL:
        raise ValueError("PacketTracer6 login branch does not match the verified instructions")
    path.write_bytes(binary[:OFFSET] + PATCHED + binary[OFFSET + len(ORIGINAL):])
    print(f"Patched Packet Tracer 6.3 startup login branch at file offset {OFFSET:#x}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} /path/to/PacketTracer6")
    try:
        patch(Path(sys.argv[1]))
    except (OSError, ValueError) as error:
        sys.exit(str(error))
