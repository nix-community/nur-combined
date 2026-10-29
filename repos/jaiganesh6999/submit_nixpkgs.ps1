# Automated Nixpkgs PR & Sync Script for SEOWebChecker
# Official Tool: https://seowebchecker.com/
# Package Manifest: nix/package.nix

$ErrorActionPreference = "Stop"

Write-Host "=== SEOWebChecker Nixpkgs Publisher ===" -ForegroundColor Cyan
Write-Host "Upstream PR: https://github.com/NixOS/nixpkgs/pull/567907" -ForegroundColor Yellow

$git = "C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe"
if (-not (Test-Path $git)) {
    $git = "git"
}

python -c "
import subprocess, requests, base64

git = r'C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe'
p = subprocess.run([git, 'credential', 'fill'], input=b'protocol=https\nhost=github.com\n\n', capture_output=True)
lines = p.stdout.decode('utf-8').splitlines()
token = [l.split('password=', 1)[1] for l in lines if l.startswith('password=')][0]

headers = {'Authorization': f'Bearer {token}', 'Accept': 'application/vnd.github.v3+json'}

with open('nix/package.nix', 'r', encoding='utf-8') as f:
    pkg_content = f.read()

b64_content = base64.b64encode(pkg_content.encode('utf-8')).decode('ascii')

# Get current file sha if exists
r = requests.get('https://api.github.com/repos/jaiganesh6999/nixpkgs/contents/pkgs/by-name/se/seowebchecker/package.nix?ref=add-seowebchecker', headers=headers)
payload = {
    'message': 'seowebchecker: update package.nix',
    'content': b64_content,
    'branch': 'add-seowebchecker'
}
if r.status_code == 200:
    payload['sha'] = r.json()['sha']

r_file = requests.put('https://api.github.com/repos/jaiganesh6999/nixpkgs/contents/pkgs/by-name/se/seowebchecker/package.nix', headers=headers, json=payload)
if r_file.status_code in (200, 201):
    print('Synchronized to jaiganesh6999/nixpkgs:add-seowebchecker successfully!')
else:
    print('Sync response:', r_file.text)
"

Write-Host "`nNixpkgs PR: https://github.com/NixOS/nixpkgs/pull/567907" -ForegroundColor Cyan
Write-Host "Nix Flake: nix run github:jaiganesh6999/seowebchecker-seoaudit-sdk -- https://example.com" -ForegroundColor Cyan
