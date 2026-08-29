{
  lib,
  stdenvNoCC,
  fetchFromGitea,
}:

stdenvNoCC.mkDerivation {
  pname = "plasma-overdose-kde-theme";
  version = "0-unstable-2026-03-29";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "notify-ctrl";
    repo = "Plasma-Overdose";
    rev = "2ca54efdeef230277294a04b0124c5572a16de0b";
    hash = "sha256-rdUMoV1aOEmCEP7OajPsxpKz0q2hhPpP1MMQbqe0AAE=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/color-schemes"
    cp "$src/plasma/desktoptheme/Plasma-Overdose/colors" \
      "$out/share/color-schemes/Plasma-Overdose.colors"

    mkdir -p "$out/share/plasma/desktoptheme"
    cp -r "$src/plasma/desktoptheme/Plasma-Overdose" \
      "$out/share/plasma/desktoptheme/"

    mkdir -p "$out/share/plasma/look-and-feel"
    cp -r "$src/plasma/look-and-feel/Plasma-Overdose" \
      "$out/share/plasma/look-and-feel/"

    mkdir -p "$out/share/aurorae/themes"
    cp -r "$src/aurorae/Plasma-Overdose"* "$out/share/aurorae/themes/"

    mkdir -p "$out/share/icons/Plasma-Overdose"
    cp "$src/cursors/index.theme" "$out/share/icons/Plasma-Overdose/index.theme"
    cp -r "$src/cursors/cursors" "$out/share/icons/Plasma-Overdose/cursors"

    mkdir -p "$out/share/sounds/PlasmaOverdose"
    cp -r "$src/sounds/"* "$out/share/sounds/PlasmaOverdose/"

    mkdir -p "$out/share/wallpapers/Plasma-Overdose"
    cp -r "$src/wallpapers/"* "$out/share/wallpapers/Plasma-Overdose/"

    mkdir -p "$out/share/konsole"
    cp "$src/konsole/Plasma-Overdose.colorscheme" "$out/share/konsole/"

    mkdir -p "$out/share/kwin/decorations"
    cp -r "$src/kwin/Plasma-Overdose-KWinDeco" "$out/share/kwin/decorations/"

    runHook postInstall
  '';

  meta = {
    description = "KDE Plasma global theme inspired by Needy Girl Overdose";
    homepage = "https://codeberg.org/notify-ctrl/Plasma-Overdose";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
