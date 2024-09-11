from functools import cache
import re
from thefuck.exceptions import EmptyCommand
from thefuck.shells import shell
from thefuck.types import Command
from thefuck.utils import format_raw_script

regex = re.compile(r'([^\s]*): command not found')
enabled_by_default = True

@cache
def get_attr(command):
    lookup = Command.from_raw_script([
        'nix-locate',
        '--minimal',
        '--no-group',
        '--type', 'x',
        '--type', 's',
        '--top-level',
        '--whole-name',
        '--at-root',
        f'"/bin/{command}"',
    ])
    return lookup.output.split()


def match(command):
    name = regex.findall(command.output)
    if name:
        return get_attr(name[0])
    return False


def get_new_command(command):
    name = regex.findall(command.output)[0]
    attrs = get_attr(name)
    return ['nix shell nixpkgs#{} -c {}'.format(attr, command.script) for attr in attrs]
