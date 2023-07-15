from pyinfra import host, local, state, logger
from pyinfra.api import FactBase
from pyinfra.api.exceptions import PyinfraError
from pyinfra.operations import server

from sys import path
from pathlib import Path
path.append(str(Path(__file__).parent.resolve()))

from pyinfra.facts.server import Hostname, Command

from lib import is_ssh, is_local, is_nixos

hostname = host.get_fact(Hostname)

if not is_nixos():
    exit(0)

if not local.shell("git status -s") == "":
    raise PyinfraError("git working tree dirty")

if not (is_local() or is_ssh()):
    raise PyinfraError("nix-copy-closure requires ssh")

symlink_path = f"/tmp/nixos-{hostname}"

local.shell(f"nix build -L -v  -o {symlink_path} .#nixosConfigurations.{hostname}.config.system.build.toplevel", print_output=True)

current_nixpkgs = host.get_fact(Command, 'realpath /etc/.nixpkgs-used || true')
new_nixpkgs = local.shell(f'realpath {symlink_path}/etc/.nixpkgs-used')

if is_ssh():
    local.shell(f"nix-copy-closure --to {host.name} {symlink_path}/", print_output=True)

config_path = Path(symlink_path).resolve()

is_nixpkgs_changed = current_nixpkgs != new_nixpkgs

if is_nixpkgs_changed:
    logger.info(f"nixpkgs changed: {current_nixpkgs} -> {new_nixpkgs}")

is_switch = host.data.get('nixos-switch', not is_nixpkgs_changed)
if is_switch:
    logger.info(f"{hostname} new configuration will be immediately applied")
else:
    logger.info(f"{hostname} new configuration will be applied in the next boot")

switch_cmd = "switch" if is_switch else "boot"

server.shell(
    _sudo=True,
    name="Applying NixOS configuration",
    commands = [
        f"{str(config_path)}/bin/switch-to-configuration {switch_cmd}"
    ]
)
