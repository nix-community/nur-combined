#!/usr/bin/env python3
"""Handle LC_REEXPORT_DYLIB changes unsupported by LLVM 21."""

import os
import stat
import struct
import subprocess
import sys
import tempfile
from typing import NoReturn

LLVM_INSTALL_NAME_TOOL = os.environ["LLVM_INSTALL_NAME_TOOL"]
LDID = os.environ["LDID"]

MH_MAGIC_64 = 0xFEEDFACF
LC_ID_DYLIB = 0xD
LC_SEGMENT_64 = 0x19
LC_CODE_SIGNATURE = 0x1D
LC_RPATH = 0x8000001C
LC_REEXPORT_DYLIB = 0x8000001F
DEPENDENCY_TYPES = {
    0xC,  # LC_LOAD_DYLIB
    0x80000018,  # LC_LOAD_WEAK_DYLIB
    LC_REEXPORT_DYLIB,
    0x20,  # LC_LAZY_LOAD_DYLIB
    0x80000023,  # LC_LOAD_UPWARD_DYLIB
}
DYLIB_TYPES = DEPENDENCY_TYPES | {LC_ID_DYLIB}
NAMED_TYPES = DYLIB_TYPES | {LC_RPATH}


def llvm_install_name_tool() -> NoReturn:
    os.execv(LLVM_INSTALL_NAME_TOOL, [LLVM_INSTALL_NAME_TOOL, *sys.argv[1:]])


def parse_arguments(arguments):
    if not arguments:
        return None

    if arguments[0] in {
        "-add_rpath",
        "-change",
        "-delete_rpath",
        "-id",
        "-rpath",
    }:
        path = arguments[-1]
        options = arguments[:-1]
    else:
        path = arguments[0]
        options = arguments[1:]

    changes = []
    new_id = None
    rpath_changes = []
    added_rpaths = []
    deleted_rpaths = []
    index = 0
    while index < len(options):
        if options[index] == "-change" and index + 2 < len(options):
            changes.append((options[index + 1], options[index + 2]))
            index += 3
        elif options[index] == "-id" and index + 1 < len(options):
            new_id = options[index + 1]
            index += 2
        elif options[index] == "-rpath" and index + 2 < len(options):
            rpath_changes.append((options[index + 1], options[index + 2]))
            index += 3
        elif options[index] == "-add_rpath" and index + 1 < len(options):
            added_rpaths.append(options[index + 1])
            index += 2
        elif options[index] == "-delete_rpath" and index + 1 < len(options):
            deleted_rpaths.append(options[index + 1])
            index += 2
        else:
            return None

    return path, changes, new_id, rpath_changes, added_rpaths, deleted_rpaths


def parse_macho(data):
    if len(data) < 32 or struct.unpack_from("<I", data)[0] != MH_MAGIC_64:
        return None

    ncmds, sizeofcmds = struct.unpack_from("<II", data, 16)
    commands_end = 32 + sizeofcmds
    if commands_end > len(data):
        raise RuntimeError("load commands extend beyond end of file")

    commands = []
    first_data = len(data)
    offset = 32
    has_signature = False

    for _ in range(ncmds):
        if offset + 8 > commands_end:
            raise RuntimeError("truncated Mach-O load command")
        command, command_size = struct.unpack_from("<II", data, offset)
        if command_size < 8 or offset + command_size > commands_end:
            raise RuntimeError("invalid Mach-O load command size")

        raw = data[offset : offset + command_size]
        name = None
        name_offset = None
        if command in NAMED_TYPES:
            minimum_size = 24 if command in DYLIB_TYPES else 12
            if command_size < minimum_size:
                raise RuntimeError("truncated named load command")
            name_offset = struct.unpack_from("<I", raw, 8)[0]
            if name_offset >= command_size:
                raise RuntimeError("invalid load-command name offset")
            name_end = raw.find(b"\0", name_offset)
            if name_end < 0:
                raise RuntimeError("unterminated load-command name")
            name = raw[name_offset:name_end].decode("utf-8")

        if command == LC_SEGMENT_64:
            if command_size < 72:
                raise RuntimeError("truncated segment load command")
            segment_offset, segment_size = struct.unpack_from("<QQ", raw, 40)
            section_count = struct.unpack_from("<I", raw, 64)[0]
            if 72 + section_count * 80 > command_size:
                raise RuntimeError("truncated section table")
            if segment_size and segment_offset:
                first_data = min(first_data, segment_offset)
            elif segment_size and section_count == 0:
                first_data = min(first_data, commands_end)
            for section_index in range(section_count):
                section_offset = struct.unpack_from(
                    "<I", raw, 72 + section_index * 80 + 48
                )[0]
                if section_offset:
                    first_data = min(first_data, section_offset)

        has_signature = has_signature or command == LC_CODE_SIGNATURE
        commands.append((command, raw, name_offset, name))
        offset += command_size

    if offset != commands_end:
        raise RuntimeError("load-command size does not match Mach-O header")
    if first_data < commands_end:
        raise RuntimeError("file data overlaps load commands")

    return sizeofcmds, first_data, commands, has_signature


def dylib_snapshot(data):
    parsed = parse_macho(data)
    if parsed is None:
        raise RuntimeError("rewritten file is not a supported Mach-O")
    return [
        (command, name)
        for command, _raw, _offset, name in parsed[2]
        if name is not None
    ]


