{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  makeBinPackage,
  ...
}:

let
  pname = "selector4nix";
  bname = "selector4nix";
  description = "Nix substituter proxy with parallel cache queries and latency-aware selection";

  sourceInfo = lib.importJSON ./source-info.json;

  commonArgs = {
    inherit
      pname
      bname
      description
      ;
  }
  // sourceInfo;

  gnu = makeBinPackage (
    commonArgs
    // {
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "gnu";
      otherNativeBuildInputs = [ pkgs.autoPatchelfHook ];
    }
  );

in
gnu
