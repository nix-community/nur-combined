import os
import re
import subprocess
import sys

updates = {
    "supertuxkart-evolution": [("pkgs/supertuxkart-evolution/default.nix", r'rev = "[a-f0-9]+"', 'rev = "d27b64e"')],
    "breathe-cli": [("by-name/br/breathe-cli/package.nix", r'version = "[^"]+"', 'version = "1.14.0"')],
    "chatbox": [("by-name/ch/chatbox/package.nix", r'version = "[^"]+"', 'version = "1.23.1"')],
    "clice": [("by-name/cl/clice/package.nix", r'version = "[^"]+"', 'version = "0.1.2026090207"')],
    "dark-reader": [("by-name/da/dark-reader/package.nix", r'version = "[^"]+"', 'version = "4.9.130"')],
    "degrees-of-lewdity": [("by-name/de/degrees-of-lewdity/package.nix", r'version = "[^"]+"', 'version = "0.5.12.8"')],
    "forkgram-desktop": [("by-name/fo/forkgram-desktop/package.nix", r'version = "[^"]+"', 'version = "7.1.4"')],
    "futo-notes": [("by-name/fu/futo-notes/package.nix", r'version = "[^"]+"', 'version = "1.7.1"')],
    "hanga-contrib": [("by-name/ha/hanga-contrib/package.nix", r'rev = "b47a6f8[^"]+"', 'rev = "83f4e42"')],
    "nlvm": [("by-name/nl/nlvm/package.nix", r'version = "3634699[^"]+"', 'version = "a7bb73d"')],
    "pygubu": [("by-name/py/pygubu/package.nix", r'version = "[^"]+"', 'version = "0.42"')],
    "sem-cli": [("by-name/se/sem-cli/package.nix", r'version = "[^"]+"', 'version = "0.24.0"')],
    "terminal-browser": [("by-name/te/terminal-browser/package.nix", r'version = "[^"]+"', 'version = "0.7.6"')],
    "unsloth-studio": [("by-name/un/unsloth-studio/package.nix", r'version = "[^"]+"', 'version = "0.1.806-beta"')],
    "user-agent-switcher-firefox": [("by-name/us/user-agent-switcher-firefox/package.nix", r'version = "[^"]+"', 'version = "1.4.103"')],
    "violentmonkey": [("by-name/vi/violentmonkey/package.nix", r'version = "[^"]+"', 'version = "2.48.1"')]
}

fake_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
fake_hash_legacy = "0000000000000000000000000000000000000000000000000000"

# Step 1: Patch versions and invalidate hashes
for pkg, patches in updates.items():
    for fpath, old, new in patches:
        if not os.path.exists(fpath):
            print(f"File not found: {fpath}")
            continue
        with open(fpath, 'r') as f:
            content = f.read()
        
        # Patch version
        content = re.sub(old, new, content)
        
        # Invalidate all hashes
        content = re.sub(r'hash = "sha256-[^"]+"', f'hash = "{fake_hash}"', content)
        content = re.sub(r'cargoHash = "sha256-[^"]+"', f'cargoHash = "{fake_hash}"', content)
        content = re.sub(r'vendorHash = "sha256-[^"]+"', f'vendorHash = "{fake_hash}"', content)
        content = re.sub(r'npmDepsHash = "sha256-[^"]+"', f'npmDepsHash = "{fake_hash}"', content)
        content = re.sub(r'sha256 = "sha256-[^"]+"', f'sha256 = "{fake_hash}"', content)
        content = re.sub(r'sha256 = "[a-z0-9]{52}"', f'sha256 = "{fake_hash_legacy}"', content)
        
        with open(fpath, 'w') as f:
            f.write(content)
        print(f"Patched {fpath}")

# Note: We will handle fixing hashes in a bash script next.
