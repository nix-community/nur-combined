"""Patch the ELF runtime and relocate SBCL's appended-core pointer."""

import os
import struct
import subprocess
import sys
from pathlib import Path

binary = Path(sys.argv[1])
interpreter, rpath = sys.argv[2:]
word = struct.Struct("<Q")
trailer = struct.Struct("<QQ")
core_magic = 0x5342434C

with binary.open("rb") as stream:
    stream.seek(-trailer.size, os.SEEK_END)
    core_offset, magic = trailer.unpack(stream.read(trailer.size))
    stream.seek(core_offset)
    if magic != core_magic or word.unpack(stream.read(word.size))[0] != core_magic:
        raise ValueError("nodecode has no recognizable SBCL core trailer")

original_size = binary.stat().st_size
subprocess.run(
    ["patchelf", "--set-interpreter", interpreter, "--set-rpath", rpath, str(binary)],
    check=True,
)

# patchelf moves the appended payload when it grows the ELF header, but does
# not know about SBCL's absolute file offset in the final two machine words.
core_offset += binary.stat().st_size - original_size
with binary.open("r+b") as stream:
    stream.seek(core_offset)
    if core_offset % 4096 or word.unpack(stream.read(word.size))[0] != core_magic:
        raise ValueError("patchelf did not preserve the page-aligned SBCL core")
    stream.seek(-trailer.size, os.SEEK_END)
    stream.write(trailer.pack(core_offset, magic))
