{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "soundfont-touhou";
  version = "1.0";

  src = fetchurl {
    url = "https://musical-artifacts.com/artifacts/433/Touhou.sf2";
    hash = "sha256-wFNy92FkqskW+ZE1UPq50w1lDPIF8ADaJ1E6uYBUtBk=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    install -Dm444 $src $out/share/soundfonts/touhou.sf2
    runHook postInstall
  '';

  meta = with lib; {
    description = "Excellent General MIDI compatible soundfont from the Touhou series of games";
    homepage = "https://musical-artifacts.com/artifacts/433";
    license = licenses.cc-by-40;
    platforms = platforms.all;
  };

  preferLocalBuild = true;
}
