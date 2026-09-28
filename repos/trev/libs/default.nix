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
  getForgejoFlake = pkgs.callPackage ./getForgejoFlake { };
  mkAppImage = pkgs.callPackage ./mkAppImage { };
  mkApps = pkgs.callPackage ./mkApps { };
  mkChecks = pkgs.callPackage ./mkChecks { };
  mkFlake = pkgs.callPackage ./mkFlake { };
  mkGleamBurrito = pkgs.callPackage ./mkGleamBurrito { };
  mkGoModule = pkgs.callPackage ./mkGoModule { };
  mkImage = pkgs.callPackage ./mkImage { };
  mkRustPackage = pkgs.callPackage ./mkRustPackage { };
}
