{ makeVacuPythonScript }:
makeVacuPythonScript {
  name = "vacu-flake-archive";
  libraries = [ "humanfriendly" ];
  src = ./archive.py;
}
