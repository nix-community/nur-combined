import os
import re
import subprocess
import sys
import concurrent.futures

pkgs = [
    "clice",
    "dark-reader",
    "degrees-of-lewdity",
    "forkgram-desktop",
    "futo-notes",
    "hanga-contrib",
    "nlvm",
    "pygubu",
    "sem-cli",
    "terminal-browser",
    "unsloth-studio",
    "user-agent-switcher-firefox",
    "violentmonkey"
]

def find_nix_file(pkg):
    res = subprocess.run(f"find by-name -name package.nix | xargs grep -l {pkg}", shell=True, capture_output=True, text=True)
    if res.stdout.strip():
        return res.stdout.strip().split('\n')[0]
    if pkg == "pygubu": return "by-name/py/pygubu/package.nix"
    if pkg == "nlvm": return "by-name/nl/nlvm/package.nix"
    if pkg == "unsloth-studio": return "by-name/un/unsloth-studio/package.nix"
    return None

def process_pkg(pkg):
    fpath = find_nix_file(pkg)
    if not fpath:
        return f"{pkg}: file not found"
        
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

with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    results = executor.map(process_pkg, pkgs)
    
for r in results:
    print(r)

