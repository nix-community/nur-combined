import re
import os

pkgs = {
    "clice": "by-name/cl/clice/package.nix",
    "dark-reader": "by-name/da/dark-reader/package.nix",
    "degrees-of-lewdity": "by-name/de/degrees-of-lewdity/package.nix",
    "forkgram-desktop": "by-name/fo/forkgram-desktop/package.nix",
    "futo-notes": "by-name/fu/futo-notes/package.nix",
    "hanga-contrib": "by-name/ha/hanga-contrib/package.nix",
    "nlvm": "by-name/nl/nlvm/package.nix",
    "pygubu": "by-name/py/pygubu/package.nix",
    "sem-cli": "by-name/se/sem-cli/package.nix",
    "terminal-browser": "by-name/te/terminal-browser/package.nix",
    "unsloth-studio": "by-name/un/unsloth-studio/package.nix",
    "user-agent-switcher-firefox": "by-name/us/user-agent-switcher-firefox/package.nix",
    "violentmonkey": "by-name/vi/violentmonkey/package.nix"
}

class Counter:
    val = 1000

def replacer(match):
    base = f"sha256-AAAA{Counter.val:04d}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    Counter.val += 1
    return match.group(1) + base + match.group(2)

for pkg, fpath in pkgs.items():
    if not os.path.exists(fpath): continue
    with open(fpath, 'r') as f:
        content = f.read()
    content = re.sub(r'(hash = ")[^"]+(")', replacer, content)
    content = re.sub(r'(cargoHash = ")[^"]+(")', replacer, content)
    content = re.sub(r'(vendorHash = ")[^"]+(")', replacer, content)
    content = re.sub(r'(npmDepsHash = ")[^"]+(")', replacer, content)
    content = re.sub(r'(sha256 = "sha256-)[^"]+(")', replacer, content)
    with open(fpath, 'w') as f:
        f.write(content)
    print(f"Patched {fpath}")
