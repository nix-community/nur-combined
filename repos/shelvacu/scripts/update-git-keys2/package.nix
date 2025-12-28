{
  lib,
  makeVacuPythonScript,
  wrappedSops,
  vacuRoot,
  writers,
}:
let
  nixData = {
    sops_bin = lib.getExe wrappedSops;
    nix_stuff = vacuRoot;
  };
  nixDataFile = writers.writeJSON "nix-data.json" nixData;
in
makeVacuPythonScript {
  name = "update-git-keys2";
  src = ./script.py;
  libraries = [
    "requests"
  ];
  makeWrapperArgs = [
    "--set" "NIX_DATA" nixDataFile
  ];
}
