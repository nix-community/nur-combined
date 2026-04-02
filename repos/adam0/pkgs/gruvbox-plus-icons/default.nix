{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  plasma5Packages,
  gnome-icon-theme,
  hicolor-icon-theme,
  folder-color ? "plasma",
}:
stdenvNoCC.mkDerivation {
  pname = "gruvbox-plus-icons";
  version = "6.3.0-unstable-2026-04-01";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "8a2c2fddf419faaf355ba4893253cc77d04e41f5";
    hash = "sha256-3ALVM1dUleW2KIQuVU0oSz2vQpIkotcm8RT1DVNU9zI=";
  };

  patches = [./folder-color.patch];

  nativeBuildInputs = [gtk3];

  propagatedBuildInputs = [
    plasma5Packages.breeze-icons
    gnome-icon-theme
    hicolor-icon-theme
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

  dontDropIconThemeCache = true;
  dontBuild = true;
  dontConfigure = true;

  meta = with lib; {
    description = "Icon pack for Linux desktops based on the Gruvbox color scheme";
    homepage = "https://github.com/SylEleuth/gruvbox-plus-icon-pack";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
