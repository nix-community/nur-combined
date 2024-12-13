#!/usr/bin/env python
import json
import os
import re
import shlex
import sys
from typing import Dict, List, Tuple

from requests.structures import CaseInsensitiveDict
from win2xcur.parser import open_blob
from win2xcur.writer import to_x11

if len(sys.argv) < 3:
    print(f"Usage: {sys.argv[0]} path/to/windows.inf path/to/linux/folder")
    exit(1)

windows_inf = sys.argv[1]
linux_folder = sys.argv[2]


class WindowsCursors:
    DEFAULT = "default"
    HELP = "help"
    PROGRESS = "progress"
    WAIT = "wait"
    CROSSHAIR = "crosshair"
    TEXT = "text"
    PENCIL = "pencil"
    NOT_ALLOWED = "not-allowed"
    SIZE_VER = "size-ver"
    SIZE_HOR = "size-hor"
    SIZE_NW_SE = "size-fdiag"
    SIZE_NE_SW = "size-bdiag"
    MOVE = "move"
    RIGHT_PTR = "right_ptr"
    POINTER = "pointer"


CURSOR_MAPPINGS: Dict[str, str] = {
    "00000000000000020006000e7e9ffc3f": WindowsCursors.PROGRESS,
    "00008160000006810000408080010102": WindowsCursors.SIZE_VER,
    "03b6e0fcb3499374a867c041f52298f0": WindowsCursors.NOT_ALLOWED,
    "08e8e1c95fe2fc01f976f1e063a24ccd": WindowsCursors.PROGRESS,
    "1081e37283d90000800003c07f3ef6bf": WindowsCursors.DEFAULT,
    "3085a0e285430894940527032f8b26df": WindowsCursors.DEFAULT,
    "3ecb610c1bf2410f44200f48c40d3599": WindowsCursors.PROGRESS,
    "4498f0e0c1937ffe01fd06f973665830": WindowsCursors.MOVE,
    "5c6cd98b3f3ebcb1f9c7f1c204630408": WindowsCursors.HELP,
    "6407b0e94181790501fd1e167b474872": WindowsCursors.DEFAULT,
    "640fb0e74195791501fd1ed57b41487f": WindowsCursors.DEFAULT,
    "9081237383d90e509aa00f00170e968f": WindowsCursors.MOVE,
    "9d800788f1b08800ae810202380a0822": WindowsCursors.POINTER,
    "a2a266d0498c3104214a47bd64ab0fc8": WindowsCursors.DEFAULT,
    "alias": WindowsCursors.DEFAULT,
    "all-scroll": WindowsCursors.MOVE,
    "b66166c04f8c3109214a4fbd64a50fc8": WindowsCursors.DEFAULT,
    "bottom_left_corner": WindowsCursors.SIZE_NE_SW,
    "bottom_right_corner": WindowsCursors.SIZE_NW_SE,
    "bottom_side": WindowsCursors.SIZE_VER,
    "bottom_tee": WindowsCursors.SIZE_VER,
    "cell": WindowsCursors.CROSSHAIR,
    "center_ptr": WindowsCursors.CROSSHAIR,
    "circle": WindowsCursors.NOT_ALLOWED,
    "closedhand": WindowsCursors.MOVE,
    "color-picker": WindowsCursors.DEFAULT,
    "col-resize": WindowsCursors.SIZE_HOR,
    "context-menu": WindowsCursors.DEFAULT,
    "copy": WindowsCursors.DEFAULT,
    "cross": WindowsCursors.CROSSHAIR,
    "crossed_circle": WindowsCursors.NOT_ALLOWED,
    "d9ce0ab605698f320427677b458ad60b": WindowsCursors.HELP,
    "dnd-copy": WindowsCursors.DEFAULT,
    "dnd-move": WindowsCursors.MOVE,
    "dnd-no-drop": WindowsCursors.NOT_ALLOWED,
    "dnd-none": WindowsCursors.MOVE,
    "down-arrow": WindowsCursors.DEFAULT,
    "draft": WindowsCursors.PENCIL,
    "e29285e634086352946a0e7090d73106": WindowsCursors.POINTER,
    "e-resize": WindowsCursors.SIZE_HOR,
    "fcf21c00b30f7e3f83fe0dfd12e71cff": WindowsCursors.MOVE,
    "fleur": WindowsCursors.MOVE,
    "forbidden": WindowsCursors.NOT_ALLOWED,
    "half-busy": WindowsCursors.PROGRESS,
    "hand1": WindowsCursors.POINTER,
    "hand2": WindowsCursors.POINTER,
    "h_double_arrow": WindowsCursors.SIZE_HOR,
    "ibeam": WindowsCursors.TEXT,
    "left-arrow": WindowsCursors.DEFAULT,
    "left_ptr": WindowsCursors.DEFAULT,
    "left_ptr_help": WindowsCursors.HELP,
    "left_ptr_watch": WindowsCursors.PROGRESS,
    "left_side": WindowsCursors.SIZE_HOR,
    "link": WindowsCursors.DEFAULT,
    "ne-resize": WindowsCursors.SIZE_NE_SW,
    "no-drop": WindowsCursors.NOT_ALLOWED,
    "resize": WindowsCursors.SIZE_VER,
    "nw-resize": WindowsCursors.SIZE_NW_SE,
    "openhand": WindowsCursors.MOVE,
    "pirate": WindowsCursors.NOT_ALLOWED,
    "plus": WindowsCursors.CROSSHAIR,
    "pointing_hand": WindowsCursors.POINTER,
    "question_arrow": WindowsCursors.HELP,
    "right-arrow": WindowsCursors.DEFAULT,
    "right_side": WindowsCursors.SIZE_HOR,
    "row-resize": WindowsCursors.SIZE_VER,
    "sb_h_double_arrow": WindowsCursors.SIZE_HOR,
    "sb_v_double_arrow": WindowsCursors.SIZE_VER,
    "se-resize": WindowsCursors.SIZE_NW_SE,
    "size_all": WindowsCursors.MOVE,
    "size_bdiag": WindowsCursors.SIZE_NE_SW,
    "size_fdiag": WindowsCursors.SIZE_NW_SE,
    "size_hor": WindowsCursors.SIZE_HOR,
    "size_ver": WindowsCursors.SIZE_VER,
    "split_h": WindowsCursors.SIZE_HOR,
    "split_v": WindowsCursors.SIZE_VER,
    "s-resize": WindowsCursors.SIZE_VER,
    "sw-resize": WindowsCursors.SIZE_NE_SW,
    "top_left_arrow": WindowsCursors.DEFAULT,
    "top_left_corner": WindowsCursors.SIZE_NW_SE,
    "top_right_corner": WindowsCursors.SIZE_NE_SW,
    "top_side": WindowsCursors.SIZE_VER,
    "top_tee": WindowsCursors.SIZE_VER,
    "up-arrow": WindowsCursors.SIZE_VER,
    "v_double_arrow": WindowsCursors.SIZE_VER,
    "vertical-text": WindowsCursors.TEXT,
    "watch": WindowsCursors.WAIT,
    "wayland-cursor": WindowsCursors.DEFAULT,
    "whats_this": WindowsCursors.HELP,
    "w-resize": WindowsCursors.SIZE_HOR,
    "x-cursor": WindowsCursors.DEFAULT,
    "xterm": WindowsCursors.TEXT,
    "zoom-in": WindowsCursors.MOVE,
    "zoom-out": WindowsCursors.MOVE,
}


