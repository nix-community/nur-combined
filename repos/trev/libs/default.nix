{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  libs = {
    bufFetchDeps = pkgs.callPackage ./bufFetchDeps { };
    bufHook = pkgs.callPackage ./bufHook { };
    # check files can ask for the libs too
    callChecks = pkgs.callPackage ./callChecks { pkgs = pkgs // libs; };
    denoCompile = pkgs.callPackage ./denoCompile { };
    gleamErlangHook = pkgs.callPackage ./gleamErlangHook { };
    gleamFetchDeps = pkgs.callPackage ./gleamFetchDeps { };
    gleamJavascriptHook = pkgs.callPackage ./gleamJavascriptHook { };
    getForgejoFlake = pkgs.callPackage ./getForgejoFlake { };
    mkAppImage = pkgs.callPackage ./mkAppImage { };
    mkApps = pkgs.callPackage ./mkApps { };
    mkCheck = pkgs.callPackage ./mkCheck { };
    mkChecks = pkgs.callPackage ./mkChecks { inherit (libs) callChecks mkCheck; };
    mkFlake = pkgs.callPackage ./mkFlake { };
    mkGleamBurrito = pkgs.callPackage ./mkGleamBurrito { };
    mkGleamPackage = pkgs.callPackage ./mkGleamPackage { };
    mkGoModule = pkgs.callPackage ./mkGoModule {
      # go runs on the build platform, like in nixpkgs' builders
      buildGoModule = pkgs.buildGoLatestModule.override {
        go = pkgs.buildPackages.callPackage ../packages/go { };
      };
    };
    mkUvEnv = pkgs.callPackage ./mkUvEnv { };
    mkUvPackage = pkgs.callPackage ./mkUvPackage { };
    mkImage = pkgs.callPackage ./mkImage { };
    mkRustPackage = pkgs.callPackage ./mkRustPackage { };
  };
in
libs
