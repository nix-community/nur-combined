#!/usr/bin/env python3

import re
import sys

# qdbuscpp2xml leaves empty signatures for Qt's D-Bus "special" types on
# Darwin while still emitting the Qt type name annotation. Restore the
# signatures that qdbusxml2cpp expects.
SIGNATURES = {
    "QPoint": "(ii)",
    "QVariantList": "av",
    "QVariantMap": "a{sv}",
}

ARG = re.compile(
    r'<arg(?P<head>[^>]*?) type=""(?P<tail>[^>]*/>)\s*\n'
    r'(?P<indent>\s*)(?P<annotation><annotation[^>]*QtTypeName[^>]*value="(?P<type>[^"]+)"/>)'
)


def replace(match):
    signature = SIGNATURES.get(match["type"])
    if signature is None:
        return match[0]
    return (
        f'<arg{match["head"]} type="{signature}"{match["tail"]}\n'
        f'{match["indent"]}{match["annotation"]}'
    )


def main():
    with open(sys.argv[1], encoding="utf-8") as source:
        xml = source.read()
    xml = ARG.sub(replace, xml)
    with open(sys.argv[2], "w", encoding="utf-8") as target:
        target.write(xml)


if __name__ == "__main__":
    main()
