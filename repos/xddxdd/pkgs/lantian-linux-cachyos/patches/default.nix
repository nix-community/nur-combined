{
  lib,
}:
{
  getPatches =
    version:
    let
      splitted = lib.splitString "-" version;
      ver0 = builtins.elemAt splitted 0;
      major = lib.versions.pad 2 ver0;
      patchDir = ./. + "/${major}";
    in
    builtins.map (n: patchDir + "/${n}") (builtins.attrNames (builtins.readDir patchDir));
}
