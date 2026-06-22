#!/usr/bin/env python3
import os
import re
import urllib.request
import urllib.error
import json
import configparser
import subprocess

def is_stable_tag(tag, allow_prerelease=False):
    if allow_prerelease:
        return True
    tl = tag.lower()
    if 'dev' in tl or 'beta' in tl or 'alpha' in tl or 'rc' in tl or 'internal' in tl:
        return False
    if re.search(r'b\d+$', tl):
        return False
    return True

def get_nvfetcher_managed():
    managed = set()
    if os.path.exists('nvfetcher.toml'):
        try:
            config = configparser.ConfigParser()
            config.read('nvfetcher.toml')
            for section in config.sections():
                managed.add(section)
        except Exception as e:
            pass
            
    if os.path.exists('_sources/generated.json'):
        try:
            with open('_sources/generated.json') as f:
                data = json.load(f)
                for k in data.keys():
                    managed.add(k)
        except:
            pass
    return managed

def get_latest_github_release(owner, repo, allow_prerelease=False):
    try:
        url = f"https://api.github.com/repos/{owner}/{repo}/releases" if allow_prerelease else f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
        req = urllib.request.Request(url)
        if 'GITHUB_TOKEN' in os.environ:
            req.add_header('Authorization', f"token {os.environ['GITHUB_TOKEN']}")
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            if allow_prerelease and isinstance(data, list) and data:
                tag = data[0].get('tag_name')
            elif not allow_prerelease and isinstance(data, dict):
                tag = data.get('tag_name')
            else:
                tag = None
            if tag and is_stable_tag(tag, allow_prerelease):
                return True, tag
            else:
                return True, None
    except urllib.error.HTTPError as e:
        if e.code == 404:
            try:
                req2 = urllib.request.Request(f"https://api.github.com/repos/{owner}/{repo}/releases")
                if 'GITHUB_TOKEN' in os.environ:
                    req2.add_header('Authorization', f"token {os.environ['GITHUB_TOKEN']}")
                with urllib.request.urlopen(req2, timeout=5) as response2:
                    data2 = json.loads(response2.read().decode())
                    if data2:
                        return True, None # Has releases, but no stable
            except Exception:
                pass
    except Exception:
        pass
    return False, None

def get_latest_github_tag_by_date(owner, repo, current_rev=None, allow_prerelease=False):
    try:
        req = urllib.request.Request(f"https://github.com/{owner}/{repo}/tags.atom")
        with urllib.request.urlopen(req, timeout=5) as response:
            content = response.read().decode()
            tags = re.findall(r'href="[^"]+/releases/tag/([^"]+)"', content)
            tags = [t for t in tags if is_stable_tag(t, allow_prerelease)]
            
            if current_rev:
                curr_norm = current_rev.lstrip('vV')
                if curr_norm and curr_norm[0].isdigit():
                    tags = [t for t in tags if re.match(r'^[vV]?\d', t)]
                    if '.' in curr_norm:
                        tags = [t for t in tags if '.' in t or t.lstrip('vV').isdigit()]
                        
            if tags:
                return tags[0]
    except Exception:
        pass
    return None

def version_key(v):
    v = v.lstrip('vV')
    parts = re.findall(r'\d+|\.|[^\d.]+', v)
    res = []
    for p in parts:
        if p.isdigit():
            res.append((2, int(p)))
        elif p == '.':
            res.append((1, p))
        else:
            res.append((0, p))
    res.append((0.5, ''))
    return res

def get_latest_git_tag_url(url, current_rev=None, allow_prerelease=False):
    try:
        env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
        output = subprocess.check_output(["git", "ls-remote", "--tags", url], stderr=subprocess.DEVNULL, env=env).decode()
        
        tags = []
        for line in output.splitlines():
            if not line.strip(): continue
            sha, ref = line.split()
            tag = ref.replace("refs/tags/", "")
            if tag.endswith('^{}'):
                tag = tag[:-3]
            tags.append(tag)
            
        tags = list(set(tags))
        tags = [t for t in tags if is_stable_tag(t, allow_prerelease)]
        
        # Filter garbage tags
        if current_rev:
            curr_norm = current_rev.lstrip('vV')
            if curr_norm and curr_norm[0].isdigit():
                # Must start with digit
                tags = [t for t in tags if re.match(r'^[vV]?\d', t)]
                # If current has dot, tag must have dot OR be just digits
                if '.' in curr_norm:
                    tags = [t for t in tags if '.' in t or t.lstrip('vV').isdigit()]
                
        if not tags:
            return None
            
        tags.sort(key=version_key, reverse=True)
        return tags[0]
    except Exception:
        pass
    return None

def get_latest_git_commit_url(url):
    try:
        env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
        output = subprocess.check_output(["git", "ls-remote", url, "HEAD"], stderr=subprocess.DEVNULL, env=env).decode()
        if output:
            return output.split()[0]
    except Exception:
        pass
    return None

def resolve_version(rev, content):
    vars = {}
    for k, v in re.findall(r'([a-zA-Z0-9_-]+)\s*=\s*"([^"]+)"', content):
        if k not in vars:
            vars[k] = v
    
    if rev in vars:
        rev = vars[rev]
    if rev == 'version' or rev.endswith('.version'):
        rev = vars.get('version', rev)

    if '${' not in rev:
        return rev
    
    def replacer(match):
        var_name = match.group(1)
        if var_name.endswith('.version'):
            var_name = 'version'
        return vars.get(var_name, match.group(0))
        
    return re.sub(r'\$\{([^}]+)\}', replacer, rev)

