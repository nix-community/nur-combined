{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-lyrics-on-panel";
  version = "2.0-unstable-2026-07-21";

  src = fetchFromGitHub {
    owner = "KangweiZhu";
    repo = "lyrics-on-panel";
    rev = "7aab0a1955f4e79cffd663823e3d1c6933f7dd2b";
    hash = "sha256-6r35RicvxZalvhHrAIel+8ye6do4pDtwTolti8RrBbE=";
  };

  sourceRoot = "source/dms";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that displays lyrics of the currently playing song from Spotify, Netease Cloud Music, Elisa, and more, anywhere on the desktop";
    homepage = "https://github.com/KangweiZhu/lyrics-on-panel";
    license = licenses.gpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
