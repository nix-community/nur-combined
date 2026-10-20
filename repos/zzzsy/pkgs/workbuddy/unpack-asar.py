"""Extract packed ASAR entries, preserving the deb's unpacked native modules."""

import json
import os
import struct
import sys
from pathlib import Path


def unpack(archive, destination):
    destination = Path(destination)
    with open(archive, "rb") as stream:
        _, header_size = struct.unpack("<II", stream.read(8))
        header = stream.read(header_size)
        json_size = struct.unpack("<I", header[4:8])[0]
        entries = json.loads(header[8 : 8 + json_size])
        data_offset = 8 + header_size
        missing = 0

        def walk(node, directory):
            nonlocal missing
            directory.mkdir(parents=True, exist_ok=True)
            for name, entry in node.get("files", {}).items():
                path = directory / name
                if "files" in entry:
                    walk(entry, path)
                elif "link" in entry:
                    if not path.is_symlink() and not path.exists():
                        target = destination / entry["link"]
                        path.symlink_to(os.path.relpath(target, path.parent))
                elif entry.get("unpacked"):
                    missing += not path.exists()
                else:
                    stream.seek(data_offset + int(entry["offset"]))
                    content = stream.read(entry["size"])
                    if len(content) != entry["size"]:
                        raise ValueError(f"Truncated ASAR entry: {path}")
                    path.write_bytes(content)
                    if entry.get("executable"):
                        path.chmod(0o755)

        walk(entries, destination)
    print(f"Extracted ASAR; skipped {missing} absent unpacked entries")


if __name__ == "__main__":
    unpack(*sys.argv[1:])
