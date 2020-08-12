#!@python3@/bin/python3 -u
from collections import defaultdict
import itertools
import json
import os
import random
import re
import subprocess
import sys

CONFIG = "@jsonConfig@"
FEH = "@feh@/bin/feh"
XRANDR = "@xrandr@/bin/xrandr"

# example: '0: +*DP1 3840/600x2160/340+1920+0  DP1'
MONITOR_RE = re.compile(r'^\d+: \+\*?(?P<id>[\w-]+) (?P<w>\d+)\/\d+x(?P<h>\d+)\/\d+\+(?P<x>\d+)\+(?P<y>\d+) \s*[\w-]+$')


def get_monitors():
    p = subprocess.run([XRANDR, '--listmonitors'], capture_output=True, check=True)
    for line in p.stdout.decode('utf-8').split('\n'):
        match = MONITOR_RE.match(line.strip())
        if match:
            yield match.groupdict()


def scan_dir(dir):
    for entry in os.scandir(dir):
        if entry.is_dir():
            yield entry.name, scan_wallpapers(entry.path)


def scan_wallpapers(dir):
    for entry in os.scandir(dir):
        if not entry.is_file():
            continue
        if entry.name.endswith('.na'):
            continue
        yield entry.path


def create_index(directories):
    index = defaultdict(list)
    for d in directories:
        for name, lst in scan_dir(d):
            index[name].extend(lst)
    return index


def get_choices_for_monitor(index, mon, alt_mapping):
    key = '%sx%s' % (mon['w'], mon['h'])
    keys = [key] + alt_mapping.get(key, [])
    return list(itertools.chain(*[index.get(k, []) for k in keys]))


def main():
    with open(CONFIG, 'r') as f:
        config = json.loads(f.read())

    directories = [os.path.expandvars(d) for d in config["directories"]]
    alt_mapping = config["altMapping"]

    index = create_index(directories)
    feh_args = []
    for mon in get_monitors():
        choices = get_choices_for_monitor(index, mon, alt_mapping)
        path = random.choice(choices) if choices else 'undefined'
        print('{id} ({w}x{h}): {path}'.format(path=path, **mon))
        feh_args.extend(['--bg-fill', path])

    if feh_args:
        subprocess.call([FEH] + feh_args)
    else:
        print('error: no monitors detected')
        sys.exit(1)
    subprocess.call([FEH] + feh_args)


if __name__ == '__main__':
    main()
