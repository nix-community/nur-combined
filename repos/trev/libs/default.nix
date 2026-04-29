{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  bufFetchDeps = pkgs.callPackage ./bufFetchDeps { };
  bufHook = pkgs.callPackage ./bufHook { };
  denoCompile = pkgs.callPackage ./denoCompile { };
  gleamErlangHook = pkgs.callPackage ./gleamErlangHook { };
  gleamFetchDeps = pkgs.callPackage ./gleamFetchDeps { };
  gleamJavascriptHook = pkgs.callPackage ./gleamJavascriptHook { };
  mkAppImage = pkgs.callPackage ./mkAppImage { };
  mkApps = pkgs.callPackage ./mkApps { };
  mkChecks = pkgs.callPackage ./mkChecks { };
  mkImage = pkgs.callPackage ./mkImage { };
}
