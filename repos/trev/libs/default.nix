{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  gleamErlangHook = pkgs.callPackage ./gleamErlangHook { };
  gleamFetchDeps = pkgs.callPackage ./gleamFetchDeps { };
  gleamJavascriptHook = pkgs.callPackage ./gleamJavascriptHook { };
  mkAppImage = pkgs.callPackage ./mkAppImage { };
  mkApps = pkgs.callPackage ./mkApps { };
  mkChecks = pkgs.callPackage ./mkChecks { };
  mkImage = pkgs.callPackage ./mkImage { };
}
