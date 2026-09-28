#!/usr/bin/env python3
"""Replace unsupported GLIBC version requirements in an ELF's .gnu.version_r.

The dynamic linker checks version requirements at load time, even if no
symbols reference them. Replace requirements newer than the target glibc
version with an older version from the same library.

Usage: fix-glibc-versions.py <elf> <glibc-version>
"""
import re
import struct
import sys

SHT_GNU_verneed = 0x6FFFFFFE


def cstr(data, off):
    return data[off:data.index(b"\0", off)].decode()


def parse_version(name):
    m = re.match(r"(?:GLIBC_)?(\d+)\.(\d+)", name)
    if not m:
        return None
    return int(m.group(1)) * 1000000 + int(m.group(2))


def elf_hash(s):
    h = 0
    for c in s.encode():
        h = (h << 4) + c
        g = h & 0xF0000000
        if g:
            h ^= g >> 24
        h &= ~g
        h &= 0xFFFFFFFF
    return h


def sections(data):
    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from("<HHH", data, 0x3A)
    shdrs = []
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        fields = struct.unpack_from("<IIQQQQIIQQ", data, off)
        shdrs.append(dict(type=fields[1], offset=fields[4], size=fields[5],
                          link=fields[6], name=fields[0]))
    shstr = shdrs[e_shstrndx]
    for s in shdrs:
        s["sname"] = cstr(data, shstr["offset"] + s["name"])
    return shdrs


def verneed_entries(data, shdrs):
    for sec in shdrs:
        if sec["type"] != SHT_GNU_verneed:
            continue
        dynstr = shdrs[sec["link"]]
        pos = sec["offset"]
        end = pos + sec["size"]
        while pos < end:
            _, vn_cnt, vn_file, vn_aux, vn_next = struct.unpack_from(
                "<HHIII", data, pos)
            fname = cstr(data, dynstr["offset"] + vn_file)
            aux = pos + vn_aux
            for _ in range(vn_cnt):
                _, _, vna_other, vna_name, vna_next = struct.unpack_from(
                    "<IHHII", data, aux)
                yield dict(aux=aux, file=fname, other=vna_other,
                           name=cstr(data, dynstr["offset"] + vna_name),
                           next=vna_next, dynstr=dynstr)
                if vna_next == 0:
                    break
                aux += vna_next
            if vn_next == 0:
                break
            pos += vn_next


def dynstr_offset_of(data, dynstr, name):
    region = bytes(data[dynstr["offset"]:dynstr["offset"] + dynstr["size"]])
    needle = name.encode() + b"\0"
    idx = region.find(b"\0" + needle)
    if idx != -1:
        return dynstr["offset"] + idx + 1
    if region.startswith(needle):
        return dynstr["offset"]
    raise SystemExit(f"fix-glibc-versions: {name!r} not found in .dynstr")


def main():
    path, max_version = sys.argv[1], sys.argv[2]
    max_num = parse_version(max_version)
    if max_num is None:
        raise SystemExit(f"fix-glibc-versions: bad version {max_version!r}")

    with open(path, "rb") as f:
        data = bytearray(f.read())

    entries = list(verneed_entries(data, sections(data)))

    replacements = {}
    for e in entries:
        num = parse_version(e["name"])
        if num is not None and num <= max_num:
            replacements.setdefault(e["file"], e["name"])
    fallback = next(iter(replacements.values()), None)

    changed = False
    for e in entries:
        num = parse_version(e["name"])
        if num is None or num <= max_num:
            continue
        newname = replacements.get(e["file"], fallback)
        if newname is None:
            raise SystemExit(f"fix-glibc-versions: no replacement for "
                             f"{e['file']}: {e['name']}")
        str_off = dynstr_offset_of(data, e["dynstr"], newname)
        struct.pack_into("<I", data, e["aux"], elf_hash(newname))
        struct.pack_into("<I", data, e["aux"] + 8,
                         str_off - e["dynstr"]["offset"])
        print(f"{path}: {e['file']}: {e['name']} -> {newname} "
              f"(vna_other={e['other']})")
        changed = True

    if changed:
        with open(path, "wb") as f:
            f.write(data)


if __name__ == "__main__":
    main()
