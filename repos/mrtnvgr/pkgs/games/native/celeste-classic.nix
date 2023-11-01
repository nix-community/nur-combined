{ lib
, stdenvNoCC
, fetchzip
, autoPatchelfHook
, SDL2
, practiceMod ? false
}:

let
  directory = if practiceMod then "CELESTE*Practice*" else "CELESTE";
  srcbin = if practiceMod then "celeste_practice_mod" else "celeste";
  outbin = if practiceMod then "celeste-classic-pm" else "celeste-classic";
in
stdenvNoCC.mkDerivation {
  pname = outbin;
  version = "1.0";

  src = fetchzip {
    url = "https://www.speedrun.com/static/resource/174ye.zip";
    hash = "sha256-GANHqKB0N905QJOLaePKWkUuPl9UlL1iqvkMMvw/CC8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ SDL2 ];

  installPhase = ''
    runHook preInstall
    install -Dsm755 ${directory}/${srcbin} $out/lib/${outbin}/${outbin}
    install -Dm444 ${directory}/data.pod $out/lib/${outbin}/data.pod
    mkdir -p $out/bin
    ln -s $out/lib/${outbin}/${outbin} $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A PICO-8 platformer about climbing a mountain, made in four days${if practiceMod then " (Practice Mod)" else ""}";
    homepage = "https://celesteclassic.github.io/";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = outbin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
