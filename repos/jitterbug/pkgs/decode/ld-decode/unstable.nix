{
  maintainers,
  lib,
  pkgs,
  fetchFromGitHub,
  symlinkJoin,
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "ld-decode-unstable";
  version = "rev7-unstable-2026-01-23";
  SETUPTOOLS_SCM_PRETEND_VERSION = ("rev7+" + builtins.substring 0 7 rev);

  rev = "f39e59e18f326b49cc86e7222b59655a0e130cb2";
  hash = "sha256-1Rq81oId2nYQkarFQggbh+d5cmDbaBkBrM/3Agtj85E=";

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "happycube";
    repo = "ld-decode";
  };

  meta = {
    inherit maintainers;
    description = "Software defined LaserDisc decoder.";
    homepage = "https://github.com/simoninns/ld-decode-tools";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "ld-decode";
  };

  inherit (pkgs.callPackage ../../lib { inherit pkgs; }) callPackage;
in
symlinkJoin {
  inherit
    pname
    src
    version
    meta
    ;

  paths = [
    ((callPackage ./ld-decode-py { }).overridePythonAttrs (prevAttrs: {
      inherit
        src
        version
        meta
        SETUPTOOLS_SCM_PRETEND_VERSION
        ;
    }))
    (
      (callPackage ./ld-decode-tools {
        inherit meta ezpwd-reed-solomon;
      }).overrideAttrs
      (
        finalAttrs: prevAttrs: {
          inherit src version;

          cmakeFlags = prevAttrs.cmakeFlags ++ [
            (lib.cmakeBool "BUILD_PYTHON" false)
          ];
        }
      )
    )
  ];
}
