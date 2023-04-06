from pyinfra import host, local, state
from pyinfra.operations import server

from sys import path
from pathlib import Path
path.append(str(Path(__file__).parent.resolve()))

from pyinfra.facts.server import Hostname
from pathlib import Path
from lib import is_ssh, is_local, is_nixos

if not is_nixos():
    exit(0)

assert is_local() or is_ssh(), "nix-copy-closure requires ssh"

symlink_path = "/tmp/hm-main"

local.shell(f"nix build -L -v  -o {symlink_path} .#homeConfigurations.main.activationPackage", print_output=True)

if is_ssh():
    local.shell(f"nix-copy-closure --to {host.name} {symlink_path}/", print_output=True)

config_path = Path(symlink_path).resolve()

server.shell(
    name="Switching home configuration",
    commands = [
        f"{str(config_path)}/bin/home-manager-generation"
    ]
)

