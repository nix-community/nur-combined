{
  stdenv,
  lib,
  fetchFromGitHub,
}: let
  inherit
    (lib)
    licenses
    ;

  version = "1.99.3";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "kaleidoscope-udev-rules";

    dontBuild = true;

    src = fetchFromGitHub {
      owner = "keyboardio";
      repo = "Kaleidoscope";
      rev = "v${version}";
      sha256 = "sha256-4WIl/Hj23j9GLzdMcyEQvg9X7HI4WSInrLkYCkj6yhM=";
    };

    installPhase = ''
      mkdir -p $out/lib/udev/rules.d
      cp etc/60-kaleidoscope.rules $out/lib/udev/rules.d/
    '';

    meta = {
      description = "udev rules for kaleidoscope firmware keyboards";
      homepage = "https://github.com/keyboardio/Kaleidoscope";
      license = licenses.gpl3Only;
    };
  }
