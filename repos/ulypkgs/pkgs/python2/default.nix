{
  lib,
  stdenv,
  callPackage,
  config,
  makeScopeWithSplicing',
  path,
  pkgsBuildBuild,
  pkgsBuildHost,
  pkgsBuildTarget,
  pkgsHostHost,
  pkgsTargetTarget,
}:

let
  passthruFun = import "${path}/pkgs/development/interpreters/python/passthrufun.nix" {
    inherit
      lib
      stdenv
      callPackage
      config
      makeScopeWithSplicing'
      ;
    pythonPackagesExtensions = [ ];
  };
  python2Base = callPackage ./cpython-2.7 {
    inherit passthruFun;
    self = python2;
    sourceVersion = {
      major = "2";
      minor = "7";
      patch = "18";
      suffix = ".12"; # ActiveState's Python 2 extended support
    };
    hash = "sha256-RuEgfpags9wJm9Xe0daotqUx4knABEUc7DvtgnQXEfE=";
  };
  python2 =
    (python2Base.override {
      self = python2;
      pkgsBuildBuild = pkgsBuildBuild // {
        python27 = python2;
      };
      pkgsBuildHost = pkgsBuildHost // {
        python27 = python2;
      };
      pkgsBuildTarget = pkgsBuildTarget // {
        python27 = python2;
      };
      pkgsHostHost = pkgsHostHost // {
        python27 = python2;
      };
      pkgsTargetTarget = pkgsTargetTarget // {
        python27 = python2;
      };
      packageOverrides = import ./packages.nix;
    }).overrideAttrs
      (attrsSuper: {
        meta = attrsSuper.meta // {
          mainProgram = "python";
        };
      });
in
python2
