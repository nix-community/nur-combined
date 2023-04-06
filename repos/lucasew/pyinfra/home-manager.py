from pyinfra import host, local, state
from pyinfra.operations import server

from pyinfra.facts.server import Hostname, LinuxName
from pathlib import Path

distro = host.get_fact(LinuxName)

if distro != "NixOS":
    exit(0)

is_local = False
if host.executor.__name__ == "pyinfra.connectors.local":
    is_local = True
assert is_local or host.executor.__name__ == "pyinfra.connectors.ssh", "nix-copy-closure requires ssh"

symlink_path = "/tmp/hm-main"

local.shell(f"nix build -L -v  -o {symlink_path} .#homeConfigurations.main.activationPackage")

if not is_local:
    local.shell(f"nix-copy-closure --to {host.name} {symlink_path}/")

config_path = Path(symlink_path).resolve()

server.shell(
    _sudo=True,
    name="Switching home configuration",
    commands = [
        f"{str(config_path)}/bin/home-manager-generation"
    ]
)

