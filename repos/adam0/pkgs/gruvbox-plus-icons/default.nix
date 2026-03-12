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

stdenvNoCC.mkDerivation rec {
  pname = "gruvbox-plus-icons";
  version = "6.3.0-unstable-2026-03-11";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "859b8ac26f646b8be84aebc28b1918b721d72049";
    hash = "sha256-IdfaPDvw2uAhxONOBB3uzj90tB17Oq+lXUKe8whT75s=";
  };

  patches = [ ./folder-color.patch ];

  nativeBuildInputs = [ gtk3 ];

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

  meta = {
    description = "Icon pack for Linux desktops based on the Gruvbox color scheme";
    homepage = "https://github.com/SylEleuth/gruvbox-plus-icon-pack";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
