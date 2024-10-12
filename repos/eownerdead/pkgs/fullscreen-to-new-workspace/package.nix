{ stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  pname = "fullscreen-to-new-workspace";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "onsah";
    repo = pname;
    rev = "26014b6f8d569891381ab2ebc75c74a51d2454df";
    hash = "sha256-S9mvODQqOBCmA+L1TBJm/c1v5Y+qVKuFpQf799LEwcI=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/share/gnome-shell/extensions/fullscreen-to-empty-workspace@aiono.dev/
    cp -r ./src/* $out/share/gnome-shell/extensions/fullscreen-to-empty-workspace@aiono.dev/

    runHook postInstall
  '';
}
