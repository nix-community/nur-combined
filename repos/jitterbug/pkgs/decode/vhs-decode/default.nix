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
  pname = "vhs-decode";
  version = "0.3.9";

  rev = version;
  hash = "sha256-FehJW/4lkstM0WI9EhEGOTnEls9E5MGHY/QGMGpg+QY=";
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

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (prevAttrs) pname;
        inherit version src;
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
