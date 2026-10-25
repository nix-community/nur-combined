#!/usr/bin/env python3
"""Check the complete built-in guide without changing personal data."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
binary = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else project / 'target/release/spotlight'
with tempfile.TemporaryDirectory(prefix='spotlight-guide-') as directory:
    root = Path(directory)
    home = root / 'home'
    home.mkdir()
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(root / 'data'),
               XDG_CONFIG_HOME=str(root / 'config'), XDG_CACHE_HOME=str(root / 'cache'),
               GSK_RENDERER='cairo')
    subprocess.run([str(binary), '--smoke-test', '--guide-smoke-test'], env=env, check=True, timeout=20)
    assert not (root / 'data/spotlight/calendars').exists(), 'Guide examples must not create events'
    print('Complete guide and example navigation verified with isolated preferences.')
