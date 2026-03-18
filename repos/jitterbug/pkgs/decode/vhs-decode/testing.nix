{
  maintainers,
  lib,
  pkgs,
  fetchFromGitHub,
  symlinkJoin,
  rustPlatform,
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "vhs-decode-testing";
  version = "0.3.9-unstable-2026-03-17";

  pySrc =
    let
      rev = "4effaf86d45a2f0c8b54f91db23c8787a3d3a521";
      hash = "sha256-YffYxGLL9djQ2HF1krkoWzEruvaYFu+oaVZNQ7pCgT8=";
      cargoHash = "sha256-fKAqjvx4Gqa426OyR2qEPXUPEneXGOT1GqOMFDol0Zc=";

      src = fetchFromGitHub {
        inherit hash rev;
        owner = "oyvindln";
        repo = "vhs-decode";
      };
    in
    {
      inherit src;

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit pname version;
        inherit src;
        hash = cargoHash;
      };
    };

  toolSrc =
    let
      rev = "5e0a178d7947bb13382bc69cfe247cd3d1f2e619";
      hash = "sha256-ALbbNTzeJC4XLvU0Cta0W8fXotcpmPkFVXf2IR7PEpI=";
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
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats.";
    homepage = "https://github.com/oyvindln/vhs-decode";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "vhs-decode";
  };

  inherit (pkgs.callPackage ../../lib { inherit pkgs; }) callPackage;

in
symlinkJoin {
  inherit pname version meta;
  inherit (pySrc) src;

  paths = [
    ((callPackage ./vhs-decode-py { }).overridePythonAttrs (prevAttrs: {
      inherit version meta;
      inherit (pySrc) src cargoDeps;

      SETUPTOOLS_SCM_PRETEND_VERSION = (
        (lib.strings.removeSuffix "-unstable" (lib.strings.getName version))
        + "+"
        + (builtins.substring 0 7 pySrc.src.rev)
      );

      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
        rustPlatform.cargoSetupHook
      ];

      propagatedBuildInputs =
        with pkgs.python3.pkgs;
        prevAttrs.propagatedBuildInputs
        ++ [
          importlib-resources
          av
        ];

      postPatch = ''
        ${prevAttrs.postPatch}
        # ld-ldf-reader-py script needs adding
        substituteInPlace setup.py \
          --replace-fail "scripts=[" 'scripts=["ld-ldf-reader-py",'
      '';
    }))

    (
      (callPackage ./vhs-decode-tools {
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
