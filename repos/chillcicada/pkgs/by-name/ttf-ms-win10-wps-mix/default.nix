{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

let
  ttf-ms-win10 = fetchFromGitHub {
    name = "ttf-ms-win10";
    owner = "streetsamurai00mi";
    repo = "ttf-ms-win10";
    rev = "417eb232e8d037964971ae2690560a7b12e5f0d4";
    sha256 = "sha256-UwkHlrSRaXhfoMlimyXFETV9yq1SbvUXykrhigf+wP8=";
  };

  ttf-wps-fonts = fetchFromGitHub {
    name = "ttf-wps-fonts";
    owner = "BannedPatriot";
    repo = "ttf-wps-fonts";
    rev = "8c980c24289cb08e03f72915970ce1bd6767e45a";
    sha256 = "sha256-x+grMnpEGLkrGVud0XXE8Wh6KT5DoqE6OHR+TS6TagI=";
  };

  pname = "ttf-ms-win10-wps-mix";
  # Based on ttf-wps-fonts
  version = "unstable-2024-10-29";
in

stdenvNoCC.mkDerivation {
  inherit pname version;

  srcs = [
    ttf-ms-win10
    ttf-wps-fonts
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype

    cp ${ttf-ms-win10}/*.ttf $out/share/fonts/truetype
    cp ${ttf-ms-win10}/*.ttc $out/share/fonts

    chmod -R +w $out/share/fonts/truetype
    cp -r ${ttf-wps-fonts}/*.{ttf,TTF} $out/share/fonts/truetype

    chmod -R -w $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/chillcicada/ttf-ms-win10-sc-sup";
    description = "Microsoft Windows 10 TrueType fonts (Simplified Chinese Supplemental fonts)";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