def main():
    managed = get_nvfetcher_managed()
    dirs_to_check = ['pkgs', 'by-name']
    
    print("Checking for updates...")
    print("-" * 50)
    
    updates_found = False

    for d in dirs_to_check:
        if not os.path.exists(d):
            continue
            
        for pkg in sorted(os.listdir(d)):
            pkg_path = os.path.join(d, pkg)
            if not os.path.isdir(pkg_path) or pkg.startswith('_'):
                continue
                
            if pkg in ['polkit', 'minetest580', 'minetest591', 'beammp-server', 'irrlichtmt', 'ogre-1_11', 'local-ai', 'pixelle-video'] or 'plugin' in pkg:
                continue
                
            pkg_nix = os.path.join(pkg_path, 'package.nix')
            if not os.path.exists(pkg_nix):
                pkg_nix = os.path.join(pkg_path, 'default.nix')
            if not os.path.exists(pkg_nix):
                continue
                
            with open(pkg_nix, 'r') as f:
                content = f.read()
                
            if re.search(r'src\s*=\s*sources\.', content) and 'fetchFromGitHub' not in content and 'fetchFromGitLab' not in content and 'fetchgit' not in content:
                continue
                
            git_match = re.search(r'\bsrc\s*=\s*(?:pkgs\.)?fetchFrom(GitHub|GitLab)\s*\{(.+?)\n\s*\}', content, re.MULTILINE | re.DOTALL)
            fetchgit_match = re.search(r'\bsrc\s*=\s*(?:pkgs\.)?fetchgit\s*\{(.+?)\n\s*\}', content, re.MULTILINE | re.DOTALL)
            
            url = None
            current_rev = None
            name_display = pkg
            domain = None
            owner = None
            repo = None
            
            if git_match:
                forge = git_match.group(1)
                src_block = git_match.group(2)
                
                owner_m = re.search(r'\bowner\s*=\s*"([^"]+)"', src_block)
                repo_m = re.search(r'\brepo\s*=\s*"([^"]+)"', src_block)
                rev_m = re.search(r'\b(?:inherit\s+(rev|tag)|(?:rev|tag)\s*=\s*(?:"([^"]+)"|([^";\s]+)))', src_block)
                domain_m = re.search(r'\bdomain\s*=\s*"([^"]+)"', src_block)
                
                if owner_m and repo_m and rev_m:
                    owner = owner_m.group(1)
                    repo = repo_m.group(1)
                    current_rev = rev_m.group(1) or rev_m.group(2) or rev_m.group(3)
                    current_rev = resolve_version(current_rev, content)
                    
                    domain = "github.com"
                    if forge == "GitLab":
                        domain = domain_m.group(1) if domain_m else "gitlab.com"
                    else:
                        domain = domain_m.group(1) if domain_m else "github.com"
                        
                    url = f"https://{domain}/{owner}/{repo}.git"
                    name_display = f"{pkg} ({owner}/{repo} on {domain})"
            
            elif fetchgit_match:
                src_block = fetchgit_match.group(1)
                url_m = re.search(r'\burl\s*=\s*(?:"([^"]+)"|([^";\s]+))', src_block)
                rev_m = re.search(r'\b(?:inherit\s+(rev|tag)|(?:rev|tag)\s*=\s*(?:"([^"]+)"|([^";\s]+)))', src_block)
                if url_m and rev_m:
                    url = url_m.group(1) if url_m.group(1) else url_m.group(2)
                    current_rev = rev_m.group(1) or rev_m.group(2) or rev_m.group(3)
                    current_rev = resolve_version(current_rev, content)
                    name_display = f"{pkg} (fetchgit {url})"
                    
                    gh_m = re.search(r'github\.com/([^/]+)/([^/.]+)(?:\.git)?', url)
                    if gh_m:
                        domain = "github.com"
                        owner = gh_m.group(1)
                        repo = gh_m.group(2)
                    
            if url and current_rev:
                if current_rev.startswith('refs/tags/'):
                    current_rev = current_rev[len('refs/tags/'):]
                
                is_commit = bool(re.match(r'^([0-9a-f]{7,8}|[0-9a-f]{40})$', current_rev))
                if is_commit and len(current_rev) == 8 and current_rev.isdigit() and current_rev.startswith(('19', '20')):
                    is_commit = False
                
                if is_commit:
                    latest = get_latest_git_commit_url(url)
                    if latest:
                        if not latest.startswith(current_rev):
                            print(f"[UPDATE] {name_display}: {current_rev[:7]} -> {latest[:7]}")
                            updates_found = True
                    else:
                        print(f"[WARN]   {name_display}: Could not fetch latest commit from {url}")
                else:
                    allow_prerelease = not is_stable_tag(current_rev)
                    latest = None
                    has_releases = False
                    if pkg != "tailscale" and domain == "github.com" and owner and repo:
                        has_releases, latest = get_latest_github_release(owner, repo, allow_prerelease)
                        if not has_releases and not latest:
                            latest = get_latest_github_tag_by_date(owner, repo, current_rev, allow_prerelease)
                    if not latest and not has_releases:
                        latest = get_latest_git_tag_url(url, current_rev, allow_prerelease)
                    if latest:
                        if version_key(latest) > version_key(current_rev):
                            print(f"[UPDATE] {name_display}: {current_rev} -> {latest}")
                            updates_found = True
                        elif version_key(latest) < version_key(current_rev):
                            print(f"[DOWNGRADE] {name_display}: {current_rev} -> {latest}")
                    else:
                        print(f"[WARN]   {name_display}: Could not fetch latest version from {url}")

    if not updates_found:
        print("No updates found.")

if __name__ == '__main__':
    main()
