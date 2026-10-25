#!/usr/bin/env python3
"""Check CLI contracts, disposable GPG/file operations, and isolated GTK dialogs."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

project = Path(__file__).resolve().parents[1]
built = subprocess.run(['cargo', 'test', '--offline', '--locked', '--no-run', '--message-format=json'], cwd=project, text=True, capture_output=True, check=True)
artifacts = [json.loads(line) for line in built.stdout.splitlines() if line.startswith('{')]
binary = next(a['executable'] for a in artifacts if a.get('reason') == 'compiler-artifact' and a.get('profile', {}).get('test') and a.get('executable'))
STUB = r'''#!/usr/bin/python3
import json, os, pathlib, sys
root = pathlib.Path(os.environ['SPOTLIGHT_SYSTEMTOOLS_FIXTURE'])
tool, args = pathlib.Path(sys.argv[0]).name, sys.argv[1:]
with (root / 'calls.jsonl').open('a') as stream:
    stream.write(json.dumps([tool, args]) + '\n')
if tool == 'rbw':
    assert args[:4] == ['get', '--field', 'password', '--']
    if args[-1] == 'ambiguous':
        print('SECRET_ERROR_MARKER do not display', file=sys.stderr); sys.exit(1)
    assert args[-1] == 'GitHub $(literal)'
    print('fixture-only-secret')
elif tool == 'keepassxc-cli':
    assert args[:4] == ['show', '--quiet', '--attributes', 'Password']
    assert args[4:6] == ['--key-file', str(root / 'database.key')]
    assert args[6:] == ['--', str(root / 'database.kdbx'), 'Group/GitHub']
    assert sys.stdin.read() == 'master-fixture\n'
    print('keepass-fixture-secret')
elif tool == 'ping':
    assert args[:-1] == ['-n', '-c', '3', '-W', '1', '-w', '4', '--']
    if args[-1] == 'unreachable.test':
        print('3 packets transmitted, 0 received, 100% packet loss'); sys.exit(1)
    assert args[-1] == '8.8.8.8'
    print('3 packets transmitted, 3 received, 0% packet loss')
elif tool == 'dig':
    assert args == ['+time=2', '+tries=1', 'github.com']; print('github.com. 30 IN A 192.0.2.1')
elif tool == 'ss':
    assert args == ['-lntup']; print('LISTEN 0 128 127.0.0.1:8080')
elif tool == 'nmcli':
    assert args == ['--wait', '8', '--colors', 'no', 'device', 'wifi', 'list', '--rescan', 'yes']; print('SSID SIGNAL SECURITY\nFixture WiFi 90 WPA2')
elif tool == 'ip':
    assert args == ['route', 'show']; print('default via 192.0.2.1 dev wlan0')
elif tool == 'plasma-apply-wallpaperimage':
    assert args == [str(root / 'wallpaper.png')]; print('applied fixture')
elif tool == 'plasma-apply-colorscheme':
    assert args == ['--accent-color', '#3DAEE9']; print('applied fixture')
else:
    raise AssertionError(tool)
'''
with tempfile.TemporaryDirectory(prefix='spotlight-systemtools-') as folder:
    root = Path(folder)
    tools = root / 'bin'; tools.mkdir()
    for name in ['rbw', 'keepassxc-cli', 'ping', 'dig', 'ss', 'nmcli', 'ip', 'plasma-apply-wallpaperimage', 'plasma-apply-colorscheme']:
        path = tools / name; path.write_text(STUB); path.chmod(0o755)
    for name in ['database.kdbx', 'database.key', 'wallpaper.png']:
        (root / name).write_bytes(b'fixture')
    home = root / 'home'; (home / 'Pictures/Wallpapers').mkdir(parents=True)
    (home / 'Pictures/Wallpapers/one.png').write_bytes(b'fixture')
    gnupg = root / 'gnupg'; gnupg.mkdir(mode=0o700)
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(root / 'data'), XDG_CONFIG_HOME=str(root / 'config'), XDG_CACHE_HOME=str(root / 'cache'), GNUPGHOME=str(gnupg), PATH=str(tools) + os.pathsep + os.environ['PATH'], SPOTLIGHT_SYSTEMTOOLS_FIXTURE=str(root), GSK_RENDERER='cairo', GTK_A11Y='none', GSETTINGS_BACKEND='memory')
    try:
        subprocess.run([binary, 'systemtools::tests::fixture_backends', '--ignored', '--exact', '--test-threads=1', '--nocapture'], cwd=project, env=env, check=True, timeout=100)
        calls = (root / 'calls.jsonl').read_text()
        assert 'fixture-only-secret' not in calls and 'master-fixture' not in calls
        if os.environ.get('DISPLAY') or os.environ.get('WAYLAND_DISPLAY'):
            subprocess.run(['dbus-run-session', '--', binary, 'systemtools_ui::tests::native_ui', '--ignored', '--exact', '--test-threads=1', '--nocapture'], cwd=project, env=env, check=True, timeout=55)
        else:
            print('GTK checks skipped: no desktop display.')
    finally:
        if shutil.which('gpgconf'):
            subprocess.run(['gpgconf', '--kill', 'gpg-agent'], env=env, capture_output=True, timeout=5)
print('Password CLI contracts, redacted errors, network reports, real GPG round trip, checksum, disposable shredding, and appearance command arguments passed.')
