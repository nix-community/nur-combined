{ lib, stdenv, callPackage, symlinkJoin }:
let
  source = callPackage ./source.nix { };
  cli = callPackage "${source}/nix/package.nix" { };
  desktop = callPackage "${source}/nix/desktop.nix" { papilot = cli; };
  combined = symlinkJoin {
    name = "papilot-${cli.version}";
    paths = [ cli desktop ];
    meta = cli.meta;
  };
in {
  inherit source cli;
  default = if stdenv.hostPlatform.isLinux then combined else cli;
} // lib.optionalAttrs stdenv.hostPlatform.isLinux { inherit desktop; }
