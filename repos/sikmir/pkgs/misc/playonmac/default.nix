{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "playonmac";
  version = "4.4.4";

  src = fetchurl {
    url = "https://repository.playonmac.com/PlayOnMac/PlayOnMac_${version}.dmg";
    hash = "sha256-e+a+4W2N8+DKpd9vZHrEN6XE137X+hsRodsC7fnGZSI=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  dontPatchShebangs = true;

  preferLocalBuild = true;

  meta = with lib; {
    description = "GUI for managing Windows programs under macOS";
    homepage = "https://www.playonmac.com/";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
