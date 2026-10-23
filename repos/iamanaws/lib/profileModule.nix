{
  lib,
  profilesDir,
  name,
  profile,
}:
let
  invalidPath = lib.any (
    part:
    lib.elem part [
      ""
      "."
      ".."
    ]
  ) (lib.splitString "/" profile);
  directDir = profilesDir + "/${profile}";
  directFile = profilesDir + "/${profile}.nix";
in
if profile == null then
  null
else if invalidPath then
  throw "Host '${name}': profile must be a relative module name, optionally qualified with a variant."
else if builtins.pathExists directFile then
  directFile
else if builtins.pathExists (directDir + "/default.nix") then
  directDir
else
  throw "Host '${name}': no profile module found for '${profile}'. Expected ${toString directFile} or ${toString directDir}/default.nix."
