# { python3Packages, writers }:
# writers.writePython3Bin "vacu-flake-archive" { libraries = [ python3Packages.humanfriendly ]; } (
#   builtins.readFile ./archive.py
# )
{ makeVacuPythonScript }:
makeVacuPythonScript "vacu-flake-archive" { libraries = [ "humanfriendly" ]; } ./archive.py
