#!/usr/bin/python3
"""Exercise native actions, private file exclusions, CLI autostart, and capture README images."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

PROJECT = Path(__file__).resolve().parents[1]
if '--inside' not in sys.argv:
    built = subprocess.run(['cargo', 'test', '--offline', '--locked', '--no-run', '--message-format=json'], cwd=PROJECT, text=True, capture_output=True, check=True)
    artifacts = [json.loads(line) for line in built.stdout.splitlines() if line.startswith('{')]
    binary = next(a['executable'] for a in artifacts if a.get('reason') == 'compiler-artifact' and a.get('profile', {}).get('test') and a.get('executable'))
    with tempfile.TemporaryDirectory(prefix='spotlight-usability-bus-') as directory:
        config = Path(directory) / 'session.conf'
        config.write_text('<busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen><auth>EXTERNAL</auth><policy context="default"><allow own="*"/><allow send_destination="*"/><allow receive_sender="*"/></policy></busconfig>')
        raise SystemExit(subprocess.call(['dbus-run-session', '--config-file=' + str(config), '--', '/usr/bin/python3', __file__, '--inside', binary], cwd=PROJECT))

with tempfile.TemporaryDirectory(prefix='spotlight-usability-') as directory:
    root = Path(directory)
    home, config, data = (root / name for name in ['home', 'config', 'data'])
    for path in [home, config, data, home / 'Private', home / 'Projects']:
        path.mkdir(parents=True, exist_ok=True)
    (home / '.spotlightignore').write_text('/Private/\n*.log\n')
    (home / 'Private/secret.txt').write_text('Private test fixture')
    (home / 'Projects/project-notes.md').write_text('# Project notes\nA native launcher for Linux.\n')
    (home / 'Projects/design.json').write_text('{"theme": "dark"}\n')
    (home / 'build.log').write_text('Ignored log')
    recent = data / 'RecentDocuments'
    recent.mkdir()
    (recent / 'private.desktop').write_text('[Desktop Entry]\nType=Link\nURL=' + (home / 'Private/secret.txt').as_uri() + '\n')
    output = PROJECT / 'docs/images'
    output.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(config), XDG_DATA_HOME=str(data), XDG_CACHE_HOME=str(root / 'cache'), GSK_RENDERER='cairo', GTK_A11Y='none', SPOTLIGHT_DEMO_OUTPUT=str(output))
    with (root / 'native.log').open('w+') as log:
        result = subprocess.run([sys.argv[-1], 'usability_smoke::native_ui', '--ignored', '--exact', '--test-threads=1', '--nocapture'], cwd=PROJECT, env=env, stdout=log, stderr=log, timeout=30)
        log.seek(0)
        if result.returncode:
            report = log.read()
            print(report[:1800] + "\n" + report[-800:])
            raise SystemExit(result.returncode)
    release = str(PROJECT / 'target/release/spotlight')
    for flag in ['--autostart', '--autostart']:
        subprocess.run([release, flag], env=env, check=True, capture_output=True, timeout=5)
    entry = config / 'autostart/spotlight.desktop'
    assert '--background' in entry.read_text() and 'X-Spotlight-Managed=true' in entry.read_text()
    subprocess.run([release, '--no-autostart'], env=env, check=True, capture_output=True, timeout=5)
    assert not entry.exists()
    with (root / 'background.log').open('w+') as log:
        child = subprocess.Popen([release, '--background'], env=env, stdout=log, stderr=log)
        try:
            for _ in range(50):
                result = subprocess.run([release, '--diagnostics'], env=env, capture_output=True, timeout=5)
                if result.returncode == 0:
                    break
                time.sleep(.1)
            else:
                raise RuntimeError('Background startup did not register')
            time.sleep(.4)
            log.flush();log.seek(0)
            assert 'Panel visible: false' in log.read()
            subprocess.run([release], env=env, check=True, timeout=8, stdout=log, stderr=log)
            subprocess.run([release, '--diagnostics'], env=env, check=True, capture_output=True, timeout=5)
            time.sleep(.2);log.seek(0)
            assert 'Panel visible: true' in log.read(), 'Normal launch should reveal a background instance'
            subprocess.run([release, '--background'], env=env, check=True, timeout=8, stdout=log, stderr=log)
            subprocess.run([release, '--diagnostics'], env=env, check=True, capture_output=True, timeout=5)
            time.sleep(.2);log.seek(0)
            assert 'Panel visible: true' in log.read().splitlines()[-1], 'Repeated background launch must not toggle an existing instance'
        finally:
            subprocess.run([release, '--quit'], env=env, capture_output=True, timeout=5)
            child.wait(timeout=8)
    for name in ['spotlight.png', 'spotlight-files.png']:
        assert (output / name).stat().st_size > 10000
    print('PASS: Tab and Ctrl+K actions, snippet precedence, ignore pruning/history, autostart enable/remove, hidden startup and activation; README screenshots captured.')
