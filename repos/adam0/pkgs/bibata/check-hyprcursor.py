import ctypes as C
import math
import os
import sys
import tempfile
from pathlib import Path

import tomllib


class Style(C.Structure):
    _fields_ = [("size", C.c_uint)]


class Image(C.Structure):
    _fields_ = [
        ("surface", C.c_void_p),
        ("size", C.c_int),
        ("delay", C.c_int),
        ("hotspot_x", C.c_int),
        ("hotspot_y", C.c_int),
    ]


def check_theme(theme: Path, config_path: Path, library: str) -> None:
    os.environ["XDG_DATA_DIRS"] = str(theme.parent.parent)
    with tempfile.TemporaryDirectory(prefix="bibata-hypr-home-") as home:
        os.environ["HOME"] = home
        api = C.CDLL(library)
        images_type = C.POINTER(C.POINTER(Image))
        signatures = {
            "hyprcursor_manager_create": ([C.c_char_p], C.c_void_p),
            "hyprcursor_manager_valid": ([C.c_void_p], C.c_int),
            "hyprcursor_manager_free": ([C.c_void_p], None),
            "hyprcursor_load_theme_style": ([C.c_void_p, Style], C.c_int),
            "hyprcursor_get_cursor_image_data": (
                [C.c_void_p, C.c_char_p, Style, C.POINTER(C.c_int)],
                images_type,
            ),
            "hyprcursor_cursor_image_data_free": ([images_type, C.c_int], None),
            "hyprcursor_style_done": ([C.c_void_p, Style], None),
        }
        for name, (arguments, result) in signatures.items():
            function = getattr(api, name)
            function.argtypes = arguments
            function.restype = result
        config = tomllib.loads(config_path.read_text())["cursors"]
        defaults = config["fallback_settings"]
        manager = api.hyprcursor_manager_create(theme.name.encode())
        assert manager and api.hyprcursor_manager_valid(manager)
        try:
            checked = 0
            for size in (24, 48):
                style = Style(size)
                assert api.hyprcursor_load_theme_style(manager, style)
                for settings in config.values():
                    name = settings.get("x11_name")
                    if not name:
                        continue
                    animated = "*" in settings["png"]
                    for shape in [name, *settings.get("x11_symlinks", [])]:
                        count = C.c_int()
                        images = api.hyprcursor_get_cursor_image_data(
                            manager, shape.encode(), style, C.byref(count)
                        )
                        assert images and count.value == (54 if animated else 1), shape
                        try:
                            for index in range(count.value):
                                image = images[index].contents
                                assert image.surface and image.size == size
                                x = settings.get("x_hotspot", defaults["x_hotspot"])
                                y = settings.get("y_hotspot", defaults["y_hotspot"])
                                assert image.hotspot_x == math.floor(
                                    size * x / 256 + 0.5
                                ), shape
                                assert image.hotspot_y == math.floor(
                                    size * y / 256 + 0.5
                                ), shape
                                if animated:
                                    assert image.delay == settings.get(
                                        "x11_delay", defaults["x11_delay"]
                                    )
                        finally:
                            api.hyprcursor_cursor_image_data_free(images, count.value)
                        checked += 1
                api.hyprcursor_style_done(manager, style)
            print(
                f"Loaded and rendered {checked} Hyprcursor shapes/aliases at 24 and 48 px"
            )
        finally:
            api.hyprcursor_manager_free(manager)


if __name__ == "__main__":
    check_theme(Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3])
