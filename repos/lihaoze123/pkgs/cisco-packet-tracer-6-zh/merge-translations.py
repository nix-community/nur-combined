#!/usr/bin/env python3
"""Merge exact Qt TS keys into an older Packet Tracer template."""
import argparse
from collections import Counter
from copy import deepcopy
from pathlib import Path
import re
import xml.etree.ElementTree as ET

PLACEHOLDER = re.compile(r"%(?:L?\d+|n)")
INCOMPLETE = {"unfinished", "obsolete", "vanished"}

def catalog(path):
    entries = {}
    for context in ET.parse(path).getroot().findall("context"):
        for message in context.findall("message"):
            key = (context.findtext("name"), message.findtext("source"), message.findtext("comment") or "")
            translation = message.find("translation")
            if translation is None or translation.get("type") in INCOMPLETE:
                continue
            text = "".join(translation.itertext())
            if not text.strip():
                continue
            source = message.findtext("source") or ""
            forms = translation.findall("numerusform")
            texts = ["".join(form.itertext()) for form in forms] if forms else [text]
            if any(Counter(PLACEHOLDER.findall(source)) != Counter(PLACEHOLDER.findall(t)) for t in texts):
                continue
            entries[key] = translation
    return entries

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("template", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("catalogs", nargs="+", type=Path, help="Higher priority catalogs first")
    args = parser.parse_args()
    catalogs = [catalog(path) for path in args.catalogs]
    tree = ET.parse(args.template)
    root = tree.getroot()
    root.set("language", "zh_CN")
    root.set("sourcelanguage", "en_US")
    translated = chinese = total = 0
    per_catalog = Counter()
    for context in root.findall("context"):
        for message in context.findall("message"):
            total += 1
            key = (context.findtext("name"), message.findtext("source"), message.findtext("comment") or "")
            for index, entries in enumerate(catalogs):
                candidate = entries.get(key)
                if candidate is None:
                    continue
                previous = message.find("translation")
                if previous is not None:
                    message.remove(previous)
                translation = deepcopy(candidate)
                # Retain a missing mnemonic for plain labels; avoid rewriting rich text.
                source = message.findtext("source") or ""
                mnemonic = re.search(r"(?<!&)&(?!&)([A-Za-z0-9])", source)
                target = "".join(translation.itertext())
                if ("<" not in source and mnemonic and len(translation) == 0
                        and not re.search(r"(?<!&)&(?!&)", target)):
                    translation.text = target + f" (&{mnemonic.group(1).upper()})"
                message.append(translation)
                translated += 1
                chinese += bool(re.search(r"[\u3400-\u9fff]", "".join(translation.itertext())))
                per_catalog[index] += 1
                break
    ET.indent(tree, space="    ")
    tree.write(args.output, encoding="utf-8", xml_declaration=True)
    print(f"{translated}/{total} translated entries; {chinese} contain Chinese")
    for index, count in sorted(per_catalog.items()):
        print(f"  {args.catalogs[index].name}: {count}")

if __name__ == "__main__":
    main()