def main():
    arguments = parse_arguments(sys.argv[1:])
    if arguments is None:
        llvm_install_name_tool()

    path, changes, new_id, rpath_changes, added_rpaths, deleted_rpaths = arguments
    path = os.path.realpath(path)
    with open(path, "rb") as source:
        original = source.read()

    parsed = parse_macho(original)
    if parsed is None:
        llvm_install_name_tool()

    sizeofcmds, data_start, commands, had_signature = parsed
    if not any(command == LC_REEXPORT_DYLIB for command, *_rest in commands):
        llvm_install_name_tool()

    entitlements = b""
    if had_signature:
        entitlements = subprocess.run(
            [LDID, "-e", path], check=True, stdout=subprocess.PIPE
        ).stdout

    names = [name for change in changes for name in change]
    names.extend(name for change in rpath_changes for name in change)
    names.extend(added_rpaths)
    names.extend(deleted_rpaths)
    if new_id is not None:
        names.append(new_id)
    if any("\0" in name for name in names):
        raise RuntimeError("dylib names cannot contain NUL bytes")

    rpath_operands = [name for change in rpath_changes for name in change]
    if len(set(rpath_operands)) != len(rpath_operands):
        raise RuntimeError("overlapping -rpath operations")
    changed_rpaths = set(rpath_operands)
    if set(deleted_rpaths) & changed_rpaths:
        raise RuntimeError("conflicting -rpath and -delete_rpath operations")
    if set(added_rpaths) & (changed_rpaths | set(deleted_rpaths)):
        raise RuntimeError("conflicting rpath add, change, or delete operations")

    rpaths = [name for command, _raw, _offset, name in commands if command == LC_RPATH]
    for old, new in rpath_changes:
        if old not in rpaths:
            raise RuntimeError(f"no LC_RPATH load command with path: {old}")
        if new != old and new in rpaths:
            raise RuntimeError(f"LC_RPATH load command already exists: {new}")
        rpaths = [new if rpath == old else rpath for rpath in rpaths]
    for rpath in deleted_rpaths:
        if rpath not in rpaths:
            raise RuntimeError(f"no LC_RPATH load command with path: {rpath}")
        rpaths = [existing for existing in rpaths if existing != rpath]
    for rpath in added_rpaths:
        if rpath in rpaths:
            raise RuntimeError(f"LC_RPATH load command already exists: {rpath}")
        rpaths.append(rpath)

    expected = []
    rewritten_commands = []

    for command, raw, name_offset, name in commands:
        replacement_name = name
        delete_command = False
        if command in DEPENDENCY_TYPES:
            for old, new in changes:
                if replacement_name == old:
                    replacement_name = new
        elif command == LC_ID_DYLIB and new_id is not None:
            replacement_name = new_id
        elif command == LC_RPATH:
            for old, new in rpath_changes:
                if replacement_name == old:
                    replacement_name = new
            delete_command = replacement_name in deleted_rpaths

        if delete_command:
            continue
        if replacement_name != name:
            replacement_bytes = replacement_name.encode("utf-8")
            required_size = name_offset + len(replacement_bytes) + 1
            required_size = (required_size + 7) & ~7
            command_size = max(len(raw), required_size)
            replacement = bytearray(command_size)
            replacement[:name_offset] = raw[:name_offset]
            struct.pack_into("<I", replacement, 4, command_size)
            replacement[name_offset : name_offset + len(replacement_bytes)] = (
                replacement_bytes
            )
            raw = bytes(replacement)
            name = replacement_name

        rewritten_commands.append(raw)
        if name is not None:
            expected.append((command, name))

    for rpath in added_rpaths:
        rpath_bytes = rpath.encode("utf-8")
        command_size = (12 + len(rpath_bytes) + 1 + 7) & ~7
        command_data = bytearray(command_size)
        struct.pack_into("<III", command_data, 0, LC_RPATH, command_size, 12)
        command_data[12 : 12 + len(rpath_bytes)] = rpath_bytes
        rewritten_commands.append(bytes(command_data))
        expected.append((LC_RPATH, rpath))

    load_commands = b"".join(rewritten_commands)
    if 32 + len(load_commands) > data_start:
        raise RuntimeError(
            f"replacement needs {len(load_commands) - sizeofcmds} bytes, but only "
            f"{data_start - 32 - sizeofcmds} bytes of load-command padding are available"
        )

    rewritten = bytearray(original)
    struct.pack_into("<II", rewritten, 16, len(rewritten_commands), len(load_commands))
    rewritten[32:data_start] = load_commands + bytes(
        data_start - 32 - len(load_commands)
    )

    directory = os.path.dirname(path)
    fd, temporary = tempfile.mkstemp(prefix=".install-name-tool-", dir=directory)
    entitlements_path = None
    try:
        with os.fdopen(fd, "wb") as result:
            result.write(rewritten)

        if bytes(rewritten[data_start:]) != original[data_start:]:
            raise RuntimeError("rewriter changed bytes outside the load-command area")
        with open(temporary, "rb") as result:
            if dylib_snapshot(result.read()) != expected:
                raise RuntimeError("rewritten dylib commands differ from expectation")

        if had_signature:
            sign_command = [LDID, "-S", temporary]
            if entitlements:
                entitlements_fd, entitlements_path = tempfile.mkstemp(
                    prefix=".install-name-tool-entitlements-", dir=directory
                )
                with os.fdopen(entitlements_fd, "wb") as entitlements_file:
                    entitlements_file.write(entitlements)
                sign_command = [LDID, f"-S{entitlements_path}", temporary]
            subprocess.run(sign_command, check=True)
            with open(temporary, "rb") as result:
                if dylib_snapshot(result.read()) != expected:
                    raise RuntimeError("ad-hoc signing altered dylib commands")

        os.chmod(temporary, stat.S_IMODE(os.stat(path).st_mode))
        os.replace(temporary, path)
    finally:
        for temporary_path in (temporary, entitlements_path):
            if temporary_path is None:
                continue
            try:
                os.unlink(temporary_path)
            except FileNotFoundError:
                pass

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
