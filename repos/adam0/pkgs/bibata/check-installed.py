import json
import struct
import sys
from collections import Counter
from pathlib import Path

import tomllib


def check_theme(theme: Path, config_path: Path) -> None:
    config = tomllib.loads(config_path.read_text())["cursors"]
    defaults = config["fallback_settings"]
    checked = 0
    for settings in config.values():
        name = settings.get("x11_name")
        if not name:
            continue
        scalable = theme / "cursors_scalable" / name
        metadata = json.loads((scalable / "metadata.json").read_text())
        hotspot_x = settings.get("x_hotspot", defaults["x_hotspot"])
        hotspot_y = settings.get("y_hotspot", defaults["y_hotspot"])
        for frame in metadata:
            assert (scalable / frame["filename"]).is_file()
            assert frame["nominal_size"] == 256
            assert frame["hotspot_x"] == hotspot_x
            assert frame["hotspot_y"] == hotspot_y
        for alias in settings.get("x11_symlinks", []):
            assert (theme / "cursors" / alias).resolve() == theme / "cursors" / name
            assert (theme / "cursors_scalable" / alias).resolve() == scalable
        sizes = Counter()
        with (theme / "cursors" / name).open("rb") as cursor:
            magic, header_size, _, count = struct.unpack("<4I", cursor.read(16))
            assert magic == 0x72756358
            cursor.seek(header_size)
            table = [struct.unpack("<3I", cursor.read(12)) for _ in range(count)]
            for chunk_type, size, position in table:
                if chunk_type != 0xFFFD0002:
                    continue
                cursor.seek(position)
                fields = struct.unpack("<9I", cursor.read(36))
                width, height, x, y, delay = fields[4:]
                assert x == int(hotspot_x * width / 256)
                assert y == int(hotspot_y * height / 256)
                if len(metadata) > 1:
                    assert delay == settings.get("x11_delay", defaults["x11_delay"])
                sizes[size] += 1
        expected_sizes = settings.get("x11_sizes", defaults["x11_sizes"])
        assert sizes == Counter({size: len(metadata) for size in expected_sizes})
        checked += 1
    assert (theme / "index.theme").is_file()
    print(
        f"Verified {checked} XCursor/scalable shapes, hotspots, aliases, sizes and delays"
    )


if __name__ == "__main__":
    check_theme(Path(sys.argv[1]), Path(sys.argv[2]))
