{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "herdr-window-title-sync";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "rjyo";
    repo = "herdr-window-title-sync";
    rev = "b07f1140b7308d66487b2f4be546c0c7db065569";
    hash = "sha256-NyRmPI7Ja0NGVzKpMOYWXdK9rISMD5xT27XCW2z6DAw=";
  };

  installPhase = ''
    mkdir -p $out/share/rjyo.window-title-sync
    cp $src/sync-title.js $out/share/rjyo.window-title-sync/
    cp ${./herdr-plugin.toml} $out/share/rjyo.window-title-sync/herdr-plugin.toml
  '';

  meta = {
    description = "Sync the outer terminal title to the focused Herdr workspace, tab, and agent session";
    homepage = "https://github.com/rjyo/herdr-window-title-sync";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
