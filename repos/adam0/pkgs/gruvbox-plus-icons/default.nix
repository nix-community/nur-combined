{
  # keep-sorted start
  fetchFromGitHub,
  folder-color ? "plasma",
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  lib,
  plasma5Packages,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "gruvbox-plus-icons";
  version = "6.4.0-unstable-2026-05-04";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "357d7d2d1fa15c15a4700e604d66371ea43c1391";
    hash = "sha256-UzM1yYVv7X/8KQQaleKwhle6qfXDDghZbi1o9WzWPQE=";
  };

  patches = [./folder-color.patch];

  nativeBuildInputs = [gtk3];

  propagatedBuildInputs = [
    # keep-sorted start
    gnome-icon-theme
    hicolor-icon-theme
    plasma5Packages.breeze-icons
    # keep-sorted end
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -r Gruvbox-Plus-Dark $out/share/icons/
    cp -r Gruvbox-Plus-Light $out/share/icons/
    patchShebangs scripts/folders-color-chooser
    ./scripts/folders-color-chooser -c ${folder-color}
    gtk-update-icon-cache $out/share/icons/Gruvbox-Plus-Dark
    gtk-update-icon-cache $out/share/icons/Gruvbox-Plus-Light

    runHook postInstall
  '';

  # keep-sorted start
  dontBuild = true;
  dontConfigure = true;
  dontDropIconThemeCache = true;
  # keep-sorted end

  meta = with lib; {
    # keep-sorted start
    description = "Icon pack for Linux desktops based on the Gruvbox color scheme";
    homepage = "https://github.com/SylEleuth/gruvbox-plus-icon-pack";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
