{ stdenvNoCC, fetchzip, autoPatchelfHook, pkgs, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "celeste-classic";
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
    install -Dm755 */CELESTE/celeste $out/bin/celeste-classic
    cp */CELESTE/data.pod $out/bin/data.pod
    runHook postInstall
  '';

  meta = with lib; {
    description = "A PICO-8 platformer about climbing a mountain, made in four days";
    homepage = "https://celesteclassic.github.io/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
