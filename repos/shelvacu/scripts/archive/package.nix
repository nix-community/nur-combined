{ allInputs, makeVacuPythonScript }:
let
  inherit (allInputs) self;
in
makeVacuPythonScript {
  name = "vacu-flake-archive";
  libraries = [ "vacu-humanfriendly" ];
  src = ./archive.py;
  data.builds = builtins.mapAttrs (_: stuff: {
    inherit (stuff)
      broken
      impure
      allSystems
      aliases
      ;
  }) self.vacuBuilds;
  dataTypeOverrides.builds = "dict[str, Any]";
}
