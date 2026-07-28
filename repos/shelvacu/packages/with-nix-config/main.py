import argparse
import os
import dataclasses
from pathlib import Path

parser = argparse.ArgumentParser(
    prog='with-builder',
)
parser.add_argument('-p', '--prop', action='store_true')
parser.add_argument('-f', '--fw', action='store_true')
parser.add_argument('-n', '--no-local', action='store_true')
parser.add_argument('-s', '--single-substituter', action='store_true')
parser.add_argument('-r', '--prefer-remote', action='store_true', dest='prefer_remote')
parser.add_argument('-o', '--option', action='append', nargs=2, dest='extra_options', default=[])
parser.add_argument('command', nargs=argparse.REMAINDER)

args = parser.parse_args()

if not args.command:
    parser.error('no command given')

new_config: list[tuple[str, str]] = []

new_config.append(('builders-use-substitutes', 'true'))

@dataclasses.dataclass
class Builder:
    store_path: str
    system_types: list[str] | None = None
    identity_file: str | Path | None = None
    build_count: int | None = None
    speed_factor: int | None = None
    supported_system_features: list[str] | None = None
    required_system_features: list[str] | None = None
    host_key: str | None = None

    def serialize(self) -> str:
        components_diverse: list[
            str | Path | list[str] | int | None
        ] = [
            self.store_path,
            self.system_types,
            self.identity_file,
            self.build_count,
            self.speed_factor,
            self.supported_system_features,
            self.required_system_features,
            self.host_key,
        ]
        
        def conv(el: str | Path | list[str] | int | None) -> str:
            if el is None:
                return '-'
            if isinstance(el, (Path, int)):
                return str(el)
            if isinstance(el, list):
                return ','.join(el)
            return el
        components: list[str] = [conv(x) for x in components_diverse]
        
        while components[-1] == '-':
            components.pop()

        return ' '.join(components)

def prop() -> Builder:
    return Builder(
        store_path='ssh://prop',
        system_types=['x86_64-linux','aarch64-linux'],
        build_count=22,
        supported_system_features=['benchmark', 'big-parallel', 'kvm', 'nixos-test'],
    )

def fw() -> Builder:
    return Builder(
        store_path='ssh://fw',
        system_types=['x86_64-linux','aarch64-linux'],
        build_count=16,
        supported_system_features=['benchmark', 'big-parallel', 'kvm', 'nixos-test'],
    )

builders_list: list[Builder] = []

if args.prop:
    builders_list.append(prop())

if args.fw:
    builders_list.append(fw())

if len(builders_list) > 0:
    if not args.prefer_remote:
        for builder in builders_list:
            builder.speed_factor = 0
    val = ';'.join(x.serialize() for x in builders_list)
    new_config.append(('builders', val))

if args.no_local:
    new_config.append(('max-jobs', '0'))

if args.single_substituter:
    new_config.append(('substituters', 'https://cache.nixos.org/'))

config_names: set[str] = set(k for (k, _) in new_config)

for [k, v] in args.extra_options:
    if k in config_names:
        parser.error(f'conflict: {k} set by --option already set')
    new_config.append((k, v))

new_environ = {k: v for (k, v) in os.environ.items()}

if len(new_config) > 0:
    val = os.environ.get('NIX_CONFIG', '')

    if val != '' and val[-1] != '\n':
        val += '\n'

    val += '\n'.join(f'{k} = {v}' for (k, v) in new_config)
    new_environ['NIX_CONFIG'] = val

os.execvpe(args.command[0], args.command, new_environ)