class WindowsInfParser:
    def __init__(self, inf_path: str):
        self.inf_path = inf_path
        self.dict, self.list = self._load(inf_path)
        print(self.dict)

    def _load(self, path: str) -> Tuple[
        CaseInsensitiveDict[str, CaseInsensitiveDict[str, str]],
        CaseInsensitiveDict[str, List[str]],
    ]:
        with open(path) as f:
            content = [s.strip() for s in f.readlines()]

        result_dict: CaseInsensitiveDict[str, CaseInsensitiveDict[str, str]] = (
            CaseInsensitiveDict()
        )
        result_list: CaseInsensitiveDict[str, List[str]] = CaseInsensitiveDict()
        current_key = None
        for line in content:
            if not line:
                continue

            match = re.match(r"^\[(.*)\]$", line, re.IGNORECASE | re.MULTILINE)
            if match:
                current_key = match[1]
                continue

            match = re.match(
                r"^(\S+)\s*=\s*(\S.*)$", line, re.IGNORECASE | re.MULTILINE
            )
            if match:
                if current_key not in result_dict:
                    result_dict[current_key] = CaseInsensitiveDict()

                result_dict[current_key][match[1]] = match[2]
                continue

            if current_key not in result_list:
                result_list[current_key] = []
            result_list[current_key].append(line)

        return result_dict, result_list

    def eval_string(self, s: str) -> str:
        def _normalize_string(s: str) -> str:
            s = s.replace("\\", "/")
            if re.match("^('|\").*('|\")$", s):
                s = json.loads(s)
            return s

        def _substitute_variable(match: re.Match[str]) -> str:
            var_name = match.group(1)
            strings: CaseInsensitiveDict = self.dict.get(
                "Strings", CaseInsensitiveDict()
            )
            return _normalize_string(strings.get(var_name, match.group(0)))

        return re.sub("%([^%]+)%", _substitute_variable, _normalize_string(s))

    def get_cursor_path(self, cursor_path: str) -> str:
        # TODO: implement path parsing instead of assuming
        # cursors are in same directory as inf file
        cursor_path = self.eval_string(cursor_path)
        return os.path.join(
            os.path.dirname(self.inf_path), os.path.basename(cursor_path)
        )

    def normalize_name(self, name: str) -> str:
        name = re.sub(r"\W+$", "", name)
        name = re.sub(r"\W+", "_", name)
        return name

    def get_cursor_scheme(self):
        add_reg = self.dict.get("DefaultInstall", CaseInsensitiveDict()).get("AddReg")

        if not add_reg:
            return None

        add_reg = add_reg.split(",")
        for reg in add_reg:
            entries = self.list[reg]
            for entry in entries:
                try:
                    args = shlex.split(entry.replace(",", " "))
                    print(f"Parse result: {args}")
                    if args[0].upper() in ["HKCU", "HKEY_CURRENT_USER"] and re.match(
                        r"Control Panel.?Cursors.?Schemes", args[1], flags=re.IGNORECASE
                    ):
                        if '"' in args[3]:
                            cursors = shlex.split(args[3])
                        else:
                            cursors = args[3].split(" ")
                        print(cursors)
                        return {
                            "__name__": self.normalize_name(self.eval_string(args[2])),
                            WindowsCursors.DEFAULT: self.get_cursor_path(cursors[0]),
                            WindowsCursors.HELP: self.get_cursor_path(cursors[1]),
                            WindowsCursors.PROGRESS: self.get_cursor_path(cursors[2]),
                            WindowsCursors.WAIT: self.get_cursor_path(cursors[3]),
                            WindowsCursors.CROSSHAIR: self.get_cursor_path(cursors[4]),
                            WindowsCursors.TEXT: self.get_cursor_path(cursors[5]),
                            WindowsCursors.PENCIL: self.get_cursor_path(cursors[6]),
                            WindowsCursors.NOT_ALLOWED: self.get_cursor_path(
                                cursors[7]
                            ),
                            WindowsCursors.SIZE_VER: self.get_cursor_path(cursors[8]),
                            WindowsCursors.SIZE_HOR: self.get_cursor_path(cursors[9]),
                            WindowsCursors.SIZE_NW_SE: self.get_cursor_path(
                                cursors[10]
                            ),
                            WindowsCursors.SIZE_NE_SW: self.get_cursor_path(
                                cursors[11]
                            ),
                            WindowsCursors.MOVE: self.get_cursor_path(cursors[12]),
                            WindowsCursors.RIGHT_PTR: self.get_cursor_path(cursors[13]),
                            WindowsCursors.POINTER: self.get_cursor_path(cursors[14]),
                        }
                except ValueError:
                    print(f"Cannot parse {entry}, skipping")

        return None

    def convert(self, target_path: str):
        scheme = self.get_cursor_scheme()
        if not scheme:
            raise RuntimeError("Invalid scheme")

        target_cursor_path = os.path.join(target_path, "cursors")

        os.makedirs(target_cursor_path, exist_ok=True)
        for cursor_name, src_file in scheme.items():
            if cursor_name == "__name__":
                continue

            dst_file = os.path.join(target_cursor_path, cursor_name)
            print(cursor_name, src_file, dst_file)

            with open(src_file, "rb") as f:
                blob = f.read()

            # with src_
            # name = file.name
            # blob = file.read()
            try:
                cursor = open_blob(blob)
            except Exception:
                print(
                    f"Error occurred while processing {cursor_name}:", file=sys.stderr
                )
            else:
                result = to_x11(cursor.frames)

                try:
                    os.remove(dst_file)
                except Exception:
                    pass

                with open(dst_file, "wb") as f:
                    f.write(result)

        for cursor_symlink, cursor_actual in CURSOR_MAPPINGS.items():
            full_path_to_create = os.path.join(target_cursor_path, cursor_symlink)

            try:
                os.remove(full_path_to_create)
            except Exception:
                pass

            print(cursor_actual, full_path_to_create)
            os.symlink(cursor_actual, full_path_to_create)

        theme_file_path = os.path.join(target_path, "cursor.theme")
        try:
            os.remove(theme_file_path)
        except Exception:
            pass

        with open(theme_file_path, "w") as f:
            scheme_name = scheme["__name__"]
            f.write(f"[Icon Theme]\nName={scheme_name}")


parser = WindowsInfParser(windows_inf)
# print(parser.dict)
scheme = parser.get_cursor_scheme()
print(scheme)
parser.convert(linux_folder)
