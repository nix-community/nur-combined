from pyinfra.facts.server import Hostname
from pyinfra.operations import files
from pyinfra import host
from pathlib import Path

print("hostname: ", host.get_fact(Hostname))
files.file(
    name="Create test temp file",
    path=Path("/tmp/eoq"),
    mode="644"
)
