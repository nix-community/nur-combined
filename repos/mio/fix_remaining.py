import subprocess, re, sys, os

pkgs = {
    "forkgram-desktop": "by-name/fo/forkgram-desktop/package.nix",
    "futo-notes": "by-name/fu/futo-notes/package.nix",
    "pygubu": "by-name/py/pygubu/package.nix",
    "sem-cli": "by-name/se/sem-cli/package.nix",
    "terminal-browser": "by-name/te/terminal-browser/package.nix",
    "unsloth-studio": "by-name/un/unsloth-studio/package.nix",
    "user-agent-switcher-firefox": "by-name/us/user-agent-switcher-firefox/package.nix",
    "violentmonkey": "by-name/vi/violentmonkey/package.nix"
}

for pkg, fpath in pkgs.items():
    print(f"\nResolving {pkg}")
    for i in range(5):
        res = subprocess.run(["nix", "build", f".#{pkg}", "--print-build-logs"], capture_output=True, text=True)
        if res.returncode == 0:
            print(f"{pkg} success!")
            break
        output = res.stdout + res.stderr
        match_spec = re.search(r'specified:\s+(sha256-[A-Za-z0-9+/=]+)', output)
        match_got = re.search(r'got:\s+(sha256-[A-Za-z0-9+/=]+)', output)
        if match_spec and match_got:
            s, g = match_spec.group(1), match_got.group(1)
            print(f"Mismatch: {s} -> {g}")
            with open(fpath, 'r') as f:
                c = f.read()
            c = c.replace(s, g)
            with open(fpath, 'w') as f:
                f.write(c)
        else:
            print(f"Failed with no mismatch for {pkg} (or genuine error). Tail:")
            print(output[-500:])
            break
