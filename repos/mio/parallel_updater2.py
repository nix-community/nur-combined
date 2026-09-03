import os
import re
import subprocess
import sys
import concurrent.futures

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
    "violentmonkey": "by-name/vi/violentmonkey/package.nix",
    "chatbox": "by-name/ch/chatbox/package.nix"
}

def process_pkg(pkg_tuple):
    pkg, fpath = pkg_tuple
    if not os.path.exists(fpath):
        return f"{pkg}: file not found {fpath}"
        
    print(f"[{pkg}] Started resolving hashes for {fpath}")
    
    max_tries = 5
    for i in range(max_tries):
        res = subprocess.run(["nix", "build", f".#{pkg}", "--print-build-logs"], capture_output=True, text=True)
        if res.returncode == 0:
            return f"{pkg}: built successfully!"
            
        output = res.stderr + res.stdout
        match_spec = re.search(r'specified:\s+(sha256-[A-Za-z0-9+/=]+)', output)
        match_got = re.search(r'got:\s+(sha256-[A-Za-z0-9+/=]+)', output)
        
        if not match_spec or not match_got:
            return f"{pkg}: Build failed without hash mismatch (or real error). Tail of log:\n" + output[-500:]
            
        spec_hash = match_spec.group(1)
        got_hash = match_got.group(1)
        
        print(f"[{pkg}] Mismatch: {spec_hash} -> {got_hash}")
        
        with open(fpath, 'r') as file:
            content = file.read()
        if spec_hash in content:
            content = content.replace(spec_hash, got_hash)
            with open(fpath, 'w') as file:
                file.write(content)
            print(f"[{pkg}] Patched {fpath}")
        else:
            return f"{pkg}: spec_hash {spec_hash} not found in {fpath}"
            
    return f"{pkg}: reached max tries"

with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
    results = executor.map(process_pkg, list(pkgs.items()))
    
for r in results:
    print(r)

