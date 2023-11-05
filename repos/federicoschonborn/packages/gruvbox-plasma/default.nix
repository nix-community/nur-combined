{ lib
, stdenv
, fetchFromGitLab
}:

stdenv.mkDerivation {
  pname = "gruvbox-plasma";
  version = "unstable-2019-09-29";

  src = fetchFromGitLab {
    domain = "www.opencode.net";
    owner = "adhe";
    repo = "GruvboxPlasma";
    rev = "990c7c0a212ba8f845cfd28d8259ebdb35fc7d0a";
    hash = "sha256-Vyb46IrLXU0wD3H+K4yCW0nPtunHRrzYIVS4zmTOyiE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{color-schemes,icons,plasma/desktoptheme}
    cp -r icons/Gruvbox $out/share/icons
    cp -r plasmatheme/GruvboxPlasma $out/share/plasma/desktoptheme
    cp -r plasmatheme/GruvboxPlasma/colors $out/share/color-schemes/GruvboxPlasma.colors

    runHook postInstall
  '';

  meta = {
    description = "Gruvbox color scheme and icon theme for Plasma";
    homepage = "https://store.kde.org/p/1327719/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
