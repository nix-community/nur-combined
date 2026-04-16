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
  version = "6.3.0-unstable-2026-04-15";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "fc587dcc41fe1ab5ec91eef402e5d30dfe54350f";
    hash = "sha256-/6AW2hvjPM08aRfi75H721gtcLw1mvJfvfm8FnFVuCw=";
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
