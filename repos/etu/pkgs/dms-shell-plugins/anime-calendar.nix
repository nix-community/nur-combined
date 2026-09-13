{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-anime-calendar";
  version = "0-unstable-2026-05-02";

  src = fetchFromGitHub {
    owner = "RiceaRaul";
    repo = "DMS-AnimeCalendarPlugin";
    rev = "b27516cbcb4ede6f4946c942e7dbe4e9d9b1bb6e";
    hash = "sha256-2TaOmT0ERede3QSJUrNj334cAPUKN3Ta/f2T3VUjfUg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell plugin that tracks anime episode releases and sends notifications when your favorite shows air";
    homepage = "https://github.com/RiceaRaul/DMS-AnimeCalendarPlugin";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
