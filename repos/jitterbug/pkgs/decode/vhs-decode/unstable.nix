{
  maintainers,
  lib,
  pkgs,
  fetchFromGitHub,
  symlinkJoin,
  rustPlatform,
  rustc,
  cargo,
  qwt-qt6,
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "vhs-decode-unstable";
  version = "0.3.8.1-unstable-2026-02-17";
  SETUPTOOLS_SCM_PRETEND_VERSION = (
    (lib.strings.removeSuffix "-unstable" (lib.strings.getName version))
    + "+"
    + (builtins.substring 0 7 rev)
  );
  rev = "e599ce2792ea16a7001db72817a29788897341b0";
  hash = "sha256-X2s36ie3mwhZXTAdtorS12UowrXtPLr/9InsGrzSPOw=";
  cargoHash = "sha256-fKAqjvx4Gqa426OyR2qEPXUPEneXGOT1GqOMFDol0Zc=";

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "oyvindln";
    repo = "vhs-decode";
  };

  meta = {
    inherit maintainers;
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats.";
    homepage = "https://github.com/oyvindln/vhs-decode";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "vhs-decode";
  };

  inherit (pkgs.callPackage ../../lib { inherit pkgs; }) callPackage;

in
symlinkJoin {
  inherit
    pname
    version
    src
    meta
    ;

  paths = [
    ((callPackage ./vhs-decode-py { }).overridePythonAttrs (prevAttrs: {
      inherit
        src
        version
        meta
        SETUPTOOLS_SCM_PRETEND_VERSION
        ;

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit pname version src;
        hash = cargoHash;
      };

      nativeBuildInputs = [
        rustPlatform.cargoSetupHook
        rustc
        cargo
      ];
    }))

    (
      (callPackage ./vhs-decode-tools {
        inherit
          meta
          qwt-qt6
          ezpwd-reed-solomon
          ;
      }).overrideAttrs
      (
        finalAttrs: prevAttrs: {
          inherit src version;

          buildInputs = prevAttrs.buildInputs ++ [
            qwt-qt6
          ];
        }
      )
    )
  ];
}
