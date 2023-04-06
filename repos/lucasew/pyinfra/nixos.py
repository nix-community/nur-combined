from pyinfra import host, local, state
from pyinfra.operations import server

from sys import path
from pathlib import Path
path.append(str(Path(__file__).parent.resolve()))

from pyinfra.facts.server import Hostname

from lib import is_ssh, is_local, is_nixos, noop

hostname = host.get_fact(Hostname)

if not is_nixos():
    exit(0)

assert is_local() or is_ssh(), "nix-copy-closure requires ssh"

symlink_path = f"/tmp/nixos-{hostname}"

noop(name=f"Building NixOS configuration for hostname {hostname}")
local.shell(f"nix build -L -v  -o {symlink_path} .#nixosConfigurations.{hostname}.config.system.build.toplevel")

if is_ssh():
    noop(name=f"Copying NixOS configuration closure for hostname {hostname}")
    local.shell(f"nix-copy-closure --to {host.name} {symlink_path}/")

config_path = Path(symlink_path).resolve()

switch_cmd = "switch" if host.data.get('nixos-switch') else "boot"

server.shell(
    _sudo=True,
    name="Switching configuration" if switch_cmd == "switch" else "Setting up configuration to be applied in the next boot",
    commands = [
        f"{str(config_path)}/bin/switch-to-configuration {switch_cmd}"
    ]
)
