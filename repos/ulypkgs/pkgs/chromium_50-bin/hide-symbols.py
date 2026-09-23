#!/usr/bin/env python3
"""Hide dynamic symbols of ELF files that would interpose on another library.

usage: hide-symbols.py <provider.so> <elf-file>...

A prebuilt executable that statically links a copy of a library exports the
symbols of that copy.  The dynamic linker resolves the references of every loaded
object starting at the executable, so the libraries that the executable loads use
the bundled copy instead of the one they were built against, and if the two
copies have different internal ABIs, that crashes the program.

Marking those symbols as hidden (STV_HIDDEN) makes the dynamic linker skip them
when it resolves the references of other objects, while the calls inside the
executable itself are unaffected, because the static linker resolved them
directly.  Symbols that are referenced by a relocation of the same file cannot be
hidden this way, because the dynamic linker has to resolve their relocation, so
they are left alone and reported.
"""
import struct
import sys

ELF_MAGIC = b"\x7fELF"
SHT_REL = 9
SHT_RELA = 4
SHT_DYNSYM = 11
STV_HIDDEN = 2


def sections_of(data):
    (shoff,) = struct.unpack_from("<Q", data, 0x28)
    shentsize, shnum, shstrndx = struct.unpack_from("<HHH", data, 0x3A)

    sections = []
    for i in range(shnum):
        fields = struct.unpack_from("<IIQQQQIIQQ", data, shoff + i * shentsize)
        sections.append(
            {
                "name": fields[0],
                "type": fields[1],
                "offset": fields[4],
                "size": fields[5],
                "link": fields[6],
                "entsize": fields[9],
            }
        )

    strtab = sections[shstrndx]

    def name_of(section):
        start = strtab["offset"] + section["name"]
        return data[start : data.index(b"\0", start)].decode()

    for section in sections:
        section["name"] = name_of(section)

    return sections


def string_at(data, strtab, offset):
    start = strtab["offset"] + offset
    return data[start : data.index(b"\0", start)].decode()


def symbols_of(data, sections):
    """Yields (index, name, defined, offset of st_other)."""
    for section in sections:
        if section["type"] != SHT_DYNSYM:
            continue
        strtab = sections[section["link"]]
        for i in range(section["size"] // section["entsize"]):
            offset = section["offset"] + i * section["entsize"]
            st_name, _, st_other, st_shndx = struct.unpack_from("<IBBH", data, offset)
            yield i, string_at(data, strtab, st_name), st_shndx != 0, offset + 5, st_other


def referenced_symbols(data, sections):
    """Returns the indices of the symbols that relocations refer to."""
    referenced = set()
    for section in sections:
        if section["type"] not in (SHT_REL, SHT_RELA):
            continue
        for i in range(section["size"] // section["entsize"]):
            offset = section["offset"] + i * section["entsize"]
            (r_info,) = struct.unpack_from("<Q", data, offset + 8)
            referenced.add(r_info >> 32)
    return referenced


def exported_symbols(path):
    with open(path, "rb") as f:
        data = f.read()
    sections = sections_of(data)
    return {name for _, name, defined, _, _ in symbols_of(data, sections) if defined}


def hide_symbols(path, names):
    with open(path, "rb") as f:
        data = bytearray(f.read())

    if data[:4] != ELF_MAGIC or data[4] != 2 or data[5] != 1:
        print(f"hideSymbols: {path} is not a little endian 64 bit ELF file, skipping")
        return 0, []

    sections = sections_of(data)
    referenced = referenced_symbols(data, sections)

    hidden = 0
    kept = []
    for index, name, defined, st_other_offset, st_other in symbols_of(data, sections):
        if not defined or name not in names:
            continue
        if index in referenced:
            kept.append(name)
            continue
        data[st_other_offset] = st_other | STV_HIDDEN
        hidden += 1

    if hidden > 0 or kept:
        with open(path, "wb") as f:
            f.write(data)

    print(f"hideSymbols: hid {hidden} symbols in {path}")
    for name in kept:
        print(f"hideSymbols: kept {name} in {path} because a relocation refers to it")

    return hidden, kept


def main():
    provider = sys.argv[1]
    names = exported_symbols(provider)
    if not names:
        raise SystemExit(f"{provider}: no dynamic symbol is exported")

    hidden = 0
    for path in sys.argv[2:]:
        count, _ = hide_symbols(path, names)
        hidden += count

    if hidden == 0:
        raise SystemExit(f"no symbol of {provider} interposes on any of {sys.argv[2:]}")

    print(f"hideSymbols: hid {hidden} symbols of {provider} in total")


if __name__ == "__main__":
    main()
