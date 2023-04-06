from pyinfra.facts.server import Hostname
from pyinfra.operations import files
from pyinfra import host, local
from pathlib import Path
from time import sleep

from sys import path
from pathlib import Path
path.append(str(Path(__file__).parent.resolve()))

from lib import noop

print("hostname: ", host.get_fact(Hostname))

noop(name="Sleeping")
local.shell('sleep 5')

files.file(
    name="Create test temp file",
    path=Path("/tmp/eoq"),
    mode="644"
)
