#!/usr/bin/env python3
import re

DEFAULT_VALUES = {
    "fetchgit": {
        "deepClone": "false",
        "fetchSubmodules": "true",
        "leaveDotGit": "false",
        "sparseCheckout": "[ ]",
    },
    "fetchFromGitHub": {
        "deepClone": "false",
        "fetchSubmodules": "false",
        "leaveDotGit": "false",
        "sparseCheckout": "[ ]",
    },
}


def get_space_prefix_length(line: str) -> int:
    i = 0
    while line[i] == " " and i < len(line):
        i += 1
    return i


def should_keep_line(line: str) -> bool:
    global current_fetch_func

    if get_space_prefix_length(line) < 4:
        return True

    match = re.match(r"^    src = (.*) \{$", line)
    if match:
        current_fetch_func = match[1]
        return True

    match = re.match(r"^      (\S+) = (.*);$", line)
    if not match:
        return True

    try:
        if match[2] == DEFAULT_VALUES[current_fetch_func][match[1]]:
            return False
    except KeyError:
        pass

    return True


result = ""

with open("_sources/generated.nix") as f:
    lines = f.read().splitlines()


current_fetch_func = ""
for line in lines:
    line = line.replace('sha256 = "', 'hash = "')
    if 'rev = "' in line:
        if re.search(r"rev = \"[0-9a-f]{40}\"", line):
            pass
        else:
            line = line.replace('rev = "', 'tag = "')
    if should_keep_line(line):
        result += line + "\n"

with open("_sources/generated.nix", "w") as f:
    f.write(result)
