#!/usr/bin/env python3
"""Exercise saved window modes, interface sizes, and rendered Settings controls."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
binary = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else project / 'target/release/spotlight'
with tempfile.TemporaryDirectory(prefix='spotlight-interface-') as data:
    env = dict(os.environ, XDG_DATA_HOME=data, GSK_RENDERER='cairo')
    subprocess.run([str(binary), '--smoke-test', '--interface-smoke-test'], env=env, check=True, timeout=20)
    subprocess.run([str(binary), '--smoke-test', '--scroll-smoke-test'], env=env, check=True, timeout=20)
    print('Isolated interface preferences and scroll rendering verified.')
