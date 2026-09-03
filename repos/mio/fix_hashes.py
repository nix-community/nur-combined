import os
import re
import subprocess
import sys

pkgs = [
    "supertuxkart-evolution",
    "breathe-cli",
    "chatbox",
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

def fix_pkg(pkg):
    print(f"\n--- Fixing {pkg} ---")
    max_tries = 5
    for i in range(max_tries):
        print(f"Build attempt {i+1}...")
        # Run nix build
        cmd = ["nix", "build", f".#{pkg}", "--print-build-logs"]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            print(f"{pkg} built successfully!")
            return True
        
        output = res.stderr + res.stdout
        
        # Look for hash mismatch
        # Example format:
        # specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
        # got:       sha256-foobar...
        
        match_spec = re.search(r'specified:\s+(sha256-[A-Za-z0-9+/=]+|0000000000000000000000000000000000000000000000000000)', output)
        match_got = re.search(r'got:\s+(sha256-[A-Za-z0-9+/=]+|[a-z0-9]{52})', output)
        
        if not match_spec or not match_got:
            print("No hash mismatch found. Might be a real build error:")
            print(output[-1000:])
            return False
            
        spec_hash = match_spec.group(1)
        got_hash = match_got.group(1)
        
        print(f"Found mismatch: {spec_hash} -> {got_hash}")
        
        # Grep for the file containing spec_hash
        cmd_grep = f"grep -rl '{spec_hash}' ."
        grep_res = subprocess.run(cmd_grep, shell=True, capture_output=True, text=True)
        files = [f for f in grep_res.stdout.split() if f.endswith('.nix')]
        
        if not files:
            print("Could not find file with specified hash!")
            return False
            
        for f in files:
            with open(f, 'r') as file:
                content = file.read()
            # Replace exactly ONE occurrence, or all? Replace all for safety if it's the fake hash.
            # But wait, if it's fake_hash, replacing all occurrences in the *same file* is wrong (we only want to fix the one that failed).
            # Actually, `sed -i "0,/$spec_hash/s//$got_hash/"` replaces the first occurrence.
            # In Python:
            content = content.replace(spec_hash, got_hash, 1)
            with open(f, 'w') as file:
                file.write(content)
            print(f"Patched {f} with {got_hash}")
            
    print("Max tries reached.")
    return False

success = True
for pkg in pkgs:
    if not fix_pkg(pkg):
        success = False
        print(f"FAILED on {pkg}")
        # continue to next to try as many as possible

sys.exit(0 if success else 1)
