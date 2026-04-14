{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
rec {
  buildGleamApplication = pkgs.callPackage ./buildGleamApplication { inherit dashMinimal; };
  dashMinimal = pkgs.callPackage ./dashMinimal { };
  gleamErlangHook = pkgs.callPackage ./gleamErlangHook { };
  gleamFetchDeps = pkgs.callPackage ./gleamFetchDeps { };
  gleamJavascriptHook = pkgs.callPackage ./gleamJavascriptHook { };
  mkAppImage = pkgs.callPackage ./mkAppImage { };
  mkApps = pkgs.callPackage ./mkApps { };
  mkChecks = pkgs.callPackage ./mkChecks { };
  mkImage = pkgs.callPackage ./mkImage { };
}
