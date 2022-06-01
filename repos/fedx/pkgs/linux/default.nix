{ lib, fetchFromGitHub, buildLinux, ... } @ args:
# INFO:
# This is built form  the official NixOS Zen config, but with v 5.17.
# This is to fix a bug I have run into with 5.18 and allow for more controll over my kernel updates.
# THIS Is PROVIDED AS IS USE AT YOUR OWN RISC!
let
  # having the full version string here makes it easier to update
  modDirVersion = "5.17.11-lqx1";
  parts = lib.splitString "-" modDirVersion;
  version = lib.elemAt parts 0;
  suffix = lib.elemAt parts 1;

  numbers = lib.splitString "." version;
  branch = "${lib.elemAt numbers 0}.${lib.elemAt numbers 1}";
  rev = if ((lib.elemAt numbers 2) == "0") then "v${branch}-${suffix}" else "v${modDirVersion}";
in

buildLinux (args // {
  inherit version modDirVersion;
  isZen = true;

  src = fetchFromGitHub {
    owner = "zen-kernel";
    repo = "zen-kernel";
    inherit rev;
    sha256 = "sha256-1afcwwJIS+ds5wK6Pba8rC4035WUYLSNQn6bK3ojcKA=";
  };

  structuredExtraConfig = with lib.kernel; {
    ZEN_INTERACTIVE = yes;
  };

  extraMeta = {
    inherit branch;
    maintainers = with lib.maintainers; [ ];
    description = "Built using the best configuration and kernel sources for desktop, multimedia, and gaming workloads.";
  };

} // (args.argsOverride or { }))
