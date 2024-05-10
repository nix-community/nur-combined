{ stdenv, fetchurl, undmg, lib }:

stdenv.mkDerivation rec {
  pname = "Firefox";
  version = "125.0.3";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
      mkdir -p "$out/Applications"
      cp -r Firefox.app "$out/Applications/Firefox.app"
    '';

  src = fetchurl {
    name = "Firefox-${version}.dmg";
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-GB/Firefox%20${version}.dmg";
    sha256 = "sha256-Yl4wvtzpNsViCHMW9mTvBDM36HGX8o57p/lx8198f1E=";
  };

  meta = with lib; {
    description = "The Firefox web browser";
    homepage = "https://www.mozilla.org/en-GB/firefox";
    maintainers = [ maintainers.meain ];
    platforms = platforms.darwin;
  };
}