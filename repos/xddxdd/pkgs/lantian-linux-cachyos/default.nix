{
  inputs,
  lib,
  pkgs,
  ...
}@importArgs:
let
  prefix = "linux-cachyos-";

  kernels = (inputs.nix-cachyos-kernel.overlays.default null pkgs).cachyosKernels;
in
lib.mapAttrs' (
  n: v:
  let
    splitted = lib.splitString "-" v.version;
    ver0 = builtins.elemAt splitted 0;
    major = lib.versions.pad 2 ver0;

    patches = pkgs.callPackage ./patches { };
  in
  lib.nameValuePair (lib.removePrefix prefix n) (
    v.override {
      autoModules = true;
      ignoreConfigErrors = true;
      modDirVersion = "${ver0}-lantian-cachy";
      patches = patches.getPatches major;
      structuredExtraConfig = (import (./custom-config + "/${major}.nix") importArgs) // {
        LOCALVERSION = lib.kernel.freeform "-lantian-cachy";
      };
    }
  )
) (lib.filterAttrs (n: v: lib.hasPrefix "${prefix}lts" n) kernels)
