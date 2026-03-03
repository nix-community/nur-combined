{
  maintainers,
  lib,
  pkgs,
  fetchFromGitHub,
  symlinkJoin,
  rustPlatform,
  rustc,
  cargo,
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "vhs-decode-testing";
  version = "0.3.8.1-unstable-2026-02-26";

  pySrc =
    let
      rev = "6589d7cfc27cab8216dbf9d82b38b1a0bcb0b2b0";
      hash = "sha256-8Wue1Mh6bKq1DhlnFzdo60eFozCnZI3T7o0dI0fhNRE=";
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

      SETUPTOOLS_SCM_PRETEND_VERSION = (
        (lib.strings.removeSuffix "-unstable" (lib.strings.getName version))
        + "+"
        + (builtins.substring 0 7 rev)
      );
    };

  toolSrc =
    let
      rev = "f637c73e780c52f05633a72b665234b0829dfcf1";
      hash = "sha256-m1FORhASaOh9t5jx1R/gX6YJMZu1H6DEXpOukMh6v6Y=";
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
      inherit (pySrc) src cargoDeps SETUPTOOLS_SCM_PRETEND_VERSION;

      nativeBuildInputs = [
        rustPlatform.cargoSetupHook
        rustc
        cargo
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
