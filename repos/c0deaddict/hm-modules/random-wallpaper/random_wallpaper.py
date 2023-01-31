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

# example: '0: +*DP1 3840/600x2160/340+1920+0  DP1'
XRANDR_MONITOR_RE = re.compile(r'^\d+: \+\*?(?P<id>[\w-]+) (?P<w>\d+)\/\d+x(?P<h>\d+)\/\d+\+(?P<x>\d+)\+(?P<y>\d+) \s*[\w-]+$')


def fatal(message):
    print(message)
    sys.exit(1)


def xorg_get_monitors():
    p = subprocess.run(['xrandr', '--listmonitors'], capture_output=True, check=True)
    for line in p.stdout.decode('utf-8').split('\n'):
        match = XRANDR_MONITOR_RE.match(line.strip())
        if match:
            yield match.groupdict()


def sway_get_monitors():
    outputs = subprocess.check_output(['swaymsg', '-rt', 'get_outputs'])
    return [
        dict(
            id=output['name'],
            w=output['current_mode']['width'],
            h=output['current_mode']['height'],
            x=output['rect']['x'],
            y=output['rect']['y'],
        )
        for output in json.loads(outputs)
        if not output.get('non_desktop', False) and output.get('active', False)
    ]


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


def xorg_set_wallpapers(wallpapers):
    feh_args = []
    for w in wallpapers:
        feh_args.extend(['--bg-fill', w['path']])
    subprocess.call(['feh'] + feh_args)


def sway_set_wallpapers(wallpapers):
    for w in wallpapers:
        subprocess.call(['swaymsg', 'output', w['monitor']['id'], 'bg', w['path'], 'fill'])


def main():
    with open(CONFIG, 'r') as f:
        config = json.loads(f.read())

    directories = [os.path.expandvars(d) for d in config["directories"]]
    alt_mapping = config["altMapping"]
    backend = config["backend"]

    if backend == 'xorg':
        get_monitors = xorg_get_monitors
        set_wallpapers = xorg_set_wallpapers
    elif backend == 'sway':
        get_monitors = sway_get_monitors
        set_wallpapers = sway_set_wallpapers
    else:
        fatal('undefined backend: {}'.format(backend))

    index = create_index(directories)
    wallpapers = []
    for monitor in get_monitors():
        choices = get_choices_for_monitor(index, monitor, alt_mapping)
        path = random.choice(choices) if choices else 'undefined'
        print('{id} ({w}x{h}): {path}'.format(path=path, **monitor))
        wallpapers.append(dict(monitor=monitor, path=path))

    if wallpapers:
        set_wallpapers(wallpapers)
    else:
        fatal('error: no monitors detected')


if __name__ == '__main__':
    main()
