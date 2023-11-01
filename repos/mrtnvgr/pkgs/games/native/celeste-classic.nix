{ stdenvNoCC, fetchzip, autoPatchelfHook, pkgs, lib, practiceMod ? false }:

let
  folder = if practiceMod then "CELESTE*Practice*" else "CELESTE";
  srcbin = if practiceMod then "celeste_practice_mod" else "celeste";
  outbin = if practiceMod then "celeste-classic-pm" else "celeste-classic";
in stdenvNoCC.mkDerivation {
  pname = outbin;
  version = "1.0";

  src = fetchzip {
    url = "https://www.speedrun.com/static/resource/174ye.zip";
    hash = "sha256-GANHqKB0N905QJOLaePKWkUuPl9UlL1iqvkMMvw/CC8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [ SDL2 ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dsm755 */${folder}/${srcbin} $out/bin/${outbin}
    install -Dm444 */${folder}/data.pod $out/bin/data.pod
    runHook postInstall
  '';

  meta = with lib; {
    description = "A PICO-8 platformer about climbing a mountain, made in four days ${if practiceMod then "(Practice Mod)" else ""}";
    homepage = "https://celesteclassic.github.io/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
