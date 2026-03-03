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
  pname = "ld-decode";
  version = "7.1.0";

  pySrc =
    let
      rev = "v${version}";
      hash = "sha256-KfC5LVaI8h71Jfty6nOm6JKE2X6WplXjzcdkagGWCo0=";
    in
    {
      src = fetchFromGitHub {
        inherit hash rev;
        owner = "happycube";
        repo = "ld-decode";
      };
    };

  toolSrc =
    let
      rev = "be19c30e3172bd6808ff40f72962dcd1305bf5d4";
      hash = "sha256-ixQGgzTNrwwrnjxCuilbz3vVfKV1xt6DtzecDR6Jni0=";
    in
    {
      src = fetchFromGitHub {
        inherit hash rev;
        owner = "simoninns";
        repo = "ld-decode-tools";
      };
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
    version
    meta
    ;

  inherit (pySrc) src;

  paths = [
    ((callPackage ./ld-decode-py { }).overridePythonAttrs (prevAttrs: {
      inherit version meta;
      inherit (pySrc) src;
    }))
    (
      (callPackage ./ld-decode-tools {
        inherit meta ezpwd-reed-solomon;
      }).overrideAttrs
      (
        finalAttrs: prevAttrs: {
          inherit version;
          inherit (toolSrc) src;
        }
      )
    )
  ];
}
