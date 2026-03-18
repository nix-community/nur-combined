{
  maintainers,
  lib,
  pkgs,
  fetchFromGitHub,
  symlinkJoin,
  rustPlatform,
  qwt-qt6,
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "vhs-decode-unstable";
  version = "0.3.9-unstable-2026-03-18";

  rev = "e8264a0f33f3191692efc84db22dc1a63e9e4786";
  hash = "sha256-zkpU58elBND4gT6l9JSnbVAOpEx8QU0R/RH4OK4OFqg=";
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
      inherit src version meta;

      SETUPTOOLS_SCM_PRETEND_VERSION = (
        (lib.strings.removeSuffix "-unstable" (lib.strings.getName version))
        + "+"
        + (builtins.substring 0 7 rev)
      );

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit pname version src;
        hash = cargoHash;
      };

      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
        rustPlatform.cargoSetupHook
      ];
    }))

    (
      (callPackage ./vhs-decode-tools {
        inherit meta qwt-qt6 ezpwd-reed-solomon;
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
