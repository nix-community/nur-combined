from pyinfra import host, local, state
from pyinfra.operations import server

from pyinfra.facts.server import Hostname, LinuxName
from pathlib import Path

hostname = host.get_fact(Hostname)
distro = host.get_fact(LinuxName)

if distro != "NixOS":
    exit(0)

is_local = False
if host.executor.__name__ == "pyinfra.connectors.local":
    is_local = True
assert is_local or host.executor.__name__ == "pyinfra.connectors.ssh", "nix-copy-closure requires ssh"

print(host.name)

local.shell(f"nix build -L -v  -o /tmp/nixos-{hostname} .#nixosConfigurations.{hostname}.config.system.build.toplevel")

if not is_local:
    local.shell(f"nix-copy-closure --to {host.name} /tmp/nixos-{hostname}/")

config_path = Path(f'/tmp/nixos-{hostname}').resolve()

switch_cmd = "boot"
if host.data.get('nixos-switch'):
    switch_cmd = "switch"

server.shell(
    _sudo=True,
    name="Switching configuration" if switch_cmd == "switch" else "Setting up configuration to be applied in the next boot",
    commands = [
        f"{str(config_path)}/bin/switch-to-configuration {switch_cmd}"            
    ]
)


print(hostname, distro)
