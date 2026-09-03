import os
import re
import subprocess
import sys

updates = {
    "supertuxkart-evolution": [("pkgs/supertuxkart-evolution/default.nix", r'(repo = "stk-code";\s*#.*?\s*rev = ")[^"]+(")', r'\g<1>d27b64e\g<2>')],
    "breathe-cli": [("by-name/br/breathe-cli/package.nix", r'(version = ")[^"]+(")', r'\g<1>1.14.0\g<2>')],
    "chatbox": [("by-name/ch/chatbox/package.nix", r'(version = ")[^"]+(")', r'\g<1>1.23.1\g<2>')],
    "clice": [("by-name/cl/clice/package.nix", r'(version = ")[^"]+(")', r'\g<1>0.1.2026090207\g<2>')],
    "dark-reader": [("by-name/da/dark-reader/package.nix", r'(version = ")[^"]+(")', r'\g<1>4.9.130\g<2>')],
    "degrees-of-lewdity": [("by-name/de/degrees-of-lewdity/package.nix", r'(version = ")[^"]+(")', r'\g<1>0.5.12.8\g<2>')],
    "forkgram-desktop": [("by-name/fo/forkgram-desktop/package.nix", r'(version = ")[^"]+(")', r'\g<1>7.1.4\g<2>')],
    "futo-notes": [("by-name/fu/futo-notes/package.nix", r'(version = ")[^"]+(")', r'\g<1>1.7.1\g<2>')],
    "hanga-contrib": [("by-name/ha/hanga-contrib/package.nix", r'(rev = ")b47a6f8[^"]+(")', r'\g<1>83f4e42\g<2>')],
    "nlvm": [("by-name/nl/nlvm/package.nix", r'(version = ")a7bb73d[^"]*(")', r'\g<1>a7bb73d\g<2>')], # Already a7bb73d from previous sed
    "pygubu": [("by-name/py/pygubu/package.nix", r'(version = ")[^"]+(")', r'\g<1>0.42\g<2>')],
    "sem-cli": [("by-name/se/sem-cli/package.nix", r'(version = ")[^"]+(")', r'\g<1>0.24.0\g<2>')],
    "terminal-browser": [("by-name/te/terminal-browser/package.nix", r'(version = ")[^"]+(")', r'\g<1>0.7.6\g<2>')],
    "unsloth-studio": [("by-name/un/unsloth-studio/package.nix", r'(version = ")[^"]+(")', r'\g<1>0.1.806-beta\g<2>')],
    "user-agent-switcher-firefox": [("by-name/us/user-agent-switcher-firefox/package.nix", r'(version = ")[^"]+(")', r'\g<1>1.4.103\g<2>')],
    "violentmonkey": [("by-name/vi/violentmonkey/package.nix", r'(version = ")[^"]+(")', r'\g<1>2.48.1\g<2>')]
}

for pkg, patches in updates.items():
    print(f"\n--- Updating {pkg} ---")
    fpaths = set()
    for fpath, old, new in patches:
        fpaths.add(fpath)
        if not os.path.exists(fpath):
            print(f"File not found: {fpath}")
            continue
        with open(fpath, 'r') as f:
            content = f.read()
        
        # Patch version
        content = re.sub(old, new, content, flags=re.DOTALL)
        with open(fpath, 'w') as f:
            f.write(content)
            
    # Now invalidate hashes for the files we modified
    # We will replace them with unique fake hashes
    class Counter:
        val = 1
    
    for fpath in fpaths:
        with open(fpath, 'r') as f:
            content = f.read()
            
        def replacer(match):
            # A valid base64 character string of length 43, plus '='
            base = f"sha256-AAAA{Counter.val:04d}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
            Counter.val += 1
            return match.group(1) + base + match.group(2)

        content = re.sub(r'(hash = ")[^"]+(")', replacer, content)
        content = re.sub(r'(cargoHash = ")[^"]+(")', replacer, content)
        content = re.sub(r'(vendorHash = ")[^"]+(")', replacer, content)
        content = re.sub(r'(npmDepsHash = ")[^"]+(")', replacer, content)
        content = re.sub(r'(sha256 = "sha256-)[^"]+(")', replacer, content)
        
        with open(fpath, 'w') as f:
            f.write(content)

    # Now loop building and fixing hashes
    max_tries = 5
    for i in range(max_tries):
        print(f"Build attempt {i+1}...")
        res = subprocess.run(["nix", "build", f".#{pkg}", "--print-build-logs"], capture_output=True, text=True)
        if res.returncode == 0:
            print(f"{pkg} built successfully!")
            break
            
        output = res.stderr + res.stdout
        
        match_spec = re.search(r'specified:\s+(sha256-[A-Za-z0-9+/=]+)', output)
        match_got = re.search(r'got:\s+(sha256-[A-Za-z0-9+/=]+)', output)
        
        if not match_spec or not match_got:
            print("No hash mismatch found. Might be a real build error:")
            print(output[-1000:])
            break
            
        spec_hash = match_spec.group(1)
        got_hash = match_got.group(1)
        
        print(f"Found mismatch: {spec_hash} -> {got_hash}")
        
        # Replace in the files
        for fpath in fpaths:
            with open(fpath, 'r') as file:
                content = file.read()
            if spec_hash in content:
                content = content.replace(spec_hash, got_hash)
                with open(fpath, 'w') as file:
                    file.write(content)
                print(f"Patched {fpath}")

