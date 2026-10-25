#!/usr/bin/env python3
"""Exercise text-to-event creation with an isolated, local Spotlight calendar."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
binary = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else project / 'target/release/spotlight'
with tempfile.TemporaryDirectory(prefix='spotlight-calendar-') as directory:
    root = Path(directory)
    home = root / 'home'
    home.mkdir()
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(root / 'data'),
               XDG_CONFIG_HOME=str(root / 'config'), XDG_CACHE_HOME=str(root / 'cache'),
               GSK_RENDERER='cairo')
    subprocess.run([str(binary), '--smoke-test', '--calendar-smoke-test'], env=env, check=True, timeout=20)
    print('Isolated text-to-calendar UI and persisted event search verified.')
