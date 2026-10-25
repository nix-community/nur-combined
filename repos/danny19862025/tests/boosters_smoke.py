#!/usr/bin/env python3
"""Exercise GTK with isolated data and fake external CLIs; requires a desktop session."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

STUB = r'''#!/usr/bin/python3
import json, os, pathlib, sys, time
tool = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
root = pathlib.Path(os.environ['SPOTLIGHT_FIXTURE_DIR'])
with (root / 'calls.jsonl').open('a') as log:
    log.write(json.dumps([tool, args]) + '\n')
if tool == 'curl':
    word = args[-1].rsplit('/', 1)[-1]
    if word == 'slow': time.sleep(1)
    if word == 'missing':
        print(json.dumps({'title': 'No Definitions Found'}))
    else:
        print(json.dumps([{'phonetic': '/test/', 'meanings': [{'partOfSpeech': 'noun', 'definitions': [{'definition': 'A procedure intended to establish the quality, performance, or reliability of something, especially before it is taken into widespread use.', 'example': 'A test of the launcher.'}]}]}]))
elif tool in ('docker', 'podman'):
    state_path = root / (tool + '.json')
    state = json.loads(state_path.read_text())
    if args[0] == 'ps':
        print(json.dumps({'ID': 'a' * 64, 'Names': 'web' if tool == 'docker' else ['db'], 'State': state, 'Image': 'example:latest'}))
    else:
        assert args[0] in ('start', 'stop') and args[1] == 'a' * 64
        state_path.write_text(json.dumps('running' if args[0] == 'start' else 'exited'))
elif tool == 'git':
    assert args[:4] == ['-c', 'credential.interactive=false', 'clone', '--']
    destination = pathlib.Path(args[-1])
    (destination / '.git').mkdir(parents=True)
elif tool == 'gh':
    assert args == ['repo', 'view', 'owner/repo', '--web']
elif tool == 'espanso':
    print('espanso is running')
else:
    raise RuntimeError(tool)
'''

project = Path(__file__).resolve().parents[1]
binary = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else project / 'target/release/spotlight'
with tempfile.TemporaryDirectory(prefix='spotlight-boosters-') as temp:
    root = Path(temp)
    tools = root / 'bin'
    tools.mkdir()
    for name in ('curl', 'docker', 'podman', 'git', 'gh', 'espanso'):
        path = tools / name
        path.write_text(STUB)
        path.chmod(0o755)
    (root / 'docker.json').write_text(json.dumps('running'))
    (root / 'podman.json').write_text(json.dumps('exited'))
    home = root / 'home'
    (home / 'Projects/spotlight/.git').mkdir(parents=True)
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(root / 'data'),
               XDG_CONFIG_HOME=str(root / 'config'), SPOTLIGHT_TEST_TOOLS='1',
               SPOTLIGHT_FIXTURE_DIR=str(root), GSK_RENDERER='cairo',
               PATH=str(tools) + os.pathsep + os.environ['PATH'])
    command = [str(binary), '--smoke-test', '--boosters-smoke-test']
    if os.environ.get('SPOTLIGHT_SMOKE_GDB') == '1':
        command = ['gdb', '--batch', '-ex', 'run', '-ex', 'thread apply all bt 8', '--args'] + command
    subprocess.run(command, env=env, check=True, timeout=45)
    calls = [json.loads(line) for line in (root / 'calls.jsonl').read_text().splitlines()]
    assert any(tool == 'git' for tool, _ in calls)
    assert any(tool == 'gh' for tool, _ in calls)
    for engine in ('docker', 'podman'):
        assert any(tool == engine and args[0] == 'start' for tool, args in calls)
    assert any(tool == 'docker' and args[0] == 'stop' for tool, args in calls)
    print('External CLI arguments and container state transitions verified.')
