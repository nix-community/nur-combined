# trampoline from flake.nix into the specific host definition, while doing a tiny bit of common setup

# args from flake-level `import`
{ hostName, variant }:

# module args
{ lib, ... }:

{
  imports = [
    ./common
    ./modules
  ] ++ lib.optionals (builtins.pathExists ./by-name/${hostName}) [
    ./by-name/${hostName}
  ];

  networking.hostName = hostName;
  system.name = if variant == null then
    hostName
  else
    "${hostName}-${variant}"
  ;

  sane = lib.mkMerge [
    (lib.mkIf (variant == "min") { maxBuildCost = 0; })
    (lib.mkIf (variant == "light") { maxBuildCost = 2; })
  ];
}
